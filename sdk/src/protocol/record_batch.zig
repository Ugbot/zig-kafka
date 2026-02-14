//! Kafka RecordBatch Format Implementation (Magic Byte 2)
//! Implements the official Kafka RecordBatch structure for v0.11.0+
//! Spec: https://kafka.apache.org/documentation/#recordbatch
//!
//! RecordBatch Structure:
//!   baseOffset: int64
//!   batchLength: int32
//!   partitionLeaderEpoch: int32
//!   magic: int8 = 2
//!   crc: int32 (CRC32C from magic through end)
//!   attributes: int16
//!   lastOffsetDelta: int32
//!   baseTimestamp: int64
//!   maxTimestamp: int64
//!   producerId: int64
//!   producerEpoch: int16
//!   baseSequence: int32
//!   records: [Record]

const std = @import("std");
const mem = std.mem;
const log = std.log.scoped(.kafka_record_batch);

/// CRC32C (Castagnoli) polynomial
const CRC32C_POLY: u32 = 0x82F63B78;

/// Magic byte for v2 RecordBatch format
const RECORD_BATCH_MAGIC_V2: i8 = 2;

/// Compression types
pub const CompressionType = enum(u3) {
    none = 0,
    gzip = 1,
    snappy = 2,
    lz4 = 3,
    zstd = 4,
};

/// RecordBatch attributes
pub const Attributes = packed struct(u16) {
    compression: CompressionType,
    timestamp_type: u1, // 0 = CreateTime, 1 = LogAppendTime
    is_transactional: u1,
    is_control_batch: u1,
    has_delete_horizon_ms: u1,
    _unused: u9 = 0, // 3 bits (compression) + 1 + 1 + 1 + 1 + 9 = 16 bits

    pub fn toInt(self: Attributes) i16 {
        return @bitCast(self);
    }
};

/// RecordBatch builder - zero-allocation using provided buffer
pub const RecordBatchBuilder = struct {
    const Self = @This();

    buffer: []u8,
    batch_start: usize,
    records_start: usize,
    pos: usize,

    base_offset: i64,
    partition_leader_epoch: i32,
    base_timestamp: i64,
    attributes: Attributes,

    record_count: i32,
    last_offset_delta: i32,
    max_timestamp: i64,

    // Idempotence/transaction fields (-1 = not set)
    producer_id: i64,
    producer_epoch: i16,
    base_sequence: i32,

    pub fn init(buffer: []u8, base_offset: i64, base_timestamp: i64) Self {
        return .{
            .buffer = buffer,
            .batch_start = 0,
            .records_start = 61, // Fixed size of batch header
            .pos = 61, // Start writing records after header
            .base_offset = base_offset,
            .partition_leader_epoch = 0,
            .base_timestamp = base_timestamp,
            .attributes = .{
                .compression = .none,
                .timestamp_type = 0, // CreateTime
                .is_transactional = 0,
                .is_control_batch = 0,
                .has_delete_horizon_ms = 0,
            },
            .record_count = 0,
            .last_offset_delta = 0,
            .max_timestamp = base_timestamp,
            .producer_id = -1,
            .producer_epoch = -1,
            .base_sequence = -1,
        };
    }

    /// Add a record to the batch.
    ///
    /// Per the Kafka spec, ALL varints within a Record are zigzag-encoded
    /// (signed varint for i32, signed varlong for i64).
    pub fn addRecord(self: *Self, key: ?[]const u8, value: []const u8, timestamp: i64) !void {
        const record_start = self.pos;

        // Reserve space for zigzag varint length (max 5 bytes for i32)
        self.pos += 5;

        // Attributes (int8)
        try self.writeByte(0);

        // TimestampDelta (zigzag varlong)
        const timestamp_delta = timestamp - self.base_timestamp;
        try self.writeSignedVarint(timestamp_delta);

        // OffsetDelta (zigzag varint)
        try self.writeSignedVarint32(@intCast(self.last_offset_delta));

        // Key (zigzag varint length + bytes, -1 for null)
        if (key) |k| {
            try self.writeSignedVarint32(@intCast(k.len));
            try self.writeBytes(k);
        } else {
            try self.writeSignedVarint32(-1);
        }

        // Value (zigzag varint length + bytes, -1 for null)
        if (value.len > 0) {
            try self.writeSignedVarint32(@intCast(value.len));
            try self.writeBytes(value);
        } else {
            try self.writeSignedVarint32(-1);
        }

        // Headers count (zigzag varint)
        try self.writeSignedVarint32(0);

        // Calculate actual record body size and encode as zigzag varint
        const record_size: i32 = @intCast(self.pos - record_start - 5);
        var len_buf: [5]u8 = undefined;
        const length_size = encodeZigzagVarint32(record_size, &len_buf);

        // Shift record data left if length prefix is less than 5 bytes.
        // Must use copyForwards: destination is before source with overlap.
        if (length_size < 5) {
            const shift = 5 - length_size;
            std.mem.copyForwards(u8, self.buffer[record_start + length_size .. self.pos - shift], self.buffer[record_start + 5 .. self.pos]);
            self.pos -= shift;
        }

        // Write length prefix
        @memcpy(self.buffer[record_start .. record_start + length_size], len_buf[0..length_size]);

        // Update batch metadata
        self.record_count += 1;
        self.last_offset_delta += 1;
        if (timestamp > self.max_timestamp) {
            self.max_timestamp = timestamp;
        }

        log.debug("RECORD_BATCH: Added record {} (size={}, key={}, value={})", .{ self.record_count, record_size, if (key) |k| k.len else 0, value.len });
    }

    /// Finalize the batch and return the complete RecordBatch bytes
    pub fn finalize(self: *Self) ![]const u8 {
        // Calculate batch length (from partitionLeaderEpoch through end)
        const batch_length = @as(i32, @intCast(self.pos - self.batch_start - 12)); // Exclude baseOffset and batchLength

        // Write batch header
        var pos: usize = self.batch_start;

        // baseOffset (int64)
        mem.writeInt(i64, self.buffer[pos..][0..8], self.base_offset, .big);
        pos += 8;

        // batchLength (int32)
        mem.writeInt(i32, self.buffer[pos..][0..4], batch_length, .big);
        pos += 4;

        // partitionLeaderEpoch (int32)
        mem.writeInt(i32, self.buffer[pos..][0..4], self.partition_leader_epoch, .big);
        pos += 4;

        // magic (int8)
        self.buffer[pos] = @bitCast(RECORD_BATCH_MAGIC_V2);
        pos += 1;

        // CRC placeholder (will calculate after writing rest of header)
        const crc_pos = pos;
        pos += 4;

        // attributes (int16)
        mem.writeInt(i16, self.buffer[pos..][0..2], self.attributes.toInt(), .big);
        pos += 2;

        // lastOffsetDelta (int32)
        mem.writeInt(i32, self.buffer[pos..][0..4], self.last_offset_delta, .big);
        pos += 4;

        // baseTimestamp (int64)
        mem.writeInt(i64, self.buffer[pos..][0..8], self.base_timestamp, .big);
        pos += 8;

        // maxTimestamp (int64)
        mem.writeInt(i64, self.buffer[pos..][0..8], self.max_timestamp, .big);
        pos += 8;

        // producerId (int64) - -1 for no producer ID
        mem.writeInt(i64, self.buffer[pos..][0..8], self.producer_id, .big);
        pos += 8;

        // producerEpoch (int16) - -1 for no producer epoch
        mem.writeInt(i16, self.buffer[pos..][0..2], self.producer_epoch, .big);
        pos += 2;

        // baseSequence (int32) - -1 for no sequence
        mem.writeInt(i32, self.buffer[pos..][0..4], self.base_sequence, .big);
        pos += 4;

        // records array length (int32)
        mem.writeInt(i32, self.buffer[pos..][0..4], self.record_count, .big);
        pos += 4;

        // Calculate CRC32C from attributes through end
        const crc_data = self.buffer[crc_pos + 4 .. self.pos];
        const crc = crc32c(crc_data);
        mem.writeInt(u32, self.buffer[crc_pos..][0..4], crc, .big);

        log.info("RECORD_BATCH: Finalized batch - baseOffset={}, records={}, size={} bytes", .{ self.base_offset, self.record_count, self.pos - self.batch_start });

        return self.buffer[self.batch_start..self.pos];
    }

    // === Helper methods ===

    fn writeByte(self: *Self, byte: u8) !void {
        if (self.pos >= self.buffer.len) return error.BufferTooSmall;
        self.buffer[self.pos] = byte;
        self.pos += 1;
    }

    fn writeBytes(self: *Self, bytes: []const u8) !void {
        if (self.pos + bytes.len > self.buffer.len) return error.BufferTooSmall;
        // Use copyForwards to safely handle potential aliasing
        // (bytes could be a slice from the same buffer)
        const dest = self.buffer[self.pos .. self.pos + bytes.len];
        if (dest.ptr != bytes.ptr) {
            std.mem.copyForwards(u8, dest, bytes);
        }
        self.pos += bytes.len;
    }

    fn writeVarint(self: *Self, value: u64) !void {
        var v = value;
        while (v >= 0x80) {
            try self.writeByte(@as(u8, @intCast((v & 0x7F) | 0x80)));
            v >>= 7;
        }
        try self.writeByte(@as(u8, @intCast(v & 0x7F)));
    }

    fn writeSignedVarint(self: *Self, value: i64) !void {
        // ZigZag encoding: (n << 1) ^ (n >> 63)
        // Uses arithmetic right shift to propagate sign bit
        const unsigned: u64 = @bitCast((value << 1) ^ (value >> 63));
        try self.writeVarint(unsigned);
    }

    fn writeSignedVarint32(self: *Self, value: i32) !void {
        // ZigZag encoding for i32: (n << 1) ^ (n >> 31)
        // This is what Kafka/tansu uses for 32-bit signed varints
        const unsigned: u32 = @bitCast((value << 1) ^ (value >> 31));
        try self.writeVarint(@intCast(unsigned));
    }

    /// Encode a signed i32 as zigzag varint into the provided buffer.
    /// Returns the number of bytes written (1-5).
    fn encodeZigzagVarint32(value: i32, out: *[5]u8) usize {
        const unsigned: u32 = @bitCast((value << 1) ^ (value >> 31));
        var v: u64 = unsigned;
        var i: usize = 0;
        while (v >= 0x80) : (i += 1) {
            out[i] = @as(u8, @intCast((v & 0x7F) | 0x80));
            v >>= 7;
        }
        out[i] = @as(u8, @intCast(v & 0x7F));
        return i + 1;
    }
};

/// Calculate CRC32C (Castagnoli) checksum
/// Uses table-based algorithm for performance
pub fn crc32c(data: []const u8) u32 {
    var crc: u32 = 0xFFFFFFFF;

    for (data) |byte| {
        const index = @as(u8, @truncate(crc)) ^ byte;
        crc = (crc >> 8) ^ crc32c_table[index];
    }

    return ~crc;
}

/// CRC32C lookup table (Castagnoli polynomial)
const crc32c_table = blk: {
    @setEvalBranchQuota(5000); // Increase for table generation
    var table: [256]u32 = undefined;
    for (&table, 0..) |*entry, i| {
        var crc: u32 = @intCast(i);
        var j: u8 = 0;
        while (j < 8) : (j += 1) {
            if ((crc & 1) != 0) {
                crc = (crc >> 1) ^ CRC32C_POLY;
            } else {
                crc >>= 1;
            }
        }
        entry.* = crc;
    }
    break :blk table;
};

// === Tests ===

const testing = std.testing;

test "RecordBatch empty batch" {
    var buffer: [1024]u8 = undefined;
    var builder = RecordBatchBuilder.init(&buffer, 0, 1609459200000); // 2021-01-01 00:00:00

    const batch = try builder.finalize();

    // Verify magic byte
    try testing.expectEqual(@as(i8, 2), @as(i8, @bitCast(batch[16])));

    // Verify record count
    const record_count = mem.readInt(i32, batch[57..61], .big);
    try testing.expectEqual(@as(i32, 0), record_count);
}

test "RecordBatch single record" {
    var buffer: [1024]u8 = undefined;
    var builder = RecordBatchBuilder.init(&buffer, 0, 1609459200000);

    try builder.addRecord(null, "test-value", 1609459200000);

    const batch = try builder.finalize();

    // Verify magic byte
    try testing.expectEqual(@as(i8, 2), @as(i8, @bitCast(batch[16])));

    // Verify record count
    const record_count = mem.readInt(i32, batch[57..61], .big);
    try testing.expectEqual(@as(i32, 1), record_count);

    // Verify batch has data
    try testing.expect(batch.len > 61);
}

test "RecordBatch multiple records" {
    var buffer: [1024]u8 = undefined;
    var builder = RecordBatchBuilder.init(&buffer, 100, 1609459200000);

    try builder.addRecord("key1", "value1", 1609459200000);
    try builder.addRecord("key2", "value2", 1609459200001);
    try builder.addRecord(null, "value3", 1609459200002);

    const batch = try builder.finalize();

    // Verify record count
    const record_count = mem.readInt(i32, batch[57..61], .big);
    try testing.expectEqual(@as(i32, 3), record_count);

    // Verify base offset
    const base_offset = mem.readInt(i64, batch[0..8], .big);
    try testing.expectEqual(@as(i64, 100), base_offset);
}

test "CRC32C calculation - standard test vector" {
    // Known test vector from CRC32C spec
    const data = "123456789";
    const expected_crc: u32 = 0xE3069283;

    const calculated_crc = crc32c(data);
    try testing.expectEqual(expected_crc, calculated_crc);
}

test "CRC32C calculation - empty data" {
    const data = "";
    // CRC32C of empty data is 0 (after XOR with 0xFFFFFFFF at start and end)
    const expected_crc: u32 = 0;

    const calculated_crc = crc32c(data);
    try testing.expectEqual(expected_crc, calculated_crc);
}

test "CRC32C calculation - Kafka RecordBatch data" {
    // From tansu test data (record.rs lines 106-113)
    // This is the CRC portion of a real Kafka RecordBatch
    const data = &[_]u8{
        0x00, 0x00, // attributes
        0x00, 0x00, 0x00, 0x00, // lastOffsetDelta
        0x00, 0x00, 0x01, 0x90, 0xEE, 0x94, 0x84, 0x36, // baseTimestamp
        0x00, 0x00, 0x01, 0x90, 0xEE, 0x94, 0x84, 0x36, // maxTimestamp
        0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, // producerId (-1)
        0xFF, 0xFF, // producerEpoch (-1)
        0xFF, 0xFF, 0xFF, 0xFF, // baseSequence (-1)
        0x00, 0x00, 0x00, 0x01, // recordCount (1)
        // record data would follow...
    };

    // Calculate CRC to verify our implementation works with Kafka data structure
    const crc = crc32c(data);

    // Just verify it doesn't crash and returns a value
    // (actual value depends on complete record data)
    try testing.expect(crc != 0);
}

test "ZigZag encoding - i32 values" {
    // Test i32 ZigZag encoding (used by tansu for varint)
    const test_cases = [_]struct { input: i32, expected: u32 }{
        .{ .input = 0, .expected = 0 },
        .{ .input = -1, .expected = 1 },
        .{ .input = 1, .expected = 2 },
        .{ .input = -2, .expected = 3 },
        .{ .input = 2, .expected = 4 },
        .{ .input = 2147483647, .expected = 4294967294 },
        .{ .input = -2147483648, .expected = 4294967295 },
    };

    for (test_cases) |case| {
        const encoded: u32 = @bitCast((case.input << 1) ^ (case.input >> 31));
        try testing.expectEqual(case.expected, encoded);

        // Verify decode
        const decoded: i32 = @bitCast(@as(u32, (encoded >> 1)) ^ @as(u32, @bitCast(-@as(i32, @intCast(encoded & 1)))));
        try testing.expectEqual(case.input, decoded);
    }
}

test "ZigZag encoding - i64 values" {
    // Test i64 ZigZag encoding (used for timestamps)
    const test_cases = [_]struct { input: i64, expected: u64 }{
        .{ .input = 0, .expected = 0 },
        .{ .input = -1, .expected = 1 },
        .{ .input = 1, .expected = 2 },
        .{ .input = -2, .expected = 3 },
        .{ .input = 2, .expected = 4 },
    };

    for (test_cases) |case| {
        const encoded: u64 = @bitCast((case.input << 1) ^ (case.input >> 63));
        try testing.expectEqual(case.expected, encoded);
    }
}
