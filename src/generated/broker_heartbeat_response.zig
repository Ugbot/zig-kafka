//! Auto-generated Kafka protocol message
//! Message: BrokerHeartbeatResponse
//! API Key: 63
//! Type: response
//! Valid Versions: 0-1
//! Flexible Versions: 0+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// BrokerHeartbeatResponse
pub const BrokerHeartbeatResponse = struct {
    const Self = @This();

    /// Duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    throttle_time_ms: i32 = 0,
    /// The error code, or 0 if there was no error.
    error_code: i16 = 0,
    /// True if the broker has approximately caught up with the latest metadata.
    is_caught_up: bool = false,
    /// True if the broker is fenced.
    is_fenced: bool = true,
    /// True if the broker should proceed with its shutdown.
    should_shut_down: bool = false,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 0, .max = 1 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 63;
    }

    /// Create a default instance of BrokerHeartbeatResponse
    pub fn default() Self {
        return .{
            .throttle_time_ms = 0,
            .error_code = 0,
            .is_caught_up = false,
            .is_fenced = true,
            .should_shut_down = false,
            ._tagged_fields = null,
        };
    }

    /// Sets `throttle_time_ms` to the passed value.
    /// Duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
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

    /// Sets `is_caught_up` to the passed value.
    /// True if the broker has approximately caught up with the latest metadata.
    pub fn withIsCaughtUp(self: Self, value: bool) Self {
        var result = self;
        result.is_caught_up = value;
        return result;
    }

    /// Sets `is_fenced` to the passed value.
    /// True if the broker is fenced.
    pub fn withIsFenced(self: Self, value: bool) Self {
        var result = self;
        result.is_fenced = value;
        return result;
    }

    /// Sets `should_shut_down` to the passed value.
    /// True if the broker should proceed with its shutdown.
    pub fn withShouldShutDown(self: Self, value: bool) Self {
        var result = self;
        result.should_shut_down = value;
        return result;
    }

    /// Encode BrokerHeartbeatResponse
    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: ThrottleTimeMs
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.throttle_time_ms);
        }

        // Field: ErrorCode
        if (version >= 0 and version <= 32767) {
            try types.encodeInt16(writer, self.error_code);
        }

        // Field: IsCaughtUp
        if (version >= 0 and version <= 32767) {
            try types.encodeBoolean(writer, self.is_caught_up);
        }

        // Field: IsFenced
        if (version >= 0 and version <= 32767) {
            try types.encodeBoolean(writer, self.is_fenced);
        }

        // Field: ShouldShutDown
        if (version >= 0 and version <= 32767) {
            try types.encodeBoolean(writer, self.should_shut_down);
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

    /// Compute the size of BrokerHeartbeatResponse for the given version
    pub fn computeSize(self: *const Self, version: i16) !usize {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        var total_size: usize = 0;

        // Field: ThrottleTimeMs
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.throttle_time_ms);
        }

        // Field: ErrorCode
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt16(self.error_code);
        }

        // Field: IsCaughtUp
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeBoolean(self.is_caught_up);
        }

        // Field: IsFenced
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeBoolean(self.is_fenced);
        }

        // Field: ShouldShutDown
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeBoolean(self.should_shut_down);
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

    /// Decode BrokerHeartbeatResponse
    pub fn decode(reader: anytype, version: i16, allocator: std.mem.Allocator) !Self {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        var self: Self = .{};

        // Field: ThrottleTimeMs
        if (version >= 0 and version <= 32767) {
            self.throttle_time_ms = try types.decodeInt32(reader);
        }

        // Field: ErrorCode
        if (version >= 0 and version <= 32767) {
            self.error_code = try types.decodeInt16(reader);
        }

        // Field: IsCaughtUp
        if (version >= 0 and version <= 32767) {
            self.is_caught_up = try types.decodeBoolean(reader);
        }

        // Field: IsFenced
        if (version >= 0 and version <= 32767) {
            self.is_fenced = try types.decodeBoolean(reader);
        }

        // Field: ShouldShutDown
        if (version >= 0 and version <= 32767) {
            self.should_shut_down = try types.decodeBoolean(reader);
        }


        if (is_flexible) {
            const num_tagged_fields = try types.decodeUnsignedVarInt(reader);
            var unknown_tagged_fields = std.ArrayList(types.TaggedField).init(allocator);

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
        const range = types.VersionRange.parse("0-1") catch return false;
        return range.contains(version);
    }
    /// Check if version uses flexible encoding
    pub fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("0+") catch return false;
        return range.contains(version);
    }
    /// Get the header version for this API version
    /// Returns 2 for flexible versions, 1 for classic versions
    pub fn headerVersion(api_version: i16) i16 {
        if (isFlexibleVersion(api_version)) return 2;
        return 1;
    }

};
