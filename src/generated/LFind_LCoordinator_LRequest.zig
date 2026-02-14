//! Auto-generated Kafka protocol message
//! Message: FindCoordinatorRequest
//! API Key: 10
//! Type: request
//! Valid Versions: 0-6
//! Flexible Versions: 3+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// FindCoordinatorRequest
pub const FindCoordinatorRequest = struct {
    const Self = @This();

    /// The coordinator key.
    /// Versions: 0-3
    key: []const u8 = "",
    /// The coordinator key type. (group, transaction, share).
    /// Versions: 1+
    key_type: i8 = 0,
    /// The coordinator keys.
    /// Versions: 4+
    coordinator_keys: ?[][]const u8 = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 0, .max = 6 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 10;
    }

    /// Create a default instance of FindCoordinatorRequest
    pub fn default() Self {
        return .{
            .key = "",
            .key_type = 0,
            .coordinator_keys = null,
            ._tagged_fields = null,
        };
    }

    /// Sets `key` to the passed value.
    /// The coordinator key.
    /// Versions: 0-3
    pub fn withKey(self: Self, value: []const u8) Self {
        var result = self;
        result.key = value;
        return result;
    }

    /// Sets `key_type` to the passed value.
    /// The coordinator key type. (group, transaction, share).
    /// Versions: 1+
    pub fn withKeyType(self: Self, value: i8) Self {
        var result = self;
        result.key_type = value;
        return result;
    }

    /// Sets `coordinator_keys` to the passed value.
    /// The coordinator keys.
    /// Versions: 4+
    pub fn withCoordinatorKeys(self: Self, value: ?[][]const u8) Self {
        var result = self;
        result.coordinator_keys = value;
        return result;
    }

    /// Encode FindCoordinatorRequest
    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: Key
        if (version >= 0 and version <= 3) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.key);
            } else {
                try types.encodeString(writer, self.key);
            }
        }

        // Field: KeyType
        if (version >= 1 and version <= 32767) {
            try types.encodeInt8(writer, self.key_type);
        }

        // Field: CoordinatorKeys
        if (version >= 4 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArray([]const u8, writer, self.coordinator_keys, types.encodeCompactString);
            } else {
                try types.encodeArray([]const u8, writer, self.coordinator_keys, types.encodeCompactString);
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

    /// Compute the size of FindCoordinatorRequest for the given version
    pub fn computeSize(self: *const Self, version: i16) !usize {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        var total_size: usize = 0;

        // Field: Key
        if (version >= 0 and version <= 3) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.key) else types.computeSizeString(self.key);
        }

        // Field: KeyType
        if (version >= 1 and version <= 32767) {
            total_size += types.computeSizeInt8(self.key_type);
        }

        // Field: CoordinatorKeys
        if (version >= 4 and version <= 32767) {
            if (self.coordinator_keys) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |item| {
                    total_size += types.computeSizeCompactString(item);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(0) else 4;
            }
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

    /// Decode FindCoordinatorRequest
    pub fn decode(reader: anytype, version: i16, allocator: std.mem.Allocator) !Self {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        var self: Self = .{};

        // Field: Key
        if (version >= 0 and version <= 3) {
            self.key = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: KeyType
        if (version >= 1 and version <= 32767) {
            self.key_type = try types.decodeInt8(reader);
        }

        // Field: CoordinatorKeys
        if (version >= 4 and version <= 32767) {
            self.coordinator_keys = if (is_flexible)
                try types.decodeCompactArray([]const u8, reader, allocator, types.decodeCompactString)
            else
                try types.decodeArray([]const u8, reader, allocator, types.decodeCompactString);
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
        const range = types.VersionRange.parse("0-6") catch return false;
        return range.contains(version);
    }
    /// Check if version uses flexible encoding
    pub fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("3+") catch return false;
        return range.contains(version);
    }
    /// Get the header version for this API version
    /// Returns 2 for flexible versions, 1 for classic versions
    pub fn headerVersion(api_version: i16) i16 {
        if (isFlexibleVersion(api_version)) return 2;
        return 1;
    }

};
