//! Kafka Protocol Library
//! Runtime support for generated Kafka protocol code

pub const types = @import("types.zig");
pub const generator = @import("complete_generator.zig");

// Re-export commonly used types
pub const Error = types.Error;
pub const VersionRange = types.VersionRange;
pub const TaggedField = types.TaggedField;

// Re-export encoding functions
pub const encodeBoolean = types.encodeBoolean;
pub const decodeBoolean = types.decodeBoolean;
pub const encodeInt8 = types.encodeInt8;
pub const decodeInt8 = types.decodeInt8;
pub const encodeInt16 = types.encodeInt16;
pub const decodeInt16 = types.decodeInt16;
pub const encodeInt32 = types.encodeInt32;
pub const decodeInt32 = types.decodeInt32;
pub const encodeInt64 = types.encodeInt64;
pub const decodeInt64 = types.decodeInt64;
pub const encodeString = types.encodeString;
pub const decodeString = types.decodeString;
pub const encodeBytes = types.encodeBytes;
pub const decodeBytes = types.decodeBytes;
pub const encodeCompactString = types.encodeCompactString;
pub const decodeCompactString = types.decodeCompactString;
pub const encodeCompactBytes = types.encodeCompactBytes;
pub const decodeCompactBytes = types.decodeCompactBytes;
pub const encodeArray = types.encodeArray;
pub const decodeArray = types.decodeArray;
pub const encodeCompactArray = types.encodeCompactArray;
pub const decodeCompactArray = types.decodeCompactArray;
pub const encodeUnsignedVarInt = types.encodeUnsignedVarInt;
pub const decodeUnsignedVarInt = types.decodeUnsignedVarInt;
pub const encodeVarInt = types.encodeVarInt;
pub const decodeVarInt = types.decodeVarInt;
pub const encodeVarLong = types.encodeVarLong;
pub const decodeVarLong = types.decodeVarLong;
pub const encodeTaggedFields = types.encodeTaggedFields;
pub const decodeTaggedFields = types.decodeTaggedFields;

test {
    const std = @import("std");
    std.testing.refAllDecls(@This());
}
