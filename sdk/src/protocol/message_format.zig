// Kafka Message Format Parser and Builder
// Handles all Kafka message formats: MessageSet (v0/v1) and RecordBatch (v2)
// Converts between Kafka wire format and TickStream's internal columnar format

const std = @import("std");
const mem = std.mem;
const log = std.log.scoped(.kafka_message_format);
const compression = @import("compression.zig");

/// TickStream's internal message format (ready for columnar storage)
pub const TickStreamMessage = struct {
    key: ?[]const u8,
    value: []const u8,
    headers: []const Header,
    timestamp: i64,
    offset: i64,
    partition: i32,

    pub const Header = struct {
        key: []const u8,
        value: ?[]const u8,
    };
};

/// Kafka RecordBatch header (magic v2)
pub const RecordBatchHeader = struct {
    base_offset: i64,
    batch_length: i32,
    partition_leader_epoch: i32,
    magic: i8,
    crc: u32,
    attributes: i16,
    last_offset_delta: i32,
    base_timestamp: i64,
    max_timestamp: i64,
    producer_id: i64,
    producer_epoch: i16,
    base_sequence: i32,
    record_count: i32,
};

/// Detect Kafka message format version by peeking at magic byte
/// RecordBatch v2: Magic at offset 16 [BaseOffset:8][BatchLength:4][PartitionLeaderEpoch:4][Magic:1]
/// MessageSet v0/v1: Magic at offset 16 [Offset:8][MessageSize:4][CRC:4][Magic:1]
fn detectMagicByte(data: []const u8) !i8 {
    if (data.len < 17) return error.InsufficientData;
    return @as(i8, @bitCast(data[16]));
}

/// Parse legacy Kafka MessageSet (magic v0/v1) and extract single message
fn parseMessageSetV0V1(allocator: mem.Allocator, data: []const u8) ![]TickStreamMessage {
    if (data.len < 14) return error.InvalidMessageSet; // Minimum: Offset(8) + MessageSize(4) + CRC(4) + Magic(1) + Attributes(1)

    var pos: usize = 0;
    var messages = std.array_list.Managed(TickStreamMessage).init(allocator);
    errdefer messages.deinit();

    // Parse MessageSet header
    const offset = mem.readInt(i64, data[pos..][0..8], .big);
    pos += 8;

    const message_size = mem.readInt(i32, data[pos..][0..4], .big);
    _ = message_size; // Used for validation
    pos += 4;

    const crc = mem.readInt(i32, data[pos..][0..4], .big);
    _ = crc; // Skip CRC validation for now
    pos += 4;

    const magic = @as(i8, @bitCast(data[pos]));
    pos += 1;

    const attributes = @as(i8, @bitCast(data[pos]));
    _ = attributes; // Check for compression if needed
    pos += 1;

    // Timestamp only exists in magic v1
    var timestamp: i64 = 0;
    if (magic == 1) {
        timestamp = mem.readInt(i64, data[pos..][0..8], .big);
        pos += 8;
    }

    // Read key (length-prefixed with i32)
    const key_len = mem.readInt(i32, data[pos..][0..4], .big);
    pos += 4;

    var key: ?[]const u8 = null;
    if (key_len >= 0) {
        if (pos + @as(usize, @intCast(key_len)) > data.len) return error.TruncatedMessage;
        key = data[pos .. pos + @as(usize, @intCast(key_len))];
        pos += @as(usize, @intCast(key_len));
    }

    // Read value (length-prefixed with i32)
    if (pos + 4 > data.len) return error.TruncatedMessage;
    const value_len = mem.readInt(i32, data[pos..][0..4], .big);
    pos += 4;

    if (value_len < 0) {
        // Null value - skip this message
        log.debug("MessageSet v{} at offset {}: null value, skipping", .{ magic, offset });
        return messages.toOwnedSlice();
    }

    if (pos + @as(usize, @intCast(value_len)) > data.len) return error.TruncatedMessage;
    const value = data[pos .. pos + @as(usize, @intCast(value_len))];

    // Create TickStream message
    try messages.append(.{
        .key = key,
        .value = value,
        .headers = &[_]TickStreamMessage.Header{}, // MessageSet v0/v1 has no headers
        .timestamp = timestamp,
        .offset = offset,
        .partition = 0, // Will be set by caller
    });

    log.info("parseMessageSetV0V1: Successfully parsed 1 message (magic={}, offset={}, value_len={})", .{ magic, offset, value.len });
    return messages.toOwnedSlice();
}

/// Parse Kafka RecordBatch v2 (magic v2) and extract messages
fn parseRecordBatchV2(allocator: mem.Allocator, data: []const u8) ![]TickStreamMessage {
    if (data.len < 61) return error.InvalidRecordBatch; // Minimum RecordBatch header size

    var pos: usize = 0;
    var messages = std.array_list.Managed(TickStreamMessage).init(allocator);
    errdefer messages.deinit();

    // Parse RecordBatch header
    const base_offset = mem.readInt(i64, data[pos..][0..8], .big);
    pos += 8;

    const batch_length = mem.readInt(i32, data[pos..][0..4], .big);
    _ = batch_length;
    pos += 4;

    const partition_leader_epoch = mem.readInt(i32, data[pos..][0..4], .big);
    _ = partition_leader_epoch;
    pos += 4;

    const magic = @as(i8, @bitCast(data[pos]));
    pos += 1;

    if (magic != 2) {
        log.warn("parseRecordBatchV2: Expected magic 2, got {}. This should not happen!", .{magic});
        return error.UnsupportedMagicVersion;
    }

    const crc = mem.readInt(u32, data[pos..][0..4], .big);
    _ = crc;
    pos += 4;

    const attributes = mem.readInt(i16, data[pos..][0..2], .big);
    const codec = compression.CompressionCodec.fromAttributes(attributes);
    pos += 2;

    const last_offset_delta = mem.readInt(i32, data[pos..][0..4], .big);
    _ = last_offset_delta;
    pos += 4;

    const base_timestamp = mem.readInt(i64, data[pos..][0..8], .big);
    pos += 8;

    const max_timestamp = mem.readInt(i64, data[pos..][0..8], .big);
    _ = max_timestamp;
    pos += 8;

    const producer_id = mem.readInt(i64, data[pos..][0..8], .big);
    _ = producer_id;
    pos += 8;

    const producer_epoch = mem.readInt(i16, data[pos..][0..2], .big);
    _ = producer_epoch;
    pos += 2;

    const base_sequence = mem.readInt(i32, data[pos..][0..4], .big);
    _ = base_sequence;
    pos += 4;

    const record_count = mem.readInt(i32, data[pos..][0..4], .big);
    pos += 4;

    // Get the records data (everything after the header)
    const records_data = data[pos..];

    // Decompress if needed
    var decompressed_data: ?[]u8 = null;
    defer if (decompressed_data) |d| allocator.free(d);

    const parse_data = if (codec != .none) blk: {
        log.info("RecordBatch uses {} compression, decompressing {} bytes", .{ codec, records_data.len });
        decompressed_data = compression.decompress(allocator, codec, records_data) catch |err| {
            log.warn("Failed to decompress RecordBatch: {any}", .{err});
            return error.DecompressionFailed;
        };
        if (decompressed_data) |d| {
            log.info("Decompressed {} bytes to {} bytes", .{ records_data.len, d.len });
            break :blk d;
        } else {
            break :blk records_data;
        }
    } else records_data;

    // Reset position for parsing records from (decompressed) data
    pos = 0;

    // Parse individual records
    log.debug("Starting to parse {} records from position {} (data len={})", .{ record_count, pos, parse_data.len });
    var offset_delta: i32 = 0;
    var i: i32 = 0;
    while (i < record_count and pos < parse_data.len) : (i += 1) {
        // Parse record
        const record_start = pos;
        log.debug("Record {}: starting at position {}, remaining bytes: {}", .{ i, pos, parse_data.len - pos });

        // Read record length (zigzag-encoded varint per Kafka v2 spec)
        const record_length = try readVarInt(parse_data[pos..]);
        log.debug("Record {}: length = {}", .{ i, record_length });

        if (record_length < 0) {
            log.err("Record {}: negative length {} - corrupt data", .{ i, record_length });
            return error.CorruptRecordLength;
        }

        pos += varIntSize(record_length);
        const record_length_usize = @as(usize, @intCast(record_length));

        if (pos + record_length_usize > parse_data.len) {
            log.warn("Record {}: incomplete data - need {} bytes but only {} available. Returning partial results.", .{ i, record_length_usize, parse_data.len - pos });
            break; // Return what we've parsed so far, keep remaining in buffer
        }

        // Record attributes (i8)
        const record_attributes = parse_data[pos];
        _ = record_attributes;
        pos += 1;

        // Timestamp delta (varlong)
        const timestamp_delta = try readVarLong(parse_data[pos..]);
        pos += varLongSize(timestamp_delta);

        // Offset delta (varint)
        offset_delta = try readVarInt(parse_data[pos..]);
        pos += varIntSize(offset_delta);

        // Key (varbytes)
        const key_len = try readVarInt(parse_data[pos..]);
        pos += varIntSize(key_len);

        var key: ?[]const u8 = null;
        if (key_len > 0) {
            key = parse_data[pos .. pos + @as(usize, @intCast(key_len))];
            pos += @as(usize, @intCast(key_len));
        }

        // Value (varbytes)
        const value_len = try readVarInt(parse_data[pos..]);
        pos += varIntSize(value_len);

        if (value_len < 0) continue; // Null value

        const value = parse_data[pos .. pos + @as(usize, @intCast(value_len))];
        pos += @as(usize, @intCast(value_len));

        // Headers array (varint count)
        const headers_count = try readVarInt(parse_data[pos..]);
        pos += varIntSize(headers_count);

        // Skip headers for now (TODO: parse if needed)
        var h: i32 = 0;
        while (h < headers_count and pos < parse_data.len) : (h += 1) {
            // Header key (varstring)
            const header_key_len = try readVarInt(parse_data[pos..]);
            pos += varIntSize(header_key_len);
            pos += @as(usize, @intCast(header_key_len));

            // Header value (varbytes)
            const header_value_len = try readVarInt(parse_data[pos..]);
            pos += varIntSize(header_value_len);
            if (header_value_len > 0) {
                pos += @as(usize, @intCast(header_value_len));
            }
        }

        // Create TickStream message
        log.debug("Record {}: creating message with offset={}, value_len={}", .{ i, base_offset + offset_delta, value.len });
        try messages.append(.{
            .key = key,
            .value = value,
            .headers = &[_]TickStreamMessage.Header{}, // TODO: parse headers
            .timestamp = base_timestamp + timestamp_delta,
            .offset = base_offset + offset_delta,
            .partition = 0, // Will be set by caller
        });

        _ = record_start;
    }

    log.info("parseRecordBatchV2: Successfully parsed {} messages", .{messages.items.len});

    return messages.toOwnedSlice();
}

/// Parse Kafka message data - auto-detects format (MessageSet v0/v1 or RecordBatch v2)
pub fn parseRecordBatch(allocator: mem.Allocator, data: []const u8) ![]TickStreamMessage {
    // Detect magic byte to determine format
    const magic = detectMagicByte(data) catch |err| {
        log.warn("Failed to detect magic byte: {}, data.len={}, first 30 bytes: {any}", .{ err, data.len, data[0..@min(30, data.len)] });
        return error.InvalidMessageFormat;
    };

    log.info("Detected magic byte: {}, data.len={}, first 30 bytes: {any}", .{ magic, data.len, data[0..@min(30, data.len)] });

    // Dispatch to appropriate parser based on magic version
    return switch (magic) {
        0, 1 => parseMessageSetV0V1(allocator, data),
        2 => parseRecordBatchV2(allocator, data),
        else => {
            log.warn("Unsupported magic version: {}", .{magic});
            return error.UnsupportedMagicVersion;
        },
    };
}

// === VAR INT/LONG HELPER FUNCTIONS ===
// ZigZag encoding for signed varints as per Kafka protocol

fn readVarInt(data: []const u8) !i32 {
    var value: u32 = 0;
    var i: usize = 0;
    var shift: u5 = 0;

    while (i < data.len and i < 5) : (i += 1) {
        const byte = data[i];
        // Add the lower 7 bits to the value
        value |= (@as(u32, byte & 0x7F) << shift);

        // If MSB is 0, this is the last byte
        if ((byte & 0x80) == 0) {
            // ZigZag decode: (n >> 1) ^ -(n & 1)
            const signed = @as(i32, @bitCast(value));
            const result = (signed >> 1) ^ -(signed & 1);
            return result;
        }
        shift += 7;
    }
    return error.InvalidVarInt;
}

fn readUnsignedVarInt(data: []const u8) !u32 {
    var value: u32 = 0;
    var i: usize = 0;
    var shift: u5 = 0;

    while (i < data.len and i < 5) : (i += 1) {
        const byte = data[i];
        // Add the lower 7 bits to the value
        value |= (@as(u32, byte & 0x7F) << shift);

        // If MSB is 0, this is the last byte
        if ((byte & 0x80) == 0) {
            return value;
        }
        shift += 7;
    }
    return error.InvalidVarInt;
}

fn readVarLong(data: []const u8) !i64 {
    var value: u64 = 0;
    var i: usize = 0;
    var shift: u6 = 0;

    while (i < data.len and i < 10) : (i += 1) {
        const byte = data[i];
        // Add the lower 7 bits to the value
        value |= (@as(u64, byte & 0x7F) << shift);

        // If MSB is 0, this is the last byte
        if ((byte & 0x80) == 0) {
            // ZigZag decode: (n >> 1) ^ -(n & 1)
            const signed = @as(i64, @bitCast(value));
            return (signed >> 1) ^ -(signed & 1);
        }
        shift += 7;
    }
    return error.InvalidVarLong;
}

fn varIntSize(value: i32) usize {
    // ZigZag encode
    const unsigned = @as(u32, @bitCast((value << 1) ^ (value >> 31)));
    var v = unsigned;
    var size: usize = 1;
    while (v >= 0x80) {
        size += 1;
        v >>= 7;
    }
    return size;
}

fn unsignedVarIntSize(value: u32) usize {
    var v = value;
    var size: usize = 1;
    while (v >= 0x80) {
        size += 1;
        v >>= 7;
    }
    return size;
}

fn varLongSize(value: i64) usize {
    // ZigZag encode
    const unsigned = @as(u64, @bitCast((value << 1) ^ (value >> 63)));
    var v = unsigned;
    var size: usize = 1;
    while (v >= 0x80) {
        size += 1;
        v >>= 7;
    }
    return size;
}

fn writeVarInt(writer: anytype, value: i32) !void {
    // ZigZag encode: (n << 1) ^ (n >> 31)
    const unsigned = @as(u32, @bitCast((value << 1) ^ (value >> 31)));
    var v = unsigned;

    // Write bytes with continuation bit
    while (v >= 0x80) {
        try writer.writeByte(@as(u8, @truncate(v & 0x7F)) | 0x80);
        v >>= 7;
    }
    try writer.writeByte(@as(u8, @truncate(v)));
}

fn writeVarLong(writer: anytype, value: i64) !void {
    // ZigZag encode: (n << 1) ^ (n >> 63)
    const unsigned = @as(u64, @bitCast((value << 1) ^ (value >> 63)));
    var v = unsigned;

    // Write bytes with continuation bit
    while (v >= 0x80) {
        try writer.writeByte(@as(u8, @truncate(v & 0x7F)) | 0x80);
        v >>= 7;
    }
    try writer.writeByte(@as(u8, @truncate(v)));
}

// === STORAGE SERIALIZATION HELPERS ===
// These functions handle serializing/deserializing Kafka message key+value
// for storage in the main level-based storage system

/// Serialize a Kafka message (key + value) for storage
/// Format: [key_len:i32][key_bytes][value_bytes]
/// - key_len = -1: null key (no key bytes)
/// - key_len >= 0: that many key bytes follow, then value bytes
pub fn serializeKafkaMessage(allocator: mem.Allocator, key: ?[]const u8, value: []const u8) ![]u8 {
    const key_len: i32 = if (key) |k| @as(i32, @intCast(k.len)) else -1;
    const total_len: usize = 4 + (if (key) |k| k.len else 0) + value.len;

    var buffer = try allocator.alloc(u8, total_len);
    errdefer allocator.free(buffer);

    // Write key length (i32, big-endian)
    mem.writeInt(i32, buffer[0..4], key_len, .big);

    var pos: usize = 4;

    // Write key bytes if present
    if (key) |k| {
        @memcpy(buffer[pos .. pos + k.len], k);
        pos += k.len;
    }

    // Write value bytes
    @memcpy(buffer[pos .. pos + value.len], value);

    return buffer;
}

/// Deserialize a Kafka message (key + value) from storage
/// Returns TickStreamMessage struct for easy conversion to RecordBatch
pub fn deserializeKafkaMessage(allocator: mem.Allocator, data: []const u8) !TickStreamMessage {
    if (data.len < 4) return error.InvalidSerializedMessage;

    // Read key length
    const key_len = mem.readInt(i32, data[0..4], .big);

    var key: ?[]const u8 = null;
    var value_start: usize = 4;

    if (key_len == -1) {
        // Null key - all remaining data is value
        key = null;
    } else if (key_len < 0) {
        return error.InvalidKeyLength;
    } else {
        if (4 + @as(usize, @intCast(key_len)) > data.len) return error.TruncatedMessage;

        // Extract key
        const key_start = 4;
        const key_end = key_start + @as(usize, @intCast(key_len));
        key = try allocator.dupe(u8, data[key_start..key_end]);
        value_start = key_end;
    }

    // Extract value (rest of data)
    const value = try allocator.dupe(u8, data[value_start..]);

    return TickStreamMessage{
        .key = key,
        .value = value,
        .headers = &[_]TickStreamMessage.Header{},
        .timestamp = @intCast(@import("ztime").milliTimestamp()),
        .offset = 0, // Will be set by caller
        .partition = 0, // Will be set by caller
    };
}

/// Pre-calculated record metadata to avoid duplicate calculations
const RecordMetadata = struct {
    offset_delta: i32,
    timestamp_delta: i64,
    key_len: i32,
    key_bytes_len: usize,
    record_size: usize,
};

/// Build Kafka RecordBatch v2 from TickStream messages
/// Returns properly formatted RecordBatch bytes for FETCH response
/// OPTIMIZED: Calculates record sizes once and reuses them
pub fn buildRecordBatchV2(
    allocator: mem.Allocator,
    messages: []const TickStreamMessage,
    base_offset: i64,
) ![]u8 {
    if (messages.len == 0) return try allocator.alloc(u8, 0);

    // Pre-calculate all record metadata (single pass)
    var metadata_stack_buffer: [256]RecordMetadata = undefined;
    var metadata_slice: []RecordMetadata = undefined;
    var should_free_metadata = false;

    if (messages.len <= 256) {
        metadata_slice = metadata_stack_buffer[0..messages.len];
    } else {
        metadata_slice = try allocator.alloc(RecordMetadata, messages.len);
        should_free_metadata = true;
    }
    defer if (should_free_metadata) allocator.free(metadata_slice);

    // Calculate total size for all records (single pass with caching)
    var total_records_size: usize = 0;
    for (messages, 0..) |msg, i| {
        const offset_delta: i32 = @intCast(i);
        const timestamp_delta: i64 = if (i == 0) 0 else msg.timestamp - messages[0].timestamp;

        // Calculate this record's size
        const key_len: i32 = if (msg.key) |k| @intCast(k.len) else -1;
        const key_bytes_len = if (msg.key) |k| k.len else 0;

        const record_size: usize = 1 + // attributes
            varLongSize(timestamp_delta) +
            varIntSize(offset_delta) +
            varIntSize(key_len) +
            key_bytes_len +
            varIntSize(@intCast(msg.value.len)) +
            msg.value.len +
            varIntSize(0); // headers count

        // Store metadata for reuse in write pass
        metadata_slice[i] = .{
            .offset_delta = offset_delta,
            .timestamp_delta = timestamp_delta,
            .key_len = key_len,
            .key_bytes_len = key_bytes_len,
            .record_size = record_size,
        };

        // Add length prefix for this record
        total_records_size += varIntSize(@intCast(record_size)) + record_size;
    }

    // RecordBatch header is 61 bytes
    const header_size: usize = 61;
    const batch_length: i32 = @intCast(header_size - 12 + total_records_size); // Exclude baseOffset(8) and batchLength(4)
    const total_size = header_size + total_records_size;

    var buffer = try allocator.alloc(u8, total_size);
    var pos: usize = 0;

    // Write RecordBatch header
    mem.writeInt(i64, buffer[pos..][0..8], base_offset, .big);
    pos += 8;

    mem.writeInt(i32, buffer[pos..][0..4], batch_length, .big);
    pos += 4;

    mem.writeInt(i32, buffer[pos..][0..4], -1, .big); // partitionLeaderEpoch
    pos += 4;

    buffer[pos] = 2; // magic v2
    pos += 1;

    // CRC placeholder (will calculate after writing rest of data)
    const crc_pos = pos;
    mem.writeInt(u32, buffer[pos..][0..4], 0, .big);
    pos += 4;

    mem.writeInt(i16, buffer[pos..][0..2], 0, .big); // attributes (no compression)
    pos += 2;

    mem.writeInt(i32, buffer[pos..][0..4], @intCast(messages.len - 1), .big); // lastOffsetDelta
    pos += 4;

    mem.writeInt(i64, buffer[pos..][0..8], messages[0].timestamp, .big); // baseTimestamp
    pos += 8;

    const max_timestamp = messages[messages.len - 1].timestamp;
    mem.writeInt(i64, buffer[pos..][0..8], max_timestamp, .big); // maxTimestamp
    pos += 8;

    mem.writeInt(i64, buffer[pos..][0..8], -1, .big); // producerId (no transactions)
    pos += 8;

    mem.writeInt(i16, buffer[pos..][0..2], -1, .big); // producerEpoch
    pos += 2;

    mem.writeInt(i32, buffer[pos..][0..4], -1, .big); // baseSequence
    pos += 4;

    mem.writeInt(i32, buffer[pos..][0..4], @intCast(messages.len), .big); // recordCount
    pos += 4;

    // Now write all records using pre-calculated metadata
    for (messages, 0..) |msg, i| {
        const meta = metadata_slice[i];

        // Write record length as varint
        var stream = @import("ztime").fixedBufferStream(buffer[pos..]);
        try writeVarInt(stream.writer(), @intCast(meta.record_size));
        pos += varIntSize(@intCast(meta.record_size));

        // Write attributes
        buffer[pos] = 0;
        pos += 1;

        // Write timestamp delta
        stream = @import("ztime").fixedBufferStream(buffer[pos..]);
        try writeVarLong(stream.writer(), meta.timestamp_delta);
        pos += varLongSize(meta.timestamp_delta);

        // Write offset delta
        stream = @import("ztime").fixedBufferStream(buffer[pos..]);
        try writeVarInt(stream.writer(), meta.offset_delta);
        pos += varIntSize(meta.offset_delta);

        // Write key length
        stream = @import("ztime").fixedBufferStream(buffer[pos..]);
        try writeVarInt(stream.writer(), meta.key_len);
        pos += varIntSize(meta.key_len);

        // Write key bytes if present
        if (msg.key) |k| {
            @memcpy(buffer[pos..][0..k.len], k);
            pos += k.len;
        }

        // Write value length
        stream = @import("ztime").fixedBufferStream(buffer[pos..]);
        try writeVarInt(stream.writer(), @intCast(msg.value.len));
        pos += varIntSize(@intCast(msg.value.len));

        // Write value bytes
        @memcpy(buffer[pos..][0..msg.value.len], msg.value);
        pos += msg.value.len;

        // Write headers count (0)
        stream = @import("ztime").fixedBufferStream(buffer[pos..]);
        try writeVarInt(stream.writer(), 0);
        pos += varIntSize(0);
    }

    // Calculate CRC32C over data from attributes field onward
    const crc_data = buffer[crc_pos + 4 .. pos];
    const crc = std.hash.Crc32.hash(crc_data);
    mem.writeInt(u32, buffer[crc_pos..][0..4], crc, .big);

    log.info("buildRecordBatchV2: Built RecordBatch with {} messages, total_size={}, base_offset={}", .{ messages.len, total_size, base_offset });

    return buffer;
}

/// Result of building RecordBatch into provided buffer
pub const RecordBatchBuffer = struct {
    slice: []u8,
    bytes_written: usize,
};

/// Build RecordBatch V2 into provided buffer (zero-allocation)
/// Returns slice pointing into buffer and number of bytes written
pub fn buildRecordBatchV2IntoBuffer(
    buffer: []u8,
    offset: usize,
    messages: []const TickStreamMessage,
    base_offset: i64,
    allocator: mem.Allocator,
) !RecordBatchBuffer {
    if (messages.len == 0) return RecordBatchBuffer{ .slice = buffer[offset..offset], .bytes_written = 0 };

    // Pre-calculate all record metadata (single pass)
    var metadata_stack_buffer: [256]RecordMetadata = undefined;
    var metadata_slice: []RecordMetadata = undefined;
    var should_free_metadata = false;

    if (messages.len <= 256) {
        metadata_slice = metadata_stack_buffer[0..messages.len];
    } else {
        metadata_slice = try allocator.alloc(RecordMetadata, messages.len);
        should_free_metadata = true;
    }
    defer if (should_free_metadata) allocator.free(metadata_slice);

    // Calculate total size for all records (single pass with caching)
    var total_records_size: usize = 0;
    for (messages, 0..) |msg, i| {
        const offset_delta: i32 = @intCast(i);
        const timestamp_delta: i64 = if (i == 0) 0 else msg.timestamp - messages[0].timestamp;

        // Calculate this record's size
        const key_len: i32 = if (msg.key) |k| @intCast(k.len) else -1;
        const key_bytes_len = if (msg.key) |k| k.len else 0;

        const record_size: usize = 1 + // attributes
            varLongSize(timestamp_delta) +
            varIntSize(offset_delta) +
            varIntSize(key_len) +
            key_bytes_len +
            varIntSize(@intCast(msg.value.len)) +
            msg.value.len +
            varIntSize(0); // headers count

        // Store metadata for reuse in write pass
        metadata_slice[i] = .{
            .offset_delta = offset_delta,
            .timestamp_delta = timestamp_delta,
            .key_len = key_len,
            .key_bytes_len = key_bytes_len,
            .record_size = record_size,
        };

        // Add length prefix for this record
        total_records_size += varIntSize(@intCast(record_size)) + record_size;
    }

    // RecordBatch header is 61 bytes
    const header_size: usize = 61;
    const batch_length: i32 = @intCast(header_size - 12 + total_records_size); // Exclude baseOffset(8) and batchLength(4)
    const total_size = header_size + total_records_size;

    // Check buffer has enough space
    if (offset + total_size > buffer.len) {
        return error.BufferTooSmall;
    }

    var pos: usize = offset;

    // Write RecordBatch header
    mem.writeInt(i64, buffer[pos..][0..8], base_offset, .big);
    pos += 8;

    mem.writeInt(i32, buffer[pos..][0..4], batch_length, .big);
    pos += 4;

    mem.writeInt(i32, buffer[pos..][0..4], -1, .big); // partitionLeaderEpoch
    pos += 4;

    buffer[pos] = 2; // magic v2
    pos += 1;

    // CRC placeholder (will calculate after writing rest of data)
    const crc_pos = pos;
    mem.writeInt(u32, buffer[pos..][0..4], 0, .big);
    pos += 4;

    mem.writeInt(i16, buffer[pos..][0..2], 0, .big); // attributes (no compression)
    pos += 2;

    mem.writeInt(i32, buffer[pos..][0..4], @intCast(messages.len - 1), .big); // lastOffsetDelta
    pos += 4;

    mem.writeInt(i64, buffer[pos..][0..8], messages[0].timestamp, .big); // baseTimestamp
    pos += 8;

    const max_timestamp = messages[messages.len - 1].timestamp;
    mem.writeInt(i64, buffer[pos..][0..8], max_timestamp, .big); // maxTimestamp
    pos += 8;

    mem.writeInt(i64, buffer[pos..][0..8], -1, .big); // producerId (no transactions)
    pos += 8;

    mem.writeInt(i16, buffer[pos..][0..2], -1, .big); // producerEpoch
    pos += 2;

    mem.writeInt(i32, buffer[pos..][0..4], -1, .big); // baseSequence
    pos += 4;

    mem.writeInt(i32, buffer[pos..][0..4], @intCast(messages.len), .big); // recordCount
    pos += 4;

    // Now write all records using pre-calculated metadata
    for (messages, 0..) |msg, i| {
        const meta = metadata_slice[i];

        // Write record length as varint
        var stream = @import("ztime").fixedBufferStream(buffer[pos..]);
        try writeVarInt(stream.writer(), @intCast(meta.record_size));
        pos += varIntSize(@intCast(meta.record_size));

        // Write attributes
        buffer[pos] = 0;
        pos += 1;

        // Write timestamp delta
        stream = @import("ztime").fixedBufferStream(buffer[pos..]);
        try writeVarLong(stream.writer(), meta.timestamp_delta);
        pos += varLongSize(meta.timestamp_delta);

        // Write offset delta
        stream = @import("ztime").fixedBufferStream(buffer[pos..]);
        try writeVarInt(stream.writer(), meta.offset_delta);
        pos += varIntSize(meta.offset_delta);

        // Write key length
        stream = @import("ztime").fixedBufferStream(buffer[pos..]);
        try writeVarInt(stream.writer(), meta.key_len);
        pos += varIntSize(meta.key_len);

        // Write key bytes if present
        if (msg.key) |k| {
            @memcpy(buffer[pos..][0..k.len], k);
            pos += k.len;
        }

        // Write value length
        stream = @import("ztime").fixedBufferStream(buffer[pos..]);
        try writeVarInt(stream.writer(), @intCast(msg.value.len));
        pos += varIntSize(@intCast(msg.value.len));

        // Write value bytes
        @memcpy(buffer[pos..][0..msg.value.len], msg.value);
        pos += msg.value.len;

        // Write headers count (0)
        stream = @import("ztime").fixedBufferStream(buffer[pos..]);
        try writeVarInt(stream.writer(), 0);
        pos += varIntSize(0);
    }

    // Calculate CRC32C over data from attributes field onward
    const crc_data = buffer[crc_pos + 4 .. pos];
    const crc = std.hash.Crc32.hash(crc_data);
    mem.writeInt(u32, buffer[crc_pos..][0..4], crc, .big);

    const bytes_written = pos - offset;
    log.info("buildRecordBatchV2IntoBuffer: Built RecordBatch with {} messages, bytes_written={}, base_offset={}", .{ messages.len, bytes_written, base_offset });

    return RecordBatchBuffer{
        .slice = buffer[offset..pos],
        .bytes_written = bytes_written,
    };
}
