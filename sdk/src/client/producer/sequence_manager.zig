const std = @import("std");

/// Manages sequence numbers for idempotent/transactional producers.
///
/// Each topic-partition pair gets its own sequence counter that starts at 0
/// and increments with each batch sent. This allows the broker to deduplicate
/// retried batches and ensure exactly-once semantics.
///
/// NOT thread-safe: Only accessed by sender thread.
pub const SequenceManager = struct {
    const Self = @This();

    /// Map from (topic, partition) to next sequence number.
    sequences: PartitionSequenceMap,

    /// Allocator for managing partition keys.
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) Self {
        return .{
            .sequences = PartitionSequenceMap.init(allocator),
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Self) void {
        // Free all keys
        var it = self.sequences.keyIterator();
        while (it.next()) |key| {
            self.allocator.free(key.topic);
        }
        self.sequences.deinit();
    }

    /// Get the next sequence number for a topic-partition.
    /// Returns 0 for first batch to this partition.
    pub fn getNextSequence(self: *Self, topic: []const u8, partition: i32) !i32 {
        const key = PartitionKey{ .topic = topic, .partition = partition };

        if (self.sequences.get(key)) |seq| {
            return seq;
        }

        // First batch to this partition - start at 0
        const topic_copy = try self.allocator.dupe(u8, topic);
        const key_owned = PartitionKey{ .topic = topic_copy, .partition = partition };
        try self.sequences.put(key_owned, 0);
        return 0;
    }

    /// Update the sequence after sending a batch.
    /// Increments by the number of records sent in the batch.
    pub fn updateSequence(self: *Self, topic: []const u8, partition: i32, record_count: i32) !void {
        const key = PartitionKey{ .topic = topic, .partition = partition };

        if (self.sequences.getPtr(key)) |seq_ptr| {
            // Increment by batch size, wrapping at i32 max
            const new_seq = @as(i64, seq_ptr.*) + record_count;
            seq_ptr.* = @intCast(@mod(new_seq, std.math.maxInt(i32)));
        } else {
            // Should never happen - getNextSequence should have initialized it
            return error.SequenceNotInitialized;
        }
    }

    /// Reset sequence for a partition (used when epoch bumps or errors occur).
    pub fn resetSequence(self: *Self, topic: []const u8, partition: i32) void {
        const key = PartitionKey{ .topic = topic, .partition = partition };
        if (self.sequences.getPtr(key)) |seq_ptr| {
            seq_ptr.* = 0;
        }
    }

    /// Reset all sequences (used when producer ID is reinitialized).
    pub fn resetAll(self: *Self) void {
        var it = self.sequences.valueIterator();
        while (it.next()) |seq| {
            seq.* = 0;
        }
    }
};

/// Key for partition sequence map: (topic, partition).
const PartitionKey = struct {
    topic: []const u8,
    partition: i32,

    pub fn hash(self: PartitionKey) u64 {
        var hasher = std.hash.Wyhash.init(0);
        hasher.update(self.topic);
        hasher.update(std.mem.asBytes(&self.partition));
        return hasher.final();
    }

    pub fn eql(self: PartitionKey, other: PartitionKey) bool {
        return self.partition == other.partition and
            std.mem.eql(u8, self.topic, other.topic);
    }
};

// 0.16 port: `std.ArrayHashMap` is absent from this stripped std. This map is
// only used for key->value lookup plus full iteration to free keys / reset
// counters (resetAll); insertion order and indexed access are never relied
// upon, so an unordered `std.HashMap` is a faithful, behaviour-preserving
// swap. Keys hold a `[]const u8` slice, so we keep the custom hash/eql context
// (default auto-hashing would hash the slice by pointer). Note the unordered
// HashMap context signature differs from ArrayHashMap: hash returns u64 and
// eql takes no trailing index argument.
const PartitionSequenceMap = std.HashMap(
    PartitionKey,
    i32,
    struct {
        pub fn hash(_: @This(), key: PartitionKey) u64 {
            return key.hash();
        }
        pub fn eql(_: @This(), a: PartitionKey, b: PartitionKey) bool {
            return a.eql(b);
        }
    },
    std.hash_map.default_max_load_percentage,
);

// ============================================================================
// Tests
// ============================================================================

test "SequenceManager basic" {
    var manager = SequenceManager.init(std.testing.allocator);
    defer manager.deinit();

    // First sequence for partition should be 0
    const seq1 = try manager.getNextSequence("test-topic", 0);
    try std.testing.expectEqual(@as(i32, 0), seq1);

    // Update after sending 5 records
    try manager.updateSequence("test-topic", 0, 5);

    // Next sequence should be 5
    const seq2 = try manager.getNextSequence("test-topic", 0);
    try std.testing.expectEqual(@as(i32, 5), seq2);

    // Update again
    try manager.updateSequence("test-topic", 0, 3);
    const seq3 = try manager.getNextSequence("test-topic", 0);
    try std.testing.expectEqual(@as(i32, 8), seq3);
}

test "SequenceManager multiple partitions" {
    var manager = SequenceManager.init(std.testing.allocator);
    defer manager.deinit();

    // Different partitions have independent sequences
    const seq_p0 = try manager.getNextSequence("topic", 0);
    const seq_p1 = try manager.getNextSequence("topic", 1);
    try std.testing.expectEqual(@as(i32, 0), seq_p0);
    try std.testing.expectEqual(@as(i32, 0), seq_p1);

    try manager.updateSequence("topic", 0, 10);
    try manager.updateSequence("topic", 1, 3);

    const seq_p0_next = try manager.getNextSequence("topic", 0);
    const seq_p1_next = try manager.getNextSequence("topic", 1);
    try std.testing.expectEqual(@as(i32, 10), seq_p0_next);
    try std.testing.expectEqual(@as(i32, 3), seq_p1_next);
}

test "SequenceManager reset" {
    var manager = SequenceManager.init(std.testing.allocator);
    defer manager.deinit();

    _ = try manager.getNextSequence("topic", 0);
    try manager.updateSequence("topic", 0, 100);

    const seq_before = try manager.getNextSequence("topic", 0);
    try std.testing.expectEqual(@as(i32, 100), seq_before);

    // Reset specific partition
    manager.resetSequence("topic", 0);
    const seq_after = try manager.getNextSequence("topic", 0);
    try std.testing.expectEqual(@as(i32, 0), seq_after);
}

test "SequenceManager resetAll" {
    var manager = SequenceManager.init(std.testing.allocator);
    defer manager.deinit();

    _ = try manager.getNextSequence("topic-a", 0);
    _ = try manager.getNextSequence("topic-b", 1);
    try manager.updateSequence("topic-a", 0, 50);
    try manager.updateSequence("topic-b", 1, 30);

    manager.resetAll();

    const seq_a = try manager.getNextSequence("topic-a", 0);
    const seq_b = try manager.getNextSequence("topic-b", 1);
    try std.testing.expectEqual(@as(i32, 0), seq_a);
    try std.testing.expectEqual(@as(i32, 0), seq_b);
}
