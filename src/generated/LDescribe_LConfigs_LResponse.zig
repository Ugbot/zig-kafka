//! Auto-generated Kafka protocol message
//! Message: DescribeConfigsResponse
//! API Key: 32
//! Type: response
//! Valid Versions: 1-4
//! Flexible Versions: 4+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// Nested struct: DescribeConfigsResult
pub const DescribeConfigsResult = struct {
    const Self = @This();

    /// The error code, or 0 if we were able to successfully describe the configurations.
    /// Versions: 0+
    error_code: i16 = 0,
    /// The error message, or null if we were able to successfully describe the configurations.
    /// Versions: 0+
    error_message: ?[]const u8 = null,
    /// The resource type.
    /// Versions: 0+
    resource_type: i8 = 0,
    /// The resource name.
    /// Versions: 0+
    resource_name: []const u8 = "",
    /// Each listed configuration.
    /// Versions: 0+
    configs: ?[]DescribeConfigsResourceResult = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
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

        // Field: ResourceType
        if (version >= 0 and version <= 32767) {
            try types.encodeInt8(writer, self.resource_type);
        }

        // Field: ResourceName
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.resource_name);
            } else {
                try types.encodeString(writer, self.resource_name);
            }
        }

        // Field: Configs
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLen(writer, self.configs);
                if (self.configs) |arr| {
                    for (arr) |*item| {
                        try DescribeConfigsResourceResult.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLen(writer, self.configs);
                if (self.configs) |arr| {
                    for (arr) |*item| {
                        try DescribeConfigsResourceResult.encode(item, writer, version);
                    }
                }
            }
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

        // Field: ErrorCode
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt16(self.error_code);
        }

        // Field: ErrorMessage
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.error_message) else types.computeSizeString(self.error_message);
        }

        // Field: ResourceType
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt8(self.resource_type);
        }

        // Field: ResourceName
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.resource_name) else types.computeSizeString(self.resource_name);
        }

        // Field: Configs
        if (version >= 0 and version <= 32767) {
            if (self.configs) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try DescribeConfigsResourceResult.computeSize(item, version);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(0) else 4;
            }
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
        // Field: ErrorCode
        if (version >= 0 and version <= 32767) {
            self.error_code = try types.decodeInt16(reader);
        }

        // Field: ErrorMessage
        if (version >= 0 and version <= 32767) {
            self.error_message = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: ResourceType
        if (version >= 0 and version <= 32767) {
            self.resource_type = try types.decodeInt8(reader);
        }

        // Field: ResourceName
        if (version >= 0 and version <= 32767) {
            self.resource_name = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: Configs
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(DescribeConfigsResourceResult, array_len);
            for (array) |*item| {
                item.* = try DescribeConfigsResourceResult.decode(reader, version, allocator);
            }
            self.configs = array;
        }


        if (is_flexible) {
            const tagged_fields_data = try types.decodeTaggedFields(reader, allocator);
            self._tagged_fields = tagged_fields_data;
        }
        return self;
    }

    fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("4+") catch return false;
        return range.contains(version);
    }
};

/// Nested struct: DescribeConfigsResourceResult
pub const DescribeConfigsResourceResult = struct {
    const Self = @This();

    /// The configuration name.
    /// Versions: 0+
    name: []const u8 = "",
    /// The configuration value.
    /// Versions: 0+
    value: ?[]const u8 = null,
    /// True if the configuration is read-only.
    /// Versions: 0+
    read_only: bool = false,
    /// The configuration source.
    /// Versions: 1+
    config_source: i8 = -1,
    /// True if this configuration is sensitive.
    /// Versions: 0+
    is_sensitive: bool = false,
    /// The synonyms for this configuration key.
    /// Versions: 1+
    synonyms: ?[]DescribeConfigsSynonym = null,
    /// The configuration data type. Type can be one of the following values - BOOLEAN, STRING, INT, SHORT, LONG, DOUBLE, LIST, CLASS, PASSWORD.
    /// Versions: 3+
    config_type: i8 = 0,
    /// The configuration documentation.
    /// Versions: 3+
    documentation: ?[]const u8 = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: Name
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.name);
            } else {
                try types.encodeString(writer, self.name);
            }
        }

        // Field: Value
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.value);
            } else {
                try types.encodeString(writer, self.value);
            }
        }

        // Field: ReadOnly
        if (version >= 0 and version <= 32767) {
            try types.encodeBoolean(writer, self.read_only);
        }

        // Field: ConfigSource
        if (version >= 1 and version <= 32767) {
            try types.encodeInt8(writer, self.config_source);
        }

        // Field: IsSensitive
        if (version >= 0 and version <= 32767) {
            try types.encodeBoolean(writer, self.is_sensitive);
        }

        // Field: Synonyms
        if (version >= 1 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLen(writer, self.synonyms);
                if (self.synonyms) |arr| {
                    for (arr) |*item| {
                        try DescribeConfigsSynonym.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLen(writer, self.synonyms);
                if (self.synonyms) |arr| {
                    for (arr) |*item| {
                        try DescribeConfigsSynonym.encode(item, writer, version);
                    }
                }
            }
        }

        // Field: ConfigType
        if (version >= 3 and version <= 32767) {
            try types.encodeInt8(writer, self.config_type);
        }

        // Field: Documentation
        if (version >= 3 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.documentation);
            } else {
                try types.encodeString(writer, self.documentation);
            }
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
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.name) else types.computeSizeString(self.name);
        }

        // Field: Value
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.value) else types.computeSizeString(self.value);
        }

        // Field: ReadOnly
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeBoolean(self.read_only);
        }

        // Field: ConfigSource
        if (version >= 1 and version <= 32767) {
            total_size += types.computeSizeInt8(self.config_source);
        }

        // Field: IsSensitive
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeBoolean(self.is_sensitive);
        }

        // Field: Synonyms
        if (version >= 1 and version <= 32767) {
            if (self.synonyms) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try DescribeConfigsSynonym.computeSize(item, version);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(0) else 4;
            }
        }

        // Field: ConfigType
        if (version >= 3 and version <= 32767) {
            total_size += types.computeSizeInt8(self.config_type);
        }

        // Field: Documentation
        if (version >= 3 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.documentation) else types.computeSizeString(self.documentation);
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
        if (version >= 0 and version <= 32767) {
            self.name = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: Value
        if (version >= 0 and version <= 32767) {
            self.value = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: ReadOnly
        if (version >= 0 and version <= 32767) {
            self.read_only = try types.decodeBoolean(reader);
        }

        // Field: ConfigSource
        if (version >= 1 and version <= 32767) {
            self.config_source = try types.decodeInt8(reader);
        }

        // Field: IsSensitive
        if (version >= 0 and version <= 32767) {
            self.is_sensitive = try types.decodeBoolean(reader);
        }

        // Field: Synonyms
        if (version >= 1 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(DescribeConfigsSynonym, array_len);
            for (array) |*item| {
                item.* = try DescribeConfigsSynonym.decode(reader, version, allocator);
            }
            self.synonyms = array;
        }

        // Field: ConfigType
        if (version >= 3 and version <= 32767) {
            self.config_type = try types.decodeInt8(reader);
        }

        // Field: Documentation
        if (version >= 3 and version <= 32767) {
            self.documentation = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }


        if (is_flexible) {
            const tagged_fields_data = try types.decodeTaggedFields(reader, allocator);
            self._tagged_fields = tagged_fields_data;
        }
        return self;
    }

    fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("4+") catch return false;
        return range.contains(version);
    }
};

/// Nested struct: DescribeConfigsSynonym
pub const DescribeConfigsSynonym = struct {
    const Self = @This();

    /// The synonym name.
    /// Versions: 1+
    name: []const u8 = "",
    /// The synonym value.
    /// Versions: 1+
    value: ?[]const u8 = null,
    /// The synonym source.
    /// Versions: 1+
    source: i8 = 0,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: Name
        if (version >= 1 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.name);
            } else {
                try types.encodeString(writer, self.name);
            }
        }

        // Field: Value
        if (version >= 1 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.value);
            } else {
                try types.encodeString(writer, self.value);
            }
        }

        // Field: Source
        if (version >= 1 and version <= 32767) {
            try types.encodeInt8(writer, self.source);
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
        if (version >= 1 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.name) else types.computeSizeString(self.name);
        }

        // Field: Value
        if (version >= 1 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.value) else types.computeSizeString(self.value);
        }

        // Field: Source
        if (version >= 1 and version <= 32767) {
            total_size += types.computeSizeInt8(self.source);
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
        if (version >= 1 and version <= 32767) {
            self.name = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: Value
        if (version >= 1 and version <= 32767) {
            self.value = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: Source
        if (version >= 1 and version <= 32767) {
            self.source = try types.decodeInt8(reader);
        }


        if (is_flexible) {
            const tagged_fields_data = try types.decodeTaggedFields(reader, allocator);
            self._tagged_fields = tagged_fields_data;
        }
        return self;
    }

    fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("4+") catch return false;
        return range.contains(version);
    }
};

/// DescribeConfigsResponse
pub const DescribeConfigsResponse = struct {
    const Self = @This();

    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    throttle_time_ms: i32 = 0,
    /// The results for each resource.
    results: ?[]DescribeConfigsResult = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 1, .max = 4 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 32;
    }

    /// Create a default instance of DescribeConfigsResponse
    pub fn default() Self {
        return .{
            .throttle_time_ms = 0,
            .results = null,
            ._tagged_fields = null,
        };
    }

    /// Sets `throttle_time_ms` to the passed value.
    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    pub fn withThrottleTimeMs(self: Self, value: i32) Self {
        var result = self;
        result.throttle_time_ms = value;
        return result;
    }

    /// Sets `results` to the passed value.
    /// The results for each resource.
    pub fn withResults(self: Self, value: ?[]DescribeConfigsResult) Self {
        var result = self;
        result.results = value;
        return result;
    }

    /// Encode DescribeConfigsResponse
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

        // Field: Results
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLen(writer, self.results);
                if (self.results) |arr| {
                    for (arr) |*item| {
                        try DescribeConfigsResult.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLen(writer, self.results);
                if (self.results) |arr| {
                    for (arr) |*item| {
                        try DescribeConfigsResult.encode(item, writer, version);
                    }
                }
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

    /// Compute the size of DescribeConfigsResponse for the given version
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

        // Field: Results
        if (version >= 0 and version <= 32767) {
            if (self.results) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try DescribeConfigsResult.computeSize(item, version);
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

    /// Decode DescribeConfigsResponse
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

        // Field: Results
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(DescribeConfigsResult, array_len);
            for (array) |*item| {
                item.* = try DescribeConfigsResult.decode(reader, version, allocator);
            }
            self.results = array;
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
        const range = types.VersionRange.parse("1-4") catch return false;
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
