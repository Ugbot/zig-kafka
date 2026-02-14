//! Auto-generated Kafka protocol message
//! Message: ShareFetchRequest
//! API Key: 78
//! Type: request
//! Valid Versions: 1
//! Flexible Versions: 0+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// Nested struct: ForgottenTopic
pub const ForgottenTopic = struct {
    const Self = @This();

    /// The unique topic ID.
    /// Versions: 0+
    topic_id: [16]u8 = [_]u8{0} ** 16,
    /// The partitions indexes to forget.
    /// Versions: 0+
    partitions: ?[]i32 = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: TopicId
        if (version >= 0 and version <= 32767) {
            try types.encodeUuid(writer, self.topic_id);
        }

        // Field: Partitions
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayNonNull(i32, writer, self.partitions, types.encodeInt32);
            } else {
                try types.encodeArrayNonNull(i32, writer, self.partitions, types.encodeInt32);
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
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeUuid(self.topic_id);
        }

        // Field: Partitions
        if (version >= 0 and version <= 32767) {
            if (self.partitions) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |item| {
                    total_size += types.computeSizeInt32(item);
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
        // Field: TopicId
        if (version >= 0 and version <= 32767) {
            self.topic_id = try types.decodeUuid(reader);
        }

        // Field: Partitions
        if (version >= 0 and version <= 32767) {
            self.partitions = if (is_flexible)
                try types.decodeCompactPrimitiveArray(i32, reader, allocator, types.decodeInt32)
            else
                try types.decodePrimitiveArray(i32, reader, allocator, types.decodeInt32);
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

/// Nested struct: FetchTopic
pub const FetchTopic = struct {
    const Self = @This();

    /// The unique topic ID.
    /// Versions: 0+
    topic_id: [16]u8 = [_]u8{0} ** 16,
    /// The partitions to fetch.
    /// Versions: 0+
    partitions: ?[]FetchPartition = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: TopicId
        if (version >= 0 and version <= 32767) {
            try types.encodeUuid(writer, self.topic_id);
        }

        // Field: Partitions
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.partitions);
                if (self.partitions) |arr| {
                    for (arr) |*item| {
                        try FetchPartition.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.partitions);
                if (self.partitions) |arr| {
                    for (arr) |*item| {
                        try FetchPartition.encode(item, writer, version);
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

        // Field: TopicId
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeUuid(self.topic_id);
        }

        // Field: Partitions
        if (version >= 0 and version <= 32767) {
            if (self.partitions) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try FetchPartition.computeSize(item, version);
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
        // Field: TopicId
        if (version >= 0 and version <= 32767) {
            self.topic_id = try types.decodeUuid(reader);
        }

        // Field: Partitions
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(FetchPartition, array_len);
            for (array) |*item| {
                item.* = try FetchPartition.decode(reader, version, allocator);
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
        const range = types.VersionRange.parse("0+") catch return false;
        return range.contains(version);
    }
};

/// Nested struct: FetchPartition
pub const FetchPartition = struct {
    const Self = @This();

    /// The partition index.
    /// Versions: 0+
    partition_index: i32 = 0,
    /// The maximum bytes to fetch from this partition. 0 when only acknowledgement with no fetching is required. See KIP-74 for cases where this limit may not be honored.
    /// Versions: 0
    partition_max_bytes: i32 = 0,
    /// Record batches to acknowledge.
    /// Versions: 0+
    acknowledgement_batches: ?[]AcknowledgementBatch = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: PartitionIndex
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.partition_index);
        }

        // Field: PartitionMaxBytes
        if (version >= 0 and version <= 0) {
            try types.encodeInt32(writer, self.partition_max_bytes);
        }

        // Field: AcknowledgementBatches
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.acknowledgement_batches);
                if (self.acknowledgement_batches) |arr| {
                    for (arr) |*item| {
                        try AcknowledgementBatch.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.acknowledgement_batches);
                if (self.acknowledgement_batches) |arr| {
                    for (arr) |*item| {
                        try AcknowledgementBatch.encode(item, writer, version);
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

        // Field: PartitionIndex
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.partition_index);
        }

        // Field: PartitionMaxBytes
        if (version >= 0 and version <= 0) {
            total_size += types.computeSizeInt32(self.partition_max_bytes);
        }

        // Field: AcknowledgementBatches
        if (version >= 0 and version <= 32767) {
            if (self.acknowledgement_batches) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try AcknowledgementBatch.computeSize(item, version);
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
        // Field: PartitionIndex
        if (version >= 0 and version <= 32767) {
            self.partition_index = try types.decodeInt32(reader);
        }

        // Field: PartitionMaxBytes
        if (version >= 0 and version <= 0) {
            self.partition_max_bytes = try types.decodeInt32(reader);
        }

        // Field: AcknowledgementBatches
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(AcknowledgementBatch, array_len);
            for (array) |*item| {
                item.* = try AcknowledgementBatch.decode(reader, version, allocator);
            }
            self.acknowledgement_batches = array;
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

/// Nested struct: AcknowledgementBatch
pub const AcknowledgementBatch = struct {
    const Self = @This();

    /// First offset of batch of records to acknowledge.
    /// Versions: 0+
    first_offset: i64 = 0,
    /// Last offset (inclusive) of batch of records to acknowledge.
    /// Versions: 0+
    last_offset: i64 = 0,
    /// Array of acknowledge types - 0:Gap,1:Accept,2:Release,3:Reject.
    /// Versions: 0+
    acknowledge_types: ?[]i8 = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: FirstOffset
        if (version >= 0 and version <= 32767) {
            try types.encodeInt64(writer, self.first_offset);
        }

        // Field: LastOffset
        if (version >= 0 and version <= 32767) {
            try types.encodeInt64(writer, self.last_offset);
        }

        // Field: AcknowledgeTypes
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayNonNull(i8, writer, self.acknowledge_types, types.encodeInt8);
            } else {
                try types.encodeArrayNonNull(i8, writer, self.acknowledge_types, types.encodeInt8);
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

        // Field: FirstOffset
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt64(self.first_offset);
        }

        // Field: LastOffset
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt64(self.last_offset);
        }

        // Field: AcknowledgeTypes
        if (version >= 0 and version <= 32767) {
            if (self.acknowledge_types) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |item| {
                    total_size += types.computeSizeInt8(item);
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
        // Field: FirstOffset
        if (version >= 0 and version <= 32767) {
            self.first_offset = try types.decodeInt64(reader);
        }

        // Field: LastOffset
        if (version >= 0 and version <= 32767) {
            self.last_offset = try types.decodeInt64(reader);
        }

        // Field: AcknowledgeTypes
        if (version >= 0 and version <= 32767) {
            self.acknowledge_types = if (is_flexible)
                try types.decodeCompactPrimitiveArray(i8, reader, allocator, types.decodeInt8)
            else
                try types.decodePrimitiveArray(i8, reader, allocator, types.decodeInt8);
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

/// ShareFetchRequest
pub const ShareFetchRequest = struct {
    const Self = @This();

    /// The group identifier.
    group_id: ?[]const u8 = null,
    /// The member ID.
    member_id: ?[]const u8 = null,
    /// The current share session epoch: 0 to open a share session; -1 to close it; otherwise increments for consecutive requests.
    share_session_epoch: i32 = 0,
    /// The maximum time in milliseconds to wait for the response.
    max_wait_ms: i32 = 0,
    /// The minimum bytes to accumulate in the response.
    min_bytes: i32 = 0,
    /// The maximum bytes to fetch. See KIP-74 for cases where this limit may not be honored.
    max_bytes: i32 = 0x7fffffff,
    /// The maximum number of records to fetch. This limit can be exceeded for alignment of batch boundaries.
    /// Versions: 1+
    max_records: i32 = 0,
    /// The optimal number of records for batches of acquired records and acknowledgements.
    /// Versions: 1+
    batch_size: i32 = 0,
    /// The topics to fetch.
    topics: ?[]FetchTopic = null,
    /// The partitions to remove from this share session.
    forgotten_topics_data: ?[]ForgottenTopic = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 1, .max = 1 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 78;
    }

    /// Create a default instance of ShareFetchRequest
    pub fn default() Self {
        return .{
            .group_id = null,
            .member_id = null,
            .share_session_epoch = 0,
            .max_wait_ms = 0,
            .min_bytes = 0,
            .max_bytes = 0x7fffffff,
            .max_records = 0,
            .batch_size = 0,
            .topics = null,
            .forgotten_topics_data = null,
            ._tagged_fields = null,
        };
    }

    /// Sets `group_id` to the passed value.
    /// The group identifier.
    pub fn withGroupId(self: Self, value: ?[]const u8) Self {
        var result = self;
        result.group_id = value;
        return result;
    }

    /// Sets `member_id` to the passed value.
    /// The member ID.
    pub fn withMemberId(self: Self, value: ?[]const u8) Self {
        var result = self;
        result.member_id = value;
        return result;
    }

    /// Sets `share_session_epoch` to the passed value.
    /// The current share session epoch: 0 to open a share session; -1 to close it; otherwise increments for consecutive requests.
    pub fn withShareSessionEpoch(self: Self, value: i32) Self {
        var result = self;
        result.share_session_epoch = value;
        return result;
    }

    /// Sets `max_wait_ms` to the passed value.
    /// The maximum time in milliseconds to wait for the response.
    pub fn withMaxWaitMs(self: Self, value: i32) Self {
        var result = self;
        result.max_wait_ms = value;
        return result;
    }

    /// Sets `min_bytes` to the passed value.
    /// The minimum bytes to accumulate in the response.
    pub fn withMinBytes(self: Self, value: i32) Self {
        var result = self;
        result.min_bytes = value;
        return result;
    }

    /// Sets `max_bytes` to the passed value.
    /// The maximum bytes to fetch. See KIP-74 for cases where this limit may not be honored.
    pub fn withMaxBytes(self: Self, value: i32) Self {
        var result = self;
        result.max_bytes = value;
        return result;
    }

    /// Sets `max_records` to the passed value.
    /// The maximum number of records to fetch. This limit can be exceeded for alignment of batch boundaries.
    /// Versions: 1+
    pub fn withMaxRecords(self: Self, value: i32) Self {
        var result = self;
        result.max_records = value;
        return result;
    }

    /// Sets `batch_size` to the passed value.
    /// The optimal number of records for batches of acquired records and acknowledgements.
    /// Versions: 1+
    pub fn withBatchSize(self: Self, value: i32) Self {
        var result = self;
        result.batch_size = value;
        return result;
    }

    /// Sets `topics` to the passed value.
    /// The topics to fetch.
    pub fn withTopics(self: Self, value: ?[]FetchTopic) Self {
        var result = self;
        result.topics = value;
        return result;
    }

    /// Sets `forgotten_topics_data` to the passed value.
    /// The partitions to remove from this share session.
    pub fn withForgottenTopicsData(self: Self, value: ?[]ForgottenTopic) Self {
        var result = self;
        result.forgotten_topics_data = value;
        return result;
    }

    /// Encode ShareFetchRequest
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

        // Field: MemberId
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.member_id);
            } else {
                try types.encodeString(writer, self.member_id);
            }
        }

        // Field: ShareSessionEpoch
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.share_session_epoch);
        }

        // Field: MaxWaitMs
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.max_wait_ms);
        }

        // Field: MinBytes
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.min_bytes);
        }

        // Field: MaxBytes
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.max_bytes);
        }

        // Field: MaxRecords
        if (version >= 1 and version <= 32767) {
            try types.encodeInt32(writer, self.max_records);
        }

        // Field: BatchSize
        if (version >= 1 and version <= 32767) {
            try types.encodeInt32(writer, self.batch_size);
        }

        // Field: Topics
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.topics);
                if (self.topics) |arr| {
                    for (arr) |*item| {
                        try FetchTopic.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.topics);
                if (self.topics) |arr| {
                    for (arr) |*item| {
                        try FetchTopic.encode(item, writer, version);
                    }
                }
            }
        }

        // Field: ForgottenTopicsData
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.forgotten_topics_data);
                if (self.forgotten_topics_data) |arr| {
                    for (arr) |*item| {
                        try ForgottenTopic.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.forgotten_topics_data);
                if (self.forgotten_topics_data) |arr| {
                    for (arr) |*item| {
                        try ForgottenTopic.encode(item, writer, version);
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

    /// Compute the size of ShareFetchRequest for the given version
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

        // Field: MemberId
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.member_id) else types.computeSizeString(self.member_id);
        }

        // Field: ShareSessionEpoch
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.share_session_epoch);
        }

        // Field: MaxWaitMs
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.max_wait_ms);
        }

        // Field: MinBytes
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.min_bytes);
        }

        // Field: MaxBytes
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.max_bytes);
        }

        // Field: MaxRecords
        if (version >= 1 and version <= 32767) {
            total_size += types.computeSizeInt32(self.max_records);
        }

        // Field: BatchSize
        if (version >= 1 and version <= 32767) {
            total_size += types.computeSizeInt32(self.batch_size);
        }

        // Field: Topics
        if (version >= 0 and version <= 32767) {
            if (self.topics) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try FetchTopic.computeSize(item, version);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(1) else 4;
            }
        }

        // Field: ForgottenTopicsData
        if (version >= 0 and version <= 32767) {
            if (self.forgotten_topics_data) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try ForgottenTopic.computeSize(item, version);
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

    /// Decode ShareFetchRequest
    pub fn decode(reader: anytype, version: i16, allocator: std.mem.Allocator) !Self {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        var self: Self = .{};

        // Field: GroupId
        if (version >= 0 and version <= 32767) {
            self.group_id = if (is_flexible)
                try types.decodeCompactString(reader, allocator)
            else
                try types.decodeString(reader, allocator);
        }

        // Field: MemberId
        if (version >= 0 and version <= 32767) {
            self.member_id = if (is_flexible)
                try types.decodeCompactString(reader, allocator)
            else
                try types.decodeString(reader, allocator);
        }

        // Field: ShareSessionEpoch
        if (version >= 0 and version <= 32767) {
            self.share_session_epoch = try types.decodeInt32(reader);
        }

        // Field: MaxWaitMs
        if (version >= 0 and version <= 32767) {
            self.max_wait_ms = try types.decodeInt32(reader);
        }

        // Field: MinBytes
        if (version >= 0 and version <= 32767) {
            self.min_bytes = try types.decodeInt32(reader);
        }

        // Field: MaxBytes
        if (version >= 0 and version <= 32767) {
            self.max_bytes = try types.decodeInt32(reader);
        }

        // Field: MaxRecords
        if (version >= 1 and version <= 32767) {
            self.max_records = try types.decodeInt32(reader);
        }

        // Field: BatchSize
        if (version >= 1 and version <= 32767) {
            self.batch_size = try types.decodeInt32(reader);
        }

        // Field: Topics
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(FetchTopic, array_len);
            for (array) |*item| {
                item.* = try FetchTopic.decode(reader, version, allocator);
            }
            self.topics = array;
        }

        // Field: ForgottenTopicsData
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(ForgottenTopic, array_len);
            for (array) |*item| {
                item.* = try ForgottenTopic.decode(reader, version, allocator);
            }
            self.forgotten_topics_data = array;
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
        const range = types.VersionRange.parse("1") catch return false;
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
