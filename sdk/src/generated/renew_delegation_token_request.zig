//! Auto-generated Kafka protocol message
//! Message: RenewDelegationTokenRequest
//! API Key: 39
//! Type: request
//! Valid Versions: 1-2
//! Flexible Versions: 2+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// RenewDelegationTokenRequest
pub const RenewDelegationTokenRequest = struct {
    const Self = @This();

    /// The HMAC of the delegation token to be renewed.
    hmac: []const u8 = &[_]u8{},
    /// The renewal time period in milliseconds.
    renew_period_ms: i64 = 0,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 1, .max = 2 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 39;
    }

    /// Create a default instance of RenewDelegationTokenRequest
    pub fn default() Self {
        return .{
            .hmac = &[_]u8{},
            .renew_period_ms = 0,
            ._tagged_fields = null,
        };
    }

    /// Sets `hmac` to the passed value.
    /// The HMAC of the delegation token to be renewed.
    pub fn withHmac(self: Self, value: []const u8) Self {
        var result = self;
        result.hmac = value;
        return result;
    }

    /// Sets `renew_period_ms` to the passed value.
    /// The renewal time period in milliseconds.
    pub fn withRenewPeriodMs(self: Self, value: i64) Self {
        var result = self;
        result.renew_period_ms = value;
        return result;
    }

    /// Encode RenewDelegationTokenRequest
    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: Hmac
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactBytes(writer, self.hmac);
            } else {
                try types.encodeBytes(writer, self.hmac);
            }
        }

        // Field: RenewPeriodMs
        if (version >= 0 and version <= 32767) {
            try types.encodeInt64(writer, self.renew_period_ms);
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

    /// Compute the size of RenewDelegationTokenRequest for the given version
    pub fn computeSize(self: *const Self, version: i16) !usize {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        var total_size: usize = 0;

        // Field: Hmac
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactBytes(self.hmac) else types.computeSizeBytes(self.hmac);
        }

        // Field: RenewPeriodMs
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt64(self.renew_period_ms);
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

    /// Decode RenewDelegationTokenRequest
    pub fn decode(reader: anytype, version: i16, allocator: std.mem.Allocator) !Self {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        var self: Self = .{};

        // Field: Hmac
        if (version >= 0 and version <= 32767) {
            self.hmac = if (is_flexible)
                try types.decodeCompactBytes(reader, allocator) orelse ""
            else
                try types.decodeBytes(reader, allocator) orelse "";
        }

        // Field: RenewPeriodMs
        if (version >= 0 and version <= 32767) {
            self.renew_period_ms = try types.decodeInt64(reader);
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
