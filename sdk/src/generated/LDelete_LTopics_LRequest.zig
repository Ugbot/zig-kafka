//! Auto-generated Kafka protocol message
//! Message: DeleteTopicsRequest
//! API Key: 20
//! Type: request
//! Valid Versions: 1-6
//! Flexible Versions: 4+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// Nested struct: DeleteTopicState
pub const DeleteTopicState = struct {
    const Self = @This();

    /// The topic name.
    /// Versions: 6+
    name: ?[]const u8 = null,
    /// The unique topic ID.
    /// Versions: 6+
    topic_id: [16]u8 = [_]u8{0} ** 16,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: Name
        if (version >= 6 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.name);
            } else {
                try types.encodeString(writer, self.name);
            }
        }

        // Field: TopicId
        if (version >= 6 and version <= 32767) {
            try types.encodeUuid(writer, self.topic_id);
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
        if (version >= 6 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.name) else types.computeSizeString(self.name);
        }

        // Field: TopicId
        if (version >= 6 and version <= 32767) {
            total_size += types.computeSizeUuid(self.topic_id);
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
        if (version >= 6 and version <= 32767) {
            self.name = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: TopicId
        if (version >= 6 and version <= 32767) {
            self.topic_id = try types.decodeUuid(reader);
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

/// DeleteTopicsRequest
pub const DeleteTopicsRequest = struct {
    const Self = @This();

    /// The name or topic ID of the topic.
    /// Versions: 6+
    topics: ?[]DeleteTopicState = null,
    /// The names of the topics to delete.
    /// Versions: 0-5
    topic_names: ?[][]const u8 = null,
    /// The length of time in milliseconds to wait for the deletions to complete.
    timeout_ms: i32 = 0,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 1, .max = 6 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 20;
    }

    /// Create a default instance of DeleteTopicsRequest
    pub fn default() Self {
        return .{
            .topics = null,
            .topic_names = null,
            .timeout_ms = 0,
            ._tagged_fields = null,
        };
    }

    /// Sets `topics` to the passed value.
    /// The name or topic ID of the topic.
    /// Versions: 6+
    pub fn withTopics(self: Self, value: ?[]DeleteTopicState) Self {
        var result = self;
        result.topics = value;
        return result;
    }

    /// Sets `topic_names` to the passed value.
    /// The names of the topics to delete.
    /// Versions: 0-5
    pub fn withTopicNames(self: Self, value: ?[][]const u8) Self {
        var result = self;
        result.topic_names = value;
        return result;
    }

    /// Sets `timeout_ms` to the passed value.
    /// The length of time in milliseconds to wait for the deletions to complete.
    pub fn withTimeoutMs(self: Self, value: i32) Self {
        var result = self;
        result.timeout_ms = value;
        return result;
    }

    /// Encode DeleteTopicsRequest
    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: Topics
        if (version >= 6 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLen(writer, self.topics);
                if (self.topics) |arr| {
                    for (arr) |*item| {
                        try DeleteTopicState.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLen(writer, self.topics);
                if (self.topics) |arr| {
                    for (arr) |*item| {
                        try DeleteTopicState.encode(item, writer, version);
                    }
                }
            }
        }

        // Field: TopicNames
        if (version >= 0 and version <= 5) {
            if (is_flexible) {
                try types.encodeCompactArray([]const u8, writer, self.topic_names, types.encodeCompactString);
            } else {
                try types.encodeArray([]const u8, writer, self.topic_names, types.encodeCompactString);
            }
        }

        // Field: TimeoutMs
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.timeout_ms);
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

    /// Compute the size of DeleteTopicsRequest for the given version
    pub fn computeSize(self: *const Self, version: i16) !usize {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        var total_size: usize = 0;

        // Field: Topics
        if (version >= 6 and version <= 32767) {
            if (self.topics) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try DeleteTopicState.computeSize(item, version);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(0) else 4;
            }
        }

        // Field: TopicNames
        if (version >= 0 and version <= 5) {
            if (self.topic_names) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |item| {
                    total_size += types.computeSizeCompactString(item);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(0) else 4;
            }
        }

        // Field: TimeoutMs
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.timeout_ms);
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

    /// Decode DeleteTopicsRequest
    pub fn decode(reader: anytype, version: i16, allocator: std.mem.Allocator) !Self {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        var self: Self = .{};

        // Field: Topics
        if (version >= 6 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(DeleteTopicState, array_len);
            for (array) |*item| {
                item.* = try DeleteTopicState.decode(reader, version, allocator);
            }
            self.topics = array;
        }

        // Field: TopicNames
        if (version >= 0 and version <= 5) {
            self.topic_names = if (is_flexible)
                try types.decodeCompactArray([]const u8, reader, allocator, types.decodeCompactString)
            else
                try types.decodeArray([]const u8, reader, allocator, types.decodeCompactString);
        }

        // Field: TimeoutMs
        if (version >= 0 and version <= 32767) {
            self.timeout_ms = try types.decodeInt32(reader);
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
        const range = types.VersionRange.parse("1-6") catch return false;
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
