//! Auto-generated Kafka protocol message
//! Message: ApiVersionsResponse
//! API Key: 18
//! Type: response
//! Valid Versions: 0-4
//! Flexible Versions: 3+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// Nested struct: FinalizedFeatureKey
pub const FinalizedFeatureKey = struct {
    const Self = @This();

    /// The name of the feature.
    /// Versions: 3+
    name: []const u8 = "",
    /// The cluster-wide finalized max version level for the feature.
    /// Versions: 3+
    max_version_level: i16 = 0,
    /// The cluster-wide finalized min version level for the feature.
    /// Versions: 3+
    min_version_level: i16 = 0,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: Name
        if (version >= 3 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.name);
            } else {
                try types.encodeString(writer, self.name);
            }
        }

        // Field: MaxVersionLevel
        if (version >= 3 and version <= 32767) {
            try types.encodeInt16(writer, self.max_version_level);
        }

        // Field: MinVersionLevel
        if (version >= 3 and version <= 32767) {
            try types.encodeInt16(writer, self.min_version_level);
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

        // Field: Name
        if (version >= 3 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.name) else types.computeSizeString(self.name);
        }

        // Field: MaxVersionLevel
        if (version >= 3 and version <= 32767) {
            total_size += types.computeSizeInt16(self.max_version_level);
        }

        // Field: MinVersionLevel
        if (version >= 3 and version <= 32767) {
            total_size += types.computeSizeInt16(self.min_version_level);
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
        // Field: Name
        if (version >= 3 and version <= 32767) {
            self.name = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: MaxVersionLevel
        if (version >= 3 and version <= 32767) {
            self.max_version_level = try types.decodeInt16(reader);
        }

        // Field: MinVersionLevel
        if (version >= 3 and version <= 32767) {
            self.min_version_level = try types.decodeInt16(reader);
        }


        if (is_flexible) {
            const tagged_fields_data = try types.decodeTaggedFields(reader, allocator);
            self._tagged_fields = tagged_fields_data;
        }
        return self;
    }

    fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("3+") catch return false;
        return range.contains(version);
    }
};

/// Nested struct: SupportedFeatureKey
pub const SupportedFeatureKey = struct {
    const Self = @This();

    /// The name of the feature.
    /// Versions: 3+
    name: []const u8 = "",
    /// The minimum supported version for the feature.
    /// Versions: 3+
    min_version: i16 = 0,
    /// The maximum supported version for the feature.
    /// Versions: 3+
    max_version: i16 = 0,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: Name
        if (version >= 3 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.name);
            } else {
                try types.encodeString(writer, self.name);
            }
        }

        // Field: MinVersion
        if (version >= 3 and version <= 32767) {
            try types.encodeInt16(writer, self.min_version);
        }

        // Field: MaxVersion
        if (version >= 3 and version <= 32767) {
            try types.encodeInt16(writer, self.max_version);
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

        // Field: Name
        if (version >= 3 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.name) else types.computeSizeString(self.name);
        }

        // Field: MinVersion
        if (version >= 3 and version <= 32767) {
            total_size += types.computeSizeInt16(self.min_version);
        }

        // Field: MaxVersion
        if (version >= 3 and version <= 32767) {
            total_size += types.computeSizeInt16(self.max_version);
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
        // Field: Name
        if (version >= 3 and version <= 32767) {
            self.name = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: MinVersion
        if (version >= 3 and version <= 32767) {
            self.min_version = try types.decodeInt16(reader);
        }

        // Field: MaxVersion
        if (version >= 3 and version <= 32767) {
            self.max_version = try types.decodeInt16(reader);
        }


        if (is_flexible) {
            const tagged_fields_data = try types.decodeTaggedFields(reader, allocator);
            self._tagged_fields = tagged_fields_data;
        }
        return self;
    }

    fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("3+") catch return false;
        return range.contains(version);
    }
};

/// Nested struct: ApiVersion
pub const ApiVersion = struct {
    const Self = @This();

    /// The API index.
    /// Versions: 0+
    api_key: i16 = 0,
    /// The minimum supported version, inclusive.
    /// Versions: 0+
    min_version: i16 = 0,
    /// The maximum supported version, inclusive.
    /// Versions: 0+
    max_version: i16 = 0,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: ApiKey
        if (version >= 0 and version <= 32767) {
            try types.encodeInt16(writer, self.api_key);
        }

        // Field: MinVersion
        if (version >= 0 and version <= 32767) {
            try types.encodeInt16(writer, self.min_version);
        }

        // Field: MaxVersion
        if (version >= 0 and version <= 32767) {
            try types.encodeInt16(writer, self.max_version);
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

        // Field: ApiKey
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt16(self.api_key);
        }

        // Field: MinVersion
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt16(self.min_version);
        }

        // Field: MaxVersion
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt16(self.max_version);
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
        // Field: ApiKey
        if (version >= 0 and version <= 32767) {
            self.api_key = try types.decodeInt16(reader);
        }

        // Field: MinVersion
        if (version >= 0 and version <= 32767) {
            self.min_version = try types.decodeInt16(reader);
        }

        // Field: MaxVersion
        if (version >= 0 and version <= 32767) {
            self.max_version = try types.decodeInt16(reader);
        }


        if (is_flexible) {
            const tagged_fields_data = try types.decodeTaggedFields(reader, allocator);
            self._tagged_fields = tagged_fields_data;
        }
        return self;
    }

    fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("3+") catch return false;
        return range.contains(version);
    }
};

/// ApiVersionsResponse
pub const ApiVersionsResponse = struct {
    const Self = @This();

    /// The top-level error code.
    error_code: i16 = 0,
    /// The APIs supported by the broker.
    api_keys: ?[]ApiVersion = null,
    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    /// Versions: 1+
    throttle_time_ms: i32 = 0,
    /// Features supported by the broker. Note: in v0-v3, features with MinSupportedVersion = 0 are omitted.
    /// Versions: 3+
    supported_features: ?[]SupportedFeatureKey = null,
    /// The monotonically increasing epoch for the finalized features information. Valid values are >= 0. A value of -1 is special and represents unknown epoch.
    /// Versions: 3+
    finalized_features_epoch: i64 = -1,
    /// List of cluster-wide finalized features. The information is valid only if FinalizedFeaturesEpoch >= 0.
    /// Versions: 3+
    finalized_features: ?[]FinalizedFeatureKey = null,
    /// Set by a KRaft controller if the required configurations for ZK migration are present.
    /// Versions: 3+
    zk_migration_ready: bool = false,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 0, .max = 4 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 18;
    }

    /// Create a default instance of ApiVersionsResponse
    pub fn default() Self {
        return .{
            .error_code = 0,
            .api_keys = null,
            .throttle_time_ms = 0,
            .supported_features = null,
            .finalized_features_epoch = -1,
            .finalized_features = null,
            .zk_migration_ready = false,
            ._tagged_fields = null,
        };
    }

    /// Sets `error_code` to the passed value.
    /// The top-level error code.
    pub fn withErrorCode(self: Self, value: i16) Self {
        var result = self;
        result.error_code = value;
        return result;
    }

    /// Sets `api_keys` to the passed value.
    /// The APIs supported by the broker.
    pub fn withApiKeys(self: Self, value: ?[]ApiVersion) Self {
        var result = self;
        result.api_keys = value;
        return result;
    }

    /// Sets `throttle_time_ms` to the passed value.
    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    /// Versions: 1+
    pub fn withThrottleTimeMs(self: Self, value: i32) Self {
        var result = self;
        result.throttle_time_ms = value;
        return result;
    }

    /// Sets `supported_features` to the passed value.
    /// Features supported by the broker. Note: in v0-v3, features with MinSupportedVersion = 0 are omitted.
    /// Versions: 3+
    pub fn withSupportedFeatures(self: Self, value: ?[]SupportedFeatureKey) Self {
        var result = self;
        result.supported_features = value;
        return result;
    }

    /// Sets `finalized_features_epoch` to the passed value.
    /// The monotonically increasing epoch for the finalized features information. Valid values are >= 0. A value of -1 is special and represents unknown epoch.
    /// Versions: 3+
    pub fn withFinalizedFeaturesEpoch(self: Self, value: i64) Self {
        var result = self;
        result.finalized_features_epoch = value;
        return result;
    }

    /// Sets `finalized_features` to the passed value.
    /// List of cluster-wide finalized features. The information is valid only if FinalizedFeaturesEpoch >= 0.
    /// Versions: 3+
    pub fn withFinalizedFeatures(self: Self, value: ?[]FinalizedFeatureKey) Self {
        var result = self;
        result.finalized_features = value;
        return result;
    }

    /// Sets `zk_migration_ready` to the passed value.
    /// Set by a KRaft controller if the required configurations for ZK migration are present.
    /// Versions: 3+
    pub fn withZkMigrationReady(self: Self, value: bool) Self {
        var result = self;
        result.zk_migration_ready = value;
        return result;
    }

    /// Encode ApiVersionsResponse
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

        // Field: ApiKeys
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.api_keys);
                if (self.api_keys) |arr| {
                    for (arr) |*item| {
                        try ApiVersion.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.api_keys);
                if (self.api_keys) |arr| {
                    for (arr) |*item| {
                        try ApiVersion.encode(item, writer, version);
                    }
                }
            }
        }

        // Field: ThrottleTimeMs
        if (version >= 1 and version <= 32767) {
            try types.encodeInt32(writer, self.throttle_time_ms);
        }


        if (is_flexible) {
            var num_tagged_fields: u32 = 0;
            if (version >= 3 and version <= 32767) {
                if (self.supported_features != null) num_tagged_fields += 1;
            }
            if (version >= 3 and version <= 32767) {
                if (self.finalized_features_epoch != -1) num_tagged_fields += 1;
            }
            if (version >= 3 and version <= 32767) {
                if (self.finalized_features != null) num_tagged_fields += 1;
            }
            if (version >= 3 and version <= 32767) {
                if (self.zk_migration_ready != false) num_tagged_fields += 1;
            }

            // Count unknown tagged fields
            if (self._tagged_fields) |fields| {
                num_tagged_fields += @intCast(fields.len);
            }

            try types.encodeUnsignedVarInt(writer, num_tagged_fields);

            // Tagged field: SupportedFeatures (tag 0)
            if (version >= 3 and version <= 32767) {
                if (self.supported_features) |val| {
                    try types.encodeUnsignedVarInt(writer, 0);
                    // Compute size of array
                    var array_size: usize = types.computeSizeUnsignedVarInt(@intCast(val.len + 1));
                    for (val) |*item| {
                        array_size += try SupportedFeatureKey.computeSize(item, version);
                    }
                    try types.encodeUnsignedVarInt(writer, @intCast(array_size));
                    try types.encodeUnsignedVarInt(writer, @intCast(val.len + 1));
                    for (val) |*item| {
                        try SupportedFeatureKey.encode(item, writer, version);
                    }
                }
            }

            // Tagged field: FinalizedFeaturesEpoch (tag 1)
            if (version >= 3 and version <= 32767) {
                if (self.finalized_features_epoch != -1) {
                    try types.encodeUnsignedVarInt(writer, 1);
                    const size = types.computeSizeInt64(self.finalized_features_epoch);
                    try types.encodeUnsignedVarInt(writer, @intCast(size));
                    try types.encodeInt64(writer, self.finalized_features_epoch);
                }
            }

            // Tagged field: FinalizedFeatures (tag 2)
            if (version >= 3 and version <= 32767) {
                if (self.finalized_features) |val| {
                    try types.encodeUnsignedVarInt(writer, 2);
                    // Compute size of array
                    var array_size: usize = types.computeSizeUnsignedVarInt(@intCast(val.len + 1));
                    for (val) |*item| {
                        array_size += try FinalizedFeatureKey.computeSize(item, version);
                    }
                    try types.encodeUnsignedVarInt(writer, @intCast(array_size));
                    try types.encodeUnsignedVarInt(writer, @intCast(val.len + 1));
                    for (val) |*item| {
                        try FinalizedFeatureKey.encode(item, writer, version);
                    }
                }
            }

            // Tagged field: ZkMigrationReady (tag 3)
            if (version >= 3 and version <= 32767) {
                if (self.zk_migration_ready != false) {
                    try types.encodeUnsignedVarInt(writer, 3);
                    const size = types.computeSizeBoolean(self.zk_migration_ready);
                    try types.encodeUnsignedVarInt(writer, @intCast(size));
                    try types.encodeBoolean(writer, self.zk_migration_ready);
                }
            }

            // Encode unknown tagged fields
            if (self._tagged_fields) |fields| {
                try types.encodeTaggedFields(writer, fields);
            }
        }
    }

    /// Compute the size of ApiVersionsResponse for the given version
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

        // Field: ApiKeys
        if (version >= 0 and version <= 32767) {
            if (self.api_keys) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try ApiVersion.computeSize(item, version);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(1) else 4;
            }
        }

        // Field: ThrottleTimeMs
        if (version >= 1 and version <= 32767) {
            total_size += types.computeSizeInt32(self.throttle_time_ms);
        }

        if (is_flexible) {
            var num_tagged_fields: u32 = 0;
            if (version >= 3 and version <= 32767) {
                if (self.supported_features != null) num_tagged_fields += 1;
            }
            if (version >= 3 and version <= 32767) {
                if (self.finalized_features_epoch != -1) num_tagged_fields += 1;
            }
            if (version >= 3 and version <= 32767) {
                if (self.finalized_features != null) num_tagged_fields += 1;
            }
            if (version >= 3 and version <= 32767) {
                if (self.zk_migration_ready != false) num_tagged_fields += 1;
            }

            if (self._tagged_fields) |fields| {
                num_tagged_fields += @intCast(fields.len);
            }

            total_size += types.computeSizeUnsignedVarInt(num_tagged_fields);

            // Tagged field: SupportedFeatures (tag 0)
            if (version >= 3 and version <= 32767) {
                if (self.supported_features) |val| {
                    total_size += types.computeSizeUnsignedVarInt(0);
                    var array_size: usize = types.computeSizeUnsignedVarInt(@intCast(val.len + 1));
                    for (val) |*item| {
                        array_size += try SupportedFeatureKey.computeSize(item, version);
                    }
                    total_size += types.computeSizeUnsignedVarInt(@intCast(array_size));
                    total_size += array_size;
                }
            }

            // Tagged field: FinalizedFeaturesEpoch (tag 1)
            if (version >= 3 and version <= 32767) {
                if (self.finalized_features_epoch != -1) {
                    total_size += types.computeSizeUnsignedVarInt(1);
                    const size = types.computeSizeInt64(self.finalized_features_epoch);
                    total_size += types.computeSizeUnsignedVarInt(@intCast(size));
                    total_size += size;
                }
            }

            // Tagged field: FinalizedFeatures (tag 2)
            if (version >= 3 and version <= 32767) {
                if (self.finalized_features) |val| {
                    total_size += types.computeSizeUnsignedVarInt(2);
                    var array_size: usize = types.computeSizeUnsignedVarInt(@intCast(val.len + 1));
                    for (val) |*item| {
                        array_size += try FinalizedFeatureKey.computeSize(item, version);
                    }
                    total_size += types.computeSizeUnsignedVarInt(@intCast(array_size));
                    total_size += array_size;
                }
            }

            // Tagged field: ZkMigrationReady (tag 3)
            if (version >= 3 and version <= 32767) {
                if (self.zk_migration_ready != false) {
                    total_size += types.computeSizeUnsignedVarInt(3);
                    const size = types.computeSizeBoolean(self.zk_migration_ready);
                    total_size += types.computeSizeUnsignedVarInt(@intCast(size));
                    total_size += size;
                }
            }

            if (self._tagged_fields) |fields| {
                total_size += types.computeSizeTaggedFields(fields);
            }
        }

        return total_size;
    }

    /// Decode ApiVersionsResponse
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

        // Field: ApiKeys
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(ApiVersion, array_len);
            for (array) |*item| {
                item.* = try ApiVersion.decode(reader, version, allocator);
            }
            self.api_keys = array;
        }

        // Field: ThrottleTimeMs
        if (version >= 1 and version <= 32767) {
            self.throttle_time_ms = try types.decodeInt32(reader);
        }


        if (is_flexible) {
            const num_tagged_fields = try types.decodeUnsignedVarInt(reader);
            var unknown_tagged_fields = std.ArrayList(types.TaggedField).init(allocator);

            var i: u32 = 0;
            while (i < num_tagged_fields) : (i += 1) {
                const tag = try types.decodeUnsignedVarInt(reader);
                const size = try types.decodeUnsignedVarInt(reader);
                switch (tag) {
                    0 => { // SupportedFeatures
                        if (version >= 3 and version <= 32767) {
                            const array_len = try types.decodeCompactArrayLen(reader);
                            const array = try allocator.alloc(SupportedFeatureKey, array_len);
                            for (array) |*item| {
                                item.* = try SupportedFeatureKey.decode(reader, version, allocator);
                            }
                            self.supported_features = array;
                        } else {
                            try reader.skipBytes(size, .{});
                        }
                    },
                    1 => { // FinalizedFeaturesEpoch
                        if (version >= 3 and version <= 32767) {
                            self.finalized_features_epoch = try types.decodeInt64(reader);
                        } else {
                            try reader.skipBytes(size, .{});
                        }
                    },
                    2 => { // FinalizedFeatures
                        if (version >= 3 and version <= 32767) {
                            const array_len = try types.decodeCompactArrayLen(reader);
                            const array = try allocator.alloc(FinalizedFeatureKey, array_len);
                            for (array) |*item| {
                                item.* = try FinalizedFeatureKey.decode(reader, version, allocator);
                            }
                            self.finalized_features = array;
                        } else {
                            try reader.skipBytes(size, .{});
                        }
                    },
                    3 => { // ZkMigrationReady
                        if (version >= 3 and version <= 32767) {
                            self.zk_migration_ready = try types.decodeBoolean(reader);
                        } else {
                            try reader.skipBytes(size, .{});
                        }
                    },
                    else => {
                        const field_data = try allocator.alloc(u8, size);
                        _ = try reader.readAll(field_data);
                        try unknown_tagged_fields.append(.{ .tag = tag, .data = field_data });
                    },
                }
            }

            if (unknown_tagged_fields.items.len > 0) {
                self._tagged_fields = try unknown_tagged_fields.toOwnedSlice();
            }
        }

        return self;
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
    /// Get the header version for this API version
    /// Returns 2 for flexible versions, 1 for classic versions
    pub fn headerVersion(api_version: i16) i16 {
        if (isFlexibleVersion(api_version)) return 2;
        return 1;
    }

};
