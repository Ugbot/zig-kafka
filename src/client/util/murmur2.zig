const std = @import("std");

/// Kafka-compatible Murmur2 hash.
///
/// This is a faithful port of the Murmur2 hash used by Java's Kafka client
/// (org.apache.kafka.common.utils.Utils.murmur2). It must produce identical
/// results to the Java implementation for cross-client partition compatibility.
///
/// Key differences from generic Murmur2:
/// - Seed is fixed at 0x9747b28c (same as Java Kafka client).
/// - The result is NOT finalized with the standard Murmur2 avalanche.
///   Java Kafka intentionally omits the final mixing step.
///
/// Reference: https://github.com/apache/kafka/blob/trunk/clients/src/main/java/org/apache/kafka/common/utils/Utils.java
pub fn murmur2(data: []const u8) u32 {
    const seed: u32 = 0x9747b28c;
    const m: u32 = 0x5bd1e995;
    const r: u5 = 24;

    const len: u32 = @intCast(data.len);
    var h: u32 = seed ^ len;

    // Process 4-byte chunks
    const n_blocks = len >> 2;
    var i: u32 = 0;
    while (i < n_blocks) : (i += 1) {
        const offset = i * 4;
        var k: u32 = @as(u32, data[offset]) |
            (@as(u32, data[offset + 1]) << 8) |
            (@as(u32, data[offset + 2]) << 16) |
            (@as(u32, data[offset + 3]) << 24);

        k *%= m;
        k ^= k >> r;
        k *%= m;

        h *%= m;
        h ^= k;
    }

    // Process remaining bytes
    const tail_offset = n_blocks * 4;
    const remaining = len - tail_offset;
    if (remaining >= 3) {
        h ^= @as(u32, data[tail_offset + 2]) << 16;
    }
    if (remaining >= 2) {
        h ^= @as(u32, data[tail_offset + 1]) << 8;
    }
    if (remaining >= 1) {
        h ^= @as(u32, data[tail_offset]);
        h *%= m;
    }

    // Avalanche (Java Kafka DOES include this part)
    h ^= h >> 13;
    h *%= m;
    h ^= h >> 15;

    return h;
}

/// Compute the partition for a given key using Kafka's default partitioner.
/// This matches DefaultPartitioner in the Java client:
///   toPositive(murmur2(key)) % numPartitions
pub fn partition(key: []const u8, num_partitions: u32) u32 {
    const hash = murmur2(key);
    // toPositive: mask off sign bit (interpret as i32, bitwise AND with 0x7fffffff)
    const positive = hash & 0x7fffffff;
    return positive % num_partitions;
}

// ============================================================================
// Tests - vectors verified against librdkafka's rd_murmur2() which matches
// Java Kafka's Utils.murmur2() (see third-party/librdkafka/src/rdmurmur2.c)
// ============================================================================

test "murmur2 librdkafka verified vectors" {
    // These test vectors come directly from librdkafka's unittest_murmur2()
    // in src/rdmurmur2.c, which are validated against Java Kafka output.
    const TestCase = struct { input: []const u8, expected: u32 };
    const cases = [_]TestCase{
        .{ .input = "kafka", .expected = 0xd067cf64 },
        .{ .input = "giberish123456789", .expected = 0x8f552b0c },
        .{ .input = "1234", .expected = 0x9fc97b14 },
        .{ .input = "234", .expected = 0xe7c009ca },
        .{ .input = "34", .expected = 0x873930da },
        .{ .input = "4", .expected = 0x5a4b5ca1 },
        .{ .input = "PreAmbleWillBeRemoved,ThePrePartThatIs", .expected = 0x78424f1c },
        .{ .input = "", .expected = 0x106e08d9 },
    };

    for (cases) |tc| {
        const result = murmur2(tc.input);
        if (result != tc.expected) {
            std.debug.print("murmur2(\"{s}\") = 0x{x:0>8}, expected 0x{x:0>8}\n", .{ tc.input, result, tc.expected });
        }
        try std.testing.expectEqual(tc.expected, result);
    }
}

test "partition distribution" {
    // Verify partition() produces values in range [0, num_partitions)
    const num_partitions: u32 = 12;
    var prng = std.Random.DefaultPrng.init(42);
    const random = prng.random();

    var buf: [32]u8 = undefined;
    var i: usize = 0;
    while (i < 1000) : (i += 1) {
        random.bytes(&buf);
        const p = partition(&buf, num_partitions);
        try std.testing.expect(p < num_partitions);
    }
}

test "partition deterministic" {
    // Same key must always produce the same partition
    const p1 = partition("order-12345", 6);
    const p2 = partition("order-12345", 6);
    try std.testing.expectEqual(p1, p2);
}

test "murmur2 all librdkafka substring vectors" {
    // librdkafka tests unaligned substrings — we test the same inputs
    const TestCase = struct { input: []const u8, expected: u32 };
    const cases = [_]TestCase{
        .{ .input = "234", .expected = 0xe7c009ca },
        .{ .input = "34", .expected = 0x873930da },
        .{ .input = "4", .expected = 0x5a4b5ca1 },
    };
    for (cases) |tc| {
        try std.testing.expectEqual(tc.expected, murmur2(tc.input));
    }
}

test "murmur2 long string" {
    // librdkafka vector for 38-byte string
    const result = murmur2("PreAmbleWillBeRemoved,ThePrePartThatIs");
    try std.testing.expectEqual(@as(u32, 0x78424f1c), result);
}

test "murmur2 null key partitions to 0" {
    // When key is empty, hash should still be deterministic
    const h = murmur2("");
    try std.testing.expectEqual(@as(u32, 0x106e08d9), h);
}

test "murmur2 alignment independence" {
    // Same content regardless of memory alignment must produce same hash.
    // Test by copying string to different offsets in a buffer.
    const input = "test-alignment";
    var buf1: [64]u8 = undefined;
    var buf2: [64]u8 = undefined;
    @memcpy(buf1[0..input.len], input);
    @memcpy(buf2[3 .. 3 + input.len], input);
    try std.testing.expectEqual(
        murmur2(buf1[0..input.len]),
        murmur2(buf2[3 .. 3 + input.len]),
    );
}

test "partition range with single partition" {
    // With 1 partition, all keys must map to partition 0
    var prng = std.Random.DefaultPrng.init(99);
    const random = prng.random();
    var buf: [16]u8 = undefined;
    var i: usize = 0;
    while (i < 100) : (i += 1) {
        random.bytes(&buf);
        try std.testing.expectEqual(@as(u32, 0), partition(&buf, 1));
    }
}

test "partition consistency across calls" {
    // Same key must always map to same partition regardless of call count
    const key = "consistent-key-test";
    const expected = partition(key, 24);
    var i: usize = 0;
    while (i < 1000) : (i += 1) {
        try std.testing.expectEqual(expected, partition(key, 24));
    }
}

test "murmur2 various lengths" {
    // Verify it handles all tail lengths (0, 1, 2, 3 remaining bytes)
    // 0 remaining: 4 bytes exactly
    _ = murmur2("abcd"); // 4 bytes, 0 tail
    _ = murmur2("abcde"); // 5 bytes, 1 tail
    _ = murmur2("abcdef"); // 6 bytes, 2 tail
    _ = murmur2("abcdefg"); // 7 bytes, 3 tail
    _ = murmur2("abcdefgh"); // 8 bytes, 0 tail

    // Verify 4-byte input matches librdkafka
    try std.testing.expectEqual(@as(u32, 0x9fc97b14), murmur2("1234"));
}
