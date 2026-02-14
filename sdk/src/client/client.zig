const std = @import("std");
const config = @import("config.zig");
const MetadataCache = @import("metadata/cache.zig").MetadataCache;
const cache_mod = @import("metadata/cache.zig");
const BrokerPool = @import("../wire/broker_pool.zig").BrokerPool;
const BrokerConnection = @import("../wire/connection.zig").BrokerConnection;
const api_versions = @import("../wire/api_versions.zig");
const KafkaProducer = @import("producer/producer.zig").KafkaProducer;
const KafkaConsumer = @import("consumer/consumer.zig").KafkaConsumer;
const KafkaAdmin = @import("admin/admin.zig").KafkaAdmin;
const tp = @import("metadata/topic_partition.zig");

/// Top-level Kafka client.
///
/// Owns the metadata cache (heap-allocated) and broker pool.
/// Factory for Producer, Consumer, Admin.
pub const KafkaClient = struct {
    const Self = @This();

    /// Cluster metadata cache (heap-allocated — too large for the stack).
    metadata: *MetadataCache,

    /// Broker connection pool.
    broker_pool: BrokerPool,

    /// Client configuration.
    cfg: config.ClientConfig,

    /// Whether the client has been initialized (bootstrap complete).
    initialized: bool = false,

    /// Whether the client has been closed.
    closed: bool = false,

    /// Allocator for protocol decode operations (metadata refresh, etc.).
    allocator: std.mem.Allocator,

    pub fn init(client_config: config.ClientConfig, allocator: std.mem.Allocator) !Self {
        const metadata = try allocator.create(MetadataCache);
        metadata.* = .{};

        var self = Self{
            .cfg = client_config,
            .allocator = allocator,
            .metadata = metadata,
            .broker_pool = BrokerPool.init(allocator),
        };
        self.broker_pool.metadata = metadata;
        self.broker_pool.client_id = client_config.client_id;
        self.broker_pool.connect_timeout_ms = client_config.connection_timeout_ms;
        self.broker_pool.request_timeout_ms = client_config.request_timeout_ms;
        return self;
    }

    /// Bootstrap: connect to the first reachable bootstrap server,
    /// negotiate API versions, and fetch initial metadata.
    pub fn bootstrap(self: *Self) !void {
        if (self.closed) return error.ClientClosed;

        // Seed the metadata cache with bootstrap servers
        var bootstrap_brokers: [64]cache_mod.BrokerEntry = undefined;
        const count = @min(self.cfg.bootstrap_servers.len, 64);
        std.debug.print("[BOOTSTRAP] Seeding metadata with {d} bootstrap servers\n", .{count});
        for (self.cfg.bootstrap_servers[0..count], 0..) |bs, i| {
            bootstrap_brokers[i] = .{
                .node_id = @intCast(i),
                .host = bs.host,
                .port = bs.port,
            };
            std.debug.print("[BOOTSTRAP]   {d}: {s}:{d}\n", .{ i, bs.host, bs.port });
        }
        self.metadata.updateBrokers(bootstrap_brokers[0..count]);

        // Try to connect to any bootstrap broker
        var connected = false;
        for (0..count) |i| {
            const node_id: i32 = @intCast(i);
            std.debug.print("[BOOTSTRAP] Attempting connection to node_id={d}\n", .{node_id});
            const conn = self.broker_pool.getConnection(node_id) catch |err| {
                std.debug.print("[BOOTSTRAP] Failed to connect to node_id={d}: {any}\n", .{ node_id, err });
                continue;
            };

            std.debug.print("[BOOTSTRAP] Connected to node_id={d}, negotiating API versions\n", .{node_id});
            // Negotiate API versions
            api_versions.negotiateApiVersions(conn, self.allocator) catch |err| {
                std.debug.print("[BOOTSTRAP] API version negotiation failed: {any}\n", .{err});
                continue;
            };

            std.debug.print("[BOOTSTRAP] Successfully bootstrapped!\n", .{});
            connected = true;
            break;
        }

        if (!connected) {
            std.debug.print("[BOOTSTRAP] ERROR: No brokers available after trying all bootstrap servers\n", .{});
            return error.NoBrokersAvailable;
        }

        // Fetch initial metadata
        try self.refreshMetadata();

        self.initialized = true;
    }

    /// Refresh cluster metadata from any available broker.
    pub fn refreshMetadata(self: *Self) !void {
        if (self.closed) return error.ClientClosed;

        const conn = self.broker_pool.getAnyBroker() catch return error.NoBrokersAvailable;

        // Use a Metadata API version the broker supports
        const version = api_versions.selectVersion(conn, 3, 0, 12) orelse return error.UnsupportedApiVersion;

        const MetadataRequest = @import("kafka_generated").metadata_request.MetadataRequest;
        var req = MetadataRequest{
            .topics = null, // null = all topics
            .allow_auto_topic_creation = true, // Enable for integration tests
        };

        const resp_size = conn.sendRequest(3, version, &req) catch return error.ConnectionFailed;

        // Parse response
        const resp_header_ver = @import("../wire/request.zig").responseHeaderVersion(3, version);
        var stream = std.io.fixedBufferStream(conn.recv_buf[4..resp_size]);
        const reader = stream.reader();
        const types = @import("kafka_generated").types;

        // Skip response header
        _ = try types.decodeInt32(reader); // correlation_id
        if (resp_header_ver >= 1) {
            _ = try types.decodeUnsignedVarInt(reader); // tagged fields count
        }

        const MetadataResponse = @import("kafka_generated").metadata_response.MetadataResponse;

        // Use arena for decode — all decoded data is temporary; we copy
        // what we need into the fixed-size MetadataCache below.
        var arena = std.heap.ArenaAllocator.init(self.allocator);
        defer arena.deinit();

        const resp = try MetadataResponse.decode(reader, version, arena.allocator());

        // Update broker metadata
        if (resp.brokers) |brokers| {
            var entries: [64]cache_mod.BrokerEntry = undefined;
            const broker_count = @min(brokers.len, 64);
            for (brokers[0..broker_count], 0..) |broker, i| {
                entries[i] = .{
                    .node_id = broker.node_id,
                    .host = broker.host,
                    .port = broker.port,
                    .rack = broker.rack,
                };
            }
            self.metadata.updateBrokers(entries[0..broker_count]);
        }

        // Update controller
        if (resp.controller_id != 0) {
            self.metadata.controller_id = resp.controller_id;
        }

        // Update topic metadata
        if (resp.topics) |topics| {
            for (topics) |topic| {
                if (topic.error_code != 0) continue;

                var parts: [tp.TopicInfo.MAX_PARTITIONS]cache_mod.PartitionEntry = undefined;
                var part_count: usize = 0;

                if (topic.partitions) |partitions| {
                    for (partitions) |p| {
                        if (part_count >= tp.TopicInfo.MAX_PARTITIONS) break;
                        parts[part_count] = .{
                            .partition_id = p.partition_index,
                            .leader_id = p.leader_id,
                            .leader_epoch = p.leader_epoch,
                        };
                        part_count += 1;
                    }
                }

                const topic_name = topic.name orelse continue;
                self.metadata.updateTopic(topic_name, parts[0..part_count]);

                // Populate topic_id if available (Metadata v12+)
                if (version >= 12) {
                    if (self.metadata.getTopic(topic_name)) |_| {
                        // getTopic returns const pointer, need mutable access
                        // Find the topic in the mutable array
                        for (&self.metadata.topics) |*slot| {
                            if (slot.*) |*existing| {
                                if (std.mem.eql(u8, existing.name(), topic_name)) {
                                    existing.topic_id = topic.topic_id;
                                    break;
                                }
                            }
                        }
                    }
                }
            }
        }

        self.metadata.last_refresh_ms = std.time.milliTimestamp();
    }

    /// Create a KafkaProducer bound to this client's metadata and broker pool.
    pub fn createProducer(self: *Self, producer_config: config.ProducerConfig) !KafkaProducer {
        return KafkaProducer.init(self.metadata, &self.broker_pool, producer_config, self.allocator);
    }

    /// Create a consumer with the given configuration.
    pub fn createConsumer(self: *Self, consumer_config: config.ConsumerConfig) !KafkaConsumer {
        return KafkaConsumer.init(self, consumer_config, self.allocator);
    }

    /// Create an admin client for managing topics and consumer groups.
    pub fn createAdmin(self: *Self) KafkaAdmin {
        return KafkaAdmin.init(&self.broker_pool, self.metadata, self.allocator);
    }

    /// Close all connections and release resources.
    pub fn close(self: *Self) void {
        if (self.closed) return;
        self.broker_pool.closeAll();
        self.allocator.destroy(self.metadata);
        self.closed = true;
    }
};

// ============================================================================
// Tests
// ============================================================================

test "KafkaClient init" {
    const cfg = config.ClientConfig{
        .client_id = "test-client",
    };
    var client = try KafkaClient.init(cfg, std.testing.allocator);
    defer client.close();

    try std.testing.expectEqual(false, client.initialized);
    try std.testing.expectEqual(false, client.closed);
}

test "KafkaClient createProducer" {
    const cfg = config.ClientConfig{};
    var client = try KafkaClient.init(cfg, std.testing.allocator);
    defer client.close();

    const pcfg = config.ProducerConfig{};
    var producer = try client.createProducer(pcfg);
    defer producer.close();
    try std.testing.expectEqual(false, producer.started);
}

test "KafkaClient double close" {
    const cfg = config.ClientConfig{};
    var client = try KafkaClient.init(cfg, std.testing.allocator);

    client.close();
    try std.testing.expect(client.closed);

    // Second close should be a no-op
    client.close();
    try std.testing.expect(client.closed);
}

test "KafkaClient bootstrap after close" {
    const cfg = config.ClientConfig{};
    var client = try KafkaClient.init(cfg, std.testing.allocator);
    client.close();

    const result = client.bootstrap();
    try std.testing.expectError(error.ClientClosed, result);
}

test "KafkaClient refreshMetadata after close" {
    const cfg = config.ClientConfig{};
    var client = try KafkaClient.init(cfg, std.testing.allocator);
    client.close();

    const result = client.refreshMetadata();
    try std.testing.expectError(error.ClientClosed, result);
}

test "KafkaClient init with custom config" {
    const cfg = config.ClientConfig{
        .client_id = "custom-id",
        .connection_timeout_ms = 5000,
        .request_timeout_ms = 10000,
    };
    var client = try KafkaClient.init(cfg, std.testing.allocator);
    defer client.close();

    try std.testing.expectEqualStrings("custom-id", client.cfg.client_id);
    try std.testing.expectEqual(@as(u32, 5000), client.cfg.connection_timeout_ms);
    try std.testing.expectEqual(@as(u32, 10000), client.cfg.request_timeout_ms);
    // Pool should inherit settings
    try std.testing.expectEqualStrings("custom-id", client.broker_pool.client_id);
    try std.testing.expectEqual(@as(u32, 5000), client.broker_pool.connect_timeout_ms);
    try std.testing.expectEqual(@as(u32, 10000), client.broker_pool.request_timeout_ms);
}

test "KafkaClient metadata initialized empty" {
    const cfg = config.ClientConfig{};
    var client = try KafkaClient.init(cfg, std.testing.allocator);
    defer client.close();

    try std.testing.expectEqual(@as(u16, 0), client.metadata.broker_count);
    try std.testing.expectEqual(@as(u16, 0), client.metadata.topic_count);
    try std.testing.expectEqual(@as(i32, -1), client.metadata.controller_id);
    try std.testing.expectEqual(@as(i64, 0), client.metadata.last_refresh_ms);
}

test "KafkaClient bootstrap with no servers" {
    const cfg = config.ClientConfig{
        .bootstrap_servers = &.{},
    };
    var client = try KafkaClient.init(cfg, std.testing.allocator);
    defer client.close();

    const result = client.bootstrap();
    try std.testing.expectError(error.NoBrokersAvailable, result);
}
