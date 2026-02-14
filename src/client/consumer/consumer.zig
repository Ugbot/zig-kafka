const std = @import("std");
const KafkaClient = @import("../client.zig").KafkaClient;
const ConsumerConfig = @import("../config.zig").ConsumerConfig;
const TopicPartition = @import("../metadata/topic_partition.zig").TopicPartition;
const SubscriptionState = @import("subscription.zig").SubscriptionState;
const GroupCoordinator = @import("coordinator.zig").GroupCoordinator;
const OffsetManager = @import("offset_manager.zig").OffsetManager;
const TopicPartitionOffset = @import("offset_manager.zig").TopicPartitionOffset;
const Fetcher = @import("fetcher.zig").Fetcher;
const ConsumerRecord = @import("fetcher.zig").Fetcher.ConsumerRecord;
const assignor_mod = @import("assignor.zig");
const ConsumerMetrics = @import("../metrics.zig").ConsumerMetrics;
const ConsumerMetricsSnapshot = @import("../metrics.zig").ConsumerMetricsSnapshot;

/// High-level Kafka consumer with group coordination support.
///
/// Supports both:
/// 1. Group consumer (with group_id) - automatic partition assignment via rebalancing
/// 2. Simple consumer (no group_id) - manual partition assignment
///
/// Example usage:
/// ```zig
/// var consumer = try client.createConsumer(.{
///     .group_id = "my-group",
///     .auto_offset_reset = .earliest,
/// });
/// defer consumer.close();
///
/// try consumer.subscribe(&.{"orders", "events"});
///
/// while (true) {
///     const records = try consumer.poll(1000);
///     for (records) |record| {
///         // Process record
///     }
/// }
/// ```
pub const KafkaConsumer = struct {
    const Self = @This();

    client: *KafkaClient,
    config: ConsumerConfig,
    allocator: std.mem.Allocator,

    subscription: *SubscriptionState,
    coordinator: ?GroupCoordinator = null,
    offset_manager: OffsetManager,
    fetcher: Fetcher,

    // Consumer metrics (heap-allocated to ensure stable address)
    metrics: *ConsumerMetrics,

    // Consumer state
    running: std.atomic.Value(bool) = std.atomic.Value(bool).init(false),
    closed: bool = false,

    pub fn init(client: *KafkaClient, config: ConsumerConfig, allocator: std.mem.Allocator) !Self {
        const subscription = try allocator.create(SubscriptionState);
        subscription.* = SubscriptionState.init(allocator);
        errdefer {
            subscription.deinit();
            allocator.destroy(subscription);
        }

        // Allocate metrics on heap for stable address
        const metrics = try allocator.create(ConsumerMetrics);
        metrics.* = .{};

        // Create result first so we can reference metrics
        var result = Self{
            .client = client,
            .config = config,
            .allocator = allocator,
            .subscription = subscription,
            .metrics = metrics,
            .coordinator = undefined, // Will be set below
            .offset_manager = undefined, // Will be set below
            .fetcher = undefined, // Will be set below
        };

        // Create coordinator if group_id is set
        const coordinator = if (config.group_id) |group_id| blk: {
            const assignor = switch (config.assignment_strategy) {
                .range => &assignor_mod.range_assignor,
                .round_robin => &assignor_mod.roundrobin_assignor,
                .sticky => @panic("sticky assignor not yet implemented"),
            };

            var coord = GroupCoordinator.init(
                allocator,
                &client.broker_pool,
                client.metadata,
                subscription,
                assignor,
                group_id,
                @intCast(config.session_timeout_ms),
                @intCast(config.heartbeat_interval_ms),
                @intCast(config.max_poll_interval_ms),
            );
            coord.setMetrics(metrics);
            break :blk coord;
        } else null;

        result.coordinator = coordinator;

        var offset_manager = OffsetManager.init(
            &client.broker_pool,
            subscription,
            config.group_id orelse "",
            config.enable_auto_commit,
            config.auto_commit_interval_ms,
            allocator,
        );
        offset_manager.setMetrics(metrics);

        const fetcher = try Fetcher.init(
            &client.broker_pool,
            client.metadata,
            subscription,
            @intCast(config.fetch_min_bytes),
            @intCast(config.fetch_max_wait_ms),
            @intCast(config.max_partition_fetch_bytes),
            config.max_poll_records,
            config.auto_offset_reset,
            metrics,
            allocator,
        );

        result.offset_manager = offset_manager;
        result.fetcher = fetcher;

        return result;
    }

    pub fn deinit(self: *Self) void {
        if (!self.closed) {
            self.close() catch {};
        }

        if (self.coordinator) |*coord| {
            coord.deinit();
        }

        self.fetcher.deinit();
        self.subscription.deinit();
        self.allocator.destroy(self.subscription);
        self.allocator.destroy(self.metrics);
    }

    /// Subscribe to topics. If group_id is set, triggers group join.
    pub fn subscribe(self: *Self, topics: []const []const u8) !void {
        if (self.closed) return error.ConsumerClosed;

        try self.subscription.subscribe(topics);

        // If using group coordination, start coordinator
        if (self.coordinator) |*coord| {
            try coord.start();

            // Link coordinator to offset manager
            self.offset_manager.setCoordinator(
                coord.coord_broker_id,
                coord.generation_id,
                coord.memberId(),
            );
        }

        self.running.store(true, .release);
    }

    /// Unsubscribe from all topics.
    pub fn unsubscribe(self: *Self) void {
        self.subscription.unsubscribe();

        if (self.coordinator) |*coord| {
            coord.stop();
        }
    }

    /// Manually assign partitions (simple consumer, no group coordination).
    pub fn assign(self: *Self, partitions: []const TopicPartition) !void {
        if (self.closed) return error.ConsumerClosed;
        if (self.config.group_id != null) return error.CannotAssignWithGroup;

        try self.subscription.assign(partitions);
        self.running.store(true, .release);
    }

    /// Poll for records. Blocking up to timeout_ms.
    /// Returns slice of records valid until next poll() call.
    pub fn poll(self: *Self, timeout_ms: i64) ![]ConsumerRecord {
        if (!self.running.load(.acquire)) return error.ConsumerNotStarted;
        if (self.closed) return error.ConsumerClosed;

        const start_ms = std.time.milliTimestamp();

        // 1. Check for rebalance events (group consumer only)
        if (self.coordinator) |*coord| {
            if (coord.pollRebalanceEvent()) |event| {
                switch (event) {
                    .revoke_start => {
                        // Commit offsets before revoke
                        if (self.config.enable_auto_commit) {
                            self.offset_manager.commitSync() catch {};
                        }
                        self.subscription.revokeAll();
                    },
                    .assign_complete => {
                        // Fetch committed offsets for new assignment
                        self.offset_manager.fetchCommitted() catch {};
                    },
                    else => {},
                }
            }
        }

        // 2. Check if auto-commit needed
        const now_ms = std.time.milliTimestamp();
        if (self.config.enable_auto_commit) {
            try self.offset_manager.maybeAutoCommit(now_ms);
        }

        // 3. Fetch records
        const remaining_ms = timeout_ms - (now_ms - start_ms);
        if (remaining_ms <= 0) return &[_]ConsumerRecord{};

        const records = try self.fetcher.fetch(remaining_ms);

        // 4. Check if metadata refresh needed (due to fetch errors)
        if (self.fetcher.checkAndClearMetadataRefresh()) {
            std.debug.print("[CONSUMER] Metadata refresh triggered by fetch errors\n", .{});
            self.client.refreshMetadata() catch |err| {
                std.debug.print("[CONSUMER] Metadata refresh failed: {any}\n", .{err});
            };
        }

        // 5. Store offsets if auto-commit enabled and record metrics
        if (self.config.enable_auto_commit) {
            for (records) |record| {
                try self.subscription.storeOffset(
                    record.topic[0..record.topic_len],
                    record.partition,
                    record.offset,
                );
            }
        }

        // 6. Record metrics
        if (records.len > 0) {
            var total_bytes: usize = 0;
            for (records) |record| {
                total_bytes += record.value.len;
            }
            self.metrics.recordMessagesConsumed(records.len, total_bytes);
        }

        return records;
    }

    /// Commit stored offsets synchronously.
    pub fn commitSync(self: *Self) !void {
        if (self.closed) return error.ConsumerClosed;
        try self.offset_manager.commitSync();
    }

    /// Commit specific offsets synchronously.
    pub fn commitOffsetsSync(self: *Self, offsets: []const TopicPartitionOffset) !void {
        if (self.closed) return error.ConsumerClosed;
        try self.offset_manager.commitOffsetsSync(offsets);
    }

    /// Store offset for later commit (used with enable_auto_commit=false).
    pub fn storeOffset(self: *Self, topic: []const u8, partition: i32, offset: i64) !void {
        if (self.closed) return error.ConsumerClosed;
        try self.subscription.storeOffset(topic, partition, offset);
    }

    /// Pause consumption from specified partitions.
    pub fn pause(self: *Self, partitions: []const TopicPartition) !void {
        if (self.closed) return error.ConsumerClosed;
        try self.subscription.pause(partitions);
    }

    /// Resume consumption from specified partitions.
    pub fn resumePartitions(self: *Self, partitions: []const TopicPartition) !void {
        if (self.closed) return error.ConsumerClosed;
        try self.subscription.resumePartitions(partitions);
    }

    /// Seek to a specific offset for a partition.
    /// The next poll() will fetch from this offset.
    pub fn seek(self: *Self, topic: []const u8, partition: i32, offset: i64) !void {
        if (self.closed) return error.ConsumerClosed;

        for (self.subscription.assigned_partitions[0..self.subscription.assigned_count]) |*part| {
            if (!part.active) continue;
            const part_topic = part.topic[0..part.topic_len];
            if (std.mem.eql(u8, part_topic, topic) and part.partition == partition) {
                part.fetch_offset = offset;
                std.debug.print("[CONSUMER] Seeked {s}-{d} to offset {d}\n", .{ topic, partition, offset });
                return;
            }
        }
        return error.PartitionNotAssigned;
    }

    /// Seek all specified partitions to the beginning (earliest available offset).
    /// Uses ListOffsets API to find the earliest offset for each partition.
    pub fn seekToBeginning(self: *Self, partitions: []const TopicPartition) !void {
        if (self.closed) return error.ConsumerClosed;

        for (partitions) |tp| {
            const offset = try self.fetcher.getEarliestOffset(tp.topic, tp.partition);
            try self.seek(tp.topic, tp.partition, offset);
        }
    }

    /// Seek all specified partitions to the end (latest available offset).
    /// Uses ListOffsets API to find the latest offset for each partition.
    pub fn seekToEnd(self: *Self, partitions: []const TopicPartition) !void {
        if (self.closed) return error.ConsumerClosed;

        for (partitions) |tp| {
            const offset = try self.fetcher.getLatestOffset(tp.topic, tp.partition);
            try self.seek(tp.topic, tp.partition, offset);
        }
    }

    /// Get offsets for the specified partitions at the given timestamps.
    /// Returns a map of TopicPartition to offset.
    /// Timestamp -2 = earliest, -1 = latest, or epoch milliseconds.
    pub fn offsetsForTimes(self: *Self, timestamps: []const TopicPartitionTimestamp) ![]TopicPartitionOffset {
        if (self.closed) return error.ConsumerClosed;

        var result = try self.allocator.alloc(TopicPartitionOffset, timestamps.len);
        errdefer self.allocator.free(result);

        for (timestamps, 0..) |tpt, i| {
            const offset = try self.fetcher.listOffsets(tpt.topic, tpt.partition, tpt.timestamp);
            result[i] = .{
                .topic = tpt.topic,
                .partition = tpt.partition,
                .offset = offset,
            };
        }

        return result;
    }

    pub const TopicPartitionTimestamp = struct {
        topic: []const u8,
        partition: i32,
        timestamp: i64,
    };

    /// Get a snapshot of consumer metrics.
    pub fn getMetrics(self: *const Self) ConsumerMetricsSnapshot {
        return self.metrics.getSnapshot();
    }

    /// Close consumer, leave group, commit final offsets.
    pub fn close(self: *Self) !void {
        if (self.closed) return;

        // Commit final offsets
        if (self.config.enable_auto_commit) {
            self.offset_manager.commitSync() catch {};
        }

        // Stop coordinator and leave group
        if (self.coordinator) |*coord| {
            coord.stop();
        }

        self.running.store(false, .release);
        self.closed = true;
    }
};

// ============================================================================
// Tests
// ============================================================================

test "KafkaConsumer init with group" {
    const allocator = std.testing.allocator;

    var client = try KafkaClient.init(.{
        .bootstrap_servers = &[_]@import("../config.zig").BrokerAddress{
            .{ .host = "localhost", .port = 9092 },
        },
    }, allocator);
    defer client.close();

    var consumer = try KafkaConsumer.init(&client, .{
        .group_id = "test-group",
        .enable_auto_commit = true,
    }, allocator);
    defer consumer.deinit();

    try std.testing.expect(consumer.coordinator != null);
    try std.testing.expect(!consumer.closed);
}

test "KafkaConsumer init without group" {
    const allocator = std.testing.allocator;

    var client = try KafkaClient.init(.{
        .bootstrap_servers = &[_]@import("../config.zig").BrokerAddress{
            .{ .host = "localhost", .port = 9092 },
        },
    }, allocator);
    defer client.close();

    var consumer = try KafkaConsumer.init(&client, .{
        .group_id = null, // No group
    }, allocator);
    defer consumer.deinit();

    try std.testing.expect(consumer.coordinator == null);
}

test "KafkaConsumer manual assign" {
    const allocator = std.testing.allocator;

    var client = try KafkaClient.init(.{
        .bootstrap_servers = &[_]@import("../config.zig").BrokerAddress{
            .{ .host = "localhost", .port = 9092 },
        },
    }, allocator);
    defer client.close();

    var consumer = try KafkaConsumer.init(&client, .{
        .group_id = null,
    }, allocator);
    defer consumer.deinit();

    const partitions = [_]TopicPartition{
        .{ .topic = "orders", .partition = 0 },
        .{ .topic = "orders", .partition = 1 },
    };

    try consumer.assign(&partitions);

    try std.testing.expect(consumer.subscription.isAssigned("orders", 0));
    try std.testing.expect(consumer.subscription.isAssigned("orders", 1));
}

test "KafkaConsumer cannot assign with group_id" {
    const allocator = std.testing.allocator;

    var client = try KafkaClient.init(.{
        .bootstrap_servers = &[_]@import("../config.zig").BrokerAddress{
            .{ .host = "localhost", .port = 9092 },
        },
    }, allocator);
    defer client.close();

    var consumer = try KafkaConsumer.init(&client, .{
        .group_id = "test-group",
    }, allocator);
    defer consumer.deinit();

    const partitions = [_]TopicPartition{
        .{ .topic = "orders", .partition = 0 },
    };

    try std.testing.expectError(error.CannotAssignWithGroup, consumer.assign(&partitions));
}

test "KafkaConsumer store offset" {
    const allocator = std.testing.allocator;

    var client = try KafkaClient.init(.{
        .bootstrap_servers = &[_]@import("../config.zig").BrokerAddress{
            .{ .host = "localhost", .port = 9092 },
        },
    }, allocator);
    defer client.close();

    var consumer = try KafkaConsumer.init(&client, .{
        .group_id = null,
        .enable_auto_commit = false,
    }, allocator);
    defer consumer.deinit();

    const partitions = [_]TopicPartition{
        .{ .topic = "orders", .partition = 0 },
    };
    try consumer.assign(&partitions);

    try consumer.storeOffset("orders", 0, 1234);

    const part = &consumer.subscription.assigned_partitions[0];
    try std.testing.expectEqual(@as(i64, 1234), part.stored_offset);
}

test "KafkaConsumer pause and resume" {
    const allocator = std.testing.allocator;

    var client = try KafkaClient.init(.{
        .bootstrap_servers = &[_]@import("../config.zig").BrokerAddress{
            .{ .host = "localhost", .port = 9092 },
        },
    }, allocator);
    defer client.close();

    var consumer = try KafkaConsumer.init(&client, .{
        .group_id = null,
    }, allocator);
    defer consumer.deinit();

    const partitions = [_]TopicPartition{
        .{ .topic = "orders", .partition = 0 },
    };
    try consumer.assign(&partitions);

    // Initially not paused
    try std.testing.expect(!consumer.subscription.isPaused("orders", 0));

    // Pause
    try consumer.pause(&partitions);
    try std.testing.expect(consumer.subscription.isPaused("orders", 0));

    // Resume
    try consumer.resumePartitions(&partitions);
    try std.testing.expect(!consumer.subscription.isPaused("orders", 0));
}

test "KafkaConsumer close" {
    const allocator = std.testing.allocator;

    var client = try KafkaClient.init(.{
        .bootstrap_servers = &[_]@import("../config.zig").BrokerAddress{
            .{ .host = "localhost", .port = 9092 },
        },
    }, allocator);
    defer client.close();

    var consumer = try KafkaConsumer.init(&client, .{
        .group_id = null,
    }, allocator);

    try std.testing.expect(!consumer.closed);

    try consumer.close();

    try std.testing.expect(consumer.closed);
    try std.testing.expect(!consumer.running.load(.acquire));

    // Close is idempotent
    try consumer.close();
}
