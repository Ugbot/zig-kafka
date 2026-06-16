//! Complete Kafka protocol type system
//! Implements ALL Kafka types including compact and tagged fields

const std = @import("std");
const mem = std.mem;

/// Kafka protocol errors
pub const Error = error{
    InvalidVarInt,
    InvalidCompactString,
    BufferTooSmall,
    InvalidVersion,
    InvalidTaggedField,
    NullNotAllowed,
    InvalidArrayLength,
    InvalidStringLength,
    UnsupportedVersion,
};

// ============================================================================
// PRIMITIVE TYPES
// ============================================================================

/// Boolean - single byte
pub fn encodeBoolean(writer: anytype, value: bool) !void {
    try writer.writeByte(if (value) 1 else 0);
}

pub fn decodeBoolean(reader: anytype) !bool {
    return (try reader.readByte()) != 0;
}

/// Int8 - signed 8-bit integer
pub fn encodeInt8(writer: anytype, value: i8) !void {
    try writer.writeByte(@bitCast(value));
}

pub fn decodeInt8(reader: anytype) !i8 {
    return @bitCast(try reader.readByte());
}

/// Int16 - signed 16-bit integer (big-endian)
pub fn encodeInt16(writer: anytype, value: i16) !void {
    try writer.writeInt(i16, value, .big);
}

pub fn decodeInt16(reader: anytype) !i16 {
    return try reader.readInt(i16, .big);
}

/// Int32 - signed 32-bit integer (big-endian)
pub fn encodeInt32(writer: anytype, value: i32) !void {
    try writer.writeInt(i32, value, .big);
}

pub fn decodeInt32(reader: anytype) !i32 {
    return try reader.readInt(i32, .big);
}

/// Int64 - signed 64-bit integer (big-endian)
pub fn encodeInt64(writer: anytype, value: i64) !void {
    try writer.writeInt(i64, value, .big);
}

pub fn decodeInt64(reader: anytype) !i64 {
    return try reader.readInt(i64, .big);
}

/// Uint16 - unsigned 16-bit integer (big-endian)
pub fn encodeUint16(writer: anytype, value: u16) !void {
    try writer.writeInt(u16, value, .big);
}

pub fn decodeUint16(reader: anytype) !u16 {
    return try reader.readInt(u16, .big);
}

/// Uint32 - unsigned 32-bit integer (big-endian)
pub fn encodeUint32(writer: anytype, value: u32) !void {
    try writer.writeInt(u32, value, .big);
}

pub fn decodeUint32(reader: anytype) !u32 {
    return try reader.readInt(u32, .big);
}

/// Float64 - IEEE 754 double precision
pub fn encodeFloat64(writer: anytype, value: f64) !void {
    const bits: u64 = @bitCast(value);
    try writer.writeInt(u64, bits, .big);
}

pub fn decodeFloat64(reader: anytype) !f64 {
    const bits = try reader.readInt(u64, .big);
    return @bitCast(bits);
}

/// UUID - 128-bit identifier
pub fn encodeUuid(writer: anytype, value: [16]u8) !void {
    try writer.writeAll(&value);
}

pub fn decodeUuid(reader: anytype) ![16]u8 {
    var uuid: [16]u8 = undefined;
    _ = try reader.readAll(&uuid);
    return uuid;
}

// ============================================================================
// VARIABLE LENGTH TYPES
// ============================================================================

/// String - length-prefixed UTF-8 string
pub fn encodeString(writer: anytype, value: ?[]const u8) !void {
    if (value) |str| {
        try encodeInt16(writer, @intCast(str.len));
        try writer.writeAll(str);
    } else {
        try encodeInt16(writer, -1); // Null string
    }
}

pub fn decodeString(reader: anytype, allocator: std.mem.Allocator) !?[]const u8 {
    const len = try decodeInt16(reader);
    if (len < 0) {
        return null; // Null string
    }
    if (len == 0) {
        return ""; // Empty string
    }
    const bytes = try allocator.alloc(u8, @intCast(len));
    _ = try reader.readAll(bytes);
    return bytes;
}

/// Non-nullable String decode — coerces wire null to empty string.
/// Used for string array element decoding where elements are non-optional.
pub fn decodeNonNullableString(reader: anytype, allocator: std.mem.Allocator) ![]const u8 {
    return try decodeString(reader, allocator) orelse "";
}

/// Non-nullable CompactString decode — coerces wire null to empty string.
pub fn decodeNonNullableCompactString(reader: anytype, allocator: std.mem.Allocator) ![]const u8 {
    return try decodeCompactString(reader, allocator) orelse "";
}

/// Bytes - length-prefixed byte array
pub fn encodeBytes(writer: anytype, value: ?[]const u8) !void {
    if (value) |bytes| {
        try encodeInt32(writer, @intCast(bytes.len));
        try writer.writeAll(bytes);
    } else {
        try encodeInt32(writer, -1); // Null bytes
    }
}

pub fn decodeBytes(reader: anytype, allocator: std.mem.Allocator) !?[]const u8 {
    const len = try decodeInt32(reader);
    if (len < 0) {
        return null; // Null bytes
    }
    if (len == 0) {
        return &[_]u8{}; // Empty bytes
    }
    const bytes = try allocator.alloc(u8, @intCast(len));
    _ = try reader.readAll(bytes);
    return bytes;
}

/// Array - length-prefixed array of elements — nullable: null encodes as -1
/// Call an encode function, handling both 2-arg (writer, value) primitive
/// encoders and 3-arg (self, writer, version) generated-struct `encode`
/// methods. Mirrors `callDecodeFn`. Generated struct methods take `*const T`
/// as their first parameter, so pass a pointer to the element; primitive
/// encoders take the element by value. Version defaults to 0 (the same default
/// `callDecodeFn` uses); call sites that need a specific version emit an
/// explicit element loop instead of going through these helpers.
fn callEncodeFn(comptime T: type, encodeFn: anytype, writer: anytype, item: *const T) !void {
    const FnInfo = @typeInfo(@TypeOf(encodeFn)).@"fn";
    if (FnInfo.params.len == 3) {
        // 3-arg generated method: encode(self: *const T, writer, version)
        try encodeFn(item, writer, @as(i16, 0));
    } else {
        // 2-arg primitive encoder: encode(writer, value)
        try encodeFn(writer, item.*);
    }
}

/// Call a size function, handling both 1-arg (value) primitive sizers and
/// 2-arg (self, version) generated-struct `computeSize` methods. Mirrors
/// `callDecodeFn`/`callEncodeFn`.
fn callComputeFn(comptime T: type, computeFn: anytype, item: *const T) !usize {
    const FnInfo = @typeInfo(@TypeOf(computeFn)).@"fn";
    if (FnInfo.params.len == 2) {
        // 2-arg generated method: computeSize(self: *const T, version)
        return try computeFn(item, @as(i16, 0));
    } else {
        // 1-arg primitive sizer: computeSize(value)
        const result = computeFn(item.*);
        // Primitive sizers return usize directly; generated ones return !usize.
        return if (@typeInfo(@TypeOf(result)) == .error_union) try result else result;
    }
}

pub fn encodeArray(comptime T: type, writer: anytype, value: ?[]const T, encodeFn: anytype) !void {
    if (value) |array| {
        try encodeInt32(writer, @intCast(array.len));
        for (array) |*item| {
            try callEncodeFn(T, encodeFn, writer, item);
        }
    } else {
        try encodeInt32(writer, -1); // Null array
    }
}

/// Array for non-nullable fields — null means empty (0 elements), not null
pub fn encodeArrayNonNull(comptime T: type, writer: anytype, value: ?[]const T, encodeFn: anytype) !void {
    if (value) |array| {
        try encodeInt32(writer, @intCast(array.len));
        for (array) |*item| {
            try callEncodeFn(T, encodeFn, writer, item);
        }
    } else {
        try encodeInt32(writer, 0); // Empty array
    }
}

/// Call a decode function, handling both 2-arg (reader, allocator) and 3-arg (reader, version, allocator) signatures.
/// Generated protocol structs use 3-arg decode; hand-written types may use 2-arg.
fn callDecodeFn(comptime T: type, decodeFn: anytype, reader: anytype, allocator: std.mem.Allocator) !T {
    const FnInfo = @typeInfo(@TypeOf(decodeFn)).@"fn";
    if (FnInfo.params.len == 3) {
        // 3-arg: decode(reader, version, allocator) — pass version 0 as default
        return decodeFn(reader, @as(i16, 0), allocator);
    } else {
        // 2-arg: decode(reader, allocator)
        return decodeFn(reader, allocator);
    }
}

pub fn decodeArray(comptime T: type, reader: anytype, allocator: std.mem.Allocator, decodeFn: anytype) !?[]T {
    const len = try decodeInt32(reader);
    if (len < 0) {
        return null; // Null array
    }
    if (len == 0) {
        return &[_]T{}; // Empty array
    }
    const array = try allocator.alloc(T, @intCast(len));
    for (array) |*item| {
        item.* = try callDecodeFn(T, decodeFn, reader, allocator);
    }
    return array;
}

/// Encode array length only (for when elements are encoded separately) — nullable: null encodes as -1
pub fn encodeArrayLen(writer: anytype, array: anytype) !void {
    if (array) |arr| {
        const len: i32 = @intCast(arr.len);
        try encodeInt32(writer, len);
    } else {
        try encodeInt32(writer, -1); // Null array
    }
}

/// Encode array length for non-nullable fields — null means empty (0 elements), not null
pub fn encodeArrayLenNonNull(writer: anytype, array: anytype) !void {
    if (array) |arr| {
        const len: i32 = @intCast(arr.len);
        try encodeInt32(writer, len);
    } else {
        try encodeInt32(writer, 0); // 0 means empty array
    }
}

/// Decode array length only
pub fn decodeArrayLen(reader: anytype) !usize {
    const len = try decodeInt32(reader);
    if (len < 0) return 0; // Treat null as empty
    return @intCast(len);
}

/// Decode array of primitives (for generator)
pub fn decodePrimitiveArray(comptime T: type, reader: anytype, allocator: std.mem.Allocator, decodeFn: anytype) !?[]T {
    const len = try decodeInt32(reader);
    if (len < 0) {
        return null; // Null array
    }
    if (len == 0) {
        return &[_]T{}; // Empty array
    }
    const array = try allocator.alloc(T, @intCast(len));
    for (array) |*item| {
        item.* = try decodeFn(reader);
    }
    return array;
}

/// Decode compact array of primitives (for generator)
pub fn decodeCompactPrimitiveArray(comptime T: type, reader: anytype, allocator: std.mem.Allocator, decodeFn: anytype) !?[]T {
    const len = try decodeUnsignedVarInt(reader);
    if (len == 0) {
        return null; // Null array
    }
    const actual_len = len - 1;
    if (actual_len == 0) {
        return &[_]T{}; // Empty array
    }
    const array = try allocator.alloc(T, actual_len);
    for (array) |*item| {
        item.* = try decodeFn(reader);
    }
    return array;
}

/// Encode compact array length (for flexible versions) — nullable: null encodes as 0 (null sentinel)
pub fn encodeCompactArrayLen(writer: anytype, array: anytype) !void {
    if (array) |arr| {
        const len: u32 = @intCast(arr.len + 1); // +1 for compact encoding
        try encodeUnsignedVarInt(writer, len);
    } else {
        try encodeUnsignedVarInt(writer, 0); // 0 means null
    }
}

/// Encode compact array length for non-nullable fields — null means empty (0 elements), not null
pub fn encodeCompactArrayLenNonNull(writer: anytype, array: anytype) !void {
    if (array) |arr| {
        const len: u32 = @intCast(arr.len + 1);
        try encodeUnsignedVarInt(writer, len);
    } else {
        try encodeUnsignedVarInt(writer, 1); // 1 means empty array (0 elements)
    }
}

/// Decode compact array length
pub fn decodeCompactArrayLen(reader: anytype) !usize {
    const len = try decodeUnsignedVarInt(reader);
    if (len == 0) return 0; // 0 means null
    return @intCast(len - 1); // Subtract 1 for compact encoding
}

// ============================================================================
// COMPACT TYPES (for flexible versions)
// ============================================================================

/// Unsigned VarInt - variable-length integer encoding
pub fn encodeUnsignedVarInt(writer: anytype, value: u32) !void {
    var v = value;
    while (v >= 0x80) {
        try writer.writeByte(@intCast((v & 0x7F) | 0x80));
        v >>= 7;
    }
    try writer.writeByte(@intCast(v & 0x7F));
}

pub fn decodeUnsignedVarInt(reader: anytype) !u32 {
    var value: u32 = 0;
    var shift: u5 = 0;
    
    while (true) {
        const byte = try reader.readByte();
        
        if (shift >= 28 and byte > 0x0F) {
            return Error.InvalidVarInt;
        }
        
        value |= @as(u32, byte & 0x7F) << shift;
        
        if ((byte & 0x80) == 0) {
            return value;
        }
        
        shift += 7;
        if (shift >= 32) {
            return Error.InvalidVarInt;
        }
    }
}

/// Signed VarInt - zigzag encoded variable-length integer
pub fn encodeVarInt(writer: anytype, value: i32) !void {
    const encoded = zigzagEncode(value);
    try encodeUnsignedVarInt(writer, encoded);
}

pub fn decodeVarInt(reader: anytype) !i32 {
    const encoded = try decodeUnsignedVarInt(reader);
    return zigzagDecode(encoded);
}

/// VarLong - variable-length long integer
pub fn encodeVarLong(writer: anytype, value: i64) !void {
    var v = zigzagEncodeLong(value);
    while (v >= 0x80) {
        try writer.writeByte(@intCast((v & 0x7F) | 0x80));
        v >>= 7;
    }
    try writer.writeByte(@intCast(v & 0x7F));
}

pub fn decodeVarLong(reader: anytype) !i64 {
    var value: u64 = 0;
    var shift: u6 = 0;
    
    while (true) {
        const byte = try reader.readByte();
        
        value |= @as(u64, byte & 0x7F) << shift;
        
        if ((byte & 0x80) == 0) {
            return zigzagDecodeLong(value);
        }
        
        shift += 7;
        if (shift >= 64) {
            return Error.InvalidVarInt;
        }
    }
}

/// Compact String - uses unsigned varint for length
pub fn encodeCompactString(writer: anytype, value: ?[]const u8) !void {
    if (value) |str| {
        try encodeUnsignedVarInt(writer, @intCast(str.len + 1));
        try writer.writeAll(str);
    } else {
        try encodeUnsignedVarInt(writer, 0); // Null string
    }
}

pub fn decodeCompactString(reader: anytype, allocator: std.mem.Allocator) !?[]const u8 {
    const len = try decodeUnsignedVarInt(reader);
    if (len == 0) {
        return null; // Null string
    }
    const actual_len = len - 1;
    if (actual_len == 0) {
        return ""; // Empty string
    }
    const bytes = try allocator.alloc(u8, actual_len);
    _ = try reader.readAll(bytes);
    return bytes;
}

/// Compact Bytes - uses unsigned varint for length
pub fn encodeCompactBytes(writer: anytype, value: ?[]const u8) !void {
    if (value) |bytes| {
        try encodeUnsignedVarInt(writer, @intCast(bytes.len + 1));
        try writer.writeAll(bytes);
    } else {
        try encodeUnsignedVarInt(writer, 0); // Null bytes
    }
}

pub fn decodeCompactBytes(reader: anytype, allocator: std.mem.Allocator) !?[]const u8 {
    const len = try decodeUnsignedVarInt(reader);
    if (len == 0) {
        return null; // Null bytes
    }
    const actual_len = len - 1;
    if (actual_len == 0) {
        return &[_]u8{}; // Empty bytes
    }
    const bytes = try allocator.alloc(u8, actual_len);
    _ = try reader.readAll(bytes);
    return bytes;
}

/// Non-nullable Bytes decode — coerces wire null to empty.
pub fn decodeNonNullableBytes(reader: anytype, allocator: std.mem.Allocator) ![]const u8 {
    return try decodeBytes(reader, allocator) orelse "";
}

/// Non-nullable CompactBytes decode — coerces wire null to empty.
pub fn decodeNonNullableCompactBytes(reader: anytype, allocator: std.mem.Allocator) ![]const u8 {
    return try decodeCompactBytes(reader, allocator) orelse "";
}

/// Compact Array - uses unsigned varint for length — nullable: null encodes as 0
pub fn encodeCompactArray(comptime T: type, writer: anytype, value: ?[]const T, encodeFn: anytype) !void {
    if (value) |array| {
        try encodeUnsignedVarInt(writer, @intCast(array.len + 1));
        for (array) |*item| {
            try callEncodeFn(T, encodeFn, writer, item);
        }
    } else {
        try encodeUnsignedVarInt(writer, 0); // Null array
    }
}

/// Compact Array for non-nullable fields — null means empty (0 elements), not null
pub fn encodeCompactArrayNonNull(comptime T: type, writer: anytype, value: ?[]const T, encodeFn: anytype) !void {
    if (value) |array| {
        try encodeUnsignedVarInt(writer, @intCast(array.len + 1));
        for (array) |*item| {
            try callEncodeFn(T, encodeFn, writer, item);
        }
    } else {
        try encodeUnsignedVarInt(writer, 1); // Empty array (0 elements)
    }
}

pub fn decodeCompactArray(comptime T: type, reader: anytype, allocator: std.mem.Allocator, decodeFn: anytype) !?[]T {
    const len = try decodeUnsignedVarInt(reader);
    if (len == 0) {
        return null; // Null array
    }
    const actual_len = len - 1;
    if (actual_len == 0) {
        return &[_]T{}; // Empty array
    }
    const array = try allocator.alloc(T, actual_len);
    for (array) |*item| {
        item.* = try callDecodeFn(T, decodeFn, reader, allocator);
    }
    return array;
}

// ============================================================================
// TAGGED FIELDS (for flexible versions)
// ============================================================================

pub const TaggedField = struct {
    tag: u32,
    data: []const u8,
};

/// Encode tagged fields
pub fn encodeTaggedFields(writer: anytype, fields: []const TaggedField) !void {
    try encodeUnsignedVarInt(writer, @intCast(fields.len));
    
    for (fields) |field| {
        try encodeUnsignedVarInt(writer, field.tag);
        try encodeUnsignedVarInt(writer, @intCast(field.data.len));
        try writer.writeAll(field.data);
    }
}

/// Decode tagged fields
pub fn decodeTaggedFields(reader: anytype, allocator: std.mem.Allocator) ![]TaggedField {
    const count = try decodeUnsignedVarInt(reader);
    if (count == 0) {
        return &[_]TaggedField{};
    }
    
    const fields = try allocator.alloc(TaggedField, count);
    
    for (fields) |*field| {
        field.tag = try decodeUnsignedVarInt(reader);
        const len = try decodeUnsignedVarInt(reader);
        field.data = try allocator.alloc(u8, len);
        _ = try reader.readAll(@constCast(field.data));
    }
    
    return fields;
}

// ============================================================================
// SIZE COMPUTATION FUNCTIONS (for compute_size methods)
// ============================================================================

/// Compute size of boolean (1 byte)
pub fn computeSizeBoolean(_: bool) usize {
    return 1;
}

/// Compute size of int8 (1 byte)
pub fn computeSizeInt8(_: i8) usize {
    return 1;
}

/// Compute size of int16 (2 bytes)
pub fn computeSizeInt16(_: i16) usize {
    return 2;
}

/// Compute size of int32 (4 bytes)
pub fn computeSizeInt32(_: i32) usize {
    return 4;
}

/// Compute size of int64 (8 bytes)
pub fn computeSizeInt64(_: i64) usize {
    return 8;
}

/// Compute size of uint16 (2 bytes)
pub fn computeSizeUint16(_: u16) usize {
    return 2;
}

/// Compute size of uint32 (4 bytes)
pub fn computeSizeUint32(_: u32) usize {
    return 4;
}

/// Compute size of float64 (8 bytes)
pub fn computeSizeFloat64(_: f64) usize {
    return 8;
}

/// Compute size of UUID (16 bytes)
pub fn computeSizeUuid(_: [16]u8) usize {
    return 16;
}

/// Compute size of string (2 bytes length + string bytes)
pub fn computeSizeString(value: ?[]const u8) usize {
    if (value) |str| {
        return 2 + str.len; // int16 length + data
    }
    return 2; // -1 length for null
}

/// Compute size of bytes (4 bytes length + byte data)
pub fn computeSizeBytes(value: ?[]const u8) usize {
    if (value) |bytes| {
        return 4 + bytes.len; // int32 length + data
    }
    return 4; // -1 length for null
}

/// Compute size of unsigned varint
pub fn computeSizeUnsignedVarInt(value: u32) usize {
    var v = value;
    var size: usize = 0;
    while (v >= 0x80) : (v >>= 7) {
        size += 1;
    }
    return size + 1;
}

/// Compute size of signed varint
pub fn computeSizeVarInt(value: i32) usize {
    return computeSizeUnsignedVarInt(zigzagEncode(value));
}

/// Compute size of varlong
pub fn computeSizeVarLong(value: i64) usize {
    var v = zigzagEncodeLong(value);
    var size: usize = 0;
    while (v >= 0x80) : (v >>= 7) {
        size += 1;
    }
    return size + 1;
}

/// Compute size of compact string (varint length + string bytes)
pub fn computeSizeCompactString(value: ?[]const u8) usize {
    if (value) |str| {
        const len: u32 = @intCast(str.len + 1);
        return computeSizeUnsignedVarInt(len) + str.len;
    }
    return computeSizeUnsignedVarInt(0); // null
}

/// Compute size of compact bytes (varint length + byte data)
pub fn computeSizeCompactBytes(value: ?[]const u8) usize {
    if (value) |bytes| {
        const len: u32 = @intCast(bytes.len + 1);
        return computeSizeUnsignedVarInt(len) + bytes.len;
    }
    return computeSizeUnsignedVarInt(0); // null
}

/// Compute size of array (int32 length + elements)
pub fn computeSizeArray(comptime T: type, value: ?[]const T, computeFn: anytype) !usize {
    if (value) |array| {
        var size: usize = 4; // int32 length
        for (array) |*item| {
            size += try callComputeFn(T, computeFn, item);
        }
        return size;
    }
    return 4; // -1 length for null
}

/// Compute size of compact array (varint length + elements) — nullable: null counted as varint(0)
pub fn computeSizeCompactArray(comptime T: type, value: ?[]const T, computeFn: anytype) !usize {
    if (value) |array| {
        const len: u32 = @intCast(array.len + 1);
        var size: usize = computeSizeUnsignedVarInt(len);
        for (array) |*item| {
            size += try callComputeFn(T, computeFn, item);
        }
        return size;
    }
    return computeSizeUnsignedVarInt(0); // null
}

/// Compute size of non-nullable compact array length — null treated as empty (varint(1))
pub fn computeSizeCompactArrayLenNonNull(array: anytype) usize {
    if (array) |arr| {
        const len: u32 = @intCast(arr.len + 1);
        return computeSizeUnsignedVarInt(len);
    } else {
        return computeSizeUnsignedVarInt(1); // empty array
    }
}

/// Compute size of non-nullable classic array length — always 4 bytes (i32)
pub fn computeSizeArrayLenNonNull(_: anytype) usize {
    return 4;
}

/// Compute size of tagged fields
pub fn computeSizeTaggedFields(fields: []const TaggedField) usize {
    var size = computeSizeUnsignedVarInt(@intCast(fields.len));
    for (fields) |field| {
        size += computeSizeUnsignedVarInt(field.tag);
        size += computeSizeUnsignedVarInt(@intCast(field.data.len));
        size += field.data.len;
    }
    return size;
}

// ============================================================================
// UTILITY FUNCTIONS
// ============================================================================

/// Zigzag encode for VarInt
fn zigzagEncode(n: i32) u32 {
    return @bitCast((n << 1) ^ (n >> 31));
}

/// Zigzag decode for VarInt
fn zigzagDecode(n: u32) i32 {
    return @bitCast((n >> 1) ^ (~(n & 1) +% 1));
}

/// Zigzag encode for VarLong
fn zigzagEncodeLong(n: i64) u64 {
    return @bitCast((n << 1) ^ (n >> 63));
}

/// Zigzag decode for VarLong
fn zigzagDecodeLong(n: u64) i64 {
    return @bitCast((n >> 1) ^ (~(n & 1) +% 1));
}

// ============================================================================
// VERSION RANGE PARSING
// ============================================================================

pub const VersionRange = struct {
    min: i16,
    max: i16,
    
    /// Parse version range string (e.g., "0+", "3-7", "5")
    pub fn parse(str: []const u8) !VersionRange {
        if (str.len == 0) {
            return Error.InvalidVersion;
        }
        
        // Handle "N+" format
        if (str[str.len - 1] == '+') {
            const min = try std.fmt.parseInt(i16, str[0..str.len - 1], 10);
            return VersionRange{ .min = min, .max = std.math.maxInt(i16) };
        }
        
        // Handle "M-N" format
        if (mem.indexOf(u8, str, "-")) |dash_pos| {
            const min = try std.fmt.parseInt(i16, str[0..dash_pos], 10);
            const max = try std.fmt.parseInt(i16, str[dash_pos + 1..], 10);
            return VersionRange{ .min = min, .max = max };
        }
        
        // Handle single version "N"
        const version = try std.fmt.parseInt(i16, str, 10);
        return VersionRange{ .min = version, .max = version };
    }
    
    /// Check if version is in range
    pub fn contains(self: VersionRange, version: i16) bool {
        return version >= self.min and version <= self.max;
    }
};

// ============================================================================
// TESTS
// ============================================================================

test "VarInt encoding/decoding" {
    const testing = std.testing;
    
    // Test cases from Kafka protocol
    const test_cases = [_]struct { value: i32, encoded: []const u8 }{
        .{ .value = 0, .encoded = &[_]u8{0x00} },
        .{ .value = -1, .encoded = &[_]u8{0x01} },
        .{ .value = 1, .encoded = &[_]u8{0x02} },
        .{ .value = 63, .encoded = &[_]u8{0x7E} },
        .{ .value = -64, .encoded = &[_]u8{0x7F} },
        .{ .value = 64, .encoded = &[_]u8{0x80, 0x01} },
        .{ .value = -65, .encoded = &[_]u8{0x81, 0x01} },
        .{ .value = 300, .encoded = &[_]u8{0xD8, 0x04} },
        .{ .value = -300, .encoded = &[_]u8{0xD7, 0x04} },
    };
    
    for (test_cases) |tc| {
        // Encode
        var buffer = std.array_list.Managed(u8).init(testing.allocator);
        defer buffer.deinit();
        try encodeVarInt(buffer.writer(), tc.value);
        try testing.expectEqualSlices(u8, tc.encoded, buffer.items);
        
        // Decode
        var stream = @import("ztime").fixedBufferStream(tc.encoded);
        const decoded = try decodeVarInt(stream.reader());
        try testing.expectEqual(tc.value, decoded);
    }
}

test "CompactString encoding/decoding" {
    const testing = std.testing;
    const allocator = testing.allocator;
    
    // Test null string
    {
        var buffer = std.array_list.Managed(u8).init(allocator);
        defer buffer.deinit();
        try encodeCompactString(buffer.writer(), null);
        try testing.expectEqualSlices(u8, &[_]u8{0x00}, buffer.items);
        
        var stream = @import("ztime").fixedBufferStream(buffer.items);
        const decoded = try decodeCompactString(stream.reader(), allocator);
        try testing.expect(decoded == null);
    }
    
    // Test empty string
    {
        var buffer = std.array_list.Managed(u8).init(allocator);
        defer buffer.deinit();
        try encodeCompactString(buffer.writer(), "");
        try testing.expectEqualSlices(u8, &[_]u8{0x01}, buffer.items);
        
        var stream = @import("ztime").fixedBufferStream(buffer.items);
        const decoded = try decodeCompactString(stream.reader(), allocator);
        defer if (decoded) |s| allocator.free(s);
        try testing.expectEqualStrings("", decoded.?);
    }
    
    // Test regular string
    {
        var buffer = std.array_list.Managed(u8).init(allocator);
        defer buffer.deinit();
        try encodeCompactString(buffer.writer(), "hello");
        try testing.expectEqualSlices(u8, &[_]u8{0x06} ++ "hello", buffer.items);
        
        var stream = @import("ztime").fixedBufferStream(buffer.items);
        const decoded = try decodeCompactString(stream.reader(), allocator);
        defer if (decoded) |s| allocator.free(s);
        try testing.expectEqualStrings("hello", decoded.?);
    }
}

test "Version range parsing" {
    const testing = std.testing;

    // Test single version
    {
        const range = try VersionRange.parse("5");
        try testing.expectEqual(@as(i16, 5), range.min);
        try testing.expectEqual(@as(i16, 5), range.max);
        try testing.expect(range.contains(5));
        try testing.expect(!range.contains(4));
        try testing.expect(!range.contains(6));
    }

    // Test range
    {
        const range = try VersionRange.parse("3-7");
        try testing.expectEqual(@as(i16, 3), range.min);
        try testing.expectEqual(@as(i16, 7), range.max);
        try testing.expect(range.contains(3));
        try testing.expect(range.contains(5));
        try testing.expect(range.contains(7));
        try testing.expect(!range.contains(2));
        try testing.expect(!range.contains(8));
    }

    // Test open-ended range
    {
        const range = try VersionRange.parse("9+");
        try testing.expectEqual(@as(i16, 9), range.min);
        try testing.expectEqual(std.math.maxInt(i16), range.max);
        try testing.expect(range.contains(9));
        try testing.expect(range.contains(100));
        try testing.expect(!range.contains(8));
    }
}

test "Boolean encoding/decoding" {
    const testing = std.testing;

    for ([_]bool{ true, false }) |val| {
        var buf = std.array_list.Managed(u8).init(testing.allocator);
        defer buf.deinit();
        try encodeBoolean(buf.writer(), val);
        try testing.expectEqual(@as(usize, 1), buf.items.len);
        try testing.expectEqual(computeSizeBoolean(val), buf.items.len);

        var stream = @import("ztime").fixedBufferStream(buf.items);
        const decoded = try decodeBoolean(stream.reader());
        try testing.expectEqual(val, decoded);
    }
    // Non-zero byte should decode as true
    {
        const bytes = [_]u8{0x42};
        var stream = @import("ztime").fixedBufferStream(&bytes);
        const decoded = try decodeBoolean(stream.reader());
        try testing.expect(decoded == true);
    }
}

test "Int8 encoding/decoding" {
    const testing = std.testing;
    const values = [_]i8{ 0, 1, -1, 127, -128 };
    for (values) |val| {
        var buf = std.array_list.Managed(u8).init(testing.allocator);
        defer buf.deinit();
        try encodeInt8(buf.writer(), val);
        try testing.expectEqual(@as(usize, 1), buf.items.len);
        try testing.expectEqual(computeSizeInt8(val), buf.items.len);

        var stream = @import("ztime").fixedBufferStream(buf.items);
        try testing.expectEqual(val, try decodeInt8(stream.reader()));
    }
}

test "Int16 encoding/decoding big-endian" {
    const testing = std.testing;
    const values = [_]i16{ 0, 1, -1, 256, -256, 32767, -32768 };
    for (values) |val| {
        var buf = std.array_list.Managed(u8).init(testing.allocator);
        defer buf.deinit();
        try encodeInt16(buf.writer(), val);
        try testing.expectEqual(@as(usize, 2), buf.items.len);
        try testing.expectEqual(computeSizeInt16(val), buf.items.len);

        var stream = @import("ztime").fixedBufferStream(buf.items);
        try testing.expectEqual(val, try decodeInt16(stream.reader()));
    }
    // Verify big-endian byte order: 0x0100 = 256
    {
        var buf = std.array_list.Managed(u8).init(testing.allocator);
        defer buf.deinit();
        try encodeInt16(buf.writer(), 256);
        try testing.expectEqualSlices(u8, &[_]u8{ 0x01, 0x00 }, buf.items);
    }
}

test "Int32 encoding/decoding big-endian" {
    const testing = std.testing;
    const values = [_]i32{ 0, 1, -1, 65536, -65536, std.math.maxInt(i32), std.math.minInt(i32) };
    for (values) |val| {
        var buf = std.array_list.Managed(u8).init(testing.allocator);
        defer buf.deinit();
        try encodeInt32(buf.writer(), val);
        try testing.expectEqual(@as(usize, 4), buf.items.len);
        try testing.expectEqual(computeSizeInt32(val), buf.items.len);

        var stream = @import("ztime").fixedBufferStream(buf.items);
        try testing.expectEqual(val, try decodeInt32(stream.reader()));
    }
    // Verify big-endian: 0x00010000 = 65536
    {
        var buf = std.array_list.Managed(u8).init(testing.allocator);
        defer buf.deinit();
        try encodeInt32(buf.writer(), 65536);
        try testing.expectEqualSlices(u8, &[_]u8{ 0x00, 0x01, 0x00, 0x00 }, buf.items);
    }
}

test "Int64 encoding/decoding big-endian" {
    const testing = std.testing;
    const values = [_]i64{ 0, 1, -1, 0x100000000, -0x100000000, std.math.maxInt(i64), std.math.minInt(i64) };
    for (values) |val| {
        var buf = std.array_list.Managed(u8).init(testing.allocator);
        defer buf.deinit();
        try encodeInt64(buf.writer(), val);
        try testing.expectEqual(@as(usize, 8), buf.items.len);
        try testing.expectEqual(computeSizeInt64(val), buf.items.len);

        var stream = @import("ztime").fixedBufferStream(buf.items);
        try testing.expectEqual(val, try decodeInt64(stream.reader()));
    }
}

test "Uint16 encoding/decoding" {
    const testing = std.testing;
    const values = [_]u16{ 0, 1, 255, 256, 65535 };
    for (values) |val| {
        var buf = std.array_list.Managed(u8).init(testing.allocator);
        defer buf.deinit();
        try encodeUint16(buf.writer(), val);
        try testing.expectEqual(@as(usize, 2), buf.items.len);
        try testing.expectEqual(computeSizeUint16(val), buf.items.len);

        var stream = @import("ztime").fixedBufferStream(buf.items);
        try testing.expectEqual(val, try decodeUint16(stream.reader()));
    }
}

test "Uint32 encoding/decoding" {
    const testing = std.testing;
    const values = [_]u32{ 0, 1, 65535, 65536, std.math.maxInt(u32) };
    for (values) |val| {
        var buf = std.array_list.Managed(u8).init(testing.allocator);
        defer buf.deinit();
        try encodeUint32(buf.writer(), val);
        try testing.expectEqual(@as(usize, 4), buf.items.len);
        try testing.expectEqual(computeSizeUint32(val), buf.items.len);

        var stream = @import("ztime").fixedBufferStream(buf.items);
        try testing.expectEqual(val, try decodeUint32(stream.reader()));
    }
}

test "Float64 encoding/decoding" {
    const testing = std.testing;
    const values = [_]f64{ 0.0, 1.0, -1.0, 3.14159265358979, std.math.floatMax(f64), std.math.floatMin(f64) };
    for (values) |val| {
        var buf = std.array_list.Managed(u8).init(testing.allocator);
        defer buf.deinit();
        try encodeFloat64(buf.writer(), val);
        try testing.expectEqual(@as(usize, 8), buf.items.len);
        try testing.expectEqual(computeSizeFloat64(val), buf.items.len);

        var stream = @import("ztime").fixedBufferStream(buf.items);
        try testing.expectEqual(val, try decodeFloat64(stream.reader()));
    }
}

test "UUID encoding/decoding" {
    const testing = std.testing;
    // Zero UUID
    {
        const zero_uuid = [_]u8{0} ** 16;
        var buf = std.array_list.Managed(u8).init(testing.allocator);
        defer buf.deinit();
        try encodeUuid(buf.writer(), zero_uuid);
        try testing.expectEqual(@as(usize, 16), buf.items.len);
        try testing.expectEqual(computeSizeUuid(zero_uuid), buf.items.len);

        var stream = @import("ztime").fixedBufferStream(buf.items);
        try testing.expectEqualSlices(u8, &zero_uuid, &try decodeUuid(stream.reader()));
    }
    // Non-zero UUID
    {
        const uuid = [16]u8{ 0x01, 0x23, 0x45, 0x67, 0x89, 0xab, 0xcd, 0xef, 0xfe, 0xdc, 0xba, 0x98, 0x76, 0x54, 0x32, 0x10 };
        var buf = std.array_list.Managed(u8).init(testing.allocator);
        defer buf.deinit();
        try encodeUuid(buf.writer(), uuid);

        var stream = @import("ztime").fixedBufferStream(buf.items);
        try testing.expectEqualSlices(u8, &uuid, &try decodeUuid(stream.reader()));
    }
}

test "VarInt extended zigzag table" {
    const testing = std.testing;

    // Extended zigzag encoding verification from Kafka protocol spec
    const extended_cases = [_]struct { value: i32, zigzag: u32 }{
        .{ .value = 0, .zigzag = 0 },
        .{ .value = -1, .zigzag = 1 },
        .{ .value = 1, .zigzag = 2 },
        .{ .value = -2, .zigzag = 3 },
        .{ .value = 2, .zigzag = 4 },
        .{ .value = std.math.maxInt(i32), .zigzag = @as(u32, std.math.maxInt(u32)) - 1 },
        .{ .value = std.math.minInt(i32), .zigzag = std.math.maxInt(u32) },
    };

    for (extended_cases) |tc| {
        try testing.expectEqual(tc.zigzag, zigzagEncode(tc.value));
        try testing.expectEqual(tc.value, zigzagDecode(tc.zigzag));
    }

    // Round-trip for max/min i32 through full encode/decode
    for ([_]i32{ std.math.maxInt(i32), std.math.minInt(i32), 0, 1, -1 }) |val| {
        var buf = std.array_list.Managed(u8).init(testing.allocator);
        defer buf.deinit();
        try encodeVarInt(buf.writer(), val);

        var stream = @import("ztime").fixedBufferStream(buf.items);
        try testing.expectEqual(val, try decodeVarInt(stream.reader()));

        // computeSize matches actual
        try testing.expectEqual(computeSizeVarInt(val), buf.items.len);
    }
}

test "UnsignedVarInt encoding/decoding" {
    const testing = std.testing;

    const cases = [_]struct { value: u32, encoded: []const u8 }{
        .{ .value = 0, .encoded = &[_]u8{0x00} },
        .{ .value = 1, .encoded = &[_]u8{0x01} },
        .{ .value = 127, .encoded = &[_]u8{0x7F} },
        .{ .value = 128, .encoded = &[_]u8{ 0x80, 0x01 } },
        .{ .value = 16383, .encoded = &[_]u8{ 0xFF, 0x7F } },
        .{ .value = 16384, .encoded = &[_]u8{ 0x80, 0x80, 0x01 } },
        .{ .value = std.math.maxInt(u32), .encoded = &[_]u8{ 0xFF, 0xFF, 0xFF, 0xFF, 0x0F } },
    };

    for (cases) |tc| {
        var buf = std.array_list.Managed(u8).init(testing.allocator);
        defer buf.deinit();
        try encodeUnsignedVarInt(buf.writer(), tc.value);
        try testing.expectEqualSlices(u8, tc.encoded, buf.items);
        try testing.expectEqual(computeSizeUnsignedVarInt(tc.value), buf.items.len);

        var stream = @import("ztime").fixedBufferStream(tc.encoded);
        try testing.expectEqual(tc.value, try decodeUnsignedVarInt(stream.reader()));
    }
}

test "VarLong encoding/decoding" {
    const testing = std.testing;

    const cases = [_]i64{ 0, 1, -1, 2, -2, 127, -128, 32767, -32768, std.math.maxInt(i64), std.math.minInt(i64) };
    for (cases) |val| {
        var buf = std.array_list.Managed(u8).init(testing.allocator);
        defer buf.deinit();
        try encodeVarLong(buf.writer(), val);

        // computeSize matches
        try testing.expectEqual(computeSizeVarLong(val), buf.items.len);

        var stream = @import("ztime").fixedBufferStream(buf.items);
        try testing.expectEqual(val, try decodeVarLong(stream.reader()));
    }

    // Verify zigzag encoding for VarLong
    try testing.expectEqual(@as(u64, 0), zigzagEncodeLong(0));
    try testing.expectEqual(@as(u64, 1), zigzagEncodeLong(-1));
    try testing.expectEqual(@as(u64, 2), zigzagEncodeLong(1));
    try testing.expectEqual(@as(u64, 3), zigzagEncodeLong(-2));
}

test "String encoding/decoding - null vs empty distinction" {
    const testing = std.testing;
    const allocator = testing.allocator;

    // Null string: length = -1 (0xFFFF as i16 big-endian)
    {
        var buf = std.array_list.Managed(u8).init(allocator);
        defer buf.deinit();
        try encodeString(buf.writer(), null);
        try testing.expectEqualSlices(u8, &[_]u8{ 0xFF, 0xFF }, buf.items);
        try testing.expectEqual(computeSizeString(null), buf.items.len);

        var stream = @import("ztime").fixedBufferStream(buf.items);
        const decoded = try decodeString(stream.reader(), allocator);
        try testing.expect(decoded == null);
    }
    // Empty string: length = 0
    {
        var buf = std.array_list.Managed(u8).init(allocator);
        defer buf.deinit();
        try encodeString(buf.writer(), "");
        try testing.expectEqualSlices(u8, &[_]u8{ 0x00, 0x00 }, buf.items);
        try testing.expectEqual(computeSizeString(""), buf.items.len);

        var stream = @import("ztime").fixedBufferStream(buf.items);
        const decoded = try decodeString(stream.reader(), allocator);
        try testing.expect(decoded != null);
        try testing.expectEqualStrings("", decoded.?);
    }
    // Regular string
    {
        var buf = std.array_list.Managed(u8).init(allocator);
        defer buf.deinit();
        try encodeString(buf.writer(), "test");
        try testing.expectEqual(@as(usize, 6), buf.items.len); // 2 + 4
        try testing.expectEqual(computeSizeString("test"), buf.items.len);

        var stream = @import("ztime").fixedBufferStream(buf.items);
        const decoded = try decodeString(stream.reader(), allocator);
        defer if (decoded) |s| allocator.free(s);
        try testing.expectEqualStrings("test", decoded.?);
    }
}

test "Bytes encoding/decoding - null vs empty distinction" {
    const testing = std.testing;
    const allocator = testing.allocator;

    // Null bytes: length = -1 (0xFFFFFFFF as i32 big-endian)
    {
        var buf = std.array_list.Managed(u8).init(allocator);
        defer buf.deinit();
        try encodeBytes(buf.writer(), null);
        try testing.expectEqualSlices(u8, &[_]u8{ 0xFF, 0xFF, 0xFF, 0xFF }, buf.items);
        try testing.expectEqual(computeSizeBytes(null), buf.items.len);

        var stream = @import("ztime").fixedBufferStream(buf.items);
        const decoded = try decodeBytes(stream.reader(), allocator);
        try testing.expect(decoded == null);
    }
    // Empty bytes: length = 0
    {
        var buf = std.array_list.Managed(u8).init(allocator);
        defer buf.deinit();
        try encodeBytes(buf.writer(), &[_]u8{});
        try testing.expectEqualSlices(u8, &[_]u8{ 0x00, 0x00, 0x00, 0x00 }, buf.items);
        try testing.expectEqual(computeSizeBytes(&[_]u8{}), buf.items.len);

        var stream = @import("ztime").fixedBufferStream(buf.items);
        const decoded = try decodeBytes(stream.reader(), allocator);
        try testing.expect(decoded != null);
        try testing.expectEqual(@as(usize, 0), decoded.?.len);
    }
    // Regular bytes
    {
        const data = &[_]u8{ 0xDE, 0xAD, 0xBE, 0xEF };
        var buf = std.array_list.Managed(u8).init(allocator);
        defer buf.deinit();
        try encodeBytes(buf.writer(), data);
        try testing.expectEqual(@as(usize, 8), buf.items.len); // 4 + 4
        try testing.expectEqual(computeSizeBytes(data), buf.items.len);

        var stream = @import("ztime").fixedBufferStream(buf.items);
        const decoded = try decodeBytes(stream.reader(), allocator);
        defer if (decoded) |d| allocator.free(d);
        try testing.expectEqualSlices(u8, data, decoded.?);
    }
}

test "CompactBytes encoding/decoding - null vs empty distinction" {
    const testing = std.testing;
    const allocator = testing.allocator;

    // Null: varint 0
    {
        var buf = std.array_list.Managed(u8).init(allocator);
        defer buf.deinit();
        try encodeCompactBytes(buf.writer(), null);
        try testing.expectEqualSlices(u8, &[_]u8{0x00}, buf.items);
        try testing.expectEqual(computeSizeCompactBytes(null), buf.items.len);

        var stream = @import("ztime").fixedBufferStream(buf.items);
        const decoded = try decodeCompactBytes(stream.reader(), allocator);
        try testing.expect(decoded == null);
    }
    // Empty: varint 1
    {
        var buf = std.array_list.Managed(u8).init(allocator);
        defer buf.deinit();
        try encodeCompactBytes(buf.writer(), &[_]u8{});
        try testing.expectEqualSlices(u8, &[_]u8{0x01}, buf.items);
        try testing.expectEqual(computeSizeCompactBytes(&[_]u8{}), buf.items.len);

        var stream = @import("ztime").fixedBufferStream(buf.items);
        const decoded = try decodeCompactBytes(stream.reader(), allocator);
        try testing.expect(decoded != null);
        try testing.expectEqual(@as(usize, 0), decoded.?.len);
    }
    // Regular
    {
        const data = &[_]u8{ 0xCA, 0xFE };
        var buf = std.array_list.Managed(u8).init(allocator);
        defer buf.deinit();
        try encodeCompactBytes(buf.writer(), data);
        try testing.expectEqual(computeSizeCompactBytes(data), buf.items.len);

        var stream = @import("ztime").fixedBufferStream(buf.items);
        const decoded = try decodeCompactBytes(stream.reader(), allocator);
        defer if (decoded) |d| allocator.free(d);
        try testing.expectEqualSlices(u8, data, decoded.?);
    }
}

test "CompactString with multi-byte varint length" {
    const testing = std.testing;
    const allocator = testing.allocator;

    // String longer than 127 bytes triggers multi-byte varint for length
    var long_str: [200]u8 = undefined;
    for (&long_str) |*b| b.* = 'A';

    var buf = std.array_list.Managed(u8).init(allocator);
    defer buf.deinit();
    try encodeCompactString(buf.writer(), &long_str);
    try testing.expectEqual(computeSizeCompactString(&long_str), buf.items.len);

    // Length is 201 (200 + 1) which needs 2 varint bytes
    try testing.expectEqual(@as(usize, 2 + 200), buf.items.len);

    var stream = @import("ztime").fixedBufferStream(buf.items);
    const decoded = try decodeCompactString(stream.reader(), allocator);
    defer if (decoded) |s| allocator.free(s);
    try testing.expectEqual(@as(usize, 200), decoded.?.len);
    try testing.expectEqualSlices(u8, &long_str, decoded.?);
}

test "Array encoding/decoding - null, empty, populated" {
    const testing = std.testing;
    const allocator = testing.allocator;

    // Null array: length = -1
    {
        var buf = std.array_list.Managed(u8).init(allocator);
        defer buf.deinit();
        try encodeArrayLen(buf.writer(), @as(?[]const i32, null));
        try testing.expectEqualSlices(u8, &[_]u8{ 0xFF, 0xFF, 0xFF, 0xFF }, buf.items);
    }
    // Empty array: length = 0
    {
        var buf = std.array_list.Managed(u8).init(allocator);
        defer buf.deinit();
        const empty: []const i32 = &[_]i32{};
        try encodeArrayLen(buf.writer(), @as(?[]const i32, empty));
        try testing.expectEqualSlices(u8, &[_]u8{ 0x00, 0x00, 0x00, 0x00 }, buf.items);
    }
    // Primitive array round-trip
    {
        var buf = std.array_list.Managed(u8).init(allocator);
        defer buf.deinit();
        const writer = buf.writer();

        // Write array of 3 int32s
        try encodeInt32(writer, 3); // length
        try encodeInt32(writer, 10);
        try encodeInt32(writer, 20);
        try encodeInt32(writer, 30);

        var stream = @import("ztime").fixedBufferStream(buf.items);
        const decoded = try decodePrimitiveArray(i32, stream.reader(), allocator, decodeInt32);
        defer if (decoded) |d| allocator.free(d);
        try testing.expect(decoded != null);
        try testing.expectEqual(@as(usize, 3), decoded.?.len);
        try testing.expectEqual(@as(i32, 10), decoded.?[0]);
        try testing.expectEqual(@as(i32, 20), decoded.?[1]);
        try testing.expectEqual(@as(i32, 30), decoded.?[2]);
    }
}

test "CompactArray encoding/decoding - null, empty, populated" {
    const testing = std.testing;
    const allocator = testing.allocator;

    // Null compact array: varint 0
    {
        var buf = std.array_list.Managed(u8).init(allocator);
        defer buf.deinit();
        try encodeCompactArrayLen(buf.writer(), @as(?[]const i32, null));
        try testing.expectEqualSlices(u8, &[_]u8{0x00}, buf.items);
    }
    // Empty compact array: varint 1
    {
        var buf = std.array_list.Managed(u8).init(allocator);
        defer buf.deinit();
        const empty: []const i32 = &[_]i32{};
        try encodeCompactArrayLen(buf.writer(), @as(?[]const i32, empty));
        try testing.expectEqualSlices(u8, &[_]u8{0x01}, buf.items);
    }
    // Compact primitive array round-trip
    {
        var buf = std.array_list.Managed(u8).init(allocator);
        defer buf.deinit();
        const writer = buf.writer();

        // Write: varint(3+1=4), then 3 int32s
        try encodeUnsignedVarInt(writer, 4); // length + 1
        try encodeInt32(writer, 100);
        try encodeInt32(writer, 200);
        try encodeInt32(writer, 300);

        var stream = @import("ztime").fixedBufferStream(buf.items);
        const decoded = try decodeCompactPrimitiveArray(i32, stream.reader(), allocator, decodeInt32);
        defer if (decoded) |d| allocator.free(d);
        try testing.expect(decoded != null);
        try testing.expectEqual(@as(usize, 3), decoded.?.len);
        try testing.expectEqual(@as(i32, 100), decoded.?[0]);
        try testing.expectEqual(@as(i32, 200), decoded.?[1]);
        try testing.expectEqual(@as(i32, 300), decoded.?[2]);
    }
}

test "TaggedFields encoding/decoding" {
    const testing = std.testing;
    const allocator = testing.allocator;

    // Empty tagged fields
    {
        var buf = std.array_list.Managed(u8).init(allocator);
        defer buf.deinit();
        try encodeTaggedFields(buf.writer(), &[_]TaggedField{});
        try testing.expectEqualSlices(u8, &[_]u8{0x00}, buf.items);
        try testing.expectEqual(computeSizeTaggedFields(&[_]TaggedField{}), buf.items.len);

        var stream = @import("ztime").fixedBufferStream(buf.items);
        const decoded = try decodeTaggedFields(stream.reader(), allocator);
        try testing.expectEqual(@as(usize, 0), decoded.len);
    }
    // Single tagged field
    {
        const data = &[_]u8{ 0xAA, 0xBB };
        const fields = [_]TaggedField{.{ .tag = 5, .data = data }};
        var buf = std.array_list.Managed(u8).init(allocator);
        defer buf.deinit();
        try encodeTaggedFields(buf.writer(), &fields);
        try testing.expectEqual(computeSizeTaggedFields(&fields), buf.items.len);

        var stream = @import("ztime").fixedBufferStream(buf.items);
        const decoded = try decodeTaggedFields(stream.reader(), allocator);
        defer {
            for (decoded) |f| allocator.free(@constCast(f.data));
            allocator.free(decoded);
        }
        try testing.expectEqual(@as(usize, 1), decoded.len);
        try testing.expectEqual(@as(u32, 5), decoded[0].tag);
        try testing.expectEqualSlices(u8, data, decoded[0].data);
    }
    // Multiple tagged fields
    {
        const data1 = &[_]u8{0x01};
        const data2 = &[_]u8{ 0x02, 0x03, 0x04 };
        const fields = [_]TaggedField{
            .{ .tag = 0, .data = data1 },
            .{ .tag = 10, .data = data2 },
        };
        var buf = std.array_list.Managed(u8).init(allocator);
        defer buf.deinit();
        try encodeTaggedFields(buf.writer(), &fields);
        try testing.expectEqual(computeSizeTaggedFields(&fields), buf.items.len);

        var stream = @import("ztime").fixedBufferStream(buf.items);
        const decoded = try decodeTaggedFields(stream.reader(), allocator);
        defer {
            for (decoded) |f| allocator.free(@constCast(f.data));
            allocator.free(decoded);
        }
        try testing.expectEqual(@as(usize, 2), decoded.len);
        try testing.expectEqual(@as(u32, 0), decoded[0].tag);
        try testing.expectEqualSlices(u8, data1, decoded[0].data);
        try testing.expectEqual(@as(u32, 10), decoded[1].tag);
        try testing.expectEqualSlices(u8, data2, decoded[1].data);
    }
}

test "computeSize consistency with encode for all types" {
    const testing = std.testing;
    const allocator = testing.allocator;

    // String computeSize
    {
        for ([_]?[]const u8{ null, "", "abc", "hello world" }) |val| {
            var buf = std.array_list.Managed(u8).init(allocator);
            defer buf.deinit();
            try encodeString(buf.writer(), val);
            try testing.expectEqual(computeSizeString(val), buf.items.len);
        }
    }
    // CompactString computeSize
    {
        for ([_]?[]const u8{ null, "", "abc", "hello world" }) |val| {
            var buf = std.array_list.Managed(u8).init(allocator);
            defer buf.deinit();
            try encodeCompactString(buf.writer(), val);
            try testing.expectEqual(computeSizeCompactString(val), buf.items.len);
        }
    }
    // Bytes computeSize
    {
        const empty_bytes: []const u8 = &[_]u8{};
        const some_bytes: []const u8 = &[_]u8{ 1, 2, 3 };
        for ([_]?[]const u8{ null, empty_bytes, some_bytes }) |val| {
            var buf = std.array_list.Managed(u8).init(allocator);
            defer buf.deinit();
            try encodeBytes(buf.writer(), val);
            try testing.expectEqual(computeSizeBytes(val), buf.items.len);
        }
    }
    // CompactBytes computeSize
    {
        const empty_bytes: []const u8 = &[_]u8{};
        const some_bytes: []const u8 = &[_]u8{ 1, 2, 3 };
        for ([_]?[]const u8{ null, empty_bytes, some_bytes }) |val| {
            var buf = std.array_list.Managed(u8).init(allocator);
            defer buf.deinit();
            try encodeCompactBytes(buf.writer(), val);
            try testing.expectEqual(computeSizeCompactBytes(val), buf.items.len);
        }
    }
    // VarInt computeSize for range of values
    {
        for ([_]i32{ 0, 1, -1, 63, -64, 64, -65, 8191, -8192, std.math.maxInt(i32), std.math.minInt(i32) }) |val| {
            var buf = std.array_list.Managed(u8).init(allocator);
            defer buf.deinit();
            try encodeVarInt(buf.writer(), val);
            try testing.expectEqual(computeSizeVarInt(val), buf.items.len);
        }
    }
    // VarLong computeSize
    {
        for ([_]i64{ 0, 1, -1, 127, -128, std.math.maxInt(i64), std.math.minInt(i64) }) |val| {
            var buf = std.array_list.Managed(u8).init(allocator);
            defer buf.deinit();
            try encodeVarLong(buf.writer(), val);
            try testing.expectEqual(computeSizeVarLong(val), buf.items.len);
        }
    }
}

test "UnsignedVarInt overflow detection" {
    const testing = std.testing;

    // 6 bytes with continuation bits — should fail (max 5 bytes for u32)
    const overflow_bytes = [_]u8{ 0x80, 0x80, 0x80, 0x80, 0x80, 0x01 };
    var stream = @import("ztime").fixedBufferStream(&overflow_bytes);
    const result = decodeUnsignedVarInt(stream.reader());
    try testing.expectError(Error.InvalidVarInt, result);
}

test "NonNull compact array encoding — null encodes as empty (varint 1)" {
    const testing = std.testing;

    // Nullable: null → varint 0 (null sentinel)
    {
        var buf = std.array_list.Managed(u8).init(testing.allocator);
        defer buf.deinit();
        try encodeCompactArrayLen(buf.writer(), @as(?[]const i32, null));
        try testing.expectEqualSlices(u8, &[_]u8{0x00}, buf.items);
    }

    // NonNull: null → varint 1 (empty array)
    {
        var buf = std.array_list.Managed(u8).init(testing.allocator);
        defer buf.deinit();
        try encodeCompactArrayLenNonNull(buf.writer(), @as(?[]const i32, null));
        try testing.expectEqualSlices(u8, &[_]u8{0x01}, buf.items);
    }

    // Both encode populated arrays identically
    {
        const arr: []const i32 = &[_]i32{ 1, 2, 3 };
        var buf_nullable = std.array_list.Managed(u8).init(testing.allocator);
        defer buf_nullable.deinit();
        try encodeCompactArrayLen(buf_nullable.writer(), @as(?[]const i32, arr));

        var buf_nonnull = std.array_list.Managed(u8).init(testing.allocator);
        defer buf_nonnull.deinit();
        try encodeCompactArrayLenNonNull(buf_nonnull.writer(), @as(?[]const i32, arr));

        // Both should write varint(4) = arr.len + 1
        try testing.expectEqualSlices(u8, &[_]u8{0x04}, buf_nullable.items);
        try testing.expectEqualSlices(u8, buf_nullable.items, buf_nonnull.items);
    }

    // Empty arrays also encode identically (varint 1)
    {
        const empty: []const i32 = &[_]i32{};
        var buf_nullable = std.array_list.Managed(u8).init(testing.allocator);
        defer buf_nullable.deinit();
        try encodeCompactArrayLen(buf_nullable.writer(), @as(?[]const i32, empty));

        var buf_nonnull = std.array_list.Managed(u8).init(testing.allocator);
        defer buf_nonnull.deinit();
        try encodeCompactArrayLenNonNull(buf_nonnull.writer(), @as(?[]const i32, empty));

        try testing.expectEqualSlices(u8, &[_]u8{0x01}, buf_nullable.items);
        try testing.expectEqualSlices(u8, buf_nullable.items, buf_nonnull.items);
    }
}

test "NonNull classic array encoding — null encodes as empty (i32 0)" {
    const testing = std.testing;

    // Nullable: null → i32(-1) = 0xFFFFFFFF
    {
        var buf = std.array_list.Managed(u8).init(testing.allocator);
        defer buf.deinit();
        try encodeArrayLen(buf.writer(), @as(?[]const i32, null));
        try testing.expectEqualSlices(u8, &[_]u8{ 0xFF, 0xFF, 0xFF, 0xFF }, buf.items);
    }

    // NonNull: null → i32(0) = 0x00000000
    {
        var buf = std.array_list.Managed(u8).init(testing.allocator);
        defer buf.deinit();
        try encodeArrayLenNonNull(buf.writer(), @as(?[]const i32, null));
        try testing.expectEqualSlices(u8, &[_]u8{ 0x00, 0x00, 0x00, 0x00 }, buf.items);
    }

    // Both encode populated arrays identically
    {
        const arr: []const i32 = &[_]i32{ 10, 20 };
        var buf_nullable = std.array_list.Managed(u8).init(testing.allocator);
        defer buf_nullable.deinit();
        try encodeArrayLen(buf_nullable.writer(), @as(?[]const i32, arr));

        var buf_nonnull = std.array_list.Managed(u8).init(testing.allocator);
        defer buf_nonnull.deinit();
        try encodeArrayLenNonNull(buf_nonnull.writer(), @as(?[]const i32, arr));

        // Both write i32(2) = 0x00000002
        try testing.expectEqualSlices(u8, &[_]u8{ 0x00, 0x00, 0x00, 0x02 }, buf_nullable.items);
        try testing.expectEqualSlices(u8, buf_nullable.items, buf_nonnull.items);
    }
}

test "NonNull computeSize — null counted as empty array, not null" {
    const testing = std.testing;

    // Compact: nullable null = varint(0) = 1 byte, non-nullable null = varint(1) = 1 byte
    // Both happen to be the same size (1 byte each), but encode different values
    try testing.expectEqual(@as(usize, 1), computeSizeUnsignedVarInt(0)); // nullable null
    try testing.expectEqual(@as(usize, 1), computeSizeUnsignedVarInt(1)); // non-nullable empty

    // computeSizeCompactArrayLenNonNull vs raw varint(0)/varint(1)
    try testing.expectEqual(computeSizeUnsignedVarInt(1), computeSizeCompactArrayLenNonNull(@as(?[]const i32, null)));

    // Populated: both same
    const arr: []const i32 = &[_]i32{ 1, 2, 3 };
    try testing.expectEqual(computeSizeUnsignedVarInt(4), computeSizeCompactArrayLenNonNull(@as(?[]const i32, arr)));

    // Classic: always 4 bytes
    try testing.expectEqual(@as(usize, 4), computeSizeArrayLenNonNull(@as(?[]const i32, null)));
    try testing.expectEqual(@as(usize, 4), computeSizeArrayLenNonNull(@as(?[]const i32, arr)));
}

test "encodeCompactArrayNonNull — full array with elements" {
    const testing = std.testing;

    // Null → varint(1) (empty), no elements
    {
        var buf = std.array_list.Managed(u8).init(testing.allocator);
        defer buf.deinit();
        try encodeCompactArrayNonNull(i32, buf.writer(), @as(?[]const i32, null), encodeInt32);
        try testing.expectEqualSlices(u8, &[_]u8{0x01}, buf.items); // varint(1) = empty
    }

    // Populated → varint(len+1) + elements
    {
        const arr: []const i32 = &[_]i32{42};
        var buf = std.array_list.Managed(u8).init(testing.allocator);
        defer buf.deinit();
        try encodeCompactArrayNonNull(i32, buf.writer(), @as(?[]const i32, arr), encodeInt32);
        // varint(2) + i32(42)
        try testing.expectEqualSlices(u8, &[_]u8{ 0x02, 0x00, 0x00, 0x00, 0x2A }, buf.items);
    }
}

test "encodeArrayNonNull — full array with elements" {
    const testing = std.testing;

    // Null → i32(0) (empty), no elements
    {
        var buf = std.array_list.Managed(u8).init(testing.allocator);
        defer buf.deinit();
        try encodeArrayNonNull(i32, buf.writer(), @as(?[]const i32, null), encodeInt32);
        try testing.expectEqualSlices(u8, &[_]u8{ 0x00, 0x00, 0x00, 0x00 }, buf.items); // i32(0)
    }

    // Populated → i32(len) + elements
    {
        const arr: []const i32 = &[_]i32{42};
        var buf = std.array_list.Managed(u8).init(testing.allocator);
        defer buf.deinit();
        try encodeArrayNonNull(i32, buf.writer(), @as(?[]const i32, arr), encodeInt32);
        // i32(1) + i32(42)
        try testing.expectEqualSlices(u8, &[_]u8{ 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x2A }, buf.items);
    }
}

// ============================================================================
// Common Kafka Protocol Nested Types
// ============================================================================

/// ReplicaState - Used in FetchRequest v15+ (KIP-903)
pub const ReplicaState = struct {
    replica_id: i32 = -1,
    replica_epoch: i64 = -1,
};

/// EpochEndOffset - Used for diverging epoch detection in FetchResponse v12+
pub const EpochEndOffset = struct {
    epoch: i32 = -1,
    end_offset: i64 = -1,
};

/// LeaderIdAndEpoch - Current leader information in FetchResponse v12+
pub const LeaderIdAndEpoch = struct {
    leader_id: i32 = -1,
    leader_epoch: i32 = -1,
};

/// Encode ReplicaState
pub fn encodeReplicaState(writer: anytype, value: ReplicaState) !void {
    try writer.writeInt(i32, value.replica_id, .big);
    try writer.writeInt(i64, value.replica_epoch, .big);
}

/// Decode ReplicaState
pub fn decodeReplicaState(reader: anytype) !ReplicaState {
    return ReplicaState{
        .replica_id = try reader.readInt(i32, .big),
        .replica_epoch = try reader.readInt(i64, .big),
    };
}

/// Encode EpochEndOffset
pub fn encodeEpochEndOffset(writer: anytype, value: EpochEndOffset) !void {
    try writer.writeInt(i32, value.epoch, .big);
    try writer.writeInt(i64, value.end_offset, .big);
}

/// Decode EpochEndOffset
pub fn decodeEpochEndOffset(reader: anytype) !EpochEndOffset {
    return EpochEndOffset{
        .epoch = try reader.readInt(i32, .big),
        .end_offset = try reader.readInt(i64, .big),
    };
}

/// Encode LeaderIdAndEpoch
pub fn encodeLeaderIdAndEpoch(writer: anytype, value: LeaderIdAndEpoch) !void {
    try writer.writeInt(i32, value.leader_id, .big);
    try writer.writeInt(i32, value.leader_epoch, .big);
}

/// Decode LeaderIdAndEpoch
pub fn decodeLeaderIdAndEpoch(reader: anytype) !LeaderIdAndEpoch {
    return LeaderIdAndEpoch{
        .leader_id = try reader.readInt(i32, .big),
        .leader_epoch = try reader.readInt(i32, .big),
    };
}