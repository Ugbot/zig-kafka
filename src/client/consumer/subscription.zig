const std = @import("std");
const TopicPartition = @import("../metadata/topic_partition.zig").TopicPartition;

/// Tracks subscription state, partition assignments, and fetch positions.
/// Thread-safe via atomic version counters for subscription and assignment changes.
pub const SubscriptionState = struct {
    const Self = @This();
    const MAX_SUBSCRIBED_TOPICS = 64;
    const MAX_ASSIGNED_PARTITIONS = 256;

    allocator: std.mem.Allocator,

    // Subscription (user-specified)
    subscribed_topics: [MAX_SUBSCRIBED_TOPICS]SubscribedTopic,
    subscribed_count: u32,
    subscription_version: std.atomic.Value(u64), // Incremented on subscribe/unsubscribe

    // Assignment (from broker after rebalance)
    assigned_partitions: [MAX_ASSIGNED_PARTITIONS]AssignedPartition,
    assigned_count: u32,
    assignment_version: std.atomic.Value(u64), // Incremented on assign/revoke
    assignment_lost: std.atomic.Value(bool), // Fenced out by broker

    // Pause/resume state
    paused_partitions: std.bit_set.IntegerBitSet(MAX_ASSIGNED_PARTITIONS),

    pub const SubscribedTopic = struct {
        name: [249]u8,
        name_len: u8,
        active: bool,
    };

    pub const AssignedPartition = struct {
        topic: [249]u8,
        topic_len: u8,
        partition: i32,

        // Fetch position
        fetch_offset: i64,
        fetch_epoch: i32, // Leader epoch for fencing

        // Stored offset (pending commit)
        stored_offset: i64,
        stored_metadata: ?[]const u8,

        // Committed offset (last successful commit)
        committed_offset: i64,

        // High water mark (from last fetch)
        high_watermark: i64,

        // Version for stale response detection
        version: u64,

        active: bool,
    };

    pub fn init(allocator: std.mem.Allocator) Self {
        return Self{
            .allocator = allocator,
            .subscribed_topics = undefined,
            .subscribed_count = 0,
            .subscription_version = std.atomic.Value(u64).init(0),
            .assigned_partitions = undefined,
            .assigned_count = 0,
            .assignment_version = std.atomic.Value(u64).init(0),
            .assignment_lost = std.atomic.Value(bool).init(false),
            .paused_partitions = std.bit_set.IntegerBitSet(MAX_ASSIGNED_PARTITIONS).initEmpty(),
        };
    }

    pub fn deinit(self: *Self) void {
        // Clean up stored metadata for assigned partitions
        for (self.assigned_partitions[0..self.assigned_count]) |*part| {
            if (part.stored_metadata) |metadata| {
                self.allocator.free(metadata);
                part.stored_metadata = null;
            }
        }
    }

    /// Subscribe to topics. Increments subscription version.
    pub fn subscribe(self: *Self, topics: []const []const u8) !void {
        if (topics.len > MAX_SUBSCRIBED_TOPICS) {
            return error.TooManyTopics;
        }

        // Clear existing subscriptions
        self.subscribed_count = 0;

        // Add new subscriptions
        for (topics) |topic| {
            if (topic.len > 249) return error.TopicNameTooLong;

            const idx = self.subscribed_count;
            var sub = &self.subscribed_topics[idx];

            @memcpy(sub.name[0..topic.len], topic);
            sub.name_len = @intCast(topic.len);
            sub.active = true;

            self.subscribed_count += 1;
        }

        // Increment version atomically
        const prev = self.subscription_version.fetchAdd(1, .monotonic);
        _ = prev;
    }

    /// Unsubscribe from all topics.
    pub fn unsubscribe(self: *Self) void {
        self.subscribed_count = 0;
        _ = self.subscription_version.fetchAdd(1, .monotonic);
    }

    /// Check if subscribed to a topic.
    pub fn isSubscribed(self: *Self, topic: []const u8) bool {
        for (self.subscribed_topics[0..self.subscribed_count]) |*sub| {
            if (!sub.active) continue;
            const name = sub.name[0..sub.name_len];
            if (std.mem.eql(u8, name, topic)) return true;
        }
        return false;
    }

    /// Assign partitions (manual assignment or after rebalance).
    pub fn assign(self: *Self, partitions: []const TopicPartition) !void {
        if (partitions.len > MAX_ASSIGNED_PARTITIONS) {
            return error.TooManyPartitions;
        }

        // Clear existing assignment
        self.assigned_count = 0;

        // Add new assignments
        for (partitions) |tp| {
            if (tp.topic.len > 249) return error.TopicNameTooLong;

            const idx = self.assigned_count;
            var part = &self.assigned_partitions[idx];

            @memcpy(part.topic[0..tp.topic.len], tp.topic);
            part.topic_len = @intCast(tp.topic.len);
            part.partition = tp.partition;
            part.fetch_offset = -1; // Will be set by seek/fetchCommitted
            part.fetch_epoch = -1;
            part.stored_offset = -1;
            part.stored_metadata = null;
            part.committed_offset = -1;
            part.high_watermark = -1;
            part.version = 0;
            part.active = true;

            self.assigned_count += 1;
        }

        // Increment version
        _ = self.assignment_version.fetchAdd(1, .monotonic);
        self.assignment_lost.store(false, .release);
    }

    /// Revoke specific partitions.
    pub fn revoke(self: *Self, partitions: []const TopicPartition) void {
        for (partitions) |tp| {
            // Find and mark inactive
            for (self.assigned_partitions[0..self.assigned_count]) |*part| {
                if (!part.active) continue;
                const name = part.topic[0..part.topic_len];
                if (std.mem.eql(u8, name, tp.topic) and part.partition == tp.partition) {
                    part.active = false;

                    // Free stored metadata
                    if (part.stored_metadata) |metadata| {
                        self.allocator.free(metadata);
                        part.stored_metadata = null;
                    }
                    break;
                }
            }
        }

        _ = self.assignment_version.fetchAdd(1, .monotonic);
    }

    /// Revoke all assigned partitions.
    pub fn revokeAll(self: *Self) void {
        for (self.assigned_partitions[0..self.assigned_count]) |*part| {
            if (part.stored_metadata) |metadata| {
                self.allocator.free(metadata);
                part.stored_metadata = null;
            }
        }
        self.assigned_count = 0;
        _ = self.assignment_version.fetchAdd(1, .monotonic);
    }

    /// Check if a partition is currently assigned.
    pub fn isAssigned(self: *Self, topic: []const u8, partition: i32) bool {
        for (self.assigned_partitions[0..self.assigned_count]) |*part| {
            if (!part.active) continue;
            const name = part.topic[0..part.topic_len];
            if (std.mem.eql(u8, name, topic) and part.partition == partition) {
                return true;
            }
        }
        return false;
    }

    /// Update fetch position for a partition.
    pub fn updateFetchPosition(self: *Self, topic: []const u8, partition: i32, offset: i64) !void {
        for (self.assigned_partitions[0..self.assigned_count]) |*part| {
            if (!part.active) continue;
            const name = part.topic[0..part.topic_len];
            if (std.mem.eql(u8, name, topic) and part.partition == partition) {
                part.fetch_offset = offset;
                return;
            }
        }
        return error.PartitionNotAssigned;
    }

    /// Store offset for later commit.
    pub fn storeOffset(self: *Self, topic: []const u8, partition: i32, offset: i64) !void {
        for (self.assigned_partitions[0..self.assigned_count]) |*part| {
            if (!part.active) continue;
            const name = part.topic[0..part.topic_len];
            if (std.mem.eql(u8, name, topic) and part.partition == partition) {
                part.stored_offset = offset;
                return;
            }
        }
        return error.PartitionNotAssigned;
    }

    /// Update committed offset after successful commit.
    pub fn updateCommittedOffset(self: *Self, topic: []const u8, partition: i32, offset: i64) !void {
        for (self.assigned_partitions[0..self.assigned_count]) |*part| {
            if (!part.active) continue;
            const name = part.topic[0..part.topic_len];
            if (std.mem.eql(u8, name, topic) and part.partition == partition) {
                part.committed_offset = offset;
                return;
            }
        }
        return error.PartitionNotAssigned;
    }

    /// Update high water mark from fetch response.
    pub fn updateHighWaterMark(self: *Self, topic: []const u8, partition: i32, hwm: i64) !void {
        for (self.assigned_partitions[0..self.assigned_count]) |*part| {
            if (!part.active) continue;
            const name = part.topic[0..part.topic_len];
            if (std.mem.eql(u8, name, topic) and part.partition == partition) {
                part.high_watermark = hwm;
                return;
            }
        }
        return error.PartitionNotAssigned;
    }

    /// Pause consumption from specified partitions.
    pub fn pause(self: *Self, partitions: []const TopicPartition) !void {
        for (partitions) |tp| {
            // Find partition index
            var found = false;
            for (self.assigned_partitions[0..self.assigned_count], 0..) |*part, idx| {
                if (!part.active) continue;
                const name = part.topic[0..part.topic_len];
                if (std.mem.eql(u8, name, tp.topic) and part.partition == tp.partition) {
                    self.paused_partitions.set(idx);
                    found = true;
                    break;
                }
            }
            if (!found) return error.PartitionNotAssigned;
        }
    }

    /// Resume consumption from specified partitions.
    pub fn resumePartitions(self: *Self, partitions: []const TopicPartition) !void {
        for (partitions) |tp| {
            // Find partition index
            var found = false;
            for (self.assigned_partitions[0..self.assigned_count], 0..) |*part, idx| {
                if (!part.active) continue;
                const name = part.topic[0..part.topic_len];
                if (std.mem.eql(u8, name, tp.topic) and part.partition == tp.partition) {
                    self.paused_partitions.unset(idx);
                    found = true;
                    break;
                }
            }
            if (!found) return error.PartitionNotAssigned;
        }
    }

    /// Check if a partition is paused.
    pub fn isPaused(self: *Self, topic: []const u8, partition: i32) bool {
        for (self.assigned_partitions[0..self.assigned_count], 0..) |*part, idx| {
            if (!part.active) continue;
            const name = part.topic[0..part.topic_len];
            if (std.mem.eql(u8, name, topic) and part.partition == partition) {
                return self.paused_partitions.isSet(idx);
            }
        }
        return false;
    }
};

// ============================================================================
// Tests
// ============================================================================

test "SubscriptionState init and deinit" {
    const allocator = std.testing.allocator;
    var state = SubscriptionState.init(allocator);
    defer state.deinit();

    try std.testing.expectEqual(@as(u32, 0), state.subscribed_count);
    try std.testing.expectEqual(@as(u32, 0), state.assigned_count);
    try std.testing.expectEqual(@as(u64, 0), state.subscription_version.load(.monotonic));
    try std.testing.expectEqual(@as(u64, 0), state.assignment_version.load(.monotonic));
    try std.testing.expect(!state.assignment_lost.load(.acquire));
}

test "subscribe to topics" {
    const allocator = std.testing.allocator;
    var state = SubscriptionState.init(allocator);
    defer state.deinit();

    const topics = [_][]const u8{ "orders", "events", "metrics" };
    try state.subscribe(&topics);

    try std.testing.expectEqual(@as(u32, 3), state.subscribed_count);
    try std.testing.expect(state.isSubscribed("orders"));
    try std.testing.expect(state.isSubscribed("events"));
    try std.testing.expect(state.isSubscribed("metrics"));
    try std.testing.expect(!state.isSubscribed("unknown"));

    // Version should have incremented
    try std.testing.expectEqual(@as(u64, 1), state.subscription_version.load(.monotonic));
}

test "unsubscribe clears topics" {
    const allocator = std.testing.allocator;
    var state = SubscriptionState.init(allocator);
    defer state.deinit();

    const topics = [_][]const u8{ "orders", "events" };
    try state.subscribe(&topics);
    try std.testing.expectEqual(@as(u32, 2), state.subscribed_count);

    state.unsubscribe();
    try std.testing.expectEqual(@as(u32, 0), state.subscribed_count);
    try std.testing.expect(!state.isSubscribed("orders"));

    // Version incremented twice (subscribe + unsubscribe)
    try std.testing.expectEqual(@as(u64, 2), state.subscription_version.load(.monotonic));
}

test "assign partitions" {
    const allocator = std.testing.allocator;
    var state = SubscriptionState.init(allocator);
    defer state.deinit();

    const partitions = [_]TopicPartition{
        .{ .topic = "orders", .partition = 0 },
        .{ .topic = "orders", .partition = 1 },
        .{ .topic = "events", .partition = 0 },
    };
    try state.assign(&partitions);

    try std.testing.expectEqual(@as(u32, 3), state.assigned_count);
    try std.testing.expect(state.isAssigned("orders", 0));
    try std.testing.expect(state.isAssigned("orders", 1));
    try std.testing.expect(state.isAssigned("events", 0));
    try std.testing.expect(!state.isAssigned("events", 1));

    // Version incremented
    try std.testing.expectEqual(@as(u64, 1), state.assignment_version.load(.monotonic));
}

test "update fetch position" {
    const allocator = std.testing.allocator;
    var state = SubscriptionState.init(allocator);
    defer state.deinit();

    const partitions = [_]TopicPartition{
        .{ .topic = "orders", .partition = 0 },
    };
    try state.assign(&partitions);

    try state.updateFetchPosition("orders", 0, 1234);

    const part = &state.assigned_partitions[0];
    try std.testing.expectEqual(@as(i64, 1234), part.fetch_offset);

    // Error if partition not assigned
    try std.testing.expectError(error.PartitionNotAssigned, state.updateFetchPosition("unknown", 0, 100));
}

test "store and retrieve offset" {
    const allocator = std.testing.allocator;
    var state = SubscriptionState.init(allocator);
    defer state.deinit();

    const partitions = [_]TopicPartition{
        .{ .topic = "orders", .partition = 0 },
    };
    try state.assign(&partitions);

    try state.storeOffset("orders", 0, 5678);

    const part = &state.assigned_partitions[0];
    try std.testing.expectEqual(@as(i64, 5678), part.stored_offset);
}

test "update committed offset" {
    const allocator = std.testing.allocator;
    var state = SubscriptionState.init(allocator);
    defer state.deinit();

    const partitions = [_]TopicPartition{
        .{ .topic = "orders", .partition = 0 },
    };
    try state.assign(&partitions);

    try state.updateCommittedOffset("orders", 0, 9999);

    const part = &state.assigned_partitions[0];
    try std.testing.expectEqual(@as(i64, 9999), part.committed_offset);
}

test "pause and resume partitions" {
    const allocator = std.testing.allocator;
    var state = SubscriptionState.init(allocator);
    defer state.deinit();

    const partitions = [_]TopicPartition{
        .{ .topic = "orders", .partition = 0 },
        .{ .topic = "orders", .partition = 1 },
    };
    try state.assign(&partitions);

    // Initially not paused
    try std.testing.expect(!state.isPaused("orders", 0));
    try std.testing.expect(!state.isPaused("orders", 1));

    // Pause partition 0
    const to_pause = [_]TopicPartition{
        .{ .topic = "orders", .partition = 0 },
    };
    try state.pause(&to_pause);

    try std.testing.expect(state.isPaused("orders", 0));
    try std.testing.expect(!state.isPaused("orders", 1));

    // Resume partition 0
    try state.resumePartitions(&to_pause);
    try std.testing.expect(!state.isPaused("orders", 0));
}

test "revoke specific partitions" {
    const allocator = std.testing.allocator;
    var state = SubscriptionState.init(allocator);
    defer state.deinit();

    const partitions = [_]TopicPartition{
        .{ .topic = "orders", .partition = 0 },
        .{ .topic = "orders", .partition = 1 },
        .{ .topic = "events", .partition = 0 },
    };
    try state.assign(&partitions);
    try std.testing.expectEqual(@as(u32, 3), state.assigned_count);

    // Revoke partition orders-0
    const to_revoke = [_]TopicPartition{
        .{ .topic = "orders", .partition = 0 },
    };
    state.revoke(&to_revoke);

    try std.testing.expect(!state.isAssigned("orders", 0));
    try std.testing.expect(state.isAssigned("orders", 1));
    try std.testing.expect(state.isAssigned("events", 0));

    // Version incremented (assign=1, revoke=2)
    try std.testing.expectEqual(@as(u64, 2), state.assignment_version.load(.monotonic));
}

test "revoke all partitions" {
    const allocator = std.testing.allocator;
    var state = SubscriptionState.init(allocator);
    defer state.deinit();

    const partitions = [_]TopicPartition{
        .{ .topic = "orders", .partition = 0 },
        .{ .topic = "events", .partition = 0 },
    };
    try state.assign(&partitions);
    try std.testing.expectEqual(@as(u32, 2), state.assigned_count);

    state.revokeAll();

    try std.testing.expectEqual(@as(u32, 0), state.assigned_count);
    try std.testing.expect(!state.isAssigned("orders", 0));
    try std.testing.expect(!state.isAssigned("events", 0));
}

test "assignment lost flag" {
    const allocator = std.testing.allocator;
    var state = SubscriptionState.init(allocator);
    defer state.deinit();

    try std.testing.expect(!state.assignment_lost.load(.acquire));

    state.assignment_lost.store(true, .release);
    try std.testing.expect(state.assignment_lost.load(.acquire));

    // Assign should clear the flag
    const partitions = [_]TopicPartition{
        .{ .topic = "orders", .partition = 0 },
    };
    try state.assign(&partitions);
    try std.testing.expect(!state.assignment_lost.load(.acquire));
}

test "subscribe to too many topics" {
    const allocator = std.testing.allocator;
    var state = SubscriptionState.init(allocator);
    defer state.deinit();

    // Create MAX_SUBSCRIBED_TOPICS + 1 topics
    var topics: [SubscriptionState.MAX_SUBSCRIBED_TOPICS + 1][]const u8 = undefined;
    for (&topics, 0..) |*t, i| {
        _ = i;
        t.* = "topic";
    }

    try std.testing.expectError(error.TooManyTopics, state.subscribe(&topics));
}

test "assign too many partitions" {
    const allocator = std.testing.allocator;
    var state = SubscriptionState.init(allocator);
    defer state.deinit();

    // Create MAX_ASSIGNED_PARTITIONS + 1 partitions
    var partitions: [SubscriptionState.MAX_ASSIGNED_PARTITIONS + 1]TopicPartition = undefined;
    for (&partitions, 0..) |*p, i| {
        p.* = .{ .topic = "topic", .partition = @intCast(i) };
    }

    try std.testing.expectError(error.TooManyPartitions, state.assign(&partitions));
}
