//! Kafka Compression Support
//! Implements decompression for Kafka RecordBatch data
//! Supports: None, GZIP, Snappy, LZ4, ZSTD

const std = @import("std");
const mem = std.mem;
const log = std.log.scoped(.kafka_compression);

/// Compression codec types (from RecordBatch attributes bits 0-2)
pub const CompressionCodec = enum(u3) {
    none = 0,
    gzip = 1,
    snappy = 2,
    lz4 = 3,
    zstd = 4,

    pub fn fromAttributes(attributes: i16) CompressionCodec {
        return @enumFromInt(@as(u3, @truncate(@as(u16, @bitCast(attributes)) & 0x7)));
    }
};

/// Decompress data based on codec type
/// Returns decompressed data (caller owns memory) or null if no decompression needed
pub fn decompress(allocator: mem.Allocator, codec: CompressionCodec, compressed_data: []const u8) !?[]u8 {
    return switch (codec) {
        .none => null, // No decompression needed
        .snappy => try decompressSnappy(allocator, compressed_data),
        .gzip => try decompressGzip(allocator, compressed_data),
        .lz4 => {
            log.warn("LZ4 compression not yet implemented", .{});
            return error.UnsupportedCompression;
        },
        .zstd => {
            log.warn("ZSTD compression not yet implemented", .{});
            return error.UnsupportedCompression;
        },
    };
}

// ============================================================================
// Snappy Decompression
// ============================================================================

/// Snappy decompression lookup table (from Google's C implementation)
/// Data stored per entry:
///   Range   Bits-used   Description
///   1..64   0..7        Literal/copy length encoded in opcode byte
///   0..7    8..10       Copy offset encoded in opcode byte / 256
///   0..4    11..13      Extra bytes after opcode
const snappy_char_table = [256]u16{
    0x0001, 0x0804, 0x1001, 0x2001, 0x0002, 0x0805, 0x1002, 0x2002,
    0x0003, 0x0806, 0x1003, 0x2003, 0x0004, 0x0807, 0x1004, 0x2004,
    0x0005, 0x0808, 0x1005, 0x2005, 0x0006, 0x0809, 0x1006, 0x2006,
    0x0007, 0x080a, 0x1007, 0x2007, 0x0008, 0x080b, 0x1008, 0x2008,
    0x0009, 0x0904, 0x1009, 0x2009, 0x000a, 0x0905, 0x100a, 0x200a,
    0x000b, 0x0906, 0x100b, 0x200b, 0x000c, 0x0907, 0x100c, 0x200c,
    0x000d, 0x0908, 0x100d, 0x200d, 0x000e, 0x0909, 0x100e, 0x200e,
    0x000f, 0x090a, 0x100f, 0x200f, 0x0010, 0x090b, 0x1010, 0x2010,
    0x0011, 0x0a04, 0x1011, 0x2011, 0x0012, 0x0a05, 0x1012, 0x2012,
    0x0013, 0x0a06, 0x1013, 0x2013, 0x0014, 0x0a07, 0x1014, 0x2014,
    0x0015, 0x0a08, 0x1015, 0x2015, 0x0016, 0x0a09, 0x1016, 0x2016,
    0x0017, 0x0a0a, 0x1017, 0x2017, 0x0018, 0x0a0b, 0x1018, 0x2018,
    0x0019, 0x0b04, 0x1019, 0x2019, 0x001a, 0x0b05, 0x101a, 0x201a,
    0x001b, 0x0b06, 0x101b, 0x201b, 0x001c, 0x0b07, 0x101c, 0x201c,
    0x001d, 0x0b08, 0x101d, 0x201d, 0x001e, 0x0b09, 0x101e, 0x201e,
    0x001f, 0x0b0a, 0x101f, 0x201f, 0x0020, 0x0b0b, 0x1020, 0x2020,
    0x0021, 0x0c04, 0x1021, 0x2021, 0x0022, 0x0c05, 0x1022, 0x2022,
    0x0023, 0x0c06, 0x1023, 0x2023, 0x0024, 0x0c07, 0x1024, 0x2024,
    0x0025, 0x0c08, 0x1025, 0x2025, 0x0026, 0x0c09, 0x1026, 0x2026,
    0x0027, 0x0c0a, 0x1027, 0x2027, 0x0028, 0x0c0b, 0x1028, 0x2028,
    0x0029, 0x0d04, 0x1029, 0x2029, 0x002a, 0x0d05, 0x102a, 0x202a,
    0x002b, 0x0d06, 0x102b, 0x202b, 0x002c, 0x0d07, 0x102c, 0x202c,
    0x002d, 0x0d08, 0x102d, 0x202d, 0x002e, 0x0d09, 0x102e, 0x202e,
    0x002f, 0x0d0a, 0x102f, 0x202f, 0x0030, 0x0d0b, 0x1030, 0x2030,
    0x0031, 0x0e04, 0x1031, 0x2031, 0x0032, 0x0e05, 0x1032, 0x2032,
    0x0033, 0x0e06, 0x1033, 0x2033, 0x0034, 0x0e07, 0x1034, 0x2034,
    0x0035, 0x0e08, 0x1035, 0x2035, 0x0036, 0x0e09, 0x1036, 0x2036,
    0x0037, 0x0e0a, 0x1037, 0x2037, 0x0038, 0x0e0b, 0x1038, 0x2038,
    0x0039, 0x0f04, 0x1039, 0x2039, 0x003a, 0x0f05, 0x103a, 0x203a,
    0x003b, 0x0f06, 0x103b, 0x203b, 0x003c, 0x0f07, 0x103c, 0x203c,
    0x0801, 0x0f08, 0x103d, 0x203d, 0x1001, 0x0f09, 0x103e, 0x203e,
    0x1801, 0x0f0a, 0x103f, 0x203f, 0x2001, 0x0f0b, 0x1040, 0x2040,
};

/// Word masks for extracting variable-length integers
const wordmask = [5]u32{ 0, 0xff, 0xffff, 0xffffff, 0xffffffff };

/// Read a varint from the start of data, return value and bytes consumed
fn readSnappyVarint(data: []const u8) !struct { value: u32, bytes_read: usize } {
    var result: u32 = 0;
    var shift: u5 = 0;
    var i: usize = 0;

    while (i < data.len and i < 5) : (i += 1) {
        const byte = data[i];
        result |= @as(u32, byte & 0x7f) << shift;
        if (byte < 128) {
            return .{ .value = result, .bytes_read = i + 1 };
        }
        shift +|= 7;
    }
    return error.InvalidVarint;
}

/// Get uncompressed length from snappy-compressed data
pub fn snappyUncompressedLength(data: []const u8) !u32 {
    const result = try readSnappyVarint(data);
    return result.value;
}

/// Decompress Snappy data
pub fn decompressSnappy(allocator: mem.Allocator, compressed: []const u8) ![]u8 {
    if (compressed.len == 0) return try allocator.alloc(u8, 0);

    // Read uncompressed length (varint at start)
    const varint_result = try readSnappyVarint(compressed);
    const uncompressed_len = varint_result.value;
    var ip: usize = varint_result.bytes_read;

    log.debug("Snappy: compressed_len={}, uncompressed_len={}, varint_bytes={}", .{ compressed.len, uncompressed_len, ip });

    // Allocate output buffer
    var output = try allocator.alloc(u8, uncompressed_len);
    errdefer allocator.free(output);
    var op: usize = 0;

    // Process tags
    while (ip < compressed.len and op < uncompressed_len) {
        const c = compressed[ip];
        ip += 1;

        if ((c & 0x3) == 0) {
            // LITERAL
            var literal_length: u32 = (c >> 2) + 1;

            if (literal_length >= 61) {
                // Long literal - length encoded in following bytes
                const extra_bytes = literal_length - 60;
                if (ip + extra_bytes > compressed.len) return error.TruncatedInput;

                literal_length = 1;
                var i: u32 = 0;
                while (i < extra_bytes) : (i += 1) {
                    literal_length += @as(u32, compressed[ip + i]) << @intCast(i * 8);
                }
                ip += extra_bytes;
            }

            // Copy literal bytes
            if (ip + literal_length > compressed.len) return error.TruncatedInput;
            if (op + literal_length > uncompressed_len) return error.OutputOverflow;

            @memcpy(output[op .. op + literal_length], compressed[ip .. ip + literal_length]);
            ip += literal_length;
            op += literal_length;
        } else {
            // COPY - use lookup table
            const entry = snappy_char_table[c];
            const extra_bytes = entry >> 11;
            const length = entry & 0xff;
            const offset_high = entry & 0x700;

            if (ip + extra_bytes > compressed.len) return error.TruncatedInput;

            // Read trailer bytes (little-endian offset)
            var trailer: u32 = 0;
            if (extra_bytes > 0) {
                var i: u32 = 0;
                while (i < extra_bytes) : (i += 1) {
                    trailer |= @as(u32, compressed[ip + i]) << @intCast(i * 8);
                }
            }
            ip += extra_bytes;

            const copy_offset = offset_high + trailer;
            if (copy_offset == 0 or copy_offset > op) return error.InvalidCopyOffset;
            if (op + length > uncompressed_len) return error.OutputOverflow;

            // Copy from earlier in output (may overlap)
            const src_start = op - copy_offset;
            var i: u32 = 0;
            while (i < length) : (i += 1) {
                output[op + i] = output[src_start + (i % copy_offset)];
            }
            op += length;
        }
    }

    if (op != uncompressed_len) {
        log.warn("Snappy: output size mismatch: expected {}, got {}", .{ uncompressed_len, op });
        return error.OutputSizeMismatch;
    }

    log.debug("Snappy: decompressed {} bytes to {} bytes", .{ compressed.len, uncompressed_len });
    return output;
}

// ============================================================================
// GZIP Decompression (using Zig std library)
// ============================================================================

pub fn decompressGzip(allocator: mem.Allocator, compressed: []const u8) ![]u8 {
    var stream = std.io.fixedBufferStream(compressed);
    var decompressor = std.compress.gzip.decompressor(stream.reader());

    var output = std.array_list.Managed(u8).init(allocator);
    errdefer output.deinit();

    // Read all decompressed data
    var buf: [4096]u8 = undefined;
    while (true) {
        const n = decompressor.read(&buf) catch |err| {
            log.warn("GZIP decompression error: {any}", .{err});
            return error.GzipDecompressError;
        };
        if (n == 0) break;
        try output.appendSlice(buf[0..n]);
    }

    log.debug("GZIP: decompressed {} bytes to {} bytes", .{ compressed.len, output.items.len });
    return try output.toOwnedSlice();
}

// ============================================================================
// ZSTD Decompression
// TODO: Implement ZSTD decompression (requires window_buffer setup)
// ============================================================================

// ============================================================================
// Tests
// ============================================================================

test "Snappy varint decode" {
    // Test single-byte varints
    const v1 = try readSnappyVarint(&[_]u8{0x00});
    try std.testing.expectEqual(@as(u32, 0), v1.value);
    try std.testing.expectEqual(@as(usize, 1), v1.bytes_read);

    const v2 = try readSnappyVarint(&[_]u8{0x7f});
    try std.testing.expectEqual(@as(u32, 127), v2.value);

    // Test multi-byte varints
    const v3 = try readSnappyVarint(&[_]u8{ 0x80, 0x01 });
    try std.testing.expectEqual(@as(u32, 128), v3.value);
    try std.testing.expectEqual(@as(usize, 2), v3.bytes_read);

    const v4 = try readSnappyVarint(&[_]u8{ 0xAC, 0x02 });
    try std.testing.expectEqual(@as(u32, 300), v4.value);
}

test "Snappy decompress literal only" {
    // Simple literal-only compressed data:
    // [uncompressed_len=5] [literal tag: len=5] [h e l l o]
    const compressed = [_]u8{
        0x05, // uncompressed length = 5
        0x10, // literal tag: (4 << 2) | 0 = 16, meaning length = 4+1 = 5
        'h',
        'e',
        'l',
        'l',
        'o',
    };

    const decompressed = try decompressSnappy(std.testing.allocator, &compressed);
    defer std.testing.allocator.free(decompressed);

    try std.testing.expectEqualSlices(u8, "hello", decompressed);
}

test "CompressionCodec from attributes" {
    try std.testing.expectEqual(CompressionCodec.none, CompressionCodec.fromAttributes(0));
    try std.testing.expectEqual(CompressionCodec.gzip, CompressionCodec.fromAttributes(1));
    try std.testing.expectEqual(CompressionCodec.snappy, CompressionCodec.fromAttributes(2));
    try std.testing.expectEqual(CompressionCodec.lz4, CompressionCodec.fromAttributes(3));
    try std.testing.expectEqual(CompressionCodec.zstd, CompressionCodec.fromAttributes(4));

    // Test with other attribute bits set
    try std.testing.expectEqual(CompressionCodec.snappy, CompressionCodec.fromAttributes(0x0102)); // bits 8 set
}
