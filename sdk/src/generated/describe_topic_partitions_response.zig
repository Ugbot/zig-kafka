//! Auto-generated Kafka protocol message
//! Message: DescribeTopicPartitionsResponse
//! API Key: 75
//! Type: response
//! Valid Versions: 0
//! Flexible Versions: 0+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// Nested struct: Cursor
pub const Cursor = struct {
    const Self = @This();

    /// The name for the first topic to process.
    /// Versions: 0+
    topic_name: []const u8 = "",
    /// The partition index to start with.
    /// Versions: 0+
    partition_index: i32 = 0,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: TopicName
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.topic_name);
            } else {
                try types.encodeString(writer, self.topic_name);
            }
        }

        // Field: PartitionIndex
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.partition_index);
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

        // Field: TopicName
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.topic_name) else types.computeSizeString(self.topic_name);
        }

        // Field: PartitionIndex
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.partition_index);
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
        // Field: TopicName
        if (version >= 0 and version <= 32767) {
            self.topic_name = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: PartitionIndex
        if (version >= 0 and version <= 32767) {
            self.partition_index = try types.decodeInt32(reader);
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

/// Nested struct: DescribeTopicPartitionsResponseTopic
pub const DescribeTopicPartitionsResponseTopic = struct {
    const Self = @This();

    /// The topic error, or 0 if there was no error.
    /// Versions: 0+
    error_code: i16 = 0,
    /// The topic name.
    /// Versions: 0+
    name: ?[]const u8 = null,
    /// The topic id.
    /// Versions: 0+
    topic_id: [16]u8 = [_]u8{0} ** 16,
    /// True if the topic is internal.
    /// Versions: 0+
    is_internal: bool = false,
    /// Each partition in the topic.
    /// Versions: 0+
    partitions: ?[]DescribeTopicPartitionsResponsePartition = null,
    /// 32-bit bitfield to represent authorized operations for this topic.
    /// Versions: 0+
    topic_authorized_operations: i32 = -2147483648,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: ErrorCode
        if (version >= 0 and version <= 32767) {
            try types.encodeInt16(writer, self.error_code);
        }

        // Field: Name
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.name);
            } else {
                try types.encodeString(writer, self.name);
            }
        }

        // Field: TopicId
        if (version >= 0 and version <= 32767) {
            try types.encodeUuid(writer, self.topic_id);
        }

        // Field: IsInternal
        if (version >= 0 and version <= 32767) {
            try types.encodeBoolean(writer, self.is_internal);
        }

        // Field: Partitions
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.partitions);
                if (self.partitions) |arr| {
                    for (arr) |*item| {
                        try DescribeTopicPartitionsResponsePartition.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.partitions);
                if (self.partitions) |arr| {
                    for (arr) |*item| {
                        try DescribeTopicPartitionsResponsePartition.encode(item, writer, version);
                    }
                }
            }
        }

        // Field: TopicAuthorizedOperations
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.topic_authorized_operations);
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

        // Field: Name
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.name) else types.computeSizeString(self.name);
        }

        // Field: TopicId
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeUuid(self.topic_id);
        }

        // Field: IsInternal
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeBoolean(self.is_internal);
        }

        // Field: Partitions
        if (version >= 0 and version <= 32767) {
            if (self.partitions) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try DescribeTopicPartitionsResponsePartition.computeSize(item, version);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(1) else 4;
            }
        }

        // Field: TopicAuthorizedOperations
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.topic_authorized_operations);
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

        // Field: Name
        if (version >= 0 and version <= 32767) {
            self.name = if (is_flexible)
                try types.decodeCompactString(reader, allocator)
            else
                try types.decodeString(reader, allocator);
        }

        // Field: TopicId
        if (version >= 0 and version <= 32767) {
            self.topic_id = try types.decodeUuid(reader);
        }

        // Field: IsInternal
        if (version >= 0 and version <= 32767) {
            self.is_internal = try types.decodeBoolean(reader);
        }

        // Field: Partitions
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(DescribeTopicPartitionsResponsePartition, array_len);
            for (array) |*item| {
                item.* = try DescribeTopicPartitionsResponsePartition.decode(reader, version, allocator);
            }
            self.partitions = array;
        }

        // Field: TopicAuthorizedOperations
        if (version >= 0 and version <= 32767) {
            self.topic_authorized_operations = try types.decodeInt32(reader);
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

/// Nested struct: DescribeTopicPartitionsResponsePartition
pub const DescribeTopicPartitionsResponsePartition = struct {
    const Self = @This();

    /// The partition error, or 0 if there was no error.
    /// Versions: 0+
    error_code: i16 = 0,
    /// The partition index.
    /// Versions: 0+
    partition_index: i32 = 0,
    /// The ID of the leader broker.
    /// Versions: 0+
    leader_id: i32 = 0,
    /// The leader epoch of this partition.
    /// Versions: 0+
    leader_epoch: i32 = -1,
    /// The set of all nodes that host this partition.
    /// Versions: 0+
    replica_nodes: ?[]i32 = null,
    /// The set of nodes that are in sync with the leader for this partition.
    /// Versions: 0+
    isr_nodes: ?[]i32 = null,
    /// The new eligible leader replicas otherwise.
    /// Versions: 0+
    eligible_leader_replicas: ?[]i32 = null,
    /// The last known ELR.
    /// Versions: 0+
    last_known_elr: ?[]i32 = null,
    /// The set of offline replicas of this partition.
    /// Versions: 0+
    offline_replicas: ?[]i32 = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: ErrorCode
        if (version >= 0 and version <= 32767) {
            try types.encodeInt16(writer, self.error_code);
        }

        // Field: PartitionIndex
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.partition_index);
        }

        // Field: LeaderId
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.leader_id);
        }

        // Field: LeaderEpoch
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.leader_epoch);
        }

        // Field: ReplicaNodes
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayNonNull(i32, writer, self.replica_nodes, types.encodeInt32);
            } else {
                try types.encodeArrayNonNull(i32, writer, self.replica_nodes, types.encodeInt32);
            }
        }

        // Field: IsrNodes
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayNonNull(i32, writer, self.isr_nodes, types.encodeInt32);
            } else {
                try types.encodeArrayNonNull(i32, writer, self.isr_nodes, types.encodeInt32);
            }
        }

        // Field: EligibleLeaderReplicas
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArray(i32, writer, self.eligible_leader_replicas, types.encodeInt32);
            } else {
                try types.encodeArray(i32, writer, self.eligible_leader_replicas, types.encodeInt32);
            }
        }

        // Field: LastKnownElr
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArray(i32, writer, self.last_known_elr, types.encodeInt32);
            } else {
                try types.encodeArray(i32, writer, self.last_known_elr, types.encodeInt32);
            }
        }

        // Field: OfflineReplicas
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayNonNull(i32, writer, self.offline_replicas, types.encodeInt32);
            } else {
                try types.encodeArrayNonNull(i32, writer, self.offline_replicas, types.encodeInt32);
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

        // Field: PartitionIndex
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.partition_index);
        }

        // Field: LeaderId
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.leader_id);
        }

        // Field: LeaderEpoch
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.leader_epoch);
        }

        // Field: ReplicaNodes
        if (version >= 0 and version <= 32767) {
            if (self.replica_nodes) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |item| {
                    total_size += types.computeSizeInt32(item);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(1) else 4;
            }
        }

        // Field: IsrNodes
        if (version >= 0 and version <= 32767) {
            if (self.isr_nodes) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |item| {
                    total_size += types.computeSizeInt32(item);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(1) else 4;
            }
        }

        // Field: EligibleLeaderReplicas
        if (version >= 0 and version <= 32767) {
            if (self.eligible_leader_replicas) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |item| {
                    total_size += types.computeSizeInt32(item);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(0) else 4;
            }
        }

        // Field: LastKnownElr
        if (version >= 0 and version <= 32767) {
            if (self.last_known_elr) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |item| {
                    total_size += types.computeSizeInt32(item);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(0) else 4;
            }
        }

        // Field: OfflineReplicas
        if (version >= 0 and version <= 32767) {
            if (self.offline_replicas) |arr| {
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
        // Field: ErrorCode
        if (version >= 0 and version <= 32767) {
            self.error_code = try types.decodeInt16(reader);
        }

        // Field: PartitionIndex
        if (version >= 0 and version <= 32767) {
            self.partition_index = try types.decodeInt32(reader);
        }

        // Field: LeaderId
        if (version >= 0 and version <= 32767) {
            self.leader_id = try types.decodeInt32(reader);
        }

        // Field: LeaderEpoch
        if (version >= 0 and version <= 32767) {
            self.leader_epoch = try types.decodeInt32(reader);
        }

        // Field: ReplicaNodes
        if (version >= 0 and version <= 32767) {
            self.replica_nodes = if (is_flexible)
                try types.decodeCompactPrimitiveArray(i32, reader, allocator, types.decodeInt32)
            else
                try types.decodePrimitiveArray(i32, reader, allocator, types.decodeInt32);
        }

        // Field: IsrNodes
        if (version >= 0 and version <= 32767) {
            self.isr_nodes = if (is_flexible)
                try types.decodeCompactPrimitiveArray(i32, reader, allocator, types.decodeInt32)
            else
                try types.decodePrimitiveArray(i32, reader, allocator, types.decodeInt32);
        }

        // Field: EligibleLeaderReplicas
        if (version >= 0 and version <= 32767) {
            self.eligible_leader_replicas = if (is_flexible)
                try types.decodeCompactPrimitiveArray(i32, reader, allocator, types.decodeInt32)
            else
                try types.decodePrimitiveArray(i32, reader, allocator, types.decodeInt32);
        }

        // Field: LastKnownElr
        if (version >= 0 and version <= 32767) {
            self.last_known_elr = if (is_flexible)
                try types.decodeCompactPrimitiveArray(i32, reader, allocator, types.decodeInt32)
            else
                try types.decodePrimitiveArray(i32, reader, allocator, types.decodeInt32);
        }

        // Field: OfflineReplicas
        if (version >= 0 and version <= 32767) {
            self.offline_replicas = if (is_flexible)
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

/// DescribeTopicPartitionsResponse
pub const DescribeTopicPartitionsResponse = struct {
    const Self = @This();

    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    throttle_time_ms: i32 = 0,
    /// Each topic in the response.
    topics: ?[]DescribeTopicPartitionsResponseTopic = null,
    /// The next topic and partition index to fetch details for.
    next_cursor: ?Cursor = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 0, .max = 0 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 75;
    }

    /// Create a default instance of DescribeTopicPartitionsResponse
    pub fn default() Self {
        return .{
            .throttle_time_ms = 0,
            .topics = null,
            .next_cursor = null,
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

    /// Sets `topics` to the passed value.
    /// Each topic in the response.
    pub fn withTopics(self: Self, value: ?[]DescribeTopicPartitionsResponseTopic) Self {
        var result = self;
        result.topics = value;
        return result;
    }

    /// Sets `next_cursor` to the passed value.
    /// The next topic and partition index to fetch details for.
    pub fn withNextCursor(self: Self, value: ?Cursor) Self {
        var result = self;
        result.next_cursor = value;
        return result;
    }

    /// Encode DescribeTopicPartitionsResponse
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

        // Field: Topics
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.topics);
                if (self.topics) |arr| {
                    for (arr) |*item| {
                        try DescribeTopicPartitionsResponseTopic.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.topics);
                if (self.topics) |arr| {
                    for (arr) |*item| {
                        try DescribeTopicPartitionsResponseTopic.encode(item, writer, version);
                    }
                }
            }
        }

        // Field: NextCursor
        if (version >= 0 and version <= 32767) {
            try Cursor.encode(&self.next_cursor, writer, version);
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

    /// Compute the size of DescribeTopicPartitionsResponse for the given version
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

        // Field: Topics
        if (version >= 0 and version <= 32767) {
            if (self.topics) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try DescribeTopicPartitionsResponseTopic.computeSize(item, version);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(1) else 4;
            }
        }

        // Field: NextCursor
        if (version >= 0 and version <= 32767) {
            total_size += try Cursor.computeSize(&self.next_cursor, version);
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

    /// Decode DescribeTopicPartitionsResponse
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

        // Field: Topics
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(DescribeTopicPartitionsResponseTopic, array_len);
            for (array) |*item| {
                item.* = try DescribeTopicPartitionsResponseTopic.decode(reader, version, allocator);
            }
            self.topics = array;
        }

        // Field: NextCursor
        if (version >= 0 and version <= 32767) {
            self.next_cursor = try Cursor.decode(reader, version, allocator);
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
        const range = types.VersionRange.parse("0") catch return false;
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
