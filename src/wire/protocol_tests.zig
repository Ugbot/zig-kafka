//! Wire protocol encoding/decoding tests.
//!
//! Matches librdkafka's unit test coverage for:
//!   - rdvarint: Variable-length integer encode/decode roundtrips
//!   - crc32c: CRC32C checksum verification
//!   - RecordBatch: Batch building, finalization, CRC integrity
//!   - Wire framing: Request/response frame structure
//!   - Compact types: Compact strings, arrays (flexible versions)

const std = @import("std");
const types = @import("kafka_generated").types;
const record_batch = @import("kafka_generated").record_batch;
const RecordBatchBuilder = record_batch.RecordBatchBuilder;
const crc32c = record_batch.crc32c;
const request_mod = @import("request.zig");
const RequestHeader = @import("kafka_generated").request_header.RequestHeader;
const ApiVersionsRequest = @import("kafka_generated").api_versions_request.ApiVersionsRequest;
const MetadataRequest = @import("kafka_generated").metadata_request.MetadataRequest;
const ProduceRequest = @import("kafka_generated").produce_request.ProduceRequest;

// ============================================================================
// Varint Encode/Decode Roundtrips (matches librdkafka rdvarint tests)
// ============================================================================

test "varint: unsigned encode/decode roundtrip" {
    const test_values = [_]u32{
        0,
        1,
        127,
        128,
        255,
        256,
        16383,
        16384,
        2097151,
        2097152,
        268435455,
        268435456,
        std.math.maxInt(u32),
    };

    for (test_values) |value| {
        var buf: [10]u8 = undefined;
        var write_stream = std.io.fixedBufferStream(&buf);
        try types.encodeUnsignedVarInt(write_stream.writer(), value);

        const written = write_stream.pos;
        var read_stream = std.io.fixedBufferStream(buf[0..written]);
        const decoded = try types.decodeUnsignedVarInt(read_stream.reader());

        try std.testing.expectEqual(value, decoded);
    }
}

test "varint: unsigned encoding size" {
    // 0-127 → 1 byte
    // 128-16383 → 2 bytes
    // 16384-2097151 → 3 bytes
    // 2097152-268435455 → 4 bytes
    // 268435456+ → 5 bytes
    const cases = [_]struct { value: u32, expected_size: usize }{
        .{ .value = 0, .expected_size = 1 },
        .{ .value = 1, .expected_size = 1 },
        .{ .value = 127, .expected_size = 1 },
        .{ .value = 128, .expected_size = 2 },
        .{ .value = 16383, .expected_size = 2 },
        .{ .value = 16384, .expected_size = 3 },
        .{ .value = 2097151, .expected_size = 3 },
        .{ .value = 2097152, .expected_size = 4 },
        .{ .value = 268435455, .expected_size = 4 },
        .{ .value = 268435456, .expected_size = 5 },
        .{ .value = std.math.maxInt(u32), .expected_size = 5 },
    };

    for (cases) |case| {
        var buf: [10]u8 = undefined;
        var stream = std.io.fixedBufferStream(&buf);
        try types.encodeUnsignedVarInt(stream.writer(), case.value);
        try std.testing.expectEqual(case.expected_size, stream.pos);
    }
}

test "varint: signed zigzag encode/decode roundtrip" {
    // ZigZag encoding: 0→0, -1→1, 1→2, -2→3, 2→4 ...
    const test_values = [_]i32{
        0,
        1,
        -1,
        2,
        -2,
        23,
        -23,
        127,
        -128,
        255,
        -256,
        1000,
        -1000,
        1234567,
        -1234567,
        std.math.maxInt(i32),
        std.math.minInt(i32),
    };

    for (test_values) |value| {
        var buf: [10]u8 = undefined;
        var write_stream = std.io.fixedBufferStream(&buf);
        try types.encodeVarInt(write_stream.writer(), value);

        const written = write_stream.pos;
        var read_stream = std.io.fixedBufferStream(buf[0..written]);
        const decoded = try types.decodeVarInt(read_stream.reader());

        try std.testing.expectEqual(value, decoded);
    }
}

test "varint: signed zigzag specific encodings" {
    // Verify the zigzag mapping matches Kafka spec
    const cases = [_]struct { input: i32, zigzag: u32 }{
        .{ .input = 0, .zigzag = 0 },
        .{ .input = -1, .zigzag = 1 },
        .{ .input = 1, .zigzag = 2 },
        .{ .input = -2, .zigzag = 3 },
        .{ .input = 2, .zigzag = 4 },
        .{ .input = -64, .zigzag = 127 },
        .{ .input = 64, .zigzag = 128 },
    };

    for (cases) |case| {
        const encoded: u32 = @bitCast((case.input << 1) ^ (case.input >> 31));
        try std.testing.expectEqual(case.zigzag, encoded);
    }
}

test "varint: i64 varlong encode/decode roundtrip" {
    const test_values = [_]i64{
        0,
        1,
        -1,
        127,
        -128,
        32767,
        -32768,
        2147483647,
        -2147483648,
        1234567890101112,
        -1234567890101112,
        std.math.maxInt(i64),
        std.math.minInt(i64),
    };

    for (test_values) |value| {
        var buf: [20]u8 = undefined;
        var write_stream = std.io.fixedBufferStream(&buf);
        try types.encodeVarLong(write_stream.writer(), value);

        const written = write_stream.pos;
        var read_stream = std.io.fixedBufferStream(buf[0..written]);
        const decoded = try types.decodeVarLong(read_stream.reader());

        try std.testing.expectEqual(value, decoded);
    }
}

// ============================================================================
// Primitive Type Roundtrips
// ============================================================================

test "primitive: int16 encode/decode roundtrip" {
    const values = [_]i16{ 0, 1, -1, 127, -128, 32767, -32768 };
    for (values) |v| {
        var buf: [2]u8 = undefined;
        var ws = std.io.fixedBufferStream(&buf);
        try types.encodeInt16(ws.writer(), v);
        var rs = std.io.fixedBufferStream(&buf);
        try std.testing.expectEqual(v, try types.decodeInt16(rs.reader()));
    }
}

test "primitive: int32 encode/decode roundtrip" {
    const values = [_]i32{ 0, 1, -1, 2147483647, -2147483648, 42, -99 };
    for (values) |v| {
        var buf: [4]u8 = undefined;
        var ws = std.io.fixedBufferStream(&buf);
        try types.encodeInt32(ws.writer(), v);
        var rs = std.io.fixedBufferStream(&buf);
        try std.testing.expectEqual(v, try types.decodeInt32(rs.reader()));
    }
}

test "primitive: int64 encode/decode roundtrip" {
    const values = [_]i64{ 0, 1, -1, std.math.maxInt(i64), std.math.minInt(i64), 1609459200000 };
    for (values) |v| {
        var buf: [8]u8 = undefined;
        var ws = std.io.fixedBufferStream(&buf);
        try types.encodeInt64(ws.writer(), v);
        var rs = std.io.fixedBufferStream(&buf);
        try std.testing.expectEqual(v, try types.decodeInt64(rs.reader()));
    }
}

test "primitive: boolean encode/decode" {
    var buf: [1]u8 = undefined;

    var ws = std.io.fixedBufferStream(&buf);
    try types.encodeBoolean(ws.writer(), true);
    var rs = std.io.fixedBufferStream(&buf);
    try std.testing.expectEqual(true, try types.decodeBoolean(rs.reader()));

    ws = std.io.fixedBufferStream(&buf);
    try types.encodeBoolean(ws.writer(), false);
    rs = std.io.fixedBufferStream(&buf);
    try std.testing.expectEqual(false, try types.decodeBoolean(rs.reader()));
}

test "primitive: float64 encode/decode" {
    const values = [_]f64{ 0.0, 1.0, -1.0, 3.14159, std.math.inf(f64) };
    for (values) |v| {
        var buf: [8]u8 = undefined;
        var ws = std.io.fixedBufferStream(&buf);
        try types.encodeFloat64(ws.writer(), v);
        var rs = std.io.fixedBufferStream(&buf);
        try std.testing.expectEqual(v, try types.decodeFloat64(rs.reader()));
    }
}

test "primitive: uuid encode/decode" {
    const uuid = [16]u8{ 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x10 };
    var buf: [16]u8 = undefined;
    var ws = std.io.fixedBufferStream(&buf);
    try types.encodeUuid(ws.writer(), uuid);
    var rs = std.io.fixedBufferStream(&buf);
    const decoded = try types.decodeUuid(rs.reader());
    try std.testing.expectEqualSlices(u8, &uuid, &decoded);
}

// ============================================================================
// String/Bytes Encoding (matches librdkafka string tests)
// ============================================================================

test "string: nullable encode/decode" {
    var buf: [256]u8 = undefined;
    var ws = std.io.fixedBufferStream(&buf);
    try types.encodeString(ws.writer(), "hello");
    var rs = std.io.fixedBufferStream(buf[0..ws.pos]);
    const decoded = try types.decodeString(rs.reader(), std.testing.allocator);
    defer if (decoded) |d| std.testing.allocator.free(d);
    try std.testing.expectEqualStrings("hello", decoded.?);
}

test "string: null string encode/decode" {
    var buf: [256]u8 = undefined;
    var ws = std.io.fixedBufferStream(&buf);
    try types.encodeString(ws.writer(), null);
    var rs = std.io.fixedBufferStream(buf[0..ws.pos]);
    const decoded = try types.decodeString(rs.reader(), std.testing.allocator);
    try std.testing.expectEqual(@as(?[]const u8, null), decoded);
}

test "string: empty string" {
    var buf: [256]u8 = undefined;
    var ws = std.io.fixedBufferStream(&buf);
    try types.encodeString(ws.writer(), "");
    var rs = std.io.fixedBufferStream(buf[0..ws.pos]);
    const decoded = try types.decodeString(rs.reader(), std.testing.allocator);
    try std.testing.expectEqualStrings("", decoded.?);
}

test "bytes: nullable encode/decode" {
    var buf: [256]u8 = undefined;
    const data = "binary\x00data";
    var ws = std.io.fixedBufferStream(&buf);
    try types.encodeBytes(ws.writer(), data);
    var rs = std.io.fixedBufferStream(buf[0..ws.pos]);
    const decoded = try types.decodeBytes(rs.reader(), std.testing.allocator);
    defer if (decoded) |d| std.testing.allocator.free(d);
    try std.testing.expectEqualSlices(u8, data, decoded.?);
}

test "bytes: null bytes" {
    var buf: [256]u8 = undefined;
    var ws = std.io.fixedBufferStream(&buf);
    try types.encodeBytes(ws.writer(), null);
    var rs = std.io.fixedBufferStream(buf[0..ws.pos]);
    const decoded = try types.decodeBytes(rs.reader(), std.testing.allocator);
    try std.testing.expectEqual(@as(?[]const u8, null), decoded);
}

// ============================================================================
// Compact String/Array (flexible version types)
// ============================================================================

test "compact string: encode/decode roundtrip" {
    var buf: [256]u8 = undefined;
    var ws = std.io.fixedBufferStream(&buf);
    try types.encodeCompactString(ws.writer(), "compact-test");
    var rs = std.io.fixedBufferStream(buf[0..ws.pos]);
    const decoded = try types.decodeCompactString(rs.reader(), std.testing.allocator);
    defer if (decoded) |d| std.testing.allocator.free(d);
    try std.testing.expectEqualStrings("compact-test", decoded.?);
}

test "compact string: null" {
    var buf: [256]u8 = undefined;
    var ws = std.io.fixedBufferStream(&buf);
    try types.encodeCompactString(ws.writer(), null);
    var rs = std.io.fixedBufferStream(buf[0..ws.pos]);
    const decoded = try types.decodeCompactString(rs.reader(), std.testing.allocator);
    try std.testing.expectEqual(@as(?[]const u8, null), decoded);
}

test "compact array length: encode/decode" {
    // Non-null array with 5 elements
    var buf: [10]u8 = undefined;
    var ws = std.io.fixedBufferStream(&buf);
    const items = [_]u8{ 1, 2, 3, 4, 5 };
    try types.encodeCompactArrayLen(ws.writer(), @as(?[]const u8, &items));
    var rs = std.io.fixedBufferStream(buf[0..ws.pos]);
    const decoded_len = try types.decodeCompactArrayLen(rs.reader());
    try std.testing.expectEqual(@as(usize, 5), decoded_len);
}

test "compact array length: null" {
    var buf: [10]u8 = undefined;
    var ws = std.io.fixedBufferStream(&buf);
    try types.encodeCompactArrayLen(ws.writer(), @as(?[]const u8, null));
    var rs = std.io.fixedBufferStream(buf[0..ws.pos]);
    const decoded_len = try types.decodeCompactArrayLen(rs.reader());
    try std.testing.expectEqual(@as(usize, 0), decoded_len);
}

// ============================================================================
// CRC32C (matches librdkafka crc32c tests)
// ============================================================================

test "crc32c: standard test vector" {
    // RFC 3720 / iSCSI test vector
    const result = crc32c("123456789");
    try std.testing.expectEqual(@as(u32, 0xE3069283), result);
}

test "crc32c: empty data" {
    const result = crc32c("");
    try std.testing.expectEqual(@as(u32, 0), result);
}

test "crc32c: single byte values" {
    // Verify deterministic for single bytes
    const a = crc32c("a");
    const b = crc32c("b");
    try std.testing.expect(a != b);
    // Same input = same output
    try std.testing.expectEqual(a, crc32c("a"));
}

test "crc32c: known vectors" {
    // Additional test vectors
    try std.testing.expectEqual(@as(u32, 0), crc32c(&[_]u8{}));
    const all_zeros = [_]u8{0} ** 32;
    const crc_zeros = crc32c(&all_zeros);
    try std.testing.expect(crc_zeros != 0);

    const all_ff = [_]u8{0xFF} ** 32;
    const crc_ff = crc32c(&all_ff);
    try std.testing.expect(crc_ff != crc_zeros);
}

test "crc32c: incremental equivalence" {
    // CRC of "abcdef" computed at once should differ from CRC of parts
    // (CRC32C is not simply additive, this verifies our table-based impl)
    const full = crc32c("abcdef");
    const part1 = crc32c("abc");
    const part2 = crc32c("def");
    // Full CRC != simple combination of parts (CRC is not linear)
    try std.testing.expect(full != part1 ^ part2);
}

// ============================================================================
// RecordBatch Building (matches librdkafka msg tests)
// ============================================================================

test "record batch: empty finalize" {
    var buf: [1024]u8 = undefined;
    var builder = RecordBatchBuilder.init(&buf, 0, 1000);
    const batch = try builder.finalize();

    // Minimum size is 61 bytes (header only)
    try std.testing.expectEqual(@as(usize, 61), batch.len);

    // Magic byte = 2
    try std.testing.expectEqual(@as(u8, 2), batch[16]);

    // Record count = 0
    const count = std.mem.readInt(i32, batch[57..61], .big);
    try std.testing.expectEqual(@as(i32, 0), count);
}

test "record batch: single record structure" {
    var buf: [1024]u8 = undefined;
    var builder = RecordBatchBuilder.init(&buf, 0, 1000);
    try builder.addRecord("key", "value", 1000);
    const batch = try builder.finalize();

    // baseOffset
    try std.testing.expectEqual(@as(i64, 0), std.mem.readInt(i64, batch[0..8], .big));
    // batchLength > 0
    try std.testing.expect(std.mem.readInt(i32, batch[8..12], .big) > 0);
    // partitionLeaderEpoch
    try std.testing.expectEqual(@as(i32, 0), std.mem.readInt(i32, batch[12..16], .big));
    // magic = 2
    try std.testing.expectEqual(@as(u8, 2), batch[16]);
    // attributes = 0 (no compression, CreateTime, not transactional)
    try std.testing.expectEqual(@as(i16, 0), std.mem.readInt(i16, batch[21..23], .big));
    // lastOffsetDelta = 0 (one record, so delta is 0)
    try std.testing.expectEqual(@as(i32, 0), std.mem.readInt(i32, batch[23..27], .big));
    // baseTimestamp
    try std.testing.expectEqual(@as(i64, 1000), std.mem.readInt(i64, batch[27..35], .big));
    // producerId = -1
    try std.testing.expectEqual(@as(i64, -1), std.mem.readInt(i64, batch[43..51], .big));
    // producerEpoch = -1
    try std.testing.expectEqual(@as(i16, -1), std.mem.readInt(i16, batch[51..53], .big));
    // baseSequence = -1
    try std.testing.expectEqual(@as(i32, -1), std.mem.readInt(i32, batch[53..57], .big));
    // record count = 1
    try std.testing.expectEqual(@as(i32, 1), std.mem.readInt(i32, batch[57..61], .big));
}

test "record batch: CRC integrity" {
    var buf: [4096]u8 = undefined;
    var builder = RecordBatchBuilder.init(&buf, 0, 1000);
    try builder.addRecord("key1", "value1", 1000);
    try builder.addRecord("key2", "value2", 1001);
    try builder.addRecord(null, "value3", 1002);
    const batch = try builder.finalize();

    // Extract CRC from batch header (bytes 17-20)
    const stored_crc = std.mem.readInt(u32, batch[17..21], .big);

    // Recalculate CRC over attributes through end (bytes 21..batch.len)
    const computed_crc = crc32c(batch[21..]);

    try std.testing.expectEqual(stored_crc, computed_crc);
}

test "record batch: multiple records count" {
    var buf: [4096]u8 = undefined;
    var builder = RecordBatchBuilder.init(&buf, 100, 5000);

    var i: usize = 0;
    while (i < 10) : (i += 1) {
        var key_buf: [16]u8 = undefined;
        const key = std.fmt.bufPrint(&key_buf, "k{d}", .{i}) catch unreachable;
        try builder.addRecord(key, "test-value", 5000 + @as(i64, @intCast(i)));
    }

    const batch = try builder.finalize();
    const count = std.mem.readInt(i32, batch[57..61], .big);
    try std.testing.expectEqual(@as(i32, 10), count);

    const base_offset = std.mem.readInt(i64, batch[0..8], .big);
    try std.testing.expectEqual(@as(i64, 100), base_offset);
}

test "record batch: null key encoding" {
    var buf: [1024]u8 = undefined;
    var builder = RecordBatchBuilder.init(&buf, 0, 1000);
    try builder.addRecord(null, "value-with-null-key", 1000);
    const batch = try builder.finalize();

    // Should finalize without error and have 1 record
    const count = std.mem.readInt(i32, batch[57..61], .big);
    try std.testing.expectEqual(@as(i32, 1), count);

    // CRC should still be valid
    const stored_crc = std.mem.readInt(u32, batch[17..21], .big);
    const computed_crc = crc32c(batch[21..]);
    try std.testing.expectEqual(stored_crc, computed_crc);
}

test "record batch: timestamp tracking" {
    var buf: [4096]u8 = undefined;
    var builder = RecordBatchBuilder.init(&buf, 0, 1000);
    try builder.addRecord("k1", "v1", 1000);
    try builder.addRecord("k2", "v2", 1500);
    try builder.addRecord("k3", "v3", 1200); // Out of order timestamp
    const batch = try builder.finalize();

    // baseTimestamp = 1000
    try std.testing.expectEqual(@as(i64, 1000), std.mem.readInt(i64, batch[27..35], .big));
    // maxTimestamp = 1500 (tracks the max)
    try std.testing.expectEqual(@as(i64, 1500), std.mem.readInt(i64, batch[35..43], .big));
}

test "record batch: buffer too small" {
    // Buffer too small to hold even the header
    var tiny_buf: [30]u8 = undefined;
    var builder = RecordBatchBuilder.init(&tiny_buf, 0, 1000);
    const result = builder.addRecord("key", "value", 1000);
    try std.testing.expectError(error.BufferTooSmall, result);
}

test "record batch: large batch fills buffer" {
    var buf: [4096]u8 = undefined;
    var builder = RecordBatchBuilder.init(&buf, 0, 1000);

    // Add records until buffer is full
    var count: i32 = 0;
    while (true) {
        builder.addRecord("key", "value-data-for-filling-the-buffer", 1000) catch break;
        count += 1;
    }

    // Should have added at least some records
    try std.testing.expect(count > 0);

    // Finalize should work with the records that fit
    const batch = try builder.finalize();
    const batch_count = std.mem.readInt(i32, batch[57..61], .big);
    try std.testing.expectEqual(count, batch_count);
}

// ============================================================================
// Request Frame Encoding (matches librdkafka request tests)
// ============================================================================

test "request frame: ApiVersions v3 structure" {
    var buf: [1024]u8 = undefined;
    var req = ApiVersionsRequest{
        .client_software_name = "test-client",
        .client_software_version = "1.0.0",
    };

    const size = try request_mod.encodeRequest(&buf, 18, 3, 1, "my-client", &req);

    // Size prefix (4 bytes)
    const msg_size = std.mem.readInt(i32, buf[0..4], .big);
    try std.testing.expectEqual(@as(usize, @intCast(msg_size)), size - 4);

    // API key = 18
    try std.testing.expectEqual(@as(i16, 18), std.mem.readInt(i16, buf[4..6], .big));
    // API version = 3
    try std.testing.expectEqual(@as(i16, 3), std.mem.readInt(i16, buf[6..8], .big));
    // Correlation ID = 1
    try std.testing.expectEqual(@as(i32, 1), std.mem.readInt(i32, buf[8..12], .big));
}

test "request frame: Metadata v1 (classic) structure" {
    var buf: [1024]u8 = undefined;
    var req = MetadataRequest{
        .topics = null,
    };

    const size = try request_mod.encodeRequest(&buf, 3, 1, 42, "test", &req);

    // API key = 3
    try std.testing.expectEqual(@as(i16, 3), std.mem.readInt(i16, buf[4..6], .big));
    // API version = 1
    try std.testing.expectEqual(@as(i16, 1), std.mem.readInt(i16, buf[6..8], .big));
    // Correlation ID = 42
    try std.testing.expectEqual(@as(i32, 42), std.mem.readInt(i32, buf[8..12], .big));
    // Total size > header
    try std.testing.expect(size > 12);
}

test "request frame: correlation ID uniqueness" {
    var buf: [1024]u8 = undefined;
    var req = ApiVersionsRequest{};

    // Two requests with different correlation IDs
    _ = try request_mod.encodeRequest(&buf, 18, 3, 100, "c", &req);
    const corr1 = std.mem.readInt(i32, buf[8..12], .big);

    _ = try request_mod.encodeRequest(&buf, 18, 3, 200, "c", &req);
    const corr2 = std.mem.readInt(i32, buf[8..12], .big);

    try std.testing.expectEqual(@as(i32, 100), corr1);
    try std.testing.expectEqual(@as(i32, 200), corr2);
    try std.testing.expect(corr1 != corr2);
}

test "request frame: header version selection" {
    // Flexible APIs use header v2, classic use v1
    // ApiVersions v3 → header v2
    try std.testing.expectEqual(@as(i16, 2), request_mod.requestHeaderVersion(18, 3));
    // ApiVersions v0 → header v1
    try std.testing.expectEqual(@as(i16, 1), request_mod.requestHeaderVersion(18, 0));
    // Produce v8 (classic) → header v1
    try std.testing.expectEqual(@as(i16, 1), request_mod.requestHeaderVersion(0, 8));
    // Produce v9 (flexible) → header v2
    try std.testing.expectEqual(@as(i16, 2), request_mod.requestHeaderVersion(0, 9));
    // Fetch v11 (classic) → header v1
    try std.testing.expectEqual(@as(i16, 1), request_mod.requestHeaderVersion(1, 11));
    // Fetch v12 (flexible) → header v2
    try std.testing.expectEqual(@as(i16, 2), request_mod.requestHeaderVersion(1, 12));
}

test "request frame: response header version for ApiVersions" {
    // ApiVersions always uses response header v0
    try std.testing.expectEqual(@as(i16, 0), request_mod.responseHeaderVersion(18, 0));
    try std.testing.expectEqual(@as(i16, 0), request_mod.responseHeaderVersion(18, 3));
    try std.testing.expectEqual(@as(i16, 0), request_mod.responseHeaderVersion(18, 4));
}

test "request frame: Produce v9 flexible encoding" {
    var buf: [1024]u8 = undefined;
    const TopicProduceData = @import("kafka_generated").produce_request.TopicProduceData;
    const PartitionProduceData = @import("kafka_generated").produce_request.PartitionProduceData;

    // Build a minimal produce request
    var batch_buf: [256]u8 = undefined;
    var builder = RecordBatchBuilder.init(&batch_buf, 0, 1000);
    try builder.addRecord("k", "v", 1000);
    const batch = try builder.finalize();

    var part_data = [_]PartitionProduceData{
        .{ .index = 0, .records = batch },
    };
    var topic_data = [_]TopicProduceData{
        .{ .name = "test-topic", .partition_data = &part_data },
    };
    var req = ProduceRequest{
        .acks = -1,
        .timeout_ms = 5000,
        .topic_data = &topic_data,
    };

    const size = try request_mod.encodeRequest(&buf, 0, 9, 1, "c", &req);
    try std.testing.expect(size > 0);

    // Verify it's a valid frame
    const msg_size = std.mem.readInt(i32, buf[0..4], .big);
    try std.testing.expectEqual(@as(usize, @intCast(msg_size)), size - 4);
}

// ============================================================================
// Array Encoding (matches librdkafka rdbuf tests for structured data)
// ============================================================================

test "array length: nullable null" {
    var buf: [10]u8 = undefined;
    var ws = std.io.fixedBufferStream(&buf);
    try types.encodeArrayLen(ws.writer(), @as(?[]const u8, null));
    var rs = std.io.fixedBufferStream(buf[0..ws.pos]);
    const len_i32 = try types.decodeInt32(rs.reader());
    try std.testing.expectEqual(@as(i32, -1), len_i32);
}

test "array length: non-null" {
    var buf: [10]u8 = undefined;
    const items = [_]u8{ 1, 2, 3 };
    var ws = std.io.fixedBufferStream(&buf);
    try types.encodeArrayLen(ws.writer(), @as(?[]const u8, &items));
    var rs = std.io.fixedBufferStream(buf[0..ws.pos]);
    const len_i32 = try types.decodeInt32(rs.reader());
    try std.testing.expectEqual(@as(i32, 3), len_i32);
}

test "array length: non-nullable null encodes as 0" {
    var buf: [10]u8 = undefined;
    var ws = std.io.fixedBufferStream(&buf);
    try types.encodeArrayLenNonNull(ws.writer(), @as(?[]const u8, null));
    var rs = std.io.fixedBufferStream(buf[0..ws.pos]);
    const len_i32 = try types.decodeInt32(rs.reader());
    try std.testing.expectEqual(@as(i32, 0), len_i32);
}

// ============================================================================
// Tagged Fields (flexible version extensions)
// ============================================================================

test "tagged fields: empty tag buffer" {
    // In flexible versions, 0 tagged fields = single byte 0x00
    var buf: [10]u8 = undefined;
    var ws = std.io.fixedBufferStream(&buf);
    try types.encodeUnsignedVarInt(ws.writer(), 0); // 0 tagged fields
    try std.testing.expectEqual(@as(usize, 1), ws.pos);
    try std.testing.expectEqual(@as(u8, 0), buf[0]);
}

// ============================================================================
// RequestHeader v2 ClientId Encoding (per-field flexibleVersions: "none")
// ============================================================================

test "request header v2: client_id uses i16 length prefix, not varint" {
    // RequestHeader v2 is flexible, but the ClientId field has
    // flexibleVersions: "none" in the spec, meaning it must always
    // use non-compact (i16 length prefix) encoding.
    var buf: [256]u8 = undefined;
    var ws = std.io.fixedBufferStream(&buf);

    const header = RequestHeader{
        .request_api_key = 18, // ApiVersions
        .request_api_version = 3,
        .correlation_id = 1,
        .client_id = "test",
    };

    try header.encode(ws.writer(), 2); // version 2 = flexible

    // Expected layout:
    //   [0..2]  request_api_key: i16 = 18
    //   [2..4]  request_api_version: i16 = 3
    //   [4..8]  correlation_id: i32 = 1
    //   [8..10] client_id length: i16 = 4 (NON-compact, 2 bytes)
    //   [10..14] "test"
    //   [14]    tagged_fields count: varint 0

    // Verify client_id length is encoded as i16 (2 bytes, big-endian)
    const client_id_len = std.mem.readInt(i16, buf[8..10], .big);
    try std.testing.expectEqual(@as(i16, 4), client_id_len);

    // Verify "test" follows
    try std.testing.expectEqualStrings("test", buf[10..14]);

    // Total: 2+2+4+2+4+1 = 15 bytes
    try std.testing.expectEqual(@as(usize, 15), ws.pos);
}

test "request header v2: null client_id uses i16 null marker" {
    var buf: [256]u8 = undefined;
    var ws = std.io.fixedBufferStream(&buf);

    const header = RequestHeader{
        .request_api_key = 18,
        .request_api_version = 3,
        .correlation_id = 1,
        .client_id = null,
    };

    try header.encode(ws.writer(), 2);

    // client_id null marker should be i16 -1 (0xFF 0xFF), not varint 0
    const client_id_len = std.mem.readInt(i16, buf[8..10], .big);
    try std.testing.expectEqual(@as(i16, -1), client_id_len);

    // Total: 2+2+4+2+1 = 11 bytes
    try std.testing.expectEqual(@as(usize, 11), ws.pos);
}

test "request header v2: encode/decode roundtrip" {
    var buf: [256]u8 = undefined;
    var ws = std.io.fixedBufferStream(&buf);

    const original = RequestHeader{
        .request_api_key = 3,
        .request_api_version = 12,
        .correlation_id = 42,
        .client_id = "roundtrip-client",
    };

    try original.encode(ws.writer(), 2);

    var rs = std.io.fixedBufferStream(buf[0..ws.pos]);
    const decoded = try RequestHeader.decode(rs.reader(), 2, std.testing.allocator);
    defer if (decoded.client_id) |cid| std.testing.allocator.free(cid);

    try std.testing.expectEqual(original.request_api_key, decoded.request_api_key);
    try std.testing.expectEqual(original.request_api_version, decoded.request_api_version);
    try std.testing.expectEqual(original.correlation_id, decoded.correlation_id);
    try std.testing.expectEqualStrings("roundtrip-client", decoded.client_id.?);
}

test "request header v2: computeSize matches encode" {
    const header = RequestHeader{
        .request_api_key = 18,
        .request_api_version = 3,
        .correlation_id = 1,
        .client_id = "size-check",
    };

    const computed = try header.computeSize(2);

    var buf: [256]u8 = undefined;
    var ws = std.io.fixedBufferStream(&buf);
    try header.encode(ws.writer(), 2);

    try std.testing.expectEqual(ws.pos, computed);
}
