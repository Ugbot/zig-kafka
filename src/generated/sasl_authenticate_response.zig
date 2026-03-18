//! Auto-generated Kafka protocol message
//! Message: SaslAuthenticateResponse
//! API Key: 36
//! Type: response
//! Valid Versions: 0-2
//! Flexible Versions: 2+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// SaslAuthenticateResponse
pub const SaslAuthenticateResponse = struct {
    const Self = @This();

    /// The error code, or 0 if there was no error.
    error_code: i16 = 0,
    /// The error message, or null if there was no error.
    error_message: ?[]const u8 = null,
    /// The SASL authentication bytes from the server, as defined by the SASL mechanism.
    auth_bytes: []const u8 = &[_]u8{},
    /// Number of milliseconds after which only re-authentication over the existing connection to create a new session can occur.
    /// Versions: 1+
    session_lifetime_ms: i64 = 0,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 0, .max = 2 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 36;
    }

    /// Create a default instance of SaslAuthenticateResponse
    pub fn default() Self {
        return .{
            .error_code = 0,
            .error_message = null,
            .auth_bytes = &[_]u8{},
            .session_lifetime_ms = 0,
            ._tagged_fields = null,
        };
    }

    /// Sets `error_code` to the passed value.
    /// The error code, or 0 if there was no error.
    pub fn withErrorCode(self: Self, value: i16) Self {
        var result = self;
        result.error_code = value;
        return result;
    }

    /// Sets `error_message` to the passed value.
    /// The error message, or null if there was no error.
    pub fn withErrorMessage(self: Self, value: ?[]const u8) Self {
        var result = self;
        result.error_message = value;
        return result;
    }

    /// Sets `auth_bytes` to the passed value.
    /// The SASL authentication bytes from the server, as defined by the SASL mechanism.
    pub fn withAuthBytes(self: Self, value: []const u8) Self {
        var result = self;
        result.auth_bytes = value;
        return result;
    }

    /// Sets `session_lifetime_ms` to the passed value.
    /// Number of milliseconds after which only re-authentication over the existing connection to create a new session can occur.
    /// Versions: 1+
    pub fn withSessionLifetimeMs(self: Self, value: i64) Self {
        var result = self;
        result.session_lifetime_ms = value;
        return result;
    }

    /// Encode SaslAuthenticateResponse
    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: ErrorCode
        if (version >= 0 and version <= 32767) {
            try types.encodeInt16(writer, self.error_code);
        }

        // Field: ErrorMessage
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.error_message);
            } else {
                try types.encodeString(writer, self.error_message);
            }
        }

        // Field: AuthBytes
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactBytes(writer, self.auth_bytes);
            } else {
                try types.encodeBytes(writer, self.auth_bytes);
            }
        }

        // Field: SessionLifetimeMs
        if (version >= 1 and version <= 32767) {
            try types.encodeInt64(writer, self.session_lifetime_ms);
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

    /// Compute the size of SaslAuthenticateResponse for the given version
    pub fn computeSize(self: *const Self, version: i16) !usize {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        var total_size: usize = 0;

        // Field: ErrorCode
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt16(self.error_code);
        }

        // Field: ErrorMessage
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.error_message) else types.computeSizeString(self.error_message);
        }

        // Field: AuthBytes
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactBytes(self.auth_bytes) else types.computeSizeBytes(self.auth_bytes);
        }

        // Field: SessionLifetimeMs
        if (version >= 1 and version <= 32767) {
            total_size += types.computeSizeInt64(self.session_lifetime_ms);
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

    /// Decode SaslAuthenticateResponse
    pub fn decode(reader: anytype, version: i16, allocator: std.mem.Allocator) !Self {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        var self: Self = .{};

        // Field: ErrorCode
        if (version >= 0 and version <= 32767) {
            self.error_code = try types.decodeInt16(reader);
        }

        // Field: ErrorMessage
        if (version >= 0 and version <= 32767) {
            self.error_message = if (is_flexible)
                try types.decodeCompactString(reader, allocator)
            else
                try types.decodeString(reader, allocator);
        }

        // Field: AuthBytes
        if (version >= 0 and version <= 32767) {
            self.auth_bytes = if (is_flexible)
                try types.decodeCompactBytes(reader, allocator) orelse ""
            else
                try types.decodeBytes(reader, allocator) orelse "";
        }

        // Field: SessionLifetimeMs
        if (version >= 1 and version <= 32767) {
            self.session_lifetime_ms = try types.decodeInt64(reader);
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
        const range = types.VersionRange.parse("0-2") catch return false;
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
