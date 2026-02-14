//! Auto-generated Kafka protocol message
//! Message: FetchRequest
//! API Key: 1
//! Type: request
//! Valid Versions: 4-18
//! Flexible Versions: 12+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// Nested struct: ForgottenTopic
pub const ForgottenTopic = struct {
    const Self = @This();

    /// The topic name.
    /// Versions: 7-12
    topic: []const u8 = "",
    /// The unique topic ID.
    /// Versions: 13+
    topic_id: [16]u8 = [_]u8{0} ** 16,
    /// The partitions indexes to forget.
    /// Versions: 7+
    partitions: ?[]i32 = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: Topic
        if (version >= 7 and version <= 12) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.topic);
            } else {
                try types.encodeString(writer, self.topic);
            }
        }

        // Field: TopicId
        if (version >= 13 and version <= 32767) {
            try types.encodeUuid(writer, self.topic_id);
        }

        // Field: Partitions
        if (version >= 7 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArray(i32, writer, self.partitions, types.encodeInt32);
            } else {
                try types.encodeArray(i32, writer, self.partitions, types.encodeInt32);
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

        // Field: Topic
        if (version >= 7 and version <= 12) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.topic) else types.computeSizeString(self.topic);
        }

        // Field: TopicId
        if (version >= 13 and version <= 32767) {
            total_size += types.computeSizeUuid(self.topic_id);
        }

        // Field: Partitions
        if (version >= 7 and version <= 32767) {
            if (self.partitions) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |item| {
                    total_size += types.computeSizeInt32(item);
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
        // Field: Topic
        if (version >= 7 and version <= 12) {
            self.topic = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: TopicId
        if (version >= 13 and version <= 32767) {
            self.topic_id = try types.decodeUuid(reader);
        }

        // Field: Partitions
        if (version >= 7 and version <= 32767) {
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
        const range = types.VersionRange.parse("12+") catch return false;
        return range.contains(version);
    }
};

/// Nested struct: FetchTopic
pub const FetchTopic = struct {
    const Self = @This();

    /// The name of the topic to fetch.
    /// Versions: 0-12
    topic: []const u8 = "",
    /// The unique topic ID.
    /// Versions: 13+
    topic_id: [16]u8 = [_]u8{0} ** 16,
    /// The partitions to fetch.
    /// Versions: 0+
    partitions: ?[]FetchPartition = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: Topic
        if (version >= 0 and version <= 12) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.topic);
            } else {
                try types.encodeString(writer, self.topic);
            }
        }

        // Field: TopicId
        if (version >= 13 and version <= 32767) {
            try types.encodeUuid(writer, self.topic_id);
        }

        // Field: Partitions
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLen(writer, self.partitions);
                if (self.partitions) |arr| {
                    for (arr) |*item| {
                        try FetchPartition.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLen(writer, self.partitions);
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

        // Field: Topic
        if (version >= 0 and version <= 12) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.topic) else types.computeSizeString(self.topic);
        }

        // Field: TopicId
        if (version >= 13 and version <= 32767) {
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
        // Field: Topic
        if (version >= 0 and version <= 12) {
            self.topic = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: TopicId
        if (version >= 13 and version <= 32767) {
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
        const range = types.VersionRange.parse("12+") catch return false;
        return range.contains(version);
    }
};

/// Nested struct: FetchPartition
pub const FetchPartition = struct {
    const Self = @This();

    /// The partition index.
    /// Versions: 0+
    partition: i32 = 0,
    /// The current leader epoch of the partition.
    /// Versions: 9+
    current_leader_epoch: i32 = -1,
    /// The message offset.
    /// Versions: 0+
    fetch_offset: i64 = 0,
    /// The epoch of the last fetched record or -1 if there is none.
    /// Versions: 12+
    last_fetched_epoch: i32 = -1,
    /// The earliest available offset of the follower replica.  The field is only used when the request is sent by the follower.
    /// Versions: 5+
    log_start_offset: i64 = -1,
    /// The maximum bytes to fetch from this partition.  See KIP-74 for cases where this limit may not be honored.
    /// Versions: 0+
    partition_max_bytes: i32 = 0,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: Partition
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.partition);
        }

        // Field: CurrentLeaderEpoch
        if (version >= 9 and version <= 32767) {
            try types.encodeInt32(writer, self.current_leader_epoch);
        }

        // Field: FetchOffset
        if (version >= 0 and version <= 32767) {
            try types.encodeInt64(writer, self.fetch_offset);
        }

        // Field: LastFetchedEpoch
        if (version >= 12 and version <= 32767) {
            try types.encodeInt32(writer, self.last_fetched_epoch);
        }

        // Field: LogStartOffset
        if (version >= 5 and version <= 32767) {
            try types.encodeInt64(writer, self.log_start_offset);
        }

        // Field: PartitionMaxBytes
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.partition_max_bytes);
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

        // Field: Partition
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.partition);
        }

        // Field: CurrentLeaderEpoch
        if (version >= 9 and version <= 32767) {
            total_size += types.computeSizeInt32(self.current_leader_epoch);
        }

        // Field: FetchOffset
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt64(self.fetch_offset);
        }

        // Field: LastFetchedEpoch
        if (version >= 12 and version <= 32767) {
            total_size += types.computeSizeInt32(self.last_fetched_epoch);
        }

        // Field: LogStartOffset
        if (version >= 5 and version <= 32767) {
            total_size += types.computeSizeInt64(self.log_start_offset);
        }

        // Field: PartitionMaxBytes
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.partition_max_bytes);
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
        // Field: Partition
        if (version >= 0 and version <= 32767) {
            self.partition = try types.decodeInt32(reader);
        }

        // Field: CurrentLeaderEpoch
        if (version >= 9 and version <= 32767) {
            self.current_leader_epoch = try types.decodeInt32(reader);
        }

        // Field: FetchOffset
        if (version >= 0 and version <= 32767) {
            self.fetch_offset = try types.decodeInt64(reader);
        }

        // Field: LastFetchedEpoch
        if (version >= 12 and version <= 32767) {
            self.last_fetched_epoch = try types.decodeInt32(reader);
        }

        // Field: LogStartOffset
        if (version >= 5 and version <= 32767) {
            self.log_start_offset = try types.decodeInt64(reader);
        }

        // Field: PartitionMaxBytes
        if (version >= 0 and version <= 32767) {
            self.partition_max_bytes = try types.decodeInt32(reader);
        }


        if (is_flexible) {
            const tagged_fields_data = try types.decodeTaggedFields(reader, allocator);
            self._tagged_fields = tagged_fields_data;
        }
        return self;
    }

    fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("12+") catch return false;
        return range.contains(version);
    }
};

/// Nested struct: ReplicaState
pub const ReplicaState = struct {
    const Self = @This();

    /// The replica ID of the follower, or -1 if this request is from a consumer.
    /// Versions: 15+
    replica_id: i32 = -1,
    /// The epoch of this follower, or -1 if not available.
    /// Versions: 15+
    replica_epoch: i64 = -1,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: ReplicaId
        if (version >= 15 and version <= 32767) {
            try types.encodeInt32(writer, self.replica_id);
        }

        // Field: ReplicaEpoch
        if (version >= 15 and version <= 32767) {
            try types.encodeInt64(writer, self.replica_epoch);
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

        // Field: ReplicaId
        if (version >= 15 and version <= 32767) {
            total_size += types.computeSizeInt32(self.replica_id);
        }

        // Field: ReplicaEpoch
        if (version >= 15 and version <= 32767) {
            total_size += types.computeSizeInt64(self.replica_epoch);
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
        // Field: ReplicaId
        if (version >= 15 and version <= 32767) {
            self.replica_id = try types.decodeInt32(reader);
        }

        // Field: ReplicaEpoch
        if (version >= 15 and version <= 32767) {
            self.replica_epoch = try types.decodeInt64(reader);
        }


        if (is_flexible) {
            const tagged_fields_data = try types.decodeTaggedFields(reader, allocator);
            self._tagged_fields = tagged_fields_data;
        }
        return self;
    }

    fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("12+") catch return false;
        return range.contains(version);
    }
};

/// FetchRequest
pub const FetchRequest = struct {
    const Self = @This();

    /// The clusterId if known. This is used to validate metadata fetches prior to broker registration.
    /// Versions: 12+
    cluster_id: ?[]const u8 = null,
    /// The broker ID of the follower, of -1 if this request is from a consumer.
    /// Versions: 0-14
    replica_id: i32 = -1,
    /// The state of the replica in the follower.
    /// Versions: 15+
    replica_state: ReplicaState = .{},
    /// The maximum time in milliseconds to wait for the response.
    max_wait_ms: i32 = 0,
    /// The minimum bytes to accumulate in the response.
    min_bytes: i32 = 0,
    /// The maximum bytes to fetch.  See KIP-74 for cases where this limit may not be honored.
    /// Versions: 3+
    max_bytes: i32 = 0x7fffffff,
    /// This setting controls the visibility of transactional records. Using READ_UNCOMMITTED (isolation_level = 0) makes all records visible. With READ_COMMITTED (isolation_level = 1), non-transactional and COMMITTED transactional records are visible. To be more concrete, READ_COMMITTED returns all data from offsets smaller than the current LSO (last stable offset), and enables the inclusion of the list of aborted transactions in the result, which allows consumers to discard ABORTED transactional records.
    /// Versions: 4+
    isolation_level: i8 = 0,
    /// The fetch session ID.
    /// Versions: 7+
    session_id: i32 = 0,
    /// The fetch session epoch, which is used for ordering requests in a session.
    /// Versions: 7+
    session_epoch: i32 = -1,
    /// The topics to fetch.
    topics: ?[]FetchTopic = null,
    /// In an incremental fetch request, the partitions to remove.
    /// Versions: 7+
    forgotten_topics_data: ?[]ForgottenTopic = null,
    /// Rack ID of the consumer making this request.
    /// Versions: 11+
    rack_id: []const u8 = "",

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 4, .max = 18 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 1;
    }

    /// Create a default instance of FetchRequest
    pub fn default() Self {
        return .{
            .cluster_id = null,
            .replica_id = -1,
            .replica_state = .{},
            .max_wait_ms = 0,
            .min_bytes = 0,
            .max_bytes = 0x7fffffff,
            .isolation_level = 0,
            .session_id = 0,
            .session_epoch = -1,
            .topics = null,
            .forgotten_topics_data = null,
            .rack_id = "",
            ._tagged_fields = null,
        };
    }

    /// Sets `cluster_id` to the passed value.
    /// The clusterId if known. This is used to validate metadata fetches prior to broker registration.
    /// Versions: 12+
    pub fn withClusterId(self: Self, value: ?[]const u8) Self {
        var result = self;
        result.cluster_id = value;
        return result;
    }

    /// Sets `replica_id` to the passed value.
    /// The broker ID of the follower, of -1 if this request is from a consumer.
    /// Versions: 0-14
    pub fn withReplicaId(self: Self, value: i32) Self {
        var result = self;
        result.replica_id = value;
        return result;
    }

    /// Sets `replica_state` to the passed value.
    /// The state of the replica in the follower.
    /// Versions: 15+
    pub fn withReplicaState(self: Self, value: ReplicaState) Self {
        var result = self;
        result.replica_state = value;
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
    /// The maximum bytes to fetch.  See KIP-74 for cases where this limit may not be honored.
    /// Versions: 3+
    pub fn withMaxBytes(self: Self, value: i32) Self {
        var result = self;
        result.max_bytes = value;
        return result;
    }

    /// Sets `isolation_level` to the passed value.
    /// This setting controls the visibility of transactional records. Using READ_UNCOMMITTED (isolation_level = 0) makes all records visible. With READ_COMMITTED (isolation_level = 1), non-transactional and COMMITTED transactional records are visible. To be more concrete, READ_COMMITTED returns all data from offsets smaller than the current LSO (last stable offset), and enables the inclusion of the list of aborted transactions in the result, which allows consumers to discard ABORTED transactional records.
    /// Versions: 4+
    pub fn withIsolationLevel(self: Self, value: i8) Self {
        var result = self;
        result.isolation_level = value;
        return result;
    }

    /// Sets `session_id` to the passed value.
    /// The fetch session ID.
    /// Versions: 7+
    pub fn withSessionId(self: Self, value: i32) Self {
        var result = self;
        result.session_id = value;
        return result;
    }

    /// Sets `session_epoch` to the passed value.
    /// The fetch session epoch, which is used for ordering requests in a session.
    /// Versions: 7+
    pub fn withSessionEpoch(self: Self, value: i32) Self {
        var result = self;
        result.session_epoch = value;
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
    /// In an incremental fetch request, the partitions to remove.
    /// Versions: 7+
    pub fn withForgottenTopicsData(self: Self, value: ?[]ForgottenTopic) Self {
        var result = self;
        result.forgotten_topics_data = value;
        return result;
    }

    /// Sets `rack_id` to the passed value.
    /// Rack ID of the consumer making this request.
    /// Versions: 11+
    pub fn withRackId(self: Self, value: []const u8) Self {
        var result = self;
        result.rack_id = value;
        return result;
    }

    /// Encode FetchRequest
    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: ReplicaId
        if (version >= 0 and version <= 14) {
            try types.encodeInt32(writer, self.replica_id);
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
        if (version >= 3 and version <= 32767) {
            try types.encodeInt32(writer, self.max_bytes);
        }

        // Field: IsolationLevel
        if (version >= 4 and version <= 32767) {
            try types.encodeInt8(writer, self.isolation_level);
        }

        // Field: SessionId
        if (version >= 7 and version <= 32767) {
            try types.encodeInt32(writer, self.session_id);
        }

        // Field: SessionEpoch
        if (version >= 7 and version <= 32767) {
            try types.encodeInt32(writer, self.session_epoch);
        }

        // Field: Topics
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLen(writer, self.topics);
                if (self.topics) |arr| {
                    for (arr) |*item| {
                        try FetchTopic.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLen(writer, self.topics);
                if (self.topics) |arr| {
                    for (arr) |*item| {
                        try FetchTopic.encode(item, writer, version);
                    }
                }
            }
        }

        // Field: ForgottenTopicsData
        if (version >= 7 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLen(writer, self.forgotten_topics_data);
                if (self.forgotten_topics_data) |arr| {
                    for (arr) |*item| {
                        try ForgottenTopic.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLen(writer, self.forgotten_topics_data);
                if (self.forgotten_topics_data) |arr| {
                    for (arr) |*item| {
                        try ForgottenTopic.encode(item, writer, version);
                    }
                }
            }
        }

        // Field: RackId
        if (version >= 11 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.rack_id);
            } else {
                try types.encodeString(writer, self.rack_id);
            }
        }


        if (is_flexible) {
            var num_tagged_fields: u32 = 0;
            if (version >= 12 and version <= 32767) {
                if (self.cluster_id != null) num_tagged_fields += 1;
            }
            if (version >= 15 and version <= 32767) {
                if (!std.mem.eql(u8, std.mem.asBytes(&self.replica_state), std.mem.asBytes(&@as(ReplicaState, .{})))) num_tagged_fields += 1;
            }

            // Count unknown tagged fields
            if (self._tagged_fields) |fields| {
                num_tagged_fields += @intCast(fields.len);
            }

            try types.encodeUnsignedVarInt(writer, num_tagged_fields);

            // Tagged field: ClusterId (tag 0)
            if (version >= 12 and version <= 32767) {
                if (self.cluster_id) |val| {
                    try types.encodeUnsignedVarInt(writer, 0);
                    const size = types.computeSizeCompactString(val);
                    try types.encodeUnsignedVarInt(writer, @intCast(size));
                    try types.encodeCompactString(writer, val);
                }
            }

            // Tagged field: ReplicaState (tag 1)
            if (version >= 15 and version <= 32767) {
                if (!std.mem.eql(u8, std.mem.asBytes(&self.replica_state), std.mem.asBytes(&@as(ReplicaState, .{})))) {
                    try types.encodeUnsignedVarInt(writer, 1);
                    const size = try ReplicaState.computeSize(&self.replica_state, version);
                    try types.encodeUnsignedVarInt(writer, @intCast(size));
                    try ReplicaState.encode(&self.replica_state, writer, version);
                }
            }

            // Encode unknown tagged fields
            if (self._tagged_fields) |fields| {
                try types.encodeTaggedFields(writer, fields);
            }
        }
    }

    /// Compute the size of FetchRequest for the given version
    pub fn computeSize(self: *const Self, version: i16) !usize {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        var total_size: usize = 0;

        // Field: ReplicaId
        if (version >= 0 and version <= 14) {
            total_size += types.computeSizeInt32(self.replica_id);
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
        if (version >= 3 and version <= 32767) {
            total_size += types.computeSizeInt32(self.max_bytes);
        }

        // Field: IsolationLevel
        if (version >= 4 and version <= 32767) {
            total_size += types.computeSizeInt8(self.isolation_level);
        }

        // Field: SessionId
        if (version >= 7 and version <= 32767) {
            total_size += types.computeSizeInt32(self.session_id);
        }

        // Field: SessionEpoch
        if (version >= 7 and version <= 32767) {
            total_size += types.computeSizeInt32(self.session_epoch);
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
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(0) else 4;
            }
        }

        // Field: ForgottenTopicsData
        if (version >= 7 and version <= 32767) {
            if (self.forgotten_topics_data) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try ForgottenTopic.computeSize(item, version);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(0) else 4;
            }
        }

        // Field: RackId
        if (version >= 11 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.rack_id) else types.computeSizeString(self.rack_id);
        }

        if (is_flexible) {
            var num_tagged_fields: u32 = 0;
            if (version >= 12 and version <= 32767) {
                if (self.cluster_id != null) num_tagged_fields += 1;
            }
            if (version >= 15 and version <= 32767) {
                if (!std.mem.eql(u8, std.mem.asBytes(&self.replica_state), std.mem.asBytes(&@as(ReplicaState, .{})))) num_tagged_fields += 1;
            }

            if (self._tagged_fields) |fields| {
                num_tagged_fields += @intCast(fields.len);
            }

            total_size += types.computeSizeUnsignedVarInt(num_tagged_fields);

            // Tagged field: ClusterId (tag 0)
            if (version >= 12 and version <= 32767) {
                if (self.cluster_id) |val| {
                    total_size += types.computeSizeUnsignedVarInt(0);
                    const size = types.computeSizeCompactString(val);
                    total_size += types.computeSizeUnsignedVarInt(@intCast(size));
                    total_size += size;
                }
            }

            // Tagged field: ReplicaState (tag 1)
            if (version >= 15 and version <= 32767) {
                if (!std.mem.eql(u8, std.mem.asBytes(&self.replica_state), std.mem.asBytes(&@as(ReplicaState, .{})))) {
                    total_size += types.computeSizeUnsignedVarInt(1);
                    const size = try ReplicaState.computeSize(&self.replica_state, version);
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

    /// Decode FetchRequest
    pub fn decode(reader: anytype, version: i16, allocator: std.mem.Allocator) !Self {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        var self: Self = .{};

        // Field: ReplicaId
        if (version >= 0 and version <= 14) {
            self.replica_id = try types.decodeInt32(reader);
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
        if (version >= 3 and version <= 32767) {
            self.max_bytes = try types.decodeInt32(reader);
        }

        // Field: IsolationLevel
        if (version >= 4 and version <= 32767) {
            self.isolation_level = try types.decodeInt8(reader);
        }

        // Field: SessionId
        if (version >= 7 and version <= 32767) {
            self.session_id = try types.decodeInt32(reader);
        }

        // Field: SessionEpoch
        if (version >= 7 and version <= 32767) {
            self.session_epoch = try types.decodeInt32(reader);
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
        if (version >= 7 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(ForgottenTopic, array_len);
            for (array) |*item| {
                item.* = try ForgottenTopic.decode(reader, version, allocator);
            }
            self.forgotten_topics_data = array;
        }

        // Field: RackId
        if (version >= 11 and version <= 32767) {
            self.rack_id = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }


        if (is_flexible) {
            const num_tagged_fields = try types.decodeUnsignedVarInt(reader);
            var unknown_tagged_fields = std.ArrayList(types.TaggedField).init(allocator);

            var i: u32 = 0;
            while (i < num_tagged_fields) : (i += 1) {
                const tag = try types.decodeUnsignedVarInt(reader);
                const size = try types.decodeUnsignedVarInt(reader);
                switch (tag) {
                    0 => { // ClusterId
                        if (version >= 12 and version <= 32767) {
                            self.cluster_id = try types.decodeCompactString(reader, allocator);
                        } else {
                            try reader.skipBytes(size, .{});
                        }
                    },
                    1 => { // ReplicaState
                        if (version >= 15 and version <= 32767) {
                            self.replica_state = try ReplicaState.decode(reader, version, allocator);
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
        const range = types.VersionRange.parse("4-18") catch return false;
        return range.contains(version);
    }
    /// Check if version uses flexible encoding
    pub fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("12+") catch return false;
        return range.contains(version);
    }
    /// Get the header version for this API version
    /// Returns 2 for flexible versions, 1 for classic versions
    pub fn headerVersion(api_version: i16) i16 {
        if (isFlexibleVersion(api_version)) return 2;
        return 1;
    }

};
