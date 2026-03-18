//! Auto-generated Kafka protocol message
//! Message: TxnOffsetCommitRequest
//! API Key: 28
//! Type: request
//! Valid Versions: 0-5
//! Flexible Versions: 3+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// Nested struct: TxnOffsetCommitRequestTopic
pub const TxnOffsetCommitRequestTopic = struct {
    const Self = @This();

    /// The topic name.
    /// Versions: 0+
    name: []const u8 = "",
    /// The partitions inside the topic that we want to commit offsets for.
    /// Versions: 0+
    partitions: ?[]TxnOffsetCommitRequestPartition = null,

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

        // Field: Partitions
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.partitions);
                if (self.partitions) |arr| {
                    for (arr) |*item| {
                        try TxnOffsetCommitRequestPartition.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.partitions);
                if (self.partitions) |arr| {
                    for (arr) |*item| {
                        try TxnOffsetCommitRequestPartition.encode(item, writer, version);
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

        // Field: Partitions
        if (version >= 0 and version <= 32767) {
            if (self.partitions) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try TxnOffsetCommitRequestPartition.computeSize(item, version);
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
        if (version >= 0 and version <= 32767) {
            self.name = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: Partitions
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(TxnOffsetCommitRequestPartition, array_len);
            for (array) |*item| {
                item.* = try TxnOffsetCommitRequestPartition.decode(reader, version, allocator);
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
        const range = types.VersionRange.parse("3+") catch return false;
        return range.contains(version);
    }
};

/// Nested struct: TxnOffsetCommitRequestPartition
pub const TxnOffsetCommitRequestPartition = struct {
    const Self = @This();

    /// The index of the partition within the topic.
    /// Versions: 0+
    partition_index: i32 = 0,
    /// The message offset to be committed.
    /// Versions: 0+
    committed_offset: i64 = 0,
    /// The leader epoch of the last consumed record.
    /// Versions: 2+
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
        if (version >= 2 and version <= 32767) {
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
        if (version >= 2 and version <= 32767) {
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
        if (version >= 2 and version <= 32767) {
            self.committed_leader_epoch = try types.decodeInt32(reader);
        }

        // Field: CommittedMetadata
        if (version >= 0 and version <= 32767) {
            self.committed_metadata = if (is_flexible)
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
        const range = types.VersionRange.parse("3+") catch return false;
        return range.contains(version);
    }
};

/// TxnOffsetCommitRequest
pub const TxnOffsetCommitRequest = struct {
    const Self = @This();

    /// The ID of the transaction.
    transactional_id: []const u8 = "",
    /// The ID of the group.
    group_id: []const u8 = "",
    /// The current producer ID in use by the transactional ID.
    producer_id: i64 = 0,
    /// The current epoch associated with the producer ID.
    producer_epoch: i16 = 0,
    /// The generation of the consumer.
    /// Versions: 3+
    generation_id: i32 = -1,
    /// The member ID assigned by the group coordinator.
    /// Versions: 3+
    member_id: []const u8 = "",
    /// The unique identifier of the consumer instance provided by end user.
    /// Versions: 3+
    group_instance_id: ?[]const u8 = null,
    /// Each topic that we want to commit offsets for.
    topics: ?[]TxnOffsetCommitRequestTopic = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 0, .max = 5 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 28;
    }

    /// Create a default instance of TxnOffsetCommitRequest
    pub fn default() Self {
        return .{
            .transactional_id = "",
            .group_id = "",
            .producer_id = 0,
            .producer_epoch = 0,
            .generation_id = -1,
            .member_id = "",
            .group_instance_id = null,
            .topics = null,
            ._tagged_fields = null,
        };
    }

    /// Sets `transactional_id` to the passed value.
    /// The ID of the transaction.
    pub fn withTransactionalId(self: Self, value: []const u8) Self {
        var result = self;
        result.transactional_id = value;
        return result;
    }

    /// Sets `group_id` to the passed value.
    /// The ID of the group.
    pub fn withGroupId(self: Self, value: []const u8) Self {
        var result = self;
        result.group_id = value;
        return result;
    }

    /// Sets `producer_id` to the passed value.
    /// The current producer ID in use by the transactional ID.
    pub fn withProducerId(self: Self, value: i64) Self {
        var result = self;
        result.producer_id = value;
        return result;
    }

    /// Sets `producer_epoch` to the passed value.
    /// The current epoch associated with the producer ID.
    pub fn withProducerEpoch(self: Self, value: i16) Self {
        var result = self;
        result.producer_epoch = value;
        return result;
    }

    /// Sets `generation_id` to the passed value.
    /// The generation of the consumer.
    /// Versions: 3+
    pub fn withGenerationId(self: Self, value: i32) Self {
        var result = self;
        result.generation_id = value;
        return result;
    }

    /// Sets `member_id` to the passed value.
    /// The member ID assigned by the group coordinator.
    /// Versions: 3+
    pub fn withMemberId(self: Self, value: []const u8) Self {
        var result = self;
        result.member_id = value;
        return result;
    }

    /// Sets `group_instance_id` to the passed value.
    /// The unique identifier of the consumer instance provided by end user.
    /// Versions: 3+
    pub fn withGroupInstanceId(self: Self, value: ?[]const u8) Self {
        var result = self;
        result.group_instance_id = value;
        return result;
    }

    /// Sets `topics` to the passed value.
    /// Each topic that we want to commit offsets for.
    pub fn withTopics(self: Self, value: ?[]TxnOffsetCommitRequestTopic) Self {
        var result = self;
        result.topics = value;
        return result;
    }

    /// Encode TxnOffsetCommitRequest
    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: TransactionalId
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.transactional_id);
            } else {
                try types.encodeString(writer, self.transactional_id);
            }
        }

        // Field: GroupId
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.group_id);
            } else {
                try types.encodeString(writer, self.group_id);
            }
        }

        // Field: ProducerId
        if (version >= 0 and version <= 32767) {
            try types.encodeInt64(writer, self.producer_id);
        }

        // Field: ProducerEpoch
        if (version >= 0 and version <= 32767) {
            try types.encodeInt16(writer, self.producer_epoch);
        }

        // Field: GenerationId
        if (version >= 3 and version <= 32767) {
            try types.encodeInt32(writer, self.generation_id);
        }

        // Field: MemberId
        if (version >= 3 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.member_id);
            } else {
                try types.encodeString(writer, self.member_id);
            }
        }

        // Field: GroupInstanceId
        if (version >= 3 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.group_instance_id);
            } else {
                try types.encodeString(writer, self.group_instance_id);
            }
        }

        // Field: Topics
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.topics);
                if (self.topics) |arr| {
                    for (arr) |*item| {
                        try TxnOffsetCommitRequestTopic.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.topics);
                if (self.topics) |arr| {
                    for (arr) |*item| {
                        try TxnOffsetCommitRequestTopic.encode(item, writer, version);
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

    /// Compute the size of TxnOffsetCommitRequest for the given version
    pub fn computeSize(self: *const Self, version: i16) !usize {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        var total_size: usize = 0;

        // Field: TransactionalId
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.transactional_id) else types.computeSizeString(self.transactional_id);
        }

        // Field: GroupId
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.group_id) else types.computeSizeString(self.group_id);
        }

        // Field: ProducerId
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt64(self.producer_id);
        }

        // Field: ProducerEpoch
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt16(self.producer_epoch);
        }

        // Field: GenerationId
        if (version >= 3 and version <= 32767) {
            total_size += types.computeSizeInt32(self.generation_id);
        }

        // Field: MemberId
        if (version >= 3 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.member_id) else types.computeSizeString(self.member_id);
        }

        // Field: GroupInstanceId
        if (version >= 3 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.group_instance_id) else types.computeSizeString(self.group_instance_id);
        }

        // Field: Topics
        if (version >= 0 and version <= 32767) {
            if (self.topics) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try TxnOffsetCommitRequestTopic.computeSize(item, version);
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

    /// Decode TxnOffsetCommitRequest
    pub fn decode(reader: anytype, version: i16, allocator: std.mem.Allocator) !Self {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        var self: Self = .{};

        // Field: TransactionalId
        if (version >= 0 and version <= 32767) {
            self.transactional_id = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: GroupId
        if (version >= 0 and version <= 32767) {
            self.group_id = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: ProducerId
        if (version >= 0 and version <= 32767) {
            self.producer_id = try types.decodeInt64(reader);
        }

        // Field: ProducerEpoch
        if (version >= 0 and version <= 32767) {
            self.producer_epoch = try types.decodeInt16(reader);
        }

        // Field: GenerationId
        if (version >= 3 and version <= 32767) {
            self.generation_id = try types.decodeInt32(reader);
        }

        // Field: MemberId
        if (version >= 3 and version <= 32767) {
            self.member_id = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: GroupInstanceId
        if (version >= 3 and version <= 32767) {
            self.group_instance_id = if (is_flexible)
                try types.decodeCompactString(reader, allocator)
            else
                try types.decodeString(reader, allocator);
        }

        // Field: Topics
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(TxnOffsetCommitRequestTopic, array_len);
            for (array) |*item| {
                item.* = try TxnOffsetCommitRequestTopic.decode(reader, version, allocator);
            }
            self.topics = array;
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
        const range = types.VersionRange.parse("0-5") catch return false;
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
