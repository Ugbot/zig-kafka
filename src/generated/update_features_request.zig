//! Auto-generated Kafka protocol message
//! Message: UpdateFeaturesRequest
//! API Key: 57
//! Type: request
//! Valid Versions: 0-2
//! Flexible Versions: 0+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// Nested struct: FeatureUpdateKey
pub const FeatureUpdateKey = struct {
    const Self = @This();

    /// The name of the finalized feature to be updated.
    /// Versions: 0+
    feature: []const u8 = "",
    /// The new maximum version level for the finalized feature. A value >= 1 is valid. A value < 1, is special, and can be used to request the deletion of the finalized feature.
    /// Versions: 0+
    max_version_level: i16 = 0,
    /// DEPRECATED in version 1 (see DowngradeType). When set to true, the finalized feature version level is allowed to be downgraded/deleted. The downgrade request will fail if the new maximum version level is a value that's not lower than the existing maximum finalized version level.
    /// Versions: 0
    allow_downgrade: bool = false,
    /// Determine which type of upgrade will be performed: 1 will perform an upgrade only (default), 2 is safe downgrades only (lossless), 3 is unsafe downgrades (lossy).
    /// Versions: 1+
    upgrade_type: i8 = 1,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: Feature
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.feature);
            } else {
                try types.encodeString(writer, self.feature);
            }
        }

        // Field: MaxVersionLevel
        if (version >= 0 and version <= 32767) {
            try types.encodeInt16(writer, self.max_version_level);
        }

        // Field: AllowDowngrade
        if (version >= 0 and version <= 0) {
            try types.encodeBoolean(writer, self.allow_downgrade);
        }

        // Field: UpgradeType
        if (version >= 1 and version <= 32767) {
            try types.encodeInt8(writer, self.upgrade_type);
        }


        if (is_flexible) {
            if (self._tagged_fields) |fields| {
                try types.encodeTaggedFields(writer, fields);
            } else {
                try types.encodeUnsignedVarInt(writer, 0);
            }
        }
    }

    pub fn computeSize(self: *const Self, version: i16) !usize {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;
        var total_size: usize = 0;

        // Field: Feature
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.feature) else types.computeSizeString(self.feature);
        }

        // Field: MaxVersionLevel
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt16(self.max_version_level);
        }

        // Field: AllowDowngrade
        if (version >= 0 and version <= 0) {
            total_size += types.computeSizeBoolean(self.allow_downgrade);
        }

        // Field: UpgradeType
        if (version >= 1 and version <= 32767) {
            total_size += types.computeSizeInt8(self.upgrade_type);
        }


        if (is_flexible) {
            if (self._tagged_fields) |fields| {
                total_size += types.computeSizeTaggedFields(fields);
            } else {
                total_size += 1; // Empty tagged fields marker
            }
        }
        return total_size;
    }

    pub fn decode(reader: anytype, version: i16, allocator: std.mem.Allocator) !Self {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;
        _ = &allocator;
        var self: Self = .{};
        // Field: Feature
        if (version >= 0 and version <= 32767) {
            self.feature = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: MaxVersionLevel
        if (version >= 0 and version <= 32767) {
            self.max_version_level = try types.decodeInt16(reader);
        }

        // Field: AllowDowngrade
        if (version >= 0 and version <= 0) {
            self.allow_downgrade = try types.decodeBoolean(reader);
        }

        // Field: UpgradeType
        if (version >= 1 and version <= 32767) {
            self.upgrade_type = try types.decodeInt8(reader);
        }


        if (is_flexible) {
            const tagged_fields_data = try types.decodeTaggedFields(reader, allocator);
            self._tagged_fields = tagged_fields_data;
        }
        return self;
    }

    fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("0+") catch return false;
        return range.contains(version);
    }
};

/// UpdateFeaturesRequest
pub const UpdateFeaturesRequest = struct {
    const Self = @This();

    /// How long to wait in milliseconds before timing out the request.
    timeout_ms: i32 = 60000,
    /// The list of updates to finalized features.
    feature_updates: ?[]FeatureUpdateKey = null,
    /// True if we should validate the request, but not perform the upgrade or downgrade.
    /// Versions: 1+
    validate_only: bool = false,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 0, .max = 2 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 57;
    }

    /// Create a default instance of UpdateFeaturesRequest
    pub fn default() Self {
        return .{
            .timeout_ms = 60000,
            .feature_updates = null,
            .validate_only = false,
            ._tagged_fields = null,
        };
    }

    /// Sets `timeout_ms` to the passed value.
    /// How long to wait in milliseconds before timing out the request.
    pub fn withtimeoutMs(self: Self, value: i32) Self {
        var result = self;
        result.timeout_ms = value;
        return result;
    }

    /// Sets `feature_updates` to the passed value.
    /// The list of updates to finalized features.
    pub fn withFeatureUpdates(self: Self, value: ?[]FeatureUpdateKey) Self {
        var result = self;
        result.feature_updates = value;
        return result;
    }

    /// Sets `validate_only` to the passed value.
    /// True if we should validate the request, but not perform the upgrade or downgrade.
    /// Versions: 1+
    pub fn withValidateOnly(self: Self, value: bool) Self {
        var result = self;
        result.validate_only = value;
        return result;
    }

    /// Encode UpdateFeaturesRequest
    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: timeoutMs
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.timeout_ms);
        }

        // Field: FeatureUpdates
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.feature_updates);
                if (self.feature_updates) |arr| {
                    for (arr) |*item| {
                        try FeatureUpdateKey.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.feature_updates);
                if (self.feature_updates) |arr| {
                    for (arr) |*item| {
                        try FeatureUpdateKey.encode(item, writer, version);
                    }
                }
            }
        }

        // Field: ValidateOnly
        if (version >= 1 and version <= 32767) {
            try types.encodeBoolean(writer, self.validate_only);
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

    /// Compute the size of UpdateFeaturesRequest for the given version
    pub fn computeSize(self: *const Self, version: i16) !usize {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        var total_size: usize = 0;

        // Field: timeoutMs
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.timeout_ms);
        }

        // Field: FeatureUpdates
        if (version >= 0 and version <= 32767) {
            if (self.feature_updates) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try FeatureUpdateKey.computeSize(item, version);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(1) else 4;
            }
        }

        // Field: ValidateOnly
        if (version >= 1 and version <= 32767) {
            total_size += types.computeSizeBoolean(self.validate_only);
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

    /// Decode UpdateFeaturesRequest
    pub fn decode(reader: anytype, version: i16, allocator: std.mem.Allocator) !Self {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        var self: Self = .{};

        // Field: timeoutMs
        if (version >= 0 and version <= 32767) {
            self.timeout_ms = try types.decodeInt32(reader);
        }

        // Field: FeatureUpdates
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(FeatureUpdateKey, array_len);
            for (array) |*item| {
                item.* = try FeatureUpdateKey.decode(reader, version, allocator);
            }
            self.feature_updates = array;
        }

        // Field: ValidateOnly
        if (version >= 1 and version <= 32767) {
            self.validate_only = try types.decodeBoolean(reader);
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
