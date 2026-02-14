//! Auto-generated Kafka protocol message
//! Message: CreateTopicsResponse
//! API Key: 19
//! Type: response
//! Valid Versions: 2-7
//! Flexible Versions: 5+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// Nested struct: CreatableTopicResult
pub const CreatableTopicResult = struct {
    const Self = @This();

    /// The topic name.
    /// Versions: 0+
    name: []const u8 = "",
    /// The unique topic ID.
    /// Versions: 7+
    topic_id: [16]u8 = [_]u8{0} ** 16,
    /// The error code, or 0 if there was no error.
    /// Versions: 0+
    error_code: i16 = 0,
    /// The error message, or null if there was no error.
    /// Versions: 1+
    error_message: ?[]const u8 = null,
    /// Number of partitions of the topic.
    /// Versions: 5+
    num_partitions: i32 = -1,
    /// Replication factor of the topic.
    /// Versions: 5+
    replication_factor: i16 = -1,
    /// Configuration of the topic.
    /// Versions: 5+
    configs: ?[]CreatableTopicConfigs = null,

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

        // Field: TopicId
        if (version >= 7 and version <= 32767) {
            try types.encodeUuid(writer, self.topic_id);
        }

        // Field: ErrorCode
        if (version >= 0 and version <= 32767) {
            try types.encodeInt16(writer, self.error_code);
        }

        // Field: ErrorMessage
        if (version >= 1 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.error_message);
            } else {
                try types.encodeString(writer, self.error_message);
            }
        }

        // Field: NumPartitions
        if (version >= 5 and version <= 32767) {
            try types.encodeInt32(writer, self.num_partitions);
        }

        // Field: ReplicationFactor
        if (version >= 5 and version <= 32767) {
            try types.encodeInt16(writer, self.replication_factor);
        }

        // Field: Configs
        if (version >= 5 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLen(writer, self.configs);
                if (self.configs) |arr| {
                    for (arr) |*item| {
                        try CreatableTopicConfigs.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLen(writer, self.configs);
                if (self.configs) |arr| {
                    for (arr) |*item| {
                        try CreatableTopicConfigs.encode(item, writer, version);
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

        // Field: Name
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.name) else types.computeSizeString(self.name);
        }

        // Field: TopicId
        if (version >= 7 and version <= 32767) {
            total_size += types.computeSizeUuid(self.topic_id);
        }

        // Field: ErrorCode
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt16(self.error_code);
        }

        // Field: ErrorMessage
        if (version >= 1 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.error_message) else types.computeSizeString(self.error_message);
        }

        // Field: NumPartitions
        if (version >= 5 and version <= 32767) {
            total_size += types.computeSizeInt32(self.num_partitions);
        }

        // Field: ReplicationFactor
        if (version >= 5 and version <= 32767) {
            total_size += types.computeSizeInt16(self.replication_factor);
        }

        // Field: Configs
        if (version >= 5 and version <= 32767) {
            if (self.configs) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try CreatableTopicConfigs.computeSize(item, version);
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
        // Field: Name
        if (version >= 0 and version <= 32767) {
            self.name = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: TopicId
        if (version >= 7 and version <= 32767) {
            self.topic_id = try types.decodeUuid(reader);
        }

        // Field: ErrorCode
        if (version >= 0 and version <= 32767) {
            self.error_code = try types.decodeInt16(reader);
        }

        // Field: ErrorMessage
        if (version >= 1 and version <= 32767) {
            self.error_message = if (is_flexible)
                try types.decodeCompactString(reader, allocator)
            else
                try types.decodeString(reader, allocator);
        }

        // Field: NumPartitions
        if (version >= 5 and version <= 32767) {
            self.num_partitions = try types.decodeInt32(reader);
        }

        // Field: ReplicationFactor
        if (version >= 5 and version <= 32767) {
            self.replication_factor = try types.decodeInt16(reader);
        }

        // Field: Configs
        if (version >= 5 and version <= 32767) {
            const raw_len: i32 = if (is_flexible) blk: {
                const v = try types.decodeUnsignedVarInt(reader);
                break :blk if (v == 0) @as(i32, -1) else @as(i32, @intCast(v - 1));
            } else try types.decodeInt32(reader);
            if (raw_len < 0) {
                self.configs = null;
            } else {
                const array_len: usize = @intCast(raw_len);
                const array = try allocator.alloc(CreatableTopicConfigs, array_len);
                for (array) |*item| {
                    item.* = try CreatableTopicConfigs.decode(reader, version, allocator);
                }
                self.configs = array;
            }
        }


        if (is_flexible) {
            const tagged_fields_data = try types.decodeTaggedFields(reader, allocator);
            self._tagged_fields = tagged_fields_data;
        }
        return self;
    }

    fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("5+") catch return false;
        return range.contains(version);
    }
};

/// Nested struct: CreatableTopicConfigs
pub const CreatableTopicConfigs = struct {
    const Self = @This();

    /// The configuration name.
    /// Versions: 5+
    name: []const u8 = "",
    /// The configuration value.
    /// Versions: 5+
    value: ?[]const u8 = null,
    /// True if the configuration is read-only.
    /// Versions: 5+
    read_only: bool = false,
    /// The configuration source.
    /// Versions: 5+
    config_source: i8 = -1,
    /// True if this configuration is sensitive.
    /// Versions: 5+
    is_sensitive: bool = false,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: Name
        if (version >= 5 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.name);
            } else {
                try types.encodeString(writer, self.name);
            }
        }

        // Field: Value
        if (version >= 5 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.value);
            } else {
                try types.encodeString(writer, self.value);
            }
        }

        // Field: ReadOnly
        if (version >= 5 and version <= 32767) {
            try types.encodeBoolean(writer, self.read_only);
        }

        // Field: ConfigSource
        if (version >= 5 and version <= 32767) {
            try types.encodeInt8(writer, self.config_source);
        }

        // Field: IsSensitive
        if (version >= 5 and version <= 32767) {
            try types.encodeBoolean(writer, self.is_sensitive);
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
        if (version >= 5 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.name) else types.computeSizeString(self.name);
        }

        // Field: Value
        if (version >= 5 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.value) else types.computeSizeString(self.value);
        }

        // Field: ReadOnly
        if (version >= 5 and version <= 32767) {
            total_size += types.computeSizeBoolean(self.read_only);
        }

        // Field: ConfigSource
        if (version >= 5 and version <= 32767) {
            total_size += types.computeSizeInt8(self.config_source);
        }

        // Field: IsSensitive
        if (version >= 5 and version <= 32767) {
            total_size += types.computeSizeBoolean(self.is_sensitive);
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
        if (version >= 5 and version <= 32767) {
            self.name = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: Value
        if (version >= 5 and version <= 32767) {
            self.value = if (is_flexible)
                try types.decodeCompactString(reader, allocator)
            else
                try types.decodeString(reader, allocator);
        }

        // Field: ReadOnly
        if (version >= 5 and version <= 32767) {
            self.read_only = try types.decodeBoolean(reader);
        }

        // Field: ConfigSource
        if (version >= 5 and version <= 32767) {
            self.config_source = try types.decodeInt8(reader);
        }

        // Field: IsSensitive
        if (version >= 5 and version <= 32767) {
            self.is_sensitive = try types.decodeBoolean(reader);
        }


        if (is_flexible) {
            const tagged_fields_data = try types.decodeTaggedFields(reader, allocator);
            self._tagged_fields = tagged_fields_data;
        }
        return self;
    }

    fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("5+") catch return false;
        return range.contains(version);
    }
};

/// CreateTopicsResponse
pub const CreateTopicsResponse = struct {
    const Self = @This();

    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    /// Versions: 2+
    throttle_time_ms: i32 = 0,
    /// Results for each topic we tried to create.
    topics: ?[]CreatableTopicResult = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 2, .max = 7 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 19;
    }

    /// Create a default instance of CreateTopicsResponse
    pub fn default() Self {
        return .{
            .throttle_time_ms = 0,
            .topics = null,
            ._tagged_fields = null,
        };
    }

    /// Sets `throttle_time_ms` to the passed value.
    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    /// Versions: 2+
    pub fn withThrottleTimeMs(self: Self, value: i32) Self {
        var result = self;
        result.throttle_time_ms = value;
        return result;
    }

    /// Sets `topics` to the passed value.
    /// Results for each topic we tried to create.
    pub fn withTopics(self: Self, value: ?[]CreatableTopicResult) Self {
        var result = self;
        result.topics = value;
        return result;
    }

    /// Encode CreateTopicsResponse
    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: ThrottleTimeMs
        if (version >= 2 and version <= 32767) {
            try types.encodeInt32(writer, self.throttle_time_ms);
        }

        // Field: Topics
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.topics);
                if (self.topics) |arr| {
                    for (arr) |*item| {
                        try CreatableTopicResult.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.topics);
                if (self.topics) |arr| {
                    for (arr) |*item| {
                        try CreatableTopicResult.encode(item, writer, version);
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

    /// Compute the size of CreateTopicsResponse for the given version
    pub fn computeSize(self: *const Self, version: i16) !usize {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        var total_size: usize = 0;

        // Field: ThrottleTimeMs
        if (version >= 2 and version <= 32767) {
            total_size += types.computeSizeInt32(self.throttle_time_ms);
        }

        // Field: Topics
        if (version >= 0 and version <= 32767) {
            if (self.topics) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try CreatableTopicResult.computeSize(item, version);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(1) else 4;
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

    /// Decode CreateTopicsResponse
    pub fn decode(reader: anytype, version: i16, allocator: std.mem.Allocator) !Self {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        var self: Self = .{};

        // Field: ThrottleTimeMs
        if (version >= 2 and version <= 32767) {
            self.throttle_time_ms = try types.decodeInt32(reader);
        }

        // Field: Topics
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(CreatableTopicResult, array_len);
            for (array) |*item| {
                item.* = try CreatableTopicResult.decode(reader, version, allocator);
            }
            self.topics = array;
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
        const range = types.VersionRange.parse("2-7") catch return false;
        return range.contains(version);
    }
    /// Check if version uses flexible encoding
    pub fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("5+") catch return false;
        return range.contains(version);
    }
    /// Get the header version for this API version
    /// Returns 2 for flexible versions, 1 for classic versions
    pub fn headerVersion(api_version: i16) i16 {
        if (isFlexibleVersion(api_version)) return 2;
        return 1;
    }

};
