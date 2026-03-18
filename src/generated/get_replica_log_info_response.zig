//! Auto-generated Kafka protocol message
//! Message: GetReplicaLogInfoResponse
//! API Key: 93
//! Type: response
//! Valid Versions: 0
//! Flexible Versions: 0+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// Nested struct: TopicPartitionLogInfo
pub const TopicPartitionLogInfo = struct {
    const Self = @This();

    /// The unique topic ID.
    /// Versions: 0+
    topic_id: [16]u8 = [_]u8{0} ** 16,
    /// The log info of a partition.
    /// Versions: 0+
    partition_log_info: ?[]PartitionLogInfo = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: TopicId
        if (version >= 0 and version <= 32767) {
            try types.encodeUuid(writer, self.topic_id);
        }

        // Field: PartitionLogInfo
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.partition_log_info);
                if (self.partition_log_info) |arr| {
                    for (arr) |*item| {
                        try PartitionLogInfo.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.partition_log_info);
                if (self.partition_log_info) |arr| {
                    for (arr) |*item| {
                        try PartitionLogInfo.encode(item, writer, version);
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

        // Field: PartitionLogInfo
        if (version >= 0 and version <= 32767) {
            if (self.partition_log_info) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try PartitionLogInfo.computeSize(item, version);
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

        // Field: PartitionLogInfo
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(PartitionLogInfo, array_len);
            for (array) |*item| {
                item.* = try PartitionLogInfo.decode(reader, version, allocator);
            }
            self.partition_log_info = array;
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

/// Nested struct: PartitionLogInfo
pub const PartitionLogInfo = struct {
    const Self = @This();

    /// The id for the partition.
    /// Versions: 0+
    partition: i32 = 0,
    /// The last written leader epoch in the log.
    /// Versions: 0+
    last_written_leader_epoch: i32 = 0,
    /// The current leader epoch for the partition from the broker point of view.
    /// Versions: 0+
    current_leader_epoch: i32 = 0,
    /// The log end offset for the partition.
    /// Versions: 0+
    log_end_offset: i64 = 0,
    /// The result error, or zero if there was no error.
    /// Versions: 0+
    error_code: i16 = 0,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: Partition
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.partition);
        }

        // Field: LastWrittenLeaderEpoch
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.last_written_leader_epoch);
        }

        // Field: CurrentLeaderEpoch
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.current_leader_epoch);
        }

        // Field: LogEndOffset
        if (version >= 0 and version <= 32767) {
            try types.encodeInt64(writer, self.log_end_offset);
        }

        // Field: ErrorCode
        if (version >= 0 and version <= 32767) {
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

        // Field: Partition
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.partition);
        }

        // Field: LastWrittenLeaderEpoch
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.last_written_leader_epoch);
        }

        // Field: CurrentLeaderEpoch
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.current_leader_epoch);
        }

        // Field: LogEndOffset
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt64(self.log_end_offset);
        }

        // Field: ErrorCode
        if (version >= 0 and version <= 32767) {
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
        // Field: Partition
        if (version >= 0 and version <= 32767) {
            self.partition = try types.decodeInt32(reader);
        }

        // Field: LastWrittenLeaderEpoch
        if (version >= 0 and version <= 32767) {
            self.last_written_leader_epoch = try types.decodeInt32(reader);
        }

        // Field: CurrentLeaderEpoch
        if (version >= 0 and version <= 32767) {
            self.current_leader_epoch = try types.decodeInt32(reader);
        }

        // Field: LogEndOffset
        if (version >= 0 and version <= 32767) {
            self.log_end_offset = try types.decodeInt64(reader);
        }

        // Field: ErrorCode
        if (version >= 0 and version <= 32767) {
            self.error_code = try types.decodeInt16(reader);
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

/// GetReplicaLogInfoResponse
pub const GetReplicaLogInfoResponse = struct {
    const Self = @This();

    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    throttle_time_ms: i32 = 0,
    /// The epoch of the broker.
    broker_epoch: i64 = 0,
    /// True if response does not include all the topic partitions requested. Only the first 1000 topic partitions are returned.
    has_more_data: bool = false,
    /// The list of the partition log info.
    topic_partition_log_info_list: ?[]TopicPartitionLogInfo = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 0, .max = 0 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 93;
    }

    /// Create a default instance of GetReplicaLogInfoResponse
    pub fn default() Self {
        return .{
            .throttle_time_ms = 0,
            .broker_epoch = 0,
            .has_more_data = false,
            .topic_partition_log_info_list = null,
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

    /// Sets `broker_epoch` to the passed value.
    /// The epoch of the broker.
    pub fn withBrokerEpoch(self: Self, value: i64) Self {
        var result = self;
        result.broker_epoch = value;
        return result;
    }

    /// Sets `has_more_data` to the passed value.
    /// True if response does not include all the topic partitions requested. Only the first 1000 topic partitions are returned.
    pub fn withHasMoreData(self: Self, value: bool) Self {
        var result = self;
        result.has_more_data = value;
        return result;
    }

    /// Sets `topic_partition_log_info_list` to the passed value.
    /// The list of the partition log info.
    pub fn withTopicPartitionLogInfoList(self: Self, value: ?[]TopicPartitionLogInfo) Self {
        var result = self;
        result.topic_partition_log_info_list = value;
        return result;
    }

    /// Encode GetReplicaLogInfoResponse
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

        // Field: BrokerEpoch
        if (version >= 0 and version <= 32767) {
            try types.encodeInt64(writer, self.broker_epoch);
        }

        // Field: HasMoreData
        if (version >= 0 and version <= 32767) {
            try types.encodeBoolean(writer, self.has_more_data);
        }

        // Field: TopicPartitionLogInfoList
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.topic_partition_log_info_list);
                if (self.topic_partition_log_info_list) |arr| {
                    for (arr) |*item| {
                        try TopicPartitionLogInfo.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.topic_partition_log_info_list);
                if (self.topic_partition_log_info_list) |arr| {
                    for (arr) |*item| {
                        try TopicPartitionLogInfo.encode(item, writer, version);
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

    /// Compute the size of GetReplicaLogInfoResponse for the given version
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

        // Field: BrokerEpoch
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt64(self.broker_epoch);
        }

        // Field: HasMoreData
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeBoolean(self.has_more_data);
        }

        // Field: TopicPartitionLogInfoList
        if (version >= 0 and version <= 32767) {
            if (self.topic_partition_log_info_list) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try TopicPartitionLogInfo.computeSize(item, version);
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

    /// Decode GetReplicaLogInfoResponse
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

        // Field: BrokerEpoch
        if (version >= 0 and version <= 32767) {
            self.broker_epoch = try types.decodeInt64(reader);
        }

        // Field: HasMoreData
        if (version >= 0 and version <= 32767) {
            self.has_more_data = try types.decodeBoolean(reader);
        }

        // Field: TopicPartitionLogInfoList
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(TopicPartitionLogInfo, array_len);
            for (array) |*item| {
                item.* = try TopicPartitionLogInfo.decode(reader, version, allocator);
            }
            self.topic_partition_log_info_list = array;
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
