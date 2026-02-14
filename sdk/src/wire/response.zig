const std = @import("std");
const types = @import("kafka_generated").types;
const ResponseHeader = @import("kafka_generated").response_header.ResponseHeader;
const request = @import("request.zig");

/// Decoded response frame metadata.
pub const ResponseFrame = struct {
    /// Correlation ID from the response header.
    correlation_id: i32,
    /// Offset into the original buffer where the response body begins.
    body_offset: usize,
    /// Length of the response body bytes.
    body_len: usize,
};

/// Decode a Kafka response frame from wire bytes.
///
/// Wire format:
///   [4 bytes] message_size (big-endian i32)
///   [N bytes] ResponseHeader (v0 or v1)
///   [M bytes] Response body
///
/// This function parses the size prefix and response header, returning
/// the correlation_id and the byte range of the body so the caller can
/// decode the appropriate generated response type.
///
/// `data` must contain at least the 4-byte size prefix. The function
/// validates that `data` contains the full message.
pub fn decodeResponseFrame(
    data: []const u8,
    api_key: i16,
    api_version: i16,
    allocator: std.mem.Allocator,
) !ResponseFrame {
    if (data.len < 4) {
        return error.ProtocolError;
    }

    // Read 4-byte message size prefix
    var stream = std.io.fixedBufferStream(data);
    const reader = stream.reader();

    const message_size = try types.decodeInt32(reader);
    if (message_size < 0) {
        return error.ProtocolError;
    }

    const msg_size: usize = @intCast(message_size);
    if (data.len < 4 + msg_size) {
        return error.ProtocolError;
    }

    // Decode response header
    const resp_header_version = request.responseHeaderVersion(api_key, api_version);
    const resp_header = try ResponseHeader.decode(reader, resp_header_version, allocator);

    const body_offset = stream.pos;
    const body_len = (4 + msg_size) - body_offset;

    return ResponseFrame{
        .correlation_id = resp_header.correlation_id,
        .body_offset = body_offset,
        .body_len = body_len,
    };
}

/// Read a complete response frame from a stream reader.
/// Reads exactly 4 + message_size bytes into `buffer`.
/// Returns the number of bytes read.
pub fn readResponseFrame(reader: anytype, buffer: []u8) !usize {
    // Read the 4-byte size prefix
    if (buffer.len < 4) {
        return error.BufferExhausted;
    }
    try reader.readNoEof(buffer[0..4]);

    const message_size = std.mem.readInt(i32, buffer[0..4], .big);
    if (message_size < 0 or message_size > 100 * 1024 * 1024) {
        return error.ProtocolError;
    }

    const msg_size: usize = @intCast(message_size);
    const total = 4 + msg_size;
    if (total > buffer.len) {
        return error.BufferExhausted;
    }

    // Read the rest of the message
    try reader.readNoEof(buffer[4..total]);

    return total;
}

// ============================================================================
// Tests
// ============================================================================

test "decodeResponseFrame non-flexible" {
    // Construct a minimal Produce v3 response:
    // [4 bytes] message_size = 4 (just the correlation_id)
    // [4 bytes] correlation_id = 42
    var buf: [8]u8 = undefined;
    std.mem.writeInt(i32, buf[0..4], 4, .big); // message_size = 4
    std.mem.writeInt(i32, buf[4..8], 42, .big); // correlation_id = 42

    const frame = try decodeResponseFrame(&buf, 0, 3, std.testing.allocator);
    try std.testing.expectEqual(@as(i32, 42), frame.correlation_id);
    try std.testing.expectEqual(@as(usize, 8), frame.body_offset);
    try std.testing.expectEqual(@as(usize, 0), frame.body_len);
}

test "decodeResponseFrame flexible" {
    // Construct a minimal Produce v9 response (flexible):
    // ResponseHeader v1 = correlation_id (4) + tagged_fields (varint 0 = 1 byte)
    // [4 bytes] message_size = 5
    // [4 bytes] correlation_id = 99
    // [1 byte]  tagged_fields count = 0
    var buf: [9]u8 = undefined;
    std.mem.writeInt(i32, buf[0..4], 5, .big);
    std.mem.writeInt(i32, buf[4..8], 99, .big);
    buf[8] = 0; // zero tagged fields

    const frame = try decodeResponseFrame(&buf, 0, 9, std.testing.allocator);
    try std.testing.expectEqual(@as(i32, 99), frame.correlation_id);
    try std.testing.expectEqual(@as(usize, 9), frame.body_offset);
    try std.testing.expectEqual(@as(usize, 0), frame.body_len);
}

test "decodeResponseFrame truncated" {
    // Only 3 bytes - not enough for size prefix
    var buf = [_]u8{ 0, 0, 0 };
    const result = decodeResponseFrame(&buf, 0, 3, std.testing.allocator);
    try std.testing.expectError(error.ProtocolError, result);
}

test "readResponseFrame" {
    // Build a fake response: size=4, correlation_id=7
    var wire: [8]u8 = undefined;
    std.mem.writeInt(i32, wire[0..4], 4, .big);
    std.mem.writeInt(i32, wire[4..8], 7, .big);

    var stream = std.io.fixedBufferStream(&wire);
    var recv_buf: [256]u8 = undefined;
    const n = try readResponseFrame(stream.reader(), &recv_buf);
    try std.testing.expectEqual(@as(usize, 8), n);
    try std.testing.expectEqual(@as(i32, 7), std.mem.readInt(i32, recv_buf[4..8], .big));
}

test "decodeResponseFrame negative message size" {
    var buf: [8]u8 = undefined;
    std.mem.writeInt(i32, buf[0..4], -1, .big); // Negative size
    std.mem.writeInt(i32, buf[4..8], 0, .big);

    const result = decodeResponseFrame(&buf, 0, 3, std.testing.allocator);
    try std.testing.expectError(error.ProtocolError, result);
}

test "decodeResponseFrame size exceeds data" {
    var buf: [8]u8 = undefined;
    std.mem.writeInt(i32, buf[0..4], 100, .big); // Claims 100 bytes but only 4 available
    std.mem.writeInt(i32, buf[4..8], 0, .big);

    const result = decodeResponseFrame(&buf, 0, 3, std.testing.allocator);
    try std.testing.expectError(error.ProtocolError, result);
}

test "decodeResponseFrame with body" {
    // Response with correlation_id and some body bytes
    var buf: [16]u8 = undefined;
    std.mem.writeInt(i32, buf[0..4], 12, .big); // 12 bytes after size prefix
    std.mem.writeInt(i32, buf[4..8], 55, .big); // correlation_id = 55
    // 8 bytes of body data
    @memset(buf[8..16], 0xAB);

    const frame = try decodeResponseFrame(&buf, 0, 3, std.testing.allocator);
    try std.testing.expectEqual(@as(i32, 55), frame.correlation_id);
    try std.testing.expectEqual(@as(usize, 8), frame.body_offset);
    try std.testing.expectEqual(@as(usize, 8), frame.body_len);
}

test "readResponseFrame buffer too small" {
    var wire: [8]u8 = undefined;
    std.mem.writeInt(i32, wire[0..4], 100, .big); // Claims 100 bytes

    var stream = std.io.fixedBufferStream(&wire);
    var recv_buf: [8]u8 = undefined; // Only 8 bytes available
    const result = readResponseFrame(stream.reader(), &recv_buf);
    try std.testing.expectError(error.BufferExhausted, result);
}

test "readResponseFrame negative size" {
    var wire: [8]u8 = undefined;
    std.mem.writeInt(i32, wire[0..4], -5, .big); // Negative

    var stream = std.io.fixedBufferStream(&wire);
    var recv_buf: [256]u8 = undefined;
    const result = readResponseFrame(stream.reader(), &recv_buf);
    try std.testing.expectError(error.ProtocolError, result);
}

test "readResponseFrame too large" {
    var wire: [8]u8 = undefined;
    // 200MB - over the 100MB limit
    std.mem.writeInt(i32, wire[0..4], 200 * 1024 * 1024, .big);

    var stream = std.io.fixedBufferStream(&wire);
    var recv_buf: [256]u8 = undefined;
    const result = readResponseFrame(stream.reader(), &recv_buf);
    try std.testing.expectError(error.ProtocolError, result);
}
