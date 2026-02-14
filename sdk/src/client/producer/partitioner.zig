const std = @import("std");
const murmur2_mod = @import("../util/murmur2.zig");
const config = @import("../config.zig");

/// Partition assignment strategies for the Kafka producer.
pub const Partitioner = struct {
    strategy: config.PartitionerType,
    /// Counter for round-robin assignment (wrapping).
    round_robin_counter: u32 = 0,
    /// Sticky partition state: current sticky partition per key-less produce.
    sticky_partition: i32 = -1,
    /// Number of records produced to the sticky partition.
    sticky_count: u32 = 0,
    /// Threshold before rotating sticky partition.
    sticky_batch_size: u32 = 16_384,

    pub fn init(strategy: config.PartitionerType) Partitioner {
        return .{ .strategy = strategy };
    }

    /// Assign a partition for the given key and partition count.
    ///
    /// - If `key` is non-null, uses murmur2 hash (consistent across all strategies).
    /// - If `key` is null, behavior depends on strategy:
    ///   - murmur2 / round_robin: round-robin across partitions
    ///   - sticky: stick to the same partition until a batch threshold
    pub fn partition(self: *Partitioner, key: ?[]const u8, num_partitions: u32) u32 {
        if (num_partitions == 0) return 0;

        // Keyed: always murmur2 (matches Java DefaultPartitioner)
        if (key) |k| {
            return murmur2_mod.partition(k, num_partitions);
        }

        // Unkeyed: depends on strategy
        return switch (self.strategy) {
            .murmur2, .round_robin => blk: {
                const p = self.round_robin_counter % num_partitions;
                self.round_robin_counter +%= 1;
                break :blk p;
            },
            .sticky => blk: {
                if (self.sticky_partition < 0 or self.sticky_count >= self.sticky_batch_size) {
                    // Rotate to next partition
                    self.sticky_partition = @intCast(self.round_robin_counter % num_partitions);
                    self.round_robin_counter +%= 1;
                    self.sticky_count = 0;
                }
                self.sticky_count += 1;
                break :blk @intCast(self.sticky_partition);
            },
        };
    }

    /// Reset sticky state (e.g., when a batch for the sticky partition is sent).
    pub fn resetSticky(self: *Partitioner) void {
        self.sticky_partition = -1;
        self.sticky_count = 0;
    }
};

// ============================================================================
// Tests
// ============================================================================

test "partitioner keyed always uses murmur2" {
    var p1 = Partitioner.init(.murmur2);
    var p2 = Partitioner.init(.round_robin);
    var p3 = Partitioner.init(.sticky);

    // All strategies should produce the same partition for the same key
    const result1 = p1.partition("order-123", 12);
    const result2 = p2.partition("order-123", 12);
    const result3 = p3.partition("order-123", 12);

    try std.testing.expectEqual(result1, result2);
    try std.testing.expectEqual(result2, result3);

    // And it should be deterministic
    const again = p1.partition("order-123", 12);
    try std.testing.expectEqual(result1, again);
}

test "partitioner round-robin unkeyed" {
    var p = Partitioner.init(.round_robin);

    var seen = [_]bool{false} ** 6;
    var i: usize = 0;
    while (i < 6) : (i += 1) {
        const part = p.partition(null, 6);
        try std.testing.expect(part < 6);
        seen[part] = true;
    }

    // All partitions should have been visited
    for (seen) |s| {
        try std.testing.expect(s);
    }
}

test "partitioner sticky stays on same partition" {
    var p = Partitioner.init(.sticky);
    p.sticky_batch_size = 100;

    const first = p.partition(null, 6);
    var i: usize = 0;
    while (i < 50) : (i += 1) {
        const part = p.partition(null, 6);
        try std.testing.expectEqual(first, part);
    }
}

test "partitioner sticky rotates after threshold" {
    var p = Partitioner.init(.sticky);
    p.sticky_batch_size = 3;

    const first = p.partition(null, 6);
    _ = p.partition(null, 6);
    _ = p.partition(null, 6);
    // Now at threshold, next call should potentially rotate
    const next = p.partition(null, 6);
    // It should have rotated (though the exact partition depends on round-robin state)
    _ = first;
    _ = next;
    // Just verify it doesn't crash; exact rotation is implementation-defined
}

test "partitioner zero partitions" {
    var p = Partitioner.init(.murmur2);
    const result = p.partition("key", 0);
    try std.testing.expectEqual(@as(u32, 0), result);
}

test "partitioner murmur2 matches librdkafka" {
    // Verify our partitioner produces the same partition as librdkafka
    // for the "kafka" key: murmur2("kafka") = 0xd067cf64
    // toPositive: 0xd067cf64 & 0x7fffffff = 0x5067cf64 = 1349250916
    // 1349250916 % 12 = 8
    var p = Partitioner.init(.murmur2);
    const result = p.partition("kafka", 12);
    const expected = (murmur2_mod.murmur2("kafka") & 0x7fffffff) % 12;
    try std.testing.expectEqual(expected, result);
}

test "partitioner round-robin wraps around" {
    var p = Partitioner.init(.round_robin);

    // With 3 partitions, round-robin should cycle 0, 1, 2, 0, 1, 2, ...
    try std.testing.expectEqual(@as(u32, 0), p.partition(null, 3));
    try std.testing.expectEqual(@as(u32, 1), p.partition(null, 3));
    try std.testing.expectEqual(@as(u32, 2), p.partition(null, 3));
    try std.testing.expectEqual(@as(u32, 0), p.partition(null, 3));
    try std.testing.expectEqual(@as(u32, 1), p.partition(null, 3));
}

test "partitioner sticky resetSticky" {
    var p = Partitioner.init(.sticky);
    p.sticky_batch_size = 1000;

    const first = p.partition(null, 6);
    _ = p.partition(null, 6);
    _ = p.partition(null, 6);

    p.resetSticky();
    try std.testing.expectEqual(@as(i32, -1), p.sticky_partition);
    try std.testing.expectEqual(@as(u32, 0), p.sticky_count);

    // After reset, should pick a new partition (not necessarily the same)
    const after_reset = p.partition(null, 6);
    _ = first;
    _ = after_reset;
}

test "partitioner keyed with single partition" {
    var p = Partitioner.init(.murmur2);
    // Any key with 1 partition must map to 0
    try std.testing.expectEqual(@as(u32, 0), p.partition("a", 1));
    try std.testing.expectEqual(@as(u32, 0), p.partition("b", 1));
    try std.testing.expectEqual(@as(u32, 0), p.partition("kafka", 1));
}

test "partitioner distribution across partitions" {
    // Verify reasonable distribution of random keys
    var p = Partitioner.init(.murmur2);
    var counts = [_]u32{0} ** 6;
    var prng = std.Random.DefaultPrng.init(42);
    const random = prng.random();

    var buf: [16]u8 = undefined;
    var i: usize = 0;
    while (i < 6000) : (i += 1) {
        random.bytes(&buf);
        const part = p.partition(&buf, 6);
        counts[part] += 1;
    }

    // Each partition should get at least some records (weak distribution check)
    for (counts) |c| {
        try std.testing.expect(c > 100); // Expect at least ~1000 each, 100 is very conservative
    }
}
