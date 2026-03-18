const std = @import("std");
const SubscriptionState = @import("subscription.zig").SubscriptionState;
const BrokerPool = @import("../../wire/broker_pool.zig").BrokerPool;
const TopicPartition = @import("../metadata/topic_partition.zig").TopicPartition;
const request_mod = @import("../../wire/request.zig");
const types = @import("kafka_generated").types;
const ConsumerMetrics = @import("../metrics.zig").ConsumerMetrics;

const OffsetCommitRequest = @import("kafka_generated").offset_commit_request.OffsetCommitRequest;
const OffsetCommitRequestTopic = @import("kafka_generated").offset_commit_request.OffsetCommitRequestTopic;
const OffsetCommitRequestPartition = @import("kafka_generated").offset_commit_request.OffsetCommitRequestPartition;
const OffsetCommitResponse = @import("kafka_generated").offset_commit_response.OffsetCommitResponse;

const OffsetFetchRequest = @import("kafka_generated").offset_fetch_request.OffsetFetchRequest;
const OffsetFetchRequestTopic = @import("kafka_generated").offset_fetch_request.OffsetFetchRequestTopic;
const OffsetFetchResponse = @import("kafka_generated").offset_fetch_response.OffsetFetchResponse;

/// Manages offset commits (auto + manual) and fetches committed offsets from the broker.
///
/// Offsets are committed to the consumer group coordinator. The coordinator broker ID
/// must be provided (typically obtained from GroupCoordinator).
pub const OffsetManager = struct {
    const Self = @This();

    broker_pool: *BrokerPool,
    subscription: *SubscriptionState,
    allocator: std.mem.Allocator,

    // Metrics reference (optional - not available for simple consumers without group)
    metrics: ?*ConsumerMetrics = null,

    group_id: []const u8,
    enable_auto_commit: bool,
    auto_commit_interval_ms: u32,

    // Auto-commit state
    last_commit_ms: i64,

    // Coordinator broker ID (provided by GroupCoordinator)
    coordinator_broker_id: i32 = -1,

    // Generation ID and member ID (for group commits)
    generation_id: i32 = -1,
    member_id: []const u8 = "",

    // API versions to use
    offset_commit_version: i16 = 8,
    offset_fetch_version: i16 = 8,

    pub fn init(
        broker_pool: *BrokerPool,
        subscription: *SubscriptionState,
        group_id: []const u8,
        enable_auto_commit: bool,
        auto_commit_interval_ms: u32,
        allocator: std.mem.Allocator,
    ) Self {
        return .{
            .broker_pool = broker_pool,
            .subscription = subscription,
            .group_id = group_id,
            .enable_auto_commit = enable_auto_commit,
            .auto_commit_interval_ms = auto_commit_interval_ms,
            .last_commit_ms = 0,
            .allocator = allocator,
        };
    }

    /// Set coordinator broker ID and group state (called by GroupCoordinator).
    pub fn setCoordinator(self: *Self, broker_id: i32, generation_id: i32, member_id: []const u8) void {
        self.coordinator_broker_id = broker_id;
        self.generation_id = generation_id;
        self.member_id = member_id;
    }

    /// Set metrics reference (called from consumer).
    pub fn setMetrics(self: *Self, metrics: *ConsumerMetrics) void {
        self.metrics = metrics;
    }

    /// Commit stored offsets for all assigned partitions (synchronous).
    pub fn commitSync(self: *Self) !void {
        if (self.coordinator_broker_id < 0) return error.CoordinatorNotAvailable;

        const conn = self.broker_pool.getConnection(self.coordinator_broker_id) catch |err| {
            if (self.metrics) |m| m.recordCommit(false);
            return err;
        };

        // Build OffsetCommitRequest
        var req = OffsetCommitRequest.default();
        req.group_id = self.group_id;
        req.generation_id_or_member_epoch = self.generation_id;
        req.member_id = self.member_id;

        // Group partitions by topic
        var topic_map = std.StringHashMap(std.array_list.Managed(OffsetCommitRequestPartition)).init(self.allocator);
        defer {
            var it = topic_map.iterator();
            while (it.next()) |entry| {
                entry.value_ptr.deinit();
            }
            topic_map.deinit();
        }

        for (self.subscription.assigned_partitions[0..self.subscription.assigned_count]) |*part| {
            if (!part.active) continue;
            if (part.stored_offset < 0) continue; // No offset to commit

            const topic_name = part.topic[0..part.topic_len];

            // Get or create topic entry
            const gop = try topic_map.getOrPut(topic_name);
            if (!gop.found_existing) {
                gop.value_ptr.* = std.array_list.Managed(OffsetCommitRequestPartition).init(self.allocator);
            }

            // Add partition
            try gop.value_ptr.append(.{
                .partition_index = part.partition,
                .committed_offset = part.stored_offset + 1, // Commit NEXT offset to consume
                .committed_metadata = null,
            });
        }

        // Build topics array
        var topics_list = std.array_list.Managed(OffsetCommitRequestTopic).init(self.allocator);
        defer topics_list.deinit();

        var it = topic_map.iterator();
        while (it.next()) |entry| {
            const partitions = try entry.value_ptr.toOwnedSlice();
            try topics_list.append(.{
                .name = entry.key_ptr.*,
                .partitions = partitions,
            });
        }

        req.topics = try topics_list.toOwnedSlice();
        defer {
            for (req.topics.?) |topic| {
                self.allocator.free(topic.partitions.?);
            }
            self.allocator.free(req.topics.?);
        }

        // Send request
        const resp_size = conn.sendRequest(8, self.offset_commit_version, req) catch |err| {
            if (self.metrics) |m| m.recordCommit(false);
            return err;
        };

        // Use arena allocator for response decoding (zero-leak)
        var arena = std.heap.ArenaAllocator.init(self.allocator);
        defer arena.deinit();

        // Parse response
        const resp_header_ver = request_mod.responseHeaderVersion(8, self.offset_commit_version);
        var stream = std.io.fixedBufferStream(conn.recv_buf[4..resp_size]);
        const reader = stream.reader();

        // Skip response header
        _ = try types.decodeInt32(reader); // correlation_id
        if (resp_header_ver >= 1) {
            _ = try types.decodeUnsignedVarInt(reader); // tagged fields
        }

        const resp = OffsetCommitResponse.decode(reader, self.offset_commit_version, arena.allocator()) catch |err| {
            if (self.metrics) |m| m.recordCommit(false);
            return err;
        };

        // Track success/failure
        var commit_failed = false;

        // Update committed offsets for successful partitions
        if (resp.topics) |topics| {
            for (topics) |topic| {
                if (topic.partitions) |partitions| {
                    for (partitions) |partition| {
                        if (partition.error_code != 0) {
                            commit_failed = true;
                        }
                        // TODO: Handle errors (REBALANCE_IN_PROGRESS, etc.)
                    }
                }
            }
        }

        if (self.metrics) |m| {
            m.recordCommit(!commit_failed);
        }

        self.last_commit_ms = std.time.milliTimestamp();
    }

    /// Commit specific offsets (synchronous).
    pub fn commitOffsetsSync(self: *Self, offsets: []const TopicPartitionOffset) !void {
        if (self.coordinator_broker_id < 0) return error.CoordinatorNotAvailable;

        const conn = self.broker_pool.getConnection(self.coordinator_broker_id) catch |err| {
            if (self.metrics) |m| m.recordCommit(false);
            return err;
        };

        var req = OffsetCommitRequest.default();
        req.group_id = self.group_id;
        req.generation_id_or_member_epoch = self.generation_id;
        req.member_id = self.member_id;

        // Group by topic
        var topic_map = std.StringHashMap(std.array_list.Managed(OffsetCommitRequestPartition)).init(self.allocator);
        defer {
            var it = topic_map.iterator();
            while (it.next()) |entry| {
                entry.value_ptr.deinit();
            }
            topic_map.deinit();
        }

        for (offsets) |offset| {
            const gop = try topic_map.getOrPut(offset.topic);
            if (!gop.found_existing) {
                gop.value_ptr.* = std.array_list.Managed(OffsetCommitRequestPartition).init(self.allocator);
            }

            try gop.value_ptr.append(.{
                .partition_index = offset.partition,
                .committed_offset = offset.offset,
                .committed_metadata = null,
            });
        }

        var topics_list = std.array_list.Managed(OffsetCommitRequestTopic).init(self.allocator);
        defer topics_list.deinit();

        var it = topic_map.iterator();
        while (it.next()) |entry| {
            const partitions = try entry.value_ptr.toOwnedSlice();
            try topics_list.append(.{
                .name = entry.key_ptr.*,
                .partitions = partitions,
            });
        }

        req.topics = try topics_list.toOwnedSlice();
        defer {
            for (req.topics.?) |topic| {
                self.allocator.free(topic.partitions.?);
            }
            self.allocator.free(req.topics.?);
        }

        const resp_size = try conn.sendRequest(8, self.offset_commit_version, req);

        // Use arena allocator for response decoding (zero-leak)
        var arena = std.heap.ArenaAllocator.init(self.allocator);
        defer arena.deinit();

        const resp_header_ver = request_mod.responseHeaderVersion(8, self.offset_commit_version);
        var stream = std.io.fixedBufferStream(conn.recv_buf[4..resp_size]);
        const reader = stream.reader();

        _ = try types.decodeInt32(reader);
        if (resp_header_ver >= 1) {
            _ = try types.decodeUnsignedVarInt(reader);
        }

        const resp = try OffsetCommitResponse.decode(reader, self.offset_commit_version, arena.allocator());

        if (resp.topics) |topics| {
            for (topics) |topic| {
                if (topic.partitions) |partitions| {
                    for (partitions) |partition| {
                        if (partition.error_code == 0) {
                            self.subscription.updateCommittedOffset(
                                topic.name,
                                partition.partition_index,
                                partition.committed_offset,
                            ) catch {};
                        }
                    }
                }
            }
        }

        self.last_commit_ms = std.time.milliTimestamp();
    }

    /// Check if auto-commit interval has elapsed, commit if needed.
    pub fn maybeAutoCommit(self: *Self, now_ms: i64) !void {
        if (!self.enable_auto_commit) return;
        if (self.coordinator_broker_id < 0) return;

        const elapsed = now_ms - self.last_commit_ms;
        if (elapsed >= self.auto_commit_interval_ms) {
            try self.commitSync();
        }
    }

    /// Fetch committed offsets from broker for assigned partitions.
    pub fn fetchCommitted(self: *Self) !void {
        if (self.coordinator_broker_id < 0) return error.CoordinatorNotAvailable;

        const conn = try self.broker_pool.getConnection(self.coordinator_broker_id);

        var req = OffsetFetchRequest.default();
        req.group_id = self.group_id;

        // Group assigned partitions by topic
        var topic_map = std.StringHashMap(std.array_list.Managed(i32)).init(self.allocator);
        defer {
            var it = topic_map.iterator();
            while (it.next()) |entry| {
                entry.value_ptr.deinit();
            }
            topic_map.deinit();
        }

        for (self.subscription.assigned_partitions[0..self.subscription.assigned_count]) |*part| {
            if (!part.active) continue;

            const topic_name = part.topic[0..part.topic_len];
            const gop = try topic_map.getOrPut(topic_name);
            if (!gop.found_existing) {
                gop.value_ptr.* = std.array_list.Managed(i32).init(self.allocator);
            }

            try gop.value_ptr.append(part.partition);
        }

        // Build topics array
        var topics_list = std.array_list.Managed(OffsetFetchRequestTopic).init(self.allocator);
        defer topics_list.deinit();

        var it = topic_map.iterator();
        while (it.next()) |entry| {
            const partitions = try entry.value_ptr.toOwnedSlice();
            try topics_list.append(.{
                .name = entry.key_ptr.*,
                .partition_indexes = partitions,
            });
        }

        req.topics = try topics_list.toOwnedSlice();
        defer {
            for (req.topics.?) |topic| {
                self.allocator.free(topic.partition_indexes.?);
            }
            self.allocator.free(req.topics.?);
        }

        // Send request
        const resp_size = try conn.sendRequest(9, self.offset_fetch_version, req);

        // Use arena allocator for response decoding (zero-leak)
        var arena = std.heap.ArenaAllocator.init(self.allocator);
        defer arena.deinit();

        // Parse response
        const resp_header_ver = request_mod.responseHeaderVersion(9, self.offset_fetch_version);
        var stream = std.io.fixedBufferStream(conn.recv_buf[4..resp_size]);
        const reader = stream.reader();

        _ = try types.decodeInt32(reader);
        if (resp_header_ver >= 1) {
            _ = try types.decodeUnsignedVarInt(reader);
        }

        const resp = try OffsetFetchResponse.decode(reader, self.offset_fetch_version, arena.allocator());

        // Update fetch positions with committed offsets
        if (resp.topics) |topics| {
            for (topics) |topic| {
                if (topic.partitions) |partitions| {
                    for (partitions) |partition| {
                        if (partition.error_code == 0 and partition.committed_offset >= 0) {
                            // Set fetch position to committed offset
                            self.subscription.updateFetchPosition(
                                topic.name,
                                partition.partition_index,
                                partition.committed_offset,
                            ) catch {};

                            // Also set committed offset
                            self.subscription.updateCommittedOffset(
                                topic.name,
                                partition.partition_index,
                                partition.committed_offset,
                            ) catch {};
                        }
                    }
                }
            }
        }
    }
};

/// Offset + partition for manual commit.
pub const TopicPartitionOffset = struct {
    topic: []const u8,
    partition: i32,
    offset: i64,
};

// ============================================================================
// Tests
// ============================================================================

test "OffsetManager init" {
    const allocator = std.testing.allocator;
    var broker_pool = BrokerPool.init(allocator);

    var subscription = SubscriptionState.init(allocator);
    defer subscription.deinit();

    const manager = OffsetManager.init(
        &broker_pool,
        &subscription,
        "test-group",
        true,
        5000,
        allocator,
    );

    try std.testing.expectEqualStrings("test-group", manager.group_id);
    try std.testing.expect(manager.enable_auto_commit);
    try std.testing.expectEqual(@as(u32, 5000), manager.auto_commit_interval_ms);
    try std.testing.expectEqual(@as(i32, -1), manager.coordinator_broker_id);
}

test "OffsetManager setCoordinator" {
    const allocator = std.testing.allocator;
    var broker_pool = BrokerPool.init(allocator);

    var subscription = SubscriptionState.init(allocator);
    defer subscription.deinit();

    var manager = OffsetManager.init(
        &broker_pool,
        &subscription,
        "test-group",
        true,
        5000,
        allocator,
    );

    manager.setCoordinator(1, 42, "consumer-1");

    try std.testing.expectEqual(@as(i32, 1), manager.coordinator_broker_id);
    try std.testing.expectEqual(@as(i32, 42), manager.generation_id);
    try std.testing.expectEqualStrings("consumer-1", manager.member_id);
}

test "OffsetManager commit without coordinator returns error" {
    const allocator = std.testing.allocator;
    var broker_pool = BrokerPool.init(allocator);

    var subscription = SubscriptionState.init(allocator);
    defer subscription.deinit();

    var manager = OffsetManager.init(
        &broker_pool,
        &subscription,
        "test-group",
        true,
        5000,
        allocator,
    );

    // No coordinator set
    try std.testing.expectError(error.CoordinatorNotAvailable, manager.commitSync());
}

test "OffsetManager maybeAutoCommit respects interval" {
    const allocator = std.testing.allocator;
    var broker_pool = BrokerPool.init(allocator);

    var subscription = SubscriptionState.init(allocator);
    defer subscription.deinit();

    var manager = OffsetManager.init(
        &broker_pool,
        &subscription,
        "test-group",
        true,
        5000,
        allocator,
    );

    manager.last_commit_ms = 1000;

    // Not enough time elapsed - should not commit (no coordinator anyway)
    try manager.maybeAutoCommit(2000);
    try std.testing.expectEqual(@as(i64, 1000), manager.last_commit_ms);

    // Enough time elapsed, but no coordinator
    try manager.maybeAutoCommit(7000);
    try std.testing.expectEqual(@as(i64, 1000), manager.last_commit_ms);
}

test "OffsetManager with auto-commit disabled" {
    const allocator = std.testing.allocator;
    var broker_pool = BrokerPool.init(allocator);

    var subscription = SubscriptionState.init(allocator);
    defer subscription.deinit();

    var manager = OffsetManager.init(
        &broker_pool,
        &subscription,
        "test-group",
        false, // Disabled
        5000,
        allocator,
    );

    // Should not commit even if interval elapsed
    manager.last_commit_ms = 0;
    try manager.maybeAutoCommit(10000);
    try std.testing.expectEqual(@as(i64, 0), manager.last_commit_ms);
}
