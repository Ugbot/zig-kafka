const std = @import("std");

/// Identifies a specific topic-partition pair.
pub const TopicPartition = struct {
    topic: []const u8,
    partition: i32,

    pub fn eql(a: TopicPartition, b: TopicPartition) bool {
        return a.partition == b.partition and std.mem.eql(u8, a.topic, b.topic);
    }
};

/// Information about a single partition within a topic.
pub const PartitionInfo = struct {
    /// Partition index.
    id: i32,
    /// Broker ID of the current leader (-1 if no leader).
    leader_id: i32 = -1,
    /// Leader epoch (for fencing stale metadata).
    leader_epoch: i32 = -1,
    /// Broker IDs of the replica set.
    replicas: [MAX_REPLICAS]i32 = [_]i32{-1} ** MAX_REPLICAS,
    replica_count: u8 = 0,
    /// Broker IDs of the in-sync replica set.
    isr: [MAX_REPLICAS]i32 = [_]i32{-1} ** MAX_REPLICAS,
    isr_count: u8 = 0,

    pub const MAX_REPLICAS = 5;
};

/// Information about a topic stored in the metadata cache.
pub const TopicInfo = struct {
    /// Topic name (stored in name_buf).
    name_buf: [MAX_TOPIC_NAME]u8 = [_]u8{0} ** MAX_TOPIC_NAME,
    name_len: u16 = 0,
    /// Topic ID (UUID, all zeros if not available).
    topic_id: [16]u8 = [_]u8{0} ** 16,
    /// Partition information, indexed by partition ID.
    partitions: [MAX_PARTITIONS]PartitionInfo = undefined,
    partition_count: u16 = 0,
    /// Whether this topic has been marked for deletion.
    is_internal: bool = false,

    pub const MAX_TOPIC_NAME = 249;
    pub const MAX_PARTITIONS = 64;

    pub fn name(self: *const TopicInfo) []const u8 {
        return self.name_buf[0..self.name_len];
    }

    /// Get the leader broker ID for a partition (-1 if unknown).
    pub fn leaderForPartition(self: *const TopicInfo, partition_id: i32) i32 {
        if (partition_id < 0 or partition_id >= self.partition_count) return -1;
        const idx: usize = @intCast(partition_id);
        return self.partitions[idx].leader_id;
    }
};

/// Information about a broker in the cluster.
pub const BrokerInfo = struct {
    node_id: i32,
    host_buf: [MAX_HOST_LEN]u8 = [_]u8{0} ** MAX_HOST_LEN,
    host_len: u16 = 0,
    port: u16 = 9092,
    rack_buf: [MAX_RACK_LEN]u8 = [_]u8{0} ** MAX_RACK_LEN,
    rack_len: u16 = 0,

    pub const MAX_HOST_LEN = 255;
    pub const MAX_RACK_LEN = 64;

    pub fn host(self: *const BrokerInfo) []const u8 {
        return self.host_buf[0..self.host_len];
    }

    pub fn rack(self: *const BrokerInfo) ?[]const u8 {
        if (self.rack_len == 0) return null;
        return self.rack_buf[0..self.rack_len];
    }
};

// ============================================================================
// Tests
// ============================================================================

test "TopicPartition equality" {
    const a = TopicPartition{ .topic = "orders", .partition = 3 };
    const b = TopicPartition{ .topic = "orders", .partition = 3 };
    const c = TopicPartition{ .topic = "orders", .partition = 4 };
    const d = TopicPartition{ .topic = "events", .partition = 3 };

    try std.testing.expect(a.eql(b));
    try std.testing.expect(!a.eql(c));
    try std.testing.expect(!a.eql(d));
}

test "TopicInfo leader lookup" {
    var info = TopicInfo{};
    info.partition_count = 3;
    info.partitions[0] = .{ .id = 0, .leader_id = 1 };
    info.partitions[1] = .{ .id = 1, .leader_id = 2 };
    info.partitions[2] = .{ .id = 2, .leader_id = 1 };

    try std.testing.expectEqual(@as(i32, 1), info.leaderForPartition(0));
    try std.testing.expectEqual(@as(i32, 2), info.leaderForPartition(1));
    try std.testing.expectEqual(@as(i32, 1), info.leaderForPartition(2));
    try std.testing.expectEqual(@as(i32, -1), info.leaderForPartition(3));
    try std.testing.expectEqual(@as(i32, -1), info.leaderForPartition(-1));
}

test "BrokerInfo name access" {
    var broker = BrokerInfo{ .node_id = 1 };
    const hostname = "broker-1.kafka.svc";
    @memcpy(broker.host_buf[0..hostname.len], hostname);
    broker.host_len = hostname.len;
    broker.port = 9092;

    try std.testing.expectEqualStrings("broker-1.kafka.svc", broker.host());
    try std.testing.expectEqual(@as(?[]const u8, null), broker.rack());
}

test "BrokerInfo with rack" {
    var broker = BrokerInfo{ .node_id = 2 };
    const hostname = "broker-2";
    @memcpy(broker.host_buf[0..hostname.len], hostname);
    broker.host_len = hostname.len;

    const rack_name = "us-east-1a";
    @memcpy(broker.rack_buf[0..rack_name.len], rack_name);
    broker.rack_len = rack_name.len;

    try std.testing.expectEqualStrings("us-east-1a", broker.rack().?);
}

test "TopicInfo name access" {
    var info = TopicInfo{};
    const name_str = "my-test-topic";
    @memcpy(info.name_buf[0..name_str.len], name_str);
    info.name_len = name_str.len;
    try std.testing.expectEqualStrings("my-test-topic", info.name());
}

test "TopicInfo max partitions" {
    var info = TopicInfo{};
    info.partition_count = TopicInfo.MAX_PARTITIONS;

    var i: i32 = 0;
    while (i < TopicInfo.MAX_PARTITIONS) : (i += 1) {
        const idx: usize = @intCast(i);
        info.partitions[idx] = .{ .id = i, .leader_id = @mod(i, 3) };
    }

    // Verify all partitions accessible
    try std.testing.expectEqual(@as(i32, 0), info.leaderForPartition(0));
    try std.testing.expectEqual(@as(i32, 1), info.leaderForPartition(1));
    try std.testing.expectEqual(@as(i32, 2), info.leaderForPartition(2));
    try std.testing.expectEqual(@as(i32, 0), info.leaderForPartition(3));
}

test "TopicPartition different topics" {
    const a = TopicPartition{ .topic = "orders", .partition = 0 };
    const b = TopicPartition{ .topic = "events", .partition = 0 };
    try std.testing.expect(!a.eql(b));
}

test "PartitionInfo with replicas" {
    var part = PartitionInfo{
        .id = 0,
        .leader_id = 1,
        .leader_epoch = 42,
    };
    part.replicas[0] = 1;
    part.replicas[1] = 2;
    part.replicas[2] = 3;
    part.replica_count = 3;

    part.isr[0] = 1;
    part.isr[1] = 2;
    part.isr_count = 2;

    try std.testing.expectEqual(@as(u8, 3), part.replica_count);
    try std.testing.expectEqual(@as(u8, 2), part.isr_count);
    try std.testing.expectEqual(@as(i32, 42), part.leader_epoch);
}

test "PartitionInfo defaults" {
    const part = PartitionInfo{ .id = 0 };
    try std.testing.expectEqual(@as(i32, -1), part.leader_id);
    try std.testing.expectEqual(@as(i32, -1), part.leader_epoch);
    try std.testing.expectEqual(@as(u8, 0), part.replica_count);
    try std.testing.expectEqual(@as(u8, 0), part.isr_count);
}

test "TopicInfo is_internal flag" {
    var info = TopicInfo{};
    try std.testing.expect(!info.is_internal);
    info.is_internal = true;
    try std.testing.expect(info.is_internal);
}
