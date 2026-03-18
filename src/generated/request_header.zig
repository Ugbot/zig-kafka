//! Auto-generated Kafka protocol message
//! Message: RequestHeader
//! Type: header
//! Valid Versions: 1-2
//! Flexible Versions: 2+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// RequestHeader
pub const RequestHeader = struct {
    const Self = @This();

    /// The API key of this request.
    request_api_key: i16 = 0,
    /// The API version of this request.
    request_api_version: i16 = 0,
    /// The correlation ID of this request.
    correlation_id: i32 = 0,
    /// The client ID string.
    /// Versions: 1+
    client_id: ?[]const u8 = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 1, .max = 2 };

    /// Create a default instance of RequestHeader
    pub fn default() Self {
        return .{
            .request_api_key = 0,
            .request_api_version = 0,
            .correlation_id = 0,
            .client_id = null,
            ._tagged_fields = null,
        };
    }

    /// Sets `request_api_key` to the passed value.
    /// The API key of this request.
    pub fn withRequestApiKey(self: Self, value: i16) Self {
        var result = self;
        result.request_api_key = value;
        return result;
    }

    /// Sets `request_api_version` to the passed value.
    /// The API version of this request.
    pub fn withRequestApiVersion(self: Self, value: i16) Self {
        var result = self;
        result.request_api_version = value;
        return result;
    }

    /// Sets `correlation_id` to the passed value.
    /// The correlation ID of this request.
    pub fn withCorrelationId(self: Self, value: i32) Self {
        var result = self;
        result.correlation_id = value;
        return result;
    }

    /// Sets `client_id` to the passed value.
    /// The client ID string.
    /// Versions: 1+
    pub fn withClientId(self: Self, value: ?[]const u8) Self {
        var result = self;
        result.client_id = value;
        return result;
    }

    /// Encode RequestHeader
    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: RequestApiKey
        if (version >= 0 and version <= 32767) {
            try types.encodeInt16(writer, self.request_api_key);
        }

        // Field: RequestApiVersion
        if (version >= 0 and version <= 32767) {
            try types.encodeInt16(writer, self.request_api_version);
        }

        // Field: CorrelationId
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.correlation_id);
        }

        // Field: ClientId
        if (version >= 1 and version <= 32767) {
            try types.encodeString(writer, self.client_id);
        }


        if (is_flexible) {
            var num_tagged_fields: u32 = 0;

            // Count unknown tagged fields
            if (self._tagged_fields) |fields| {
                num_tagged_fields += @intCast(fields.len);
            }

            try types.encodeUnsignedVarInt(writer, num_tagged_fields);

            // Encode unknown tagged fields
            if (self._tagged_fields) |fields| {
                try types.encodeTaggedFields(writer, fields);
            }
        }
    }

    /// Compute the size of RequestHeader for the given version
    pub fn computeSize(self: *const Self, version: i16) !usize {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        var total_size: usize = 0;

        // Field: RequestApiKey
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt16(self.request_api_key);
        }

        // Field: RequestApiVersion
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt16(self.request_api_version);
        }

        // Field: CorrelationId
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.correlation_id);
        }

        // Field: ClientId
        if (version >= 1 and version <= 32767) {
            total_size += types.computeSizeString(self.client_id);
        }

        if (is_flexible) {
            var num_tagged_fields: u32 = 0;

            if (self._tagged_fields) |fields| {
                num_tagged_fields += @intCast(fields.len);
            }

            total_size += types.computeSizeUnsignedVarInt(num_tagged_fields);

            if (self._tagged_fields) |fields| {
                total_size += types.computeSizeTaggedFields(fields);
            }
        }

        return total_size;
    }

    /// Decode RequestHeader
    pub fn decode(reader: anytype, version: i16, allocator: std.mem.Allocator) !Self {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        var self: Self = .{};

        // Field: RequestApiKey
        if (version >= 0 and version <= 32767) {
            self.request_api_key = try types.decodeInt16(reader);
        }

        // Field: RequestApiVersion
        if (version >= 0 and version <= 32767) {
            self.request_api_version = try types.decodeInt16(reader);
        }

        // Field: CorrelationId
        if (version >= 0 and version <= 32767) {
            self.correlation_id = try types.decodeInt32(reader);
        }

        // Field: ClientId
        if (version >= 1 and version <= 32767) {
            self.client_id = try types.decodeString(reader, allocator);
        }


        if (is_flexible) {
            const num_tagged_fields = try types.decodeUnsignedVarInt(reader);
            var unknown_tagged_fields = std.array_list.Managed(types.TaggedField).init(allocator);

            var i: u32 = 0;
            while (i < num_tagged_fields) : (i += 1) {
                const tag = try types.decodeUnsignedVarInt(reader);
                const size = try types.decodeUnsignedVarInt(reader);
                const field_data = try allocator.alloc(u8, size);
                _ = try reader.readAll(field_data);
                try unknown_tagged_fields.append(.{ .tag = tag, .data = field_data });
            }

            if (unknown_tagged_fields.items.len > 0) {
                self._tagged_fields = try unknown_tagged_fields.toOwnedSlice();
            }
        }

        return self;
    }

    /// Check if version is valid
    pub fn isValidVersion(version: i16) bool {
        const range = types.VersionRange.parse("1-2") catch return false;
        return range.contains(version);
    }
    /// Check if version uses flexible encoding
    pub fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("2+") catch return false;
        return range.contains(version);
    }
    /// Get the header version for this API version
    /// Returns 2 for flexible versions, 1 for classic versions
    pub fn headerVersion(api_version: i16) i16 {
        if (isFlexibleVersion(api_version)) return 2;
        return 1;
    }

};
