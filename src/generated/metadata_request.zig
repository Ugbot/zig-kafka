//! Auto-generated Kafka protocol message
//! Message: MetadataRequest
//! API Key: 3
//! Type: request
//! Valid Versions: 0-13
//! Flexible Versions: 9+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// Nested struct: MetadataRequestTopic
pub const MetadataRequestTopic = struct {
    const Self = @This();

    /// The topic id.
    /// Versions: 10+
    topic_id: [16]u8 = [_]u8{0} ** 16,
    /// The topic name.
    /// Versions: 0+
    name: ?[]const u8 = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: TopicId
        if (version >= 10 and version <= 32767) {
            try types.encodeUuid(writer, self.topic_id);
        }

        // Field: Name
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.name);
            } else {
                try types.encodeString(writer, self.name);
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

        // Field: TopicId
        if (version >= 10 and version <= 32767) {
            total_size += types.computeSizeUuid(self.topic_id);
        }

        // Field: Name
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.name) else types.computeSizeString(self.name);
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
        // Field: TopicId
        if (version >= 10 and version <= 32767) {
            self.topic_id = try types.decodeUuid(reader);
        }

        // Field: Name
        if (version >= 0 and version <= 32767) {
            self.name = if (is_flexible)
                try types.decodeCompactString(reader, allocator)
            else
                try types.decodeString(reader, allocator);
        }


        if (is_flexible) {
            const tagged_fields_data = try types.decodeTaggedFields(reader, allocator);
            self._tagged_fields = tagged_fields_data;
        }
        return self;
    }

    fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("9+") catch return false;
        return range.contains(version);
    }
};

/// MetadataRequest
pub const MetadataRequest = struct {
    const Self = @This();

    /// The topics to fetch metadata for.
    topics: ?[]MetadataRequestTopic = null,
    /// If this is true, the broker may auto-create topics that we requested which do not already exist, if it is configured to do so.
    /// Versions: 4+
    allow_auto_topic_creation: bool = true,
    /// Whether to include cluster authorized operations.
    /// Versions: 8-10
    include_cluster_authorized_operations: bool = false,
    /// Whether to include topic authorized operations.
    /// Versions: 8+
    include_topic_authorized_operations: bool = false,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 0, .max = 13 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 3;
    }

    /// Create a default instance of MetadataRequest
    pub fn default() Self {
        return .{
            .topics = null,
            .allow_auto_topic_creation = true,
            .include_cluster_authorized_operations = false,
            .include_topic_authorized_operations = false,
            ._tagged_fields = null,
        };
    }

    /// Sets `topics` to the passed value.
    /// The topics to fetch metadata for.
    pub fn withTopics(self: Self, value: ?[]MetadataRequestTopic) Self {
        var result = self;
        result.topics = value;
        return result;
    }

    /// Sets `allow_auto_topic_creation` to the passed value.
    /// If this is true, the broker may auto-create topics that we requested which do not already exist, if it is configured to do so.
    /// Versions: 4+
    pub fn withAllowAutoTopicCreation(self: Self, value: bool) Self {
        var result = self;
        result.allow_auto_topic_creation = value;
        return result;
    }

    /// Sets `include_cluster_authorized_operations` to the passed value.
    /// Whether to include cluster authorized operations.
    /// Versions: 8-10
    pub fn withIncludeClusterAuthorizedOperations(self: Self, value: bool) Self {
        var result = self;
        result.include_cluster_authorized_operations = value;
        return result;
    }

    /// Sets `include_topic_authorized_operations` to the passed value.
    /// Whether to include topic authorized operations.
    /// Versions: 8+
    pub fn withIncludeTopicAuthorizedOperations(self: Self, value: bool) Self {
        var result = self;
        result.include_topic_authorized_operations = value;
        return result;
    }

    /// Encode MetadataRequest
    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: Topics
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLen(writer, self.topics);
                if (self.topics) |arr| {
                    for (arr) |*item| {
                        try MetadataRequestTopic.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLen(writer, self.topics);
                if (self.topics) |arr| {
                    for (arr) |*item| {
                        try MetadataRequestTopic.encode(item, writer, version);
                    }
                }
            }
        }

        // Field: AllowAutoTopicCreation
        if (version >= 4 and version <= 32767) {
            try types.encodeBoolean(writer, self.allow_auto_topic_creation);
        }

        // Field: IncludeClusterAuthorizedOperations
        if (version >= 8 and version <= 10) {
            try types.encodeBoolean(writer, self.include_cluster_authorized_operations);
        }

        // Field: IncludeTopicAuthorizedOperations
        if (version >= 8 and version <= 32767) {
            try types.encodeBoolean(writer, self.include_topic_authorized_operations);
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

    /// Compute the size of MetadataRequest for the given version
    pub fn computeSize(self: *const Self, version: i16) !usize {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        var total_size: usize = 0;

        // Field: Topics
        if (version >= 0 and version <= 32767) {
            if (self.topics) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try MetadataRequestTopic.computeSize(item, version);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(0) else 4;
            }
        }

        // Field: AllowAutoTopicCreation
        if (version >= 4 and version <= 32767) {
            total_size += types.computeSizeBoolean(self.allow_auto_topic_creation);
        }

        // Field: IncludeClusterAuthorizedOperations
        if (version >= 8 and version <= 10) {
            total_size += types.computeSizeBoolean(self.include_cluster_authorized_operations);
        }

        // Field: IncludeTopicAuthorizedOperations
        if (version >= 8 and version <= 32767) {
            total_size += types.computeSizeBoolean(self.include_topic_authorized_operations);
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

    /// Decode MetadataRequest
    pub fn decode(reader: anytype, version: i16, allocator: std.mem.Allocator) !Self {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        var self: Self = .{};

        // Field: Topics
        if (version >= 0 and version <= 32767) {
            const raw_len: i32 = if (is_flexible) blk: {
                const v = try types.decodeUnsignedVarInt(reader);
                break :blk if (v == 0) @as(i32, -1) else @as(i32, @intCast(v - 1));
            } else try types.decodeInt32(reader);
            if (raw_len < 0) {
                self.topics = null;
            } else {
                const array_len: usize = @intCast(raw_len);
                const array = try allocator.alloc(MetadataRequestTopic, array_len);
                for (array) |*item| {
                    item.* = try MetadataRequestTopic.decode(reader, version, allocator);
                }
                self.topics = array;
            }
        }

        // Field: AllowAutoTopicCreation
        if (version >= 4 and version <= 32767) {
            self.allow_auto_topic_creation = try types.decodeBoolean(reader);
        }

        // Field: IncludeClusterAuthorizedOperations
        if (version >= 8 and version <= 10) {
            self.include_cluster_authorized_operations = try types.decodeBoolean(reader);
        }

        // Field: IncludeTopicAuthorizedOperations
        if (version >= 8 and version <= 32767) {
            self.include_topic_authorized_operations = try types.decodeBoolean(reader);
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
        const range = types.VersionRange.parse("0-13") catch return false;
        return range.contains(version);
    }
    /// Check if version uses flexible encoding
    pub fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("9+") catch return false;
        return range.contains(version);
    }
    /// Get the header version for this API version
    /// Returns 2 for flexible versions, 1 for classic versions
    pub fn headerVersion(api_version: i16) i16 {
        if (isFlexibleVersion(api_version)) return 2;
        return 1;
    }

};
