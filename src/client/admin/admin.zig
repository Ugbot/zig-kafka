const std = @import("std");
const BrokerPool = @import("../../wire/broker_pool.zig").BrokerPool;
const MetadataCache = @import("../metadata/cache.zig").MetadataCache;
const request_mod = @import("../../wire/request.zig");
const types = @import("kafka_generated").types;

/// Kafka Admin Client for managing topics, consumer groups, and cluster configuration.
///
/// Example usage:
/// ```zig
/// var admin = KafkaAdmin.init(client.broker_pool, client.metadata, allocator);
/// defer admin.deinit();
///
/// // List consumer groups
/// const groups = try admin.listConsumerGroups();
/// defer admin.allocator.free(groups);
///
/// // Create topic
/// try admin.createTopics(&[_]NewTopic{
///     .{ .name = "orders", .num_partitions = 3, .replication_factor = 1 },
/// });
/// ```
pub const KafkaAdmin = struct {
    const Self = @This();

    broker_pool: *BrokerPool,
    metadata_cache: *MetadataCache,
    allocator: std.mem.Allocator,

    pub fn init(
        broker_pool: *BrokerPool,
        metadata_cache: *MetadataCache,
        allocator: std.mem.Allocator,
    ) Self {
        return .{
            .broker_pool = broker_pool,
            .metadata_cache = metadata_cache,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Self) void {
        _ = self;
    }

    // ========================================================================
    // Topic Management
    // ========================================================================

    /// Create new topics.
    pub fn createTopics(self: *Self, topics: []const NewTopic) !void {
        const CreateTopicsRequest = @import("kafka_generated").create_topics_request.CreateTopicsRequest;
        const CreatableTopic = @import("kafka_generated").create_topics_request.CreatableTopic;
        const CreateTopicsResponse = @import("kafka_generated").create_topics_response.CreateTopicsResponse;

        const conn = try self.broker_pool.getAnyBroker();

        // Negotiate API version (v0-v7)
        const api_versions = @import("../../wire/api_versions.zig");
        const negotiated_version = api_versions.selectVersion(conn, 19, 0, 7) orelse {
            return error.UnsupportedApiVersion;
        };

        // Build request topics
        var request_topics = try self.allocator.alloc(CreatableTopic, topics.len);
        defer self.allocator.free(request_topics);

        for (topics, 0..) |topic, i| {
            request_topics[i] = CreatableTopic{
                .name = topic.name,
                .num_partitions = topic.num_partitions,
                .replication_factor = @intCast(topic.replication_factor),
            };
        }

        var req = CreateTopicsRequest.default();
        req.topics = request_topics;
        req.timeout_ms = 30000;

        const resp_size = try conn.sendRequest(19, negotiated_version, req);

        // Parse response
        var arena = std.heap.ArenaAllocator.init(self.allocator);
        defer arena.deinit();

        const resp_header_ver = request_mod.responseHeaderVersion(19, negotiated_version);
        var stream = std.io.fixedBufferStream(conn.recv_buf[4..resp_size]);
        const reader = stream.reader();

        _ = try types.decodeInt32(reader);
        if (resp_header_ver >= 1) {
            _ = try types.decodeUnsignedVarInt(reader);
        }

        const resp = try CreateTopicsResponse.decode(reader, negotiated_version, arena.allocator());

        // Check for errors
        if (resp.topics) |resp_topics| {
            for (resp_topics) |topic_resp| {
                if (topic_resp.error_code != 0) {
                    std.debug.print("[ADMIN] CreateTopic failed for '{s}': error_code={d}\n", .{ topic_resp.name, topic_resp.error_code });
                    return error.CreateTopicFailed;
                }
            }
        }
    }

    /// Delete topics.
    pub fn deleteTopics(self: *Self, topic_names: []const []const u8) !void {
        const DeleteTopicsRequest = @import("kafka_generated").delete_topics_request.DeleteTopicsRequest;
        const DeleteTopicsResponse = @import("kafka_generated").delete_topics_response.DeleteTopicsResponse;

        const conn = try self.broker_pool.getAnyBroker();

        // Negotiate API version (v0-v6)
        const api_versions = @import("../../wire/api_versions.zig");
        const negotiated_version = api_versions.selectVersion(conn, 20, 0, 6) orelse {
            return error.UnsupportedApiVersion;
        };

        var req = DeleteTopicsRequest.default();
        req.topic_names = @constCast(topic_names);
        req.timeout_ms = 30000;

        const resp_size = try conn.sendRequest(20, negotiated_version, req);

        // Parse response
        var arena = std.heap.ArenaAllocator.init(self.allocator);
        defer arena.deinit();

        const resp_header_ver = request_mod.responseHeaderVersion(20, negotiated_version);
        var stream = std.io.fixedBufferStream(conn.recv_buf[4..resp_size]);
        const reader = stream.reader();

        _ = try types.decodeInt32(reader);
        if (resp_header_ver >= 1) {
            _ = try types.decodeUnsignedVarInt(reader);
        }

        const resp = try DeleteTopicsResponse.decode(reader, negotiated_version, arena.allocator());

        // Check for errors
        if (resp.responses) |responses| {
            for (responses) |topic_resp| {
                if (topic_resp.error_code != 0) {
                    std.debug.print("[ADMIN] DeleteTopic failed for '{?s}': error_code={d}\n", .{ topic_resp.name, topic_resp.error_code });
                    return error.DeleteTopicFailed;
                }
            }
        }
    }

    /// Describe topics (get detailed information).
    pub fn describeTopics(self: *Self, topic_names: []const []const u8) ![]TopicDescription {
        _ = self;
        _ = topic_names;
        // TODO: Implement using MetadataRequest API (key=3)
        return error.NotImplemented;
    }

    // ========================================================================
    // Consumer Group Management
    // ========================================================================

    /// List all consumer groups.
    pub fn listConsumerGroups(self: *Self) ![]ConsumerGroupListing {
        const ListGroupsRequest = @import("kafka_generated").list_groups_request.ListGroupsRequest;
        const ListGroupsResponse = @import("kafka_generated").list_groups_response.ListGroupsResponse;

        const conn = try self.broker_pool.getAnyBroker();

        // Negotiate API version (v0-v4)
        const api_versions = @import("../../wire/api_versions.zig");
        const negotiated_version = api_versions.selectVersion(conn, 16, 0, 4) orelse {
            return error.UnsupportedApiVersion;
        };

        const req = ListGroupsRequest.default();

        const resp_size = try conn.sendRequest(16, negotiated_version, req);

        // Parse response
        var arena = std.heap.ArenaAllocator.init(self.allocator);
        defer arena.deinit();

        const resp_header_ver = request_mod.responseHeaderVersion(16, negotiated_version);
        var stream = std.io.fixedBufferStream(conn.recv_buf[4..resp_size]);
        const reader = stream.reader();

        _ = try types.decodeInt32(reader);
        if (resp_header_ver >= 1) {
            _ = try types.decodeUnsignedVarInt(reader);
        }

        const resp = try ListGroupsResponse.decode(reader, negotiated_version, arena.allocator());

        if (resp.error_code != 0) {
            return error.ListGroupsFailed;
        }

        // Convert response to our format
        const groups = resp.groups orelse return &[_]ConsumerGroupListing{};
        var result = try self.allocator.alloc(ConsumerGroupListing, groups.len);

        for (groups, 0..) |group, i| {
            result[i] = .{
                .group_id = try self.allocator.dupe(u8, group.group_id),
                .protocol_type = try self.allocator.dupe(u8, group.protocol_type),
            };
        }

        return result;
    }

    /// Free consumer group listings returned by listConsumerGroups.
    pub fn freeConsumerGroupListings(self: *Self, groups: []ConsumerGroupListing) void {
        for (groups) |group| {
            self.allocator.free(group.group_id);
            self.allocator.free(group.protocol_type);
        }
        self.allocator.free(groups);
    }

    /// Describe consumer groups (get detailed information).
    pub fn describeConsumerGroups(self: *Self, group_ids: []const []const u8) ![]ConsumerGroupDescription {
        _ = self;
        _ = group_ids;
        // TODO: Implement using DescribeGroupsRequest API (key=15)
        return error.NotImplemented;
    }

    /// Delete consumer groups.
    pub fn deleteConsumerGroups(self: *Self, group_ids: []const []const u8) !void {
        const DeleteGroupsRequest = @import("kafka_generated").delete_groups_request.DeleteGroupsRequest;
        const DeleteGroupsResponse = @import("kafka_generated").delete_groups_response.DeleteGroupsResponse;

        const conn = try self.broker_pool.getAnyBroker();

        // Negotiate API version (v0-v2)
        const api_versions = @import("../../wire/api_versions.zig");
        const negotiated_version = api_versions.selectVersion(conn, 42, 0, 2) orelse {
            return error.UnsupportedApiVersion;
        };

        var req = DeleteGroupsRequest.default();
        req.groups_names = @constCast(group_ids);

        const resp_size = try conn.sendRequest(42, negotiated_version, req);

        // Parse response
        var arena = std.heap.ArenaAllocator.init(self.allocator);
        defer arena.deinit();

        const resp_header_ver = request_mod.responseHeaderVersion(42, negotiated_version);
        var stream = std.io.fixedBufferStream(conn.recv_buf[4..resp_size]);
        const reader = stream.reader();

        _ = try types.decodeInt32(reader);
        if (resp_header_ver >= 1) {
            _ = try types.decodeUnsignedVarInt(reader);
        }

        const resp = try DeleteGroupsResponse.decode(reader, negotiated_version, arena.allocator());

        // Check for errors
        if (resp.results) |results| {
            for (results) |result| {
                if (result.error_code != 0) {
                    std.debug.print("[ADMIN] DeleteGroup failed for '{s}': error_code={d}\n", .{ result.group_id, result.error_code });
                    return error.DeleteGroupFailed;
                }
            }
        }
    }

    // ========================================================================
    // Types
    // ========================================================================

    pub const NewTopic = struct {
        name: []const u8,
        num_partitions: i32,
        replication_factor: i16,
    };

    pub const TopicDescription = struct {
        name: []const u8,
        is_internal: bool,
        partitions: []PartitionDescription,
    };

    pub const PartitionDescription = struct {
        partition_id: i32,
        leader_id: i32,
        replica_nodes: []i32,
        isr_nodes: []i32,
    };

    pub const ConsumerGroupListing = struct {
        group_id: []const u8,
        protocol_type: []const u8,
    };

    pub const ConsumerGroupDescription = struct {
        group_id: []const u8,
        state: []const u8,
        protocol_type: []const u8,
        protocol_data: []const u8,
        members: []MemberDescription,
    };

    pub const MemberDescription = struct {
        member_id: []const u8,
        client_id: []const u8,
        client_host: []const u8,
        member_metadata: []const u8,
        member_assignment: []const u8,
    };
};

// ============================================================================
// Tests
// ============================================================================

test "KafkaAdmin init" {
    const allocator = std.testing.allocator;

    var broker_pool = BrokerPool.init(allocator);
    var metadata = MetadataCache{};

    var admin = KafkaAdmin.init(&broker_pool, &metadata, allocator);
    defer admin.deinit();

    // Just verify initialization works
    try std.testing.expect(admin.allocator.ptr == allocator.ptr);
}
