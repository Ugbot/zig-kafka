const std = @import("std");
const tp = @import("topic_partition.zig");

/// Fixed-capacity cluster metadata cache.
///
/// Stores broker, topic, and partition information parsed from MetadataResponses.
/// All storage is inline (no heap allocation) — fixed arrays sized to practical limits.
pub const MetadataCache = struct {
    const Self = @This();

    /// Known brokers in the cluster (indexed by slot, NOT by node_id).
    brokers: [MAX_BROKERS]?tp.BrokerInfo = [_]?tp.BrokerInfo{null} ** MAX_BROKERS,
    broker_count: u16 = 0,

    /// Known topics (indexed by slot).
    topics: [MAX_TOPICS]?tp.TopicInfo = [_]?tp.TopicInfo{null} ** MAX_TOPICS,
    topic_count: u16 = 0,

    /// Cluster ID (if available).
    cluster_id_buf: [64]u8 = [_]u8{0} ** 64,
    cluster_id_len: u8 = 0,

    /// Controller broker ID.
    controller_id: i32 = -1,

    /// Timestamp of last successful metadata refresh.
    last_refresh_ms: i64 = 0,

    pub const MAX_BROKERS = 64;
    pub const MAX_TOPICS = 128;

    /// Get broker info by node ID.
    pub fn getBroker(self: *const Self, node_id: i32) ?*const tp.BrokerInfo {
        for (&self.brokers) |*slot| {
            if (slot.*) |*broker| {
                if (broker.node_id == node_id) return broker;
            }
        }
        return null;
    }

    /// Get topic info by name.
    pub fn getTopic(self: *const Self, topic_name: []const u8) ?*const tp.TopicInfo {
        for (&self.topics) |*slot| {
            if (slot.*) |*topic| {
                if (std.mem.eql(u8, topic.name(), topic_name)) return topic;
            }
        }
        return null;
    }

    /// Get topic info by UUID (for Fetch v13+ response parsing).
    /// Returns null if no topic with the given UUID is found.
    pub fn getTopicByUuid(self: *const Self, uuid: [16]u8) ?*const tp.TopicInfo {
        // Check if UUID is all zeros (not available)
        const is_zero = std.mem.allEqual(u8, &uuid, 0);
        if (is_zero) return null;

        for (&self.topics) |*slot| {
            if (slot.*) |*topic| {
                if (std.mem.eql(u8, &topic.topic_id, &uuid)) return topic;
            }
        }
        return null;
    }

    /// Get the leader broker ID for a topic-partition (-1 if unknown).
    pub fn getLeader(self: *const Self, topic_name: []const u8, partition_id: i32) i32 {
        const topic = self.getTopic(topic_name) orelse return -1;
        return topic.leaderForPartition(partition_id);
    }

    /// Get the partition count for a topic (0 if unknown).
    pub fn getPartitionCount(self: *const Self, topic_name: []const u8) u16 {
        const topic = self.getTopic(topic_name) orelse return 0;
        return topic.partition_count;
    }

    /// Update broker list from a MetadataResponse.
    /// Replaces all broker entries.
    pub fn updateBrokers(self: *Self, brokers: []const BrokerEntry) void {
        // Clear existing
        for (&self.brokers) |*slot| slot.* = null;
        self.broker_count = 0;

        for (brokers) |entry| {
            if (self.broker_count >= MAX_BROKERS) break;
            var info = tp.BrokerInfo{ .node_id = entry.node_id };

            const host_len = @min(entry.host.len, tp.BrokerInfo.MAX_HOST_LEN);
            @memcpy(info.host_buf[0..host_len], entry.host[0..host_len]);
            info.host_len = @intCast(host_len);
            info.port = @intCast(entry.port);

            if (entry.rack) |rack| {
                const rack_len = @min(rack.len, tp.BrokerInfo.MAX_RACK_LEN);
                @memcpy(info.rack_buf[0..rack_len], rack[0..rack_len]);
                info.rack_len = @intCast(rack_len);
            }

            self.brokers[self.broker_count] = info;
            self.broker_count += 1;
        }
    }

    /// Update a single topic's metadata.
    /// If the topic already exists, it is replaced in-place.
    /// If new, it is appended.
    pub fn updateTopic(self: *Self, topic_name: []const u8, partitions: []const PartitionEntry) void {
        // Find existing slot or allocate new one
        var slot_idx: ?usize = null;
        for (&self.topics, 0..) |*slot, i| {
            if (slot.*) |*existing| {
                if (std.mem.eql(u8, existing.name(), topic_name)) {
                    slot_idx = i;
                    break;
                }
            }
        }

        if (slot_idx == null) {
            // Find first empty slot
            for (&self.topics, 0..) |*slot, i| {
                if (slot.* == null) {
                    slot_idx = i;
                    break;
                }
            }
        }

        const idx = slot_idx orelse return; // No space

        var info = tp.TopicInfo{};
        const name_len = @min(topic_name.len, tp.TopicInfo.MAX_TOPIC_NAME);
        @memcpy(info.name_buf[0..name_len], topic_name[0..name_len]);
        info.name_len = @intCast(name_len);

        for (partitions) |entry| {
            if (info.partition_count >= tp.TopicInfo.MAX_PARTITIONS) break;
            const pidx: usize = info.partition_count;
            info.partitions[pidx] = .{
                .id = entry.partition_id,
                .leader_id = entry.leader_id,
                .leader_epoch = entry.leader_epoch,
            };

            // Copy replicas
            for (entry.replicas[0..entry.replica_count]) |r| {
                if (info.partitions[pidx].replica_count >= tp.PartitionInfo.MAX_REPLICAS) break;
                info.partitions[pidx].replicas[info.partitions[pidx].replica_count] = r;
                info.partitions[pidx].replica_count += 1;
            }

            // Copy ISR
            for (entry.isr[0..entry.isr_count]) |r| {
                if (info.partitions[pidx].isr_count >= tp.PartitionInfo.MAX_REPLICAS) break;
                info.partitions[pidx].isr[info.partitions[pidx].isr_count] = r;
                info.partitions[pidx].isr_count += 1;
            }

            info.partition_count += 1;
        }

        const is_new = self.topics[idx] == null;
        self.topics[idx] = info;
        if (is_new) {
            self.topic_count += 1;
        }
    }

    /// Remove a topic from the cache.
    pub fn removeTopic(self: *Self, topic_name: []const u8) void {
        for (&self.topics) |*slot| {
            if (slot.*) |*existing| {
                if (std.mem.eql(u8, existing.name(), topic_name)) {
                    slot.* = null;
                    if (self.topic_count > 0) self.topic_count -= 1;
                    return;
                }
            }
        }
    }

    pub fn clusterIdSlice(self: *const Self) ?[]const u8 {
        if (self.cluster_id_len == 0) return null;
        return self.cluster_id_buf[0..self.cluster_id_len];
    }
};

/// Broker metadata from a MetadataResponse (intermediate form for updateBrokers).
pub const BrokerEntry = struct {
    node_id: i32,
    host: []const u8,
    port: i32,
    rack: ?[]const u8 = null,
};

/// Partition metadata from a MetadataResponse (intermediate form for updateTopic).
pub const PartitionEntry = struct {
    partition_id: i32,
    leader_id: i32,
    leader_epoch: i32 = -1,
    replicas: [5]i32 = [_]i32{-1} ** 5,
    replica_count: u8 = 0,
    isr: [5]i32 = [_]i32{-1} ** 5,
    isr_count: u8 = 0,
};

// ============================================================================
// Tests
// ============================================================================

test "MetadataCache broker operations" {
    var cache = MetadataCache{};

    const brokers = [_]BrokerEntry{
        .{ .node_id = 0, .host = "broker-0", .port = 9092 },
        .{ .node_id = 1, .host = "broker-1", .port = 9093 },
        .{ .node_id = 2, .host = "broker-2", .port = 9094, .rack = "us-east-1a" },
    };
    cache.updateBrokers(&brokers);

    try std.testing.expectEqual(@as(u16, 3), cache.broker_count);

    const b0 = cache.getBroker(0).?;
    try std.testing.expectEqualStrings("broker-0", b0.host());
    try std.testing.expectEqual(@as(u16, 9092), b0.port);

    const b2 = cache.getBroker(2).?;
    try std.testing.expectEqualStrings("us-east-1a", b2.rack().?);

    try std.testing.expectEqual(@as(?*const tp.BrokerInfo, null), cache.getBroker(99));
}

test "MetadataCache topic operations" {
    var cache = MetadataCache{};

    var parts: [3]PartitionEntry = undefined;
    parts[0] = .{ .partition_id = 0, .leader_id = 1 };
    parts[1] = .{ .partition_id = 1, .leader_id = 2 };
    parts[2] = .{ .partition_id = 2, .leader_id = 0 };

    cache.updateTopic("orders", &parts);

    try std.testing.expectEqual(@as(u16, 3), cache.getPartitionCount("orders"));
    try std.testing.expectEqual(@as(i32, 1), cache.getLeader("orders", 0));
    try std.testing.expectEqual(@as(i32, 2), cache.getLeader("orders", 1));
    try std.testing.expectEqual(@as(i32, 0), cache.getLeader("orders", 2));
    try std.testing.expectEqual(@as(i32, -1), cache.getLeader("orders", 3));
    try std.testing.expectEqual(@as(i32, -1), cache.getLeader("unknown", 0));
}

test "MetadataCache topic update replaces" {
    var cache = MetadataCache{};

    var parts1 = [_]PartitionEntry{
        .{ .partition_id = 0, .leader_id = 1 },
    };
    cache.updateTopic("test", &parts1);
    try std.testing.expectEqual(@as(i32, 1), cache.getLeader("test", 0));

    // Update with new leader
    var parts2 = [_]PartitionEntry{
        .{ .partition_id = 0, .leader_id = 2 },
    };
    cache.updateTopic("test", &parts2);
    try std.testing.expectEqual(@as(i32, 2), cache.getLeader("test", 0));
}

test "MetadataCache topic removal" {
    var cache = MetadataCache{};

    var parts = [_]PartitionEntry{
        .{ .partition_id = 0, .leader_id = 1 },
    };
    cache.updateTopic("temp", &parts);
    try std.testing.expectEqual(@as(u16, 1), cache.getPartitionCount("temp"));

    cache.removeTopic("temp");
    try std.testing.expectEqual(@as(u16, 0), cache.getPartitionCount("temp"));
}

test "MetadataCache remove nonexistent topic" {
    var cache = MetadataCache{};
    // Should not crash or modify count
    cache.removeTopic("ghost");
    try std.testing.expectEqual(@as(u16, 0), cache.topic_count);
}

test "MetadataCache broker replacement" {
    var cache = MetadataCache{};

    const brokers1 = [_]BrokerEntry{
        .{ .node_id = 0, .host = "old-host", .port = 9092 },
    };
    cache.updateBrokers(&brokers1);
    try std.testing.expectEqual(@as(u16, 1), cache.broker_count);

    // Replace with new set
    const brokers2 = [_]BrokerEntry{
        .{ .node_id = 0, .host = "new-host-a", .port = 9092 },
        .{ .node_id = 1, .host = "new-host-b", .port = 9093 },
        .{ .node_id = 2, .host = "new-host-c", .port = 9094 },
    };
    cache.updateBrokers(&brokers2);
    try std.testing.expectEqual(@as(u16, 3), cache.broker_count);

    // Old broker should be gone, new ones present
    const b0 = cache.getBroker(0).?;
    try std.testing.expectEqualStrings("new-host-a", b0.host());
}

test "MetadataCache many topics" {
    var cache = MetadataCache{};

    // Fill up to MAX_TOPICS
    var parts = [_]PartitionEntry{
        .{ .partition_id = 0, .leader_id = 0 },
    };

    var name_buf: [32]u8 = undefined;
    var i: usize = 0;
    while (i < MetadataCache.MAX_TOPICS) : (i += 1) {
        const len = std.fmt.bufPrint(&name_buf, "topic-{d}", .{i}) catch unreachable;
        cache.updateTopic(len, &parts);
    }
    try std.testing.expectEqual(@as(u16, MetadataCache.MAX_TOPICS), cache.topic_count);

    // Verify we can look up the first and last
    try std.testing.expectEqual(@as(u16, 1), cache.getPartitionCount("topic-0"));
    const last_name = std.fmt.bufPrint(&name_buf, "topic-{d}", .{MetadataCache.MAX_TOPICS - 1}) catch unreachable;
    try std.testing.expectEqual(@as(u16, 1), cache.getPartitionCount(last_name));
}

test "MetadataCache topic slot reuse after removal" {
    var cache = MetadataCache{};

    var parts = [_]PartitionEntry{
        .{ .partition_id = 0, .leader_id = 1 },
    };
    cache.updateTopic("ephemeral", &parts);
    try std.testing.expectEqual(@as(u16, 1), cache.topic_count);

    cache.removeTopic("ephemeral");
    try std.testing.expectEqual(@as(u16, 0), cache.topic_count);

    // Slot should be reusable
    cache.updateTopic("reborn", &parts);
    try std.testing.expectEqual(@as(u16, 1), cache.topic_count);
    try std.testing.expectEqual(@as(u16, 1), cache.getPartitionCount("reborn"));
}

test "MetadataCache cluster ID" {
    var cache = MetadataCache{};
    try std.testing.expectEqual(@as(?[]const u8, null), cache.clusterIdSlice());

    const id = "abc-123-def";
    @memcpy(cache.cluster_id_buf[0..id.len], id);
    cache.cluster_id_len = id.len;
    try std.testing.expectEqualStrings("abc-123-def", cache.clusterIdSlice().?);
}

test "MetadataCache partition with replicas and ISR" {
    var cache = MetadataCache{};

    var parts = [_]PartitionEntry{
        .{
            .partition_id = 0,
            .leader_id = 1,
            .leader_epoch = 5,
            .replicas = .{ 1, 2, 3, -1, -1 },
            .replica_count = 3,
            .isr = .{ 1, 2, -1, -1, -1 },
            .isr_count = 2,
        },
    };
    cache.updateTopic("replicated", &parts);

    const topic = cache.getTopic("replicated").?;
    try std.testing.expectEqual(@as(u16, 1), topic.partition_count);
    try std.testing.expectEqual(@as(u8, 3), topic.partitions[0].replica_count);
    try std.testing.expectEqual(@as(u8, 2), topic.partitions[0].isr_count);
    try std.testing.expectEqual(@as(i32, 1), topic.partitions[0].replicas[0]);
    try std.testing.expectEqual(@as(i32, 2), topic.partitions[0].replicas[1]);
    try std.testing.expectEqual(@as(i32, 3), topic.partitions[0].replicas[2]);
}

test "MetadataCache long topic name" {
    var cache = MetadataCache{};

    // Kafka allows topic names up to 249 chars
    var long_name: [249]u8 = undefined;
    @memset(&long_name, 'x');

    var parts = [_]PartitionEntry{
        .{ .partition_id = 0, .leader_id = 0 },
    };
    cache.updateTopic(&long_name, &parts);
    try std.testing.expectEqual(@as(u16, 1), cache.getPartitionCount(&long_name));
}

test "MetadataCache getLeader for unknown partition" {
    var cache = MetadataCache{};

    var parts = [_]PartitionEntry{
        .{ .partition_id = 0, .leader_id = 5 },
    };
    cache.updateTopic("t", &parts);

    // Known partition
    try std.testing.expectEqual(@as(i32, 5), cache.getLeader("t", 0));
    // Unknown partition
    try std.testing.expectEqual(@as(i32, -1), cache.getLeader("t", 1));
    // Negative partition
    try std.testing.expectEqual(@as(i32, -1), cache.getLeader("t", -1));
}

test "MetadataCache getTopicByUuid" {
    var cache = MetadataCache{};

    var parts = [_]PartitionEntry{
        .{ .partition_id = 0, .leader_id = 1 },
    };
    cache.updateTopic("test-topic", &parts);

    // Set a UUID for the topic
    const test_uuid = [_]u8{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 };
    for (&cache.topics) |*slot| {
        if (slot.*) |*topic| {
            if (std.mem.eql(u8, topic.name(), "test-topic")) {
                topic.topic_id = test_uuid;
                break;
            }
        }
    }

    // Test finding by UUID
    const found = cache.getTopicByUuid(test_uuid);
    try std.testing.expect(found != null);
    try std.testing.expectEqualStrings("test-topic", found.?.name());

    // Test with unknown UUID
    const unknown_uuid = [_]u8{ 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99 };
    try std.testing.expectEqual(@as(?*const tp.TopicInfo, null), cache.getTopicByUuid(unknown_uuid));

    // Test with zero UUID (not available)
    const zero_uuid = [_]u8{0} ** 16;
    try std.testing.expectEqual(@as(?*const tp.TopicInfo, null), cache.getTopicByUuid(zero_uuid));
}
