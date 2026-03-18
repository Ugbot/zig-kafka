//! Auto-generated Kafka protocol message
//! Message: OffsetFetchResponse
//! API Key: 9
//! Type: response
//! Valid Versions: 1-10
//! Flexible Versions: 6+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// Nested struct: OffsetFetchResponseGroup
pub const OffsetFetchResponseGroup = struct {
    const Self = @This();

    /// The group ID.
    /// Versions: 8+
    group_id: []const u8 = "",
    /// The responses per topic.
    /// Versions: 8+
    topics: ?[]OffsetFetchResponseTopics = null,
    /// The group-level error code, or 0 if there was no error.
    /// Versions: 8+
    error_code: i16 = 0,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: GroupId
        if (version >= 8 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.group_id);
            } else {
                try types.encodeString(writer, self.group_id);
            }
        }

        // Field: Topics
        if (version >= 8 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.topics);
                if (self.topics) |arr| {
                    for (arr) |*item| {
                        try OffsetFetchResponseTopics.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.topics);
                if (self.topics) |arr| {
                    for (arr) |*item| {
                        try OffsetFetchResponseTopics.encode(item, writer, version);
                    }
                }
            }
        }

        // Field: ErrorCode
        if (version >= 8 and version <= 32767) {
            try types.encodeInt16(writer, self.error_code);
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

        // Field: GroupId
        if (version >= 8 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.group_id) else types.computeSizeString(self.group_id);
        }

        // Field: Topics
        if (version >= 8 and version <= 32767) {
            if (self.topics) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try OffsetFetchResponseTopics.computeSize(item, version);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(1) else 4;
            }
        }

        // Field: ErrorCode
        if (version >= 8 and version <= 32767) {
            total_size += types.computeSizeInt16(self.error_code);
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
        // Field: GroupId
        if (version >= 8 and version <= 32767) {
            self.group_id = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: Topics
        if (version >= 8 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(OffsetFetchResponseTopics, array_len);
            for (array) |*item| {
                item.* = try OffsetFetchResponseTopics.decode(reader, version, allocator);
            }
            self.topics = array;
        }

        // Field: ErrorCode
        if (version >= 8 and version <= 32767) {
            self.error_code = try types.decodeInt16(reader);
        }


        if (is_flexible) {
            const tagged_fields_data = try types.decodeTaggedFields(reader, allocator);
            self._tagged_fields = tagged_fields_data;
        }
        return self;
    }

    fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("6+") catch return false;
        return range.contains(version);
    }
};

/// Nested struct: OffsetFetchResponseTopics
pub const OffsetFetchResponseTopics = struct {
    const Self = @This();

    /// The topic name.
    /// Versions: 8-9
    name: []const u8 = "",
    /// The topic ID.
    /// Versions: 10+
    topic_id: [16]u8 = [_]u8{0} ** 16,
    /// The responses per partition.
    /// Versions: 8+
    partitions: ?[]OffsetFetchResponsePartitions = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: Name
        if (version >= 8 and version <= 9) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.name);
            } else {
                try types.encodeString(writer, self.name);
            }
        }

        // Field: TopicId
        if (version >= 10 and version <= 32767) {
            try types.encodeUuid(writer, self.topic_id);
        }

        // Field: Partitions
        if (version >= 8 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.partitions);
                if (self.partitions) |arr| {
                    for (arr) |*item| {
                        try OffsetFetchResponsePartitions.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.partitions);
                if (self.partitions) |arr| {
                    for (arr) |*item| {
                        try OffsetFetchResponsePartitions.encode(item, writer, version);
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
        if (version >= 8 and version <= 9) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.name) else types.computeSizeString(self.name);
        }

        // Field: TopicId
        if (version >= 10 and version <= 32767) {
            total_size += types.computeSizeUuid(self.topic_id);
        }

        // Field: Partitions
        if (version >= 8 and version <= 32767) {
            if (self.partitions) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try OffsetFetchResponsePartitions.computeSize(item, version);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(1) else 4;
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
        if (version >= 8 and version <= 9) {
            self.name = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: TopicId
        if (version >= 10 and version <= 32767) {
            self.topic_id = try types.decodeUuid(reader);
        }

        // Field: Partitions
        if (version >= 8 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(OffsetFetchResponsePartitions, array_len);
            for (array) |*item| {
                item.* = try OffsetFetchResponsePartitions.decode(reader, version, allocator);
            }
            self.partitions = array;
        }


        if (is_flexible) {
            const tagged_fields_data = try types.decodeTaggedFields(reader, allocator);
            self._tagged_fields = tagged_fields_data;
        }
        return self;
    }

    fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("6+") catch return false;
        return range.contains(version);
    }
};

/// Nested struct: OffsetFetchResponsePartitions
pub const OffsetFetchResponsePartitions = struct {
    const Self = @This();

    /// The partition index.
    /// Versions: 8+
    partition_index: i32 = 0,
    /// The committed message offset.
    /// Versions: 8+
    committed_offset: i64 = 0,
    /// The leader epoch.
    /// Versions: 8+
    committed_leader_epoch: i32 = -1,
    /// The partition metadata.
    /// Versions: 8+
    metadata: ?[]const u8 = null,
    /// The partition-level error code, or 0 if there was no error.
    /// Versions: 8+
    error_code: i16 = 0,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: PartitionIndex
        if (version >= 8 and version <= 32767) {
            try types.encodeInt32(writer, self.partition_index);
        }

        // Field: CommittedOffset
        if (version >= 8 and version <= 32767) {
            try types.encodeInt64(writer, self.committed_offset);
        }

        // Field: CommittedLeaderEpoch
        if (version >= 8 and version <= 32767) {
            try types.encodeInt32(writer, self.committed_leader_epoch);
        }

        // Field: Metadata
        if (version >= 8 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.metadata);
            } else {
                try types.encodeString(writer, self.metadata);
            }
        }

        // Field: ErrorCode
        if (version >= 8 and version <= 32767) {
            try types.encodeInt16(writer, self.error_code);
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

        // Field: PartitionIndex
        if (version >= 8 and version <= 32767) {
            total_size += types.computeSizeInt32(self.partition_index);
        }

        // Field: CommittedOffset
        if (version >= 8 and version <= 32767) {
            total_size += types.computeSizeInt64(self.committed_offset);
        }

        // Field: CommittedLeaderEpoch
        if (version >= 8 and version <= 32767) {
            total_size += types.computeSizeInt32(self.committed_leader_epoch);
        }

        // Field: Metadata
        if (version >= 8 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.metadata) else types.computeSizeString(self.metadata);
        }

        // Field: ErrorCode
        if (version >= 8 and version <= 32767) {
            total_size += types.computeSizeInt16(self.error_code);
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
        // Field: PartitionIndex
        if (version >= 8 and version <= 32767) {
            self.partition_index = try types.decodeInt32(reader);
        }

        // Field: CommittedOffset
        if (version >= 8 and version <= 32767) {
            self.committed_offset = try types.decodeInt64(reader);
        }

        // Field: CommittedLeaderEpoch
        if (version >= 8 and version <= 32767) {
            self.committed_leader_epoch = try types.decodeInt32(reader);
        }

        // Field: Metadata
        if (version >= 8 and version <= 32767) {
            self.metadata = if (is_flexible)
                try types.decodeCompactString(reader, allocator)
            else
                try types.decodeString(reader, allocator);
        }

        // Field: ErrorCode
        if (version >= 8 and version <= 32767) {
            self.error_code = try types.decodeInt16(reader);
        }


        if (is_flexible) {
            const tagged_fields_data = try types.decodeTaggedFields(reader, allocator);
            self._tagged_fields = tagged_fields_data;
        }
        return self;
    }

    fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("6+") catch return false;
        return range.contains(version);
    }
};

/// Nested struct: OffsetFetchResponseTopic
pub const OffsetFetchResponseTopic = struct {
    const Self = @This();

    /// The topic name.
    /// Versions: 0-7
    name: []const u8 = "",
    /// The responses per partition.
    /// Versions: 0-7
    partitions: ?[]OffsetFetchResponsePartition = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: Name
        if (version >= 0 and version <= 7) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.name);
            } else {
                try types.encodeString(writer, self.name);
            }
        }

        // Field: Partitions
        if (version >= 0 and version <= 7) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.partitions);
                if (self.partitions) |arr| {
                    for (arr) |*item| {
                        try OffsetFetchResponsePartition.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.partitions);
                if (self.partitions) |arr| {
                    for (arr) |*item| {
                        try OffsetFetchResponsePartition.encode(item, writer, version);
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
        if (version >= 0 and version <= 7) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.name) else types.computeSizeString(self.name);
        }

        // Field: Partitions
        if (version >= 0 and version <= 7) {
            if (self.partitions) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try OffsetFetchResponsePartition.computeSize(item, version);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(1) else 4;
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
        if (version >= 0 and version <= 7) {
            self.name = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: Partitions
        if (version >= 0 and version <= 7) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(OffsetFetchResponsePartition, array_len);
            for (array) |*item| {
                item.* = try OffsetFetchResponsePartition.decode(reader, version, allocator);
            }
            self.partitions = array;
        }


        if (is_flexible) {
            const tagged_fields_data = try types.decodeTaggedFields(reader, allocator);
            self._tagged_fields = tagged_fields_data;
        }
        return self;
    }

    fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("6+") catch return false;
        return range.contains(version);
    }
};

/// Nested struct: OffsetFetchResponsePartition
pub const OffsetFetchResponsePartition = struct {
    const Self = @This();

    /// The partition index.
    /// Versions: 0-7
    partition_index: i32 = 0,
    /// The committed message offset.
    /// Versions: 0-7
    committed_offset: i64 = 0,
    /// The leader epoch.
    /// Versions: 5-7
    committed_leader_epoch: i32 = -1,
    /// The partition metadata.
    /// Versions: 0-7
    metadata: ?[]const u8 = null,
    /// The error code, or 0 if there was no error.
    /// Versions: 0-7
    error_code: i16 = 0,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: PartitionIndex
        if (version >= 0 and version <= 7) {
            try types.encodeInt32(writer, self.partition_index);
        }

        // Field: CommittedOffset
        if (version >= 0 and version <= 7) {
            try types.encodeInt64(writer, self.committed_offset);
        }

        // Field: CommittedLeaderEpoch
        if (version >= 5 and version <= 7) {
            try types.encodeInt32(writer, self.committed_leader_epoch);
        }

        // Field: Metadata
        if (version >= 0 and version <= 7) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.metadata);
            } else {
                try types.encodeString(writer, self.metadata);
            }
        }

        // Field: ErrorCode
        if (version >= 0 and version <= 7) {
            try types.encodeInt16(writer, self.error_code);
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

        // Field: PartitionIndex
        if (version >= 0 and version <= 7) {
            total_size += types.computeSizeInt32(self.partition_index);
        }

        // Field: CommittedOffset
        if (version >= 0 and version <= 7) {
            total_size += types.computeSizeInt64(self.committed_offset);
        }

        // Field: CommittedLeaderEpoch
        if (version >= 5 and version <= 7) {
            total_size += types.computeSizeInt32(self.committed_leader_epoch);
        }

        // Field: Metadata
        if (version >= 0 and version <= 7) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.metadata) else types.computeSizeString(self.metadata);
        }

        // Field: ErrorCode
        if (version >= 0 and version <= 7) {
            total_size += types.computeSizeInt16(self.error_code);
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
        // Field: PartitionIndex
        if (version >= 0 and version <= 7) {
            self.partition_index = try types.decodeInt32(reader);
        }

        // Field: CommittedOffset
        if (version >= 0 and version <= 7) {
            self.committed_offset = try types.decodeInt64(reader);
        }

        // Field: CommittedLeaderEpoch
        if (version >= 5 and version <= 7) {
            self.committed_leader_epoch = try types.decodeInt32(reader);
        }

        // Field: Metadata
        if (version >= 0 and version <= 7) {
            self.metadata = if (is_flexible)
                try types.decodeCompactString(reader, allocator)
            else
                try types.decodeString(reader, allocator);
        }

        // Field: ErrorCode
        if (version >= 0 and version <= 7) {
            self.error_code = try types.decodeInt16(reader);
        }


        if (is_flexible) {
            const tagged_fields_data = try types.decodeTaggedFields(reader, allocator);
            self._tagged_fields = tagged_fields_data;
        }
        return self;
    }

    fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("6+") catch return false;
        return range.contains(version);
    }
};

/// OffsetFetchResponse
pub const OffsetFetchResponse = struct {
    const Self = @This();

    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    /// Versions: 3+
    throttle_time_ms: i32 = 0,
    /// The responses per topic.
    /// Versions: 0-7
    topics: ?[]OffsetFetchResponseTopic = null,
    /// The top-level error code, or 0 if there was no error.
    /// Versions: 2-7
    error_code: i16 = 0,
    /// The responses per group id.
    /// Versions: 8+
    groups: ?[]OffsetFetchResponseGroup = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 1, .max = 10 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 9;
    }

    /// Create a default instance of OffsetFetchResponse
    pub fn default() Self {
        return .{
            .throttle_time_ms = 0,
            .topics = null,
            .error_code = 0,
            .groups = null,
            ._tagged_fields = null,
        };
    }

    /// Sets `throttle_time_ms` to the passed value.
    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    /// Versions: 3+
    pub fn withThrottleTimeMs(self: Self, value: i32) Self {
        var result = self;
        result.throttle_time_ms = value;
        return result;
    }

    /// Sets `topics` to the passed value.
    /// The responses per topic.
    /// Versions: 0-7
    pub fn withTopics(self: Self, value: ?[]OffsetFetchResponseTopic) Self {
        var result = self;
        result.topics = value;
        return result;
    }

    /// Sets `error_code` to the passed value.
    /// The top-level error code, or 0 if there was no error.
    /// Versions: 2-7
    pub fn withErrorCode(self: Self, value: i16) Self {
        var result = self;
        result.error_code = value;
        return result;
    }

    /// Sets `groups` to the passed value.
    /// The responses per group id.
    /// Versions: 8+
    pub fn withGroups(self: Self, value: ?[]OffsetFetchResponseGroup) Self {
        var result = self;
        result.groups = value;
        return result;
    }

    /// Encode OffsetFetchResponse
    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: ThrottleTimeMs
        if (version >= 3 and version <= 32767) {
            try types.encodeInt32(writer, self.throttle_time_ms);
        }

        // Field: Topics
        if (version >= 0 and version <= 7) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.topics);
                if (self.topics) |arr| {
                    for (arr) |*item| {
                        try OffsetFetchResponseTopic.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.topics);
                if (self.topics) |arr| {
                    for (arr) |*item| {
                        try OffsetFetchResponseTopic.encode(item, writer, version);
                    }
                }
            }
        }

        // Field: ErrorCode
        if (version >= 2 and version <= 7) {
            try types.encodeInt16(writer, self.error_code);
        }

        // Field: Groups
        if (version >= 8 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.groups);
                if (self.groups) |arr| {
                    for (arr) |*item| {
                        try OffsetFetchResponseGroup.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.groups);
                if (self.groups) |arr| {
                    for (arr) |*item| {
                        try OffsetFetchResponseGroup.encode(item, writer, version);
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

    /// Compute the size of OffsetFetchResponse for the given version
    pub fn computeSize(self: *const Self, version: i16) !usize {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        var total_size: usize = 0;

        // Field: ThrottleTimeMs
        if (version >= 3 and version <= 32767) {
            total_size += types.computeSizeInt32(self.throttle_time_ms);
        }

        // Field: Topics
        if (version >= 0 and version <= 7) {
            if (self.topics) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try OffsetFetchResponseTopic.computeSize(item, version);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(1) else 4;
            }
        }

        // Field: ErrorCode
        if (version >= 2 and version <= 7) {
            total_size += types.computeSizeInt16(self.error_code);
        }

        // Field: Groups
        if (version >= 8 and version <= 32767) {
            if (self.groups) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try OffsetFetchResponseGroup.computeSize(item, version);
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

    /// Decode OffsetFetchResponse
    pub fn decode(reader: anytype, version: i16, allocator: std.mem.Allocator) !Self {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        var self: Self = .{};

        // Field: ThrottleTimeMs
        if (version >= 3 and version <= 32767) {
            self.throttle_time_ms = try types.decodeInt32(reader);
        }

        // Field: Topics
        if (version >= 0 and version <= 7) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(OffsetFetchResponseTopic, array_len);
            for (array) |*item| {
                item.* = try OffsetFetchResponseTopic.decode(reader, version, allocator);
            }
            self.topics = array;
        }

        // Field: ErrorCode
        if (version >= 2 and version <= 7) {
            self.error_code = try types.decodeInt16(reader);
        }

        // Field: Groups
        if (version >= 8 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(OffsetFetchResponseGroup, array_len);
            for (array) |*item| {
                item.* = try OffsetFetchResponseGroup.decode(reader, version, allocator);
            }
            self.groups = array;
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
        const range = types.VersionRange.parse("1-10") catch return false;
        return range.contains(version);
    }
    /// Check if version uses flexible encoding
    pub fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("6+") catch return false;
        return range.contains(version);
    }
    /// Get the header version for this API version
    /// Returns 2 for flexible versions, 1 for classic versions
    pub fn headerVersion(api_version: i16) i16 {
        if (isFlexibleVersion(api_version)) return 2;
        return 1;
    }

};
