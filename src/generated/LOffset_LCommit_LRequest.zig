//! Auto-generated Kafka protocol message
//! Message: OffsetCommitRequest
//! API Key: 8
//! Type: request
//! Valid Versions: 2-10
//! Flexible Versions: 8+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// Nested struct: OffsetCommitRequestTopic
pub const OffsetCommitRequestTopic = struct {
    const Self = @This();

    /// The topic name.
    /// Versions: 0-9
    name: []const u8 = "",
    /// The topic ID.
    /// Versions: 10+
    topic_id: [16]u8 = [_]u8{0} ** 16,
    /// Each partition to commit offsets for.
    /// Versions: 0+
    partitions: ?[]OffsetCommitRequestPartition = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: Name
        if (version >= 0 and version <= 9) {
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
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLen(writer, self.partitions);
                if (self.partitions) |arr| {
                    for (arr) |*item| {
                        try OffsetCommitRequestPartition.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLen(writer, self.partitions);
                if (self.partitions) |arr| {
                    for (arr) |*item| {
                        try OffsetCommitRequestPartition.encode(item, writer, version);
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
        if (version >= 0 and version <= 9) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.name) else types.computeSizeString(self.name);
        }

        // Field: TopicId
        if (version >= 10 and version <= 32767) {
            total_size += types.computeSizeUuid(self.topic_id);
        }

        // Field: Partitions
        if (version >= 0 and version <= 32767) {
            if (self.partitions) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try OffsetCommitRequestPartition.computeSize(item, version);
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
        if (version >= 0 and version <= 9) {
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
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(OffsetCommitRequestPartition, array_len);
            for (array) |*item| {
                item.* = try OffsetCommitRequestPartition.decode(reader, version, allocator);
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
        const range = types.VersionRange.parse("8+") catch return false;
        return range.contains(version);
    }
};

/// Nested struct: OffsetCommitRequestPartition
pub const OffsetCommitRequestPartition = struct {
    const Self = @This();

    /// The partition index.
    /// Versions: 0+
    partition_index: i32 = 0,
    /// The message offset to be committed.
    /// Versions: 0+
    committed_offset: i64 = 0,
    /// The leader epoch of this partition.
    /// Versions: 6+
    committed_leader_epoch: i32 = -1,
    /// Any associated metadata the client wants to keep.
    /// Versions: 0+
    committed_metadata: ?[]const u8 = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: PartitionIndex
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.partition_index);
        }

        // Field: CommittedOffset
        if (version >= 0 and version <= 32767) {
            try types.encodeInt64(writer, self.committed_offset);
        }

        // Field: CommittedLeaderEpoch
        if (version >= 6 and version <= 32767) {
            try types.encodeInt32(writer, self.committed_leader_epoch);
        }

        // Field: CommittedMetadata
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.committed_metadata);
            } else {
                try types.encodeString(writer, self.committed_metadata);
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

        // Field: PartitionIndex
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.partition_index);
        }

        // Field: CommittedOffset
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt64(self.committed_offset);
        }

        // Field: CommittedLeaderEpoch
        if (version >= 6 and version <= 32767) {
            total_size += types.computeSizeInt32(self.committed_leader_epoch);
        }

        // Field: CommittedMetadata
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.committed_metadata) else types.computeSizeString(self.committed_metadata);
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
        if (version >= 0 and version <= 32767) {
            self.partition_index = try types.decodeInt32(reader);
        }

        // Field: CommittedOffset
        if (version >= 0 and version <= 32767) {
            self.committed_offset = try types.decodeInt64(reader);
        }

        // Field: CommittedLeaderEpoch
        if (version >= 6 and version <= 32767) {
            self.committed_leader_epoch = try types.decodeInt32(reader);
        }

        // Field: CommittedMetadata
        if (version >= 0 and version <= 32767) {
            self.committed_metadata = if (is_flexible)
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
        const range = types.VersionRange.parse("8+") catch return false;
        return range.contains(version);
    }
};

/// OffsetCommitRequest
pub const OffsetCommitRequest = struct {
    const Self = @This();

    /// The unique group identifier.
    group_id: []const u8 = "",
    /// The generation of the group if using the classic group protocol or the member epoch if using the consumer protocol.
    /// Versions: 1+
    generation_id_or_member_epoch: i32 = -1,
    /// The member ID assigned by the group coordinator.
    /// Versions: 1+
    member_id: []const u8 = "",
    /// The unique identifier of the consumer instance provided by end user.
    /// Versions: 7+
    group_instance_id: ?[]const u8 = null,
    /// The time period in ms to retain the offset.
    /// Versions: 2-4
    retention_time_ms: i64 = -1,
    /// The topics to commit offsets for.
    topics: ?[]OffsetCommitRequestTopic = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 2, .max = 10 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 8;
    }

    /// Create a default instance of OffsetCommitRequest
    pub fn default() Self {
        return .{
            .group_id = "",
            .generation_id_or_member_epoch = -1,
            .member_id = "",
            .group_instance_id = null,
            .retention_time_ms = -1,
            .topics = null,
            ._tagged_fields = null,
        };
    }

    /// Sets `group_id` to the passed value.
    /// The unique group identifier.
    pub fn withGroupId(self: Self, value: []const u8) Self {
        var result = self;
        result.group_id = value;
        return result;
    }

    /// Sets `generation_id_or_member_epoch` to the passed value.
    /// The generation of the group if using the classic group protocol or the member epoch if using the consumer protocol.
    /// Versions: 1+
    pub fn withGenerationIdOrMemberEpoch(self: Self, value: i32) Self {
        var result = self;
        result.generation_id_or_member_epoch = value;
        return result;
    }

    /// Sets `member_id` to the passed value.
    /// The member ID assigned by the group coordinator.
    /// Versions: 1+
    pub fn withMemberId(self: Self, value: []const u8) Self {
        var result = self;
        result.member_id = value;
        return result;
    }

    /// Sets `group_instance_id` to the passed value.
    /// The unique identifier of the consumer instance provided by end user.
    /// Versions: 7+
    pub fn withGroupInstanceId(self: Self, value: ?[]const u8) Self {
        var result = self;
        result.group_instance_id = value;
        return result;
    }

    /// Sets `retention_time_ms` to the passed value.
    /// The time period in ms to retain the offset.
    /// Versions: 2-4
    pub fn withRetentionTimeMs(self: Self, value: i64) Self {
        var result = self;
        result.retention_time_ms = value;
        return result;
    }

    /// Sets `topics` to the passed value.
    /// The topics to commit offsets for.
    pub fn withTopics(self: Self, value: ?[]OffsetCommitRequestTopic) Self {
        var result = self;
        result.topics = value;
        return result;
    }

    /// Encode OffsetCommitRequest
    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: GroupId
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.group_id);
            } else {
                try types.encodeString(writer, self.group_id);
            }
        }

        // Field: GenerationIdOrMemberEpoch
        if (version >= 1 and version <= 32767) {
            try types.encodeInt32(writer, self.generation_id_or_member_epoch);
        }

        // Field: MemberId
        if (version >= 1 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.member_id);
            } else {
                try types.encodeString(writer, self.member_id);
            }
        }

        // Field: GroupInstanceId
        if (version >= 7 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.group_instance_id);
            } else {
                try types.encodeString(writer, self.group_instance_id);
            }
        }

        // Field: RetentionTimeMs
        if (version >= 2 and version <= 4) {
            try types.encodeInt64(writer, self.retention_time_ms);
        }

        // Field: Topics
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLen(writer, self.topics);
                if (self.topics) |arr| {
                    for (arr) |*item| {
                        try OffsetCommitRequestTopic.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLen(writer, self.topics);
                if (self.topics) |arr| {
                    for (arr) |*item| {
                        try OffsetCommitRequestTopic.encode(item, writer, version);
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

    /// Compute the size of OffsetCommitRequest for the given version
    pub fn computeSize(self: *const Self, version: i16) !usize {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        var total_size: usize = 0;

        // Field: GroupId
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.group_id) else types.computeSizeString(self.group_id);
        }

        // Field: GenerationIdOrMemberEpoch
        if (version >= 1 and version <= 32767) {
            total_size += types.computeSizeInt32(self.generation_id_or_member_epoch);
        }

        // Field: MemberId
        if (version >= 1 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.member_id) else types.computeSizeString(self.member_id);
        }

        // Field: GroupInstanceId
        if (version >= 7 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.group_instance_id) else types.computeSizeString(self.group_instance_id);
        }

        // Field: RetentionTimeMs
        if (version >= 2 and version <= 4) {
            total_size += types.computeSizeInt64(self.retention_time_ms);
        }

        // Field: Topics
        if (version >= 0 and version <= 32767) {
            if (self.topics) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try OffsetCommitRequestTopic.computeSize(item, version);
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

    /// Decode OffsetCommitRequest
    pub fn decode(reader: anytype, version: i16, allocator: std.mem.Allocator) !Self {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        var self: Self = .{};

        // Field: GroupId
        if (version >= 0 and version <= 32767) {
            self.group_id = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: GenerationIdOrMemberEpoch
        if (version >= 1 and version <= 32767) {
            self.generation_id_or_member_epoch = try types.decodeInt32(reader);
        }

        // Field: MemberId
        if (version >= 1 and version <= 32767) {
            self.member_id = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: GroupInstanceId
        if (version >= 7 and version <= 32767) {
            self.group_instance_id = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: RetentionTimeMs
        if (version >= 2 and version <= 4) {
            self.retention_time_ms = try types.decodeInt64(reader);
        }

        // Field: Topics
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(OffsetCommitRequestTopic, array_len);
            for (array) |*item| {
                item.* = try OffsetCommitRequestTopic.decode(reader, version, allocator);
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
        const range = types.VersionRange.parse("2-10") catch return false;
        return range.contains(version);
    }
    /// Check if version uses flexible encoding
    pub fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("8+") catch return false;
        return range.contains(version);
    }
    /// Get the header version for this API version
    /// Returns 2 for flexible versions, 1 for classic versions
    pub fn headerVersion(api_version: i16) i16 {
        if (isFlexibleVersion(api_version)) return 2;
        return 1;
    }

};
