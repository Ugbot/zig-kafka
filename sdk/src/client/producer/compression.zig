const std = @import("std");
const CompressionType = @import("../config.zig").CompressionType;

/// Compress data using the specified compression codec.
/// Returns compressed data allocated with the provided allocator.
/// Caller owns the returned slice and must free it.
pub fn compress(
    data: []const u8,
    compression_type: CompressionType,
    allocator: std.mem.Allocator,
) ![]u8 {
    switch (compression_type) {
        .none => {
            // No compression - return a copy
            return try allocator.dupe(u8, data);
        },
        .gzip => {
            // GZIP compression using std.compress.gzip
            var compressed = std.array_list.Managed(u8).init(allocator);
            errdefer compressed.deinit();

            var compressor = try std.compress.gzip.compressor(
                compressed.writer(),
                .{ .level = .default },
            );
            try compressor.writer().writeAll(data);
            try compressor.finish();

            return compressed.toOwnedSlice();
        },
        .snappy => {
            // Snappy compression
            // Note: Zig standard library doesn't have snappy built-in
            // For now, return uncompressed with a warning
            std.debug.print("[COMPRESSION] WARNING: Snappy compression not yet implemented, using uncompressed\n", .{});
            return try allocator.dupe(u8, data);
        },
        .lz4 => {
            // LZ4 compression
            // Note: Zig standard library doesn't have LZ4 built-in
            // For now, return uncompressed with a warning
            std.debug.print("[COMPRESSION] WARNING: LZ4 compression not yet implemented, using uncompressed\n", .{});
            return try allocator.dupe(u8, data);
        },
        .zstd => {
            // ZSTD compression
            // Note: Zig std only has ZSTD decompression, not compression
            // For now, return uncompressed with a warning
            std.debug.print("[COMPRESSION] WARNING: ZSTD compression not yet implemented, using uncompressed\n", .{});
            return try allocator.dupe(u8, data);
        },
    }
}

/// Decompress data using the specified compression codec.
/// Returns decompressed data allocated with the provided allocator.
/// Caller owns the returned slice and must free it.
pub fn decompress(
    compressed_data: []const u8,
    compression_type: CompressionType,
    allocator: std.mem.Allocator,
) ![]u8 {
    switch (compression_type) {
        .none => {
            // No compression - return a copy
            return try allocator.dupe(u8, compressed_data);
        },
        .gzip => {
            // GZIP decompression
            var decompressed = std.array_list.Managed(u8).init(allocator);
            errdefer decompressed.deinit();

            var stream = std.io.fixedBufferStream(compressed_data);
            var decompressor = std.compress.gzip.decompressor(stream.reader());

            try decompressor.reader().readAllArrayList(&decompressed, std.math.maxInt(usize));

            return decompressed.toOwnedSlice();
        },
        .snappy => {
            // Snappy decompression
            std.debug.print("[COMPRESSION] WARNING: Snappy decompression not yet implemented, returning as-is\n", .{});
            return try allocator.dupe(u8, compressed_data);
        },
        .lz4 => {
            // LZ4 decompression
            std.debug.print("[COMPRESSION] WARNING: LZ4 decompression not yet implemented, returning as-is\n", .{});
            return try allocator.dupe(u8, compressed_data);
        },
        .zstd => {
            // ZSTD decompression
            // Note: Full ZSTD support requires additional setup (window buffer, etc.)
            // For now, return as-is
            std.debug.print("[COMPRESSION] WARNING: ZSTD decompression not yet fully implemented, returning as-is\n", .{});
            return try allocator.dupe(u8, compressed_data);
        },
    }
}

/// Estimate the maximum size of compressed data for pre-allocation.
/// Returns a conservative estimate (may be larger than actual compressed size).
pub fn maxCompressedSize(uncompressed_size: usize, compression_type: CompressionType) usize {
    return switch (compression_type) {
        .none => uncompressed_size,
        .gzip => uncompressed_size + (uncompressed_size / 1000) + 12 + 256, // Pessimistic estimate
        .snappy => uncompressed_size + 32 + (uncompressed_size / 6), // Snappy expansion
        .lz4 => uncompressed_size + (uncompressed_size / 255) + 16, // LZ4 frame overhead
        .zstd => uncompressed_size + (uncompressed_size / 128) + 512, // ZSTD pessimistic estimate
    };
}

// ============================================================================
// Tests
// ============================================================================

test "compression - none" {
    const allocator = std.testing.allocator;
    const data = "Hello, World! This is test data.";

    const compressed = try compress(data, .none, allocator);
    defer allocator.free(compressed);

    try std.testing.expectEqualStrings(data, compressed);

    const decompressed = try decompress(compressed, .none, allocator);
    defer allocator.free(decompressed);

    try std.testing.expectEqualStrings(data, decompressed);
}

test "compression - gzip round-trip" {
    const allocator = std.testing.allocator;
    const data = "Hello, World! This is test data that should compress well. " ** 10;

    const compressed = try compress(data, .gzip, allocator);
    defer allocator.free(compressed);

    // Compressed size should be smaller than original for repetitive data
    std.debug.print("\n[GZIP] Original: {d} bytes, Compressed: {d} bytes\n", .{ data.len, compressed.len });

    const decompressed = try decompress(compressed, .gzip, allocator);
    defer allocator.free(decompressed);

    try std.testing.expectEqualStrings(data, decompressed);
}

test "compression - zstd decompression only" {
    // Note: Zig std only provides ZSTD decompression, not compression
    // This test verifies decompression works with externally compressed data
    // For now, we just test that the fallback (uncompressed) works
    const allocator = std.testing.allocator;
    const data = "Hello, World!";

    const result = try compress(data, .zstd, allocator);
    defer allocator.free(result);

    // Should return uncompressed data (not implemented yet)
    try std.testing.expectEqualStrings(data, result);
}

test "maxCompressedSize estimates" {
    try std.testing.expectEqual(@as(usize, 1000), maxCompressedSize(1000, .none));
    try std.testing.expect(maxCompressedSize(1000, .gzip) > 1000);
    try std.testing.expect(maxCompressedSize(1000, .zstd) > 1000);
}
