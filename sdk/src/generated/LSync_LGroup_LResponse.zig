//! Auto-generated Kafka protocol message
//! Message: SyncGroupResponse
//! API Key: 14
//! Type: response
//! Valid Versions: 0-5
//! Flexible Versions: 4+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// SyncGroupResponse
pub const SyncGroupResponse = struct {
    const Self = @This();

    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    /// Versions: 1+
    throttle_time_ms: i32 = 0,
    /// The error code, or 0 if there was no error.
    error_code: i16 = 0,
    /// The group protocol type.
    /// Versions: 5+
    protocol_type: ?[]const u8 = null,
    /// The group protocol name.
    /// Versions: 5+
    protocol_name: ?[]const u8 = null,
    /// The member assignment.
    assignment: []const u8 = &[_]u8{},

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 0, .max = 5 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 14;
    }

    /// Create a default instance of SyncGroupResponse
    pub fn default() Self {
        return .{
            .throttle_time_ms = 0,
            .error_code = 0,
            .protocol_type = null,
            .protocol_name = null,
            .assignment = &[_]u8{},
            ._tagged_fields = null,
        };
    }

    /// Sets `throttle_time_ms` to the passed value.
    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    /// Versions: 1+
    pub fn withThrottleTimeMs(self: Self, value: i32) Self {
        var result = self;
        result.throttle_time_ms = value;
        return result;
    }

    /// Sets `error_code` to the passed value.
    /// The error code, or 0 if there was no error.
    pub fn withErrorCode(self: Self, value: i16) Self {
        var result = self;
        result.error_code = value;
        return result;
    }

    /// Sets `protocol_type` to the passed value.
    /// The group protocol type.
    /// Versions: 5+
    pub fn withProtocolType(self: Self, value: ?[]const u8) Self {
        var result = self;
        result.protocol_type = value;
        return result;
    }

    /// Sets `protocol_name` to the passed value.
    /// The group protocol name.
    /// Versions: 5+
    pub fn withProtocolName(self: Self, value: ?[]const u8) Self {
        var result = self;
        result.protocol_name = value;
        return result;
    }

    /// Sets `assignment` to the passed value.
    /// The member assignment.
    pub fn withAssignment(self: Self, value: []const u8) Self {
        var result = self;
        result.assignment = value;
        return result;
    }

    /// Encode SyncGroupResponse
    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: ThrottleTimeMs
        if (version >= 1 and version <= 32767) {
            try types.encodeInt32(writer, self.throttle_time_ms);
        }

        // Field: ErrorCode
        if (version >= 0 and version <= 32767) {
            try types.encodeInt16(writer, self.error_code);
        }

        // Field: ProtocolType
        if (version >= 5 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.protocol_type);
            } else {
                try types.encodeString(writer, self.protocol_type);
            }
        }

        // Field: ProtocolName
        if (version >= 5 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.protocol_name);
            } else {
                try types.encodeString(writer, self.protocol_name);
            }
        }

        // Field: Assignment
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactBytes(writer, self.assignment);
            } else {
                try types.encodeBytes(writer, self.assignment);
            }
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

    /// Compute the size of SyncGroupResponse for the given version
    pub fn computeSize(self: *const Self, version: i16) !usize {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        var total_size: usize = 0;

        // Field: ThrottleTimeMs
        if (version >= 1 and version <= 32767) {
            total_size += types.computeSizeInt32(self.throttle_time_ms);
        }

        // Field: ErrorCode
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt16(self.error_code);
        }

        // Field: ProtocolType
        if (version >= 5 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.protocol_type) else types.computeSizeString(self.protocol_type);
        }

        // Field: ProtocolName
        if (version >= 5 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.protocol_name) else types.computeSizeString(self.protocol_name);
        }

        // Field: Assignment
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactBytes(self.assignment) else types.computeSizeBytes(self.assignment);
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

    /// Decode SyncGroupResponse
    pub fn decode(reader: anytype, version: i16, allocator: std.mem.Allocator) !Self {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        var self: Self = .{};

        // Field: ThrottleTimeMs
        if (version >= 1 and version <= 32767) {
            self.throttle_time_ms = try types.decodeInt32(reader);
        }

        // Field: ErrorCode
        if (version >= 0 and version <= 32767) {
            self.error_code = try types.decodeInt16(reader);
        }

        // Field: ProtocolType
        if (version >= 5 and version <= 32767) {
            self.protocol_type = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: ProtocolName
        if (version >= 5 and version <= 32767) {
            self.protocol_name = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: Assignment
        if (version >= 0 and version <= 32767) {
            self.assignment = if (is_flexible)
                try types.decodeCompactBytes(reader, allocator) orelse ""
            else
                try types.decodeBytes(reader, allocator) orelse "";
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
        const range = types.VersionRange.parse("0-5") catch return false;
        return range.contains(version);
    }
    /// Check if version uses flexible encoding
    pub fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("4+") catch return false;
        return range.contains(version);
    }
    /// Get the header version for this API version
    /// Returns 2 for flexible versions, 1 for classic versions
    pub fn headerVersion(api_version: i16) i16 {
        if (isFlexibleVersion(api_version)) return 2;
        return 1;
    }

};
