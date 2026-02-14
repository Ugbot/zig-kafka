//! Auto-generated Kafka protocol message
//! Message: ApiVersionsRequest
//! API Key: 18
//! Type: request
//! Valid Versions: 0-4
//! Flexible Versions: 3+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// ApiVersionsRequest
pub const ApiVersionsRequest = struct {
    const Self = @This();

    /// The name of the client.
    /// Versions: 3+
    client_software_name: []const u8 = "",
    /// The version of the client.
    /// Versions: 3+
    client_software_version: []const u8 = "",

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,
};

/// Encode ApiVersionsRequest
pub fn encode(self: *const ApiVersionsRequest, writer: anytype, version: i16) !void {
    if (!isValidVersion(version)) {
        return types.Error.UnsupportedVersion;
    }
    const _ = isFlexibleVersion(version);

    // Field: ClientSoftwareName
    if (version >= 3 and version <= 32767) {
        try types.encodeCompactString(writer, self.client_software_name);
    }

    // Field: ClientSoftwareVersion
    if (version >= 3 and version <= 32767) {
        try types.encodeCompactString(writer, self.client_software_version);
    }


    if (is_flexible) {
        if (self._tagged_fields) |fields| {
            try types.encodeTaggedFields(writer, fields);
        } else {
            try types.encodeUnsignedVarInt(writer, 0);
        }
    }
}

/// Decode ApiVersionsRequest
pub fn decode(reader: anytype, version: i16, allocator: std.mem.Allocator) !ApiVersionsRequest {
    if (!isValidVersion(version)) {
        return types.Error.UnsupportedVersion;
    }
    const _ = isFlexibleVersion(version);
    
    var self: ApiVersionsRequest = .{};

    // Field: ClientSoftwareName
    if (version >= 3 and version <= 32767) {
        self.client_software_name = try types.decodeCompactString(reader, allocator) orelse "";
    }

    // Field: ClientSoftwareVersion
    if (version >= 3 and version <= 32767) {
        self.client_software_version = try types.decodeCompactString(reader, allocator) orelse "";
    }


    if (is_flexible) {
        self._tagged_fields = try types.decodeTaggedFields(reader, allocator);
    }
    
    return self;
}

/// Get the API key
pub fn apiKey() i16 {
    return 18;
}

/// Check if version is valid
pub fn isValidVersion(version: i16) bool {
    const range = types.VersionRange.parse("0-4") catch return false;
    return range.contains(version);
}
/// Check if version uses flexible encoding
pub fn isFlexibleVersion(version: i16) bool {
    const range = types.VersionRange.parse("3+") catch return false;
    return range.contains(version);
}
