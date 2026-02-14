//! Auto-generated Kafka protocol message
//! Message: StreamsGroupHeartbeatResponse
//! API Key: 88
//! Type: response
//! Valid Versions: 0
//! Flexible Versions: 0+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// Nested struct: EndpointToPartitions
pub const EndpointToPartitions = struct {
    const Self = @This();

    /// User-defined endpoint to connect to the node
    /// Versions: 0+
    user_endpoint: Endpoint = .{},
    /// All topic partitions materialized by active tasks on the node
    /// Versions: 0+
    active_partitions: ?[]TopicPartition = null,
    /// All topic partitions materialized by standby tasks on the node
    /// Versions: 0+
    standby_partitions: ?[]TopicPartition = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: UserEndpoint
        if (version >= 0 and version <= 32767) {
            try Endpoint.encode(&self.user_endpoint, writer, version);
        }

        // Field: ActivePartitions
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayNonNull(TopicPartition, writer, self.active_partitions, TopicPartition.encode);
            } else {
                try types.encodeArrayNonNull(TopicPartition, writer, self.active_partitions, TopicPartition.encode);
            }
        }

        // Field: StandbyPartitions
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayNonNull(TopicPartition, writer, self.standby_partitions, TopicPartition.encode);
            } else {
                try types.encodeArrayNonNull(TopicPartition, writer, self.standby_partitions, TopicPartition.encode);
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

        // Field: UserEndpoint
        if (version >= 0 and version <= 32767) {
            total_size += try Endpoint.computeSize(&self.user_endpoint, version);
        }

        // Field: ActivePartitions
        if (version >= 0 and version <= 32767) {
            if (self.active_partitions) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |item| {
                    total_size += TopicPartition.computeSize(item);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(1) else 4;
            }
        }

        // Field: StandbyPartitions
        if (version >= 0 and version <= 32767) {
            if (self.standby_partitions) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |item| {
                    total_size += TopicPartition.computeSize(item);
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
        // Field: UserEndpoint
        if (version >= 0 and version <= 32767) {
            self.user_endpoint = try Endpoint.decode(reader, version, allocator);
        }

        // Field: ActivePartitions
        if (version >= 0 and version <= 32767) {
            self.active_partitions = if (is_flexible)
                try types.decodeCompactArray(TopicPartition, reader, allocator, TopicPartition.decode)
            else
                try types.decodeArray(TopicPartition, reader, allocator, TopicPartition.decode);
        }

        // Field: StandbyPartitions
        if (version >= 0 and version <= 32767) {
            self.standby_partitions = if (is_flexible)
                try types.decodeCompactArray(TopicPartition, reader, allocator, TopicPartition.decode)
            else
                try types.decodeArray(TopicPartition, reader, allocator, TopicPartition.decode);
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

/// StreamsGroupHeartbeatResponse
pub const StreamsGroupHeartbeatResponse = struct {
    const Self = @This();

    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    throttle_time_ms: i32 = 0,
    /// The top-level error code, or 0 if there was no error
    error_code: i16 = 0,
    /// The top-level error message, or null if there was no error.
    error_message: ?[]const u8 = null,
    /// The member id is always generated by the streams consumer.
    member_id: []const u8 = "",
    /// The member epoch.
    member_epoch: i32 = 0,
    /// The heartbeat interval in milliseconds.
    heartbeat_interval_ms: i32 = 0,
    /// The maximal lag a warm-up task can have to be considered caught-up.
    acceptable_recovery_lag: i32 = 0,
    /// The interval in which the task changelog offsets on a client are updated on the broker. The offsets are sent with the next heartbeat after this time has passed.
    task_offset_interval_ms: i32 = 0,
    /// Indicate zero or more status for the group.  Null if unchanged since last heartbeat.
    status: ?[]Status = null,
    /// Assigned active tasks for this client. Null if unchanged since last heartbeat.
    active_tasks: ?[]TaskIds = null,
    /// Assigned standby tasks for this client. Null if unchanged since last heartbeat.
    standby_tasks: ?[]TaskIds = null,
    /// Assigned warm-up tasks for this client. Null if unchanged since last heartbeat.
    warmup_tasks: ?[]TaskIds = null,
    /// The endpoint epoch set in the response
    endpoint_information_epoch: i32 = 0,
    /// Global assignment information used for IQ. Null if unchanged since last heartbeat.
    partitions_by_user_endpoint: ?[]EndpointToPartitions = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 0, .max = 0 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 88;
    }

    /// Create a default instance of StreamsGroupHeartbeatResponse
    pub fn default() Self {
        return .{
            .throttle_time_ms = 0,
            .error_code = 0,
            .error_message = null,
            .member_id = "",
            .member_epoch = 0,
            .heartbeat_interval_ms = 0,
            .acceptable_recovery_lag = 0,
            .task_offset_interval_ms = 0,
            .status = null,
            .active_tasks = null,
            .standby_tasks = null,
            .warmup_tasks = null,
            .endpoint_information_epoch = 0,
            .partitions_by_user_endpoint = null,
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

    /// Sets `error_code` to the passed value.
    /// The top-level error code, or 0 if there was no error
    pub fn withErrorCode(self: Self, value: i16) Self {
        var result = self;
        result.error_code = value;
        return result;
    }

    /// Sets `error_message` to the passed value.
    /// The top-level error message, or null if there was no error.
    pub fn withErrorMessage(self: Self, value: ?[]const u8) Self {
        var result = self;
        result.error_message = value;
        return result;
    }

    /// Sets `member_id` to the passed value.
    /// The member id is always generated by the streams consumer.
    pub fn withMemberId(self: Self, value: []const u8) Self {
        var result = self;
        result.member_id = value;
        return result;
    }

    /// Sets `member_epoch` to the passed value.
    /// The member epoch.
    pub fn withMemberEpoch(self: Self, value: i32) Self {
        var result = self;
        result.member_epoch = value;
        return result;
    }

    /// Sets `heartbeat_interval_ms` to the passed value.
    /// The heartbeat interval in milliseconds.
    pub fn withHeartbeatIntervalMs(self: Self, value: i32) Self {
        var result = self;
        result.heartbeat_interval_ms = value;
        return result;
    }

    /// Sets `acceptable_recovery_lag` to the passed value.
    /// The maximal lag a warm-up task can have to be considered caught-up.
    pub fn withAcceptableRecoveryLag(self: Self, value: i32) Self {
        var result = self;
        result.acceptable_recovery_lag = value;
        return result;
    }

    /// Sets `task_offset_interval_ms` to the passed value.
    /// The interval in which the task changelog offsets on a client are updated on the broker. The offsets are sent with the next heartbeat after this time has passed.
    pub fn withTaskOffsetIntervalMs(self: Self, value: i32) Self {
        var result = self;
        result.task_offset_interval_ms = value;
        return result;
    }

    /// Sets `status` to the passed value.
    /// Indicate zero or more status for the group.  Null if unchanged since last heartbeat.
    pub fn withStatus(self: Self, value: ?[]Status) Self {
        var result = self;
        result.status = value;
        return result;
    }

    /// Sets `active_tasks` to the passed value.
    /// Assigned active tasks for this client. Null if unchanged since last heartbeat.
    pub fn withActiveTasks(self: Self, value: ?[]TaskIds) Self {
        var result = self;
        result.active_tasks = value;
        return result;
    }

    /// Sets `standby_tasks` to the passed value.
    /// Assigned standby tasks for this client. Null if unchanged since last heartbeat.
    pub fn withStandbyTasks(self: Self, value: ?[]TaskIds) Self {
        var result = self;
        result.standby_tasks = value;
        return result;
    }

    /// Sets `warmup_tasks` to the passed value.
    /// Assigned warm-up tasks for this client. Null if unchanged since last heartbeat.
    pub fn withWarmupTasks(self: Self, value: ?[]TaskIds) Self {
        var result = self;
        result.warmup_tasks = value;
        return result;
    }

    /// Sets `endpoint_information_epoch` to the passed value.
    /// The endpoint epoch set in the response
    pub fn withEndpointInformationEpoch(self: Self, value: i32) Self {
        var result = self;
        result.endpoint_information_epoch = value;
        return result;
    }

    /// Sets `partitions_by_user_endpoint` to the passed value.
    /// Global assignment information used for IQ. Null if unchanged since last heartbeat.
    pub fn withPartitionsByUserEndpoint(self: Self, value: ?[]EndpointToPartitions) Self {
        var result = self;
        result.partitions_by_user_endpoint = value;
        return result;
    }

    /// Encode StreamsGroupHeartbeatResponse
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

        // Field: ErrorCode
        if (version >= 0 and version <= 32767) {
            try types.encodeInt16(writer, self.error_code);
        }

        // Field: ErrorMessage
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.error_message);
            } else {
                try types.encodeString(writer, self.error_message);
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

        // Field: MemberEpoch
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.member_epoch);
        }

        // Field: HeartbeatIntervalMs
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.heartbeat_interval_ms);
        }

        // Field: AcceptableRecoveryLag
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.acceptable_recovery_lag);
        }

        // Field: TaskOffsetIntervalMs
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.task_offset_interval_ms);
        }

        // Field: Status
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArray(Status, writer, self.status, Status.encode);
            } else {
                try types.encodeArray(Status, writer, self.status, Status.encode);
            }
        }

        // Field: ActiveTasks
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArray(TaskIds, writer, self.active_tasks, TaskIds.encode);
            } else {
                try types.encodeArray(TaskIds, writer, self.active_tasks, TaskIds.encode);
            }
        }

        // Field: StandbyTasks
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArray(TaskIds, writer, self.standby_tasks, TaskIds.encode);
            } else {
                try types.encodeArray(TaskIds, writer, self.standby_tasks, TaskIds.encode);
            }
        }

        // Field: WarmupTasks
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArray(TaskIds, writer, self.warmup_tasks, TaskIds.encode);
            } else {
                try types.encodeArray(TaskIds, writer, self.warmup_tasks, TaskIds.encode);
            }
        }

        // Field: EndpointInformationEpoch
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.endpoint_information_epoch);
        }

        // Field: PartitionsByUserEndpoint
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLen(writer, self.partitions_by_user_endpoint);
                if (self.partitions_by_user_endpoint) |arr| {
                    for (arr) |*item| {
                        try EndpointToPartitions.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLen(writer, self.partitions_by_user_endpoint);
                if (self.partitions_by_user_endpoint) |arr| {
                    for (arr) |*item| {
                        try EndpointToPartitions.encode(item, writer, version);
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

    /// Compute the size of StreamsGroupHeartbeatResponse for the given version
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

        // Field: ErrorCode
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt16(self.error_code);
        }

        // Field: ErrorMessage
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.error_message) else types.computeSizeString(self.error_message);
        }

        // Field: MemberId
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.member_id) else types.computeSizeString(self.member_id);
        }

        // Field: MemberEpoch
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.member_epoch);
        }

        // Field: HeartbeatIntervalMs
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.heartbeat_interval_ms);
        }

        // Field: AcceptableRecoveryLag
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.acceptable_recovery_lag);
        }

        // Field: TaskOffsetIntervalMs
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.task_offset_interval_ms);
        }

        // Field: Status
        if (version >= 0 and version <= 32767) {
            if (self.status) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |item| {
                    total_size += Status.computeSize(item);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(0) else 4;
            }
        }

        // Field: ActiveTasks
        if (version >= 0 and version <= 32767) {
            if (self.active_tasks) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |item| {
                    total_size += TaskIds.computeSize(item);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(0) else 4;
            }
        }

        // Field: StandbyTasks
        if (version >= 0 and version <= 32767) {
            if (self.standby_tasks) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |item| {
                    total_size += TaskIds.computeSize(item);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(0) else 4;
            }
        }

        // Field: WarmupTasks
        if (version >= 0 and version <= 32767) {
            if (self.warmup_tasks) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |item| {
                    total_size += TaskIds.computeSize(item);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(0) else 4;
            }
        }

        // Field: EndpointInformationEpoch
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.endpoint_information_epoch);
        }

        // Field: PartitionsByUserEndpoint
        if (version >= 0 and version <= 32767) {
            if (self.partitions_by_user_endpoint) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try EndpointToPartitions.computeSize(item, version);
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

    /// Decode StreamsGroupHeartbeatResponse
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

        // Field: ErrorCode
        if (version >= 0 and version <= 32767) {
            self.error_code = try types.decodeInt16(reader);
        }

        // Field: ErrorMessage
        if (version >= 0 and version <= 32767) {
            self.error_message = if (is_flexible)
                try types.decodeCompactString(reader, allocator)
            else
                try types.decodeString(reader, allocator);
        }

        // Field: MemberId
        if (version >= 0 and version <= 32767) {
            self.member_id = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: MemberEpoch
        if (version >= 0 and version <= 32767) {
            self.member_epoch = try types.decodeInt32(reader);
        }

        // Field: HeartbeatIntervalMs
        if (version >= 0 and version <= 32767) {
            self.heartbeat_interval_ms = try types.decodeInt32(reader);
        }

        // Field: AcceptableRecoveryLag
        if (version >= 0 and version <= 32767) {
            self.acceptable_recovery_lag = try types.decodeInt32(reader);
        }

        // Field: TaskOffsetIntervalMs
        if (version >= 0 and version <= 32767) {
            self.task_offset_interval_ms = try types.decodeInt32(reader);
        }

        // Field: Status
        if (version >= 0 and version <= 32767) {
            self.status = if (is_flexible)
                try types.decodeCompactArray(Status, reader, allocator, Status.decode)
            else
                try types.decodeArray(Status, reader, allocator, Status.decode);
        }

        // Field: ActiveTasks
        if (version >= 0 and version <= 32767) {
            self.active_tasks = if (is_flexible)
                try types.decodeCompactArray(TaskIds, reader, allocator, TaskIds.decode)
            else
                try types.decodeArray(TaskIds, reader, allocator, TaskIds.decode);
        }

        // Field: StandbyTasks
        if (version >= 0 and version <= 32767) {
            self.standby_tasks = if (is_flexible)
                try types.decodeCompactArray(TaskIds, reader, allocator, TaskIds.decode)
            else
                try types.decodeArray(TaskIds, reader, allocator, TaskIds.decode);
        }

        // Field: WarmupTasks
        if (version >= 0 and version <= 32767) {
            self.warmup_tasks = if (is_flexible)
                try types.decodeCompactArray(TaskIds, reader, allocator, TaskIds.decode)
            else
                try types.decodeArray(TaskIds, reader, allocator, TaskIds.decode);
        }

        // Field: EndpointInformationEpoch
        if (version >= 0 and version <= 32767) {
            self.endpoint_information_epoch = try types.decodeInt32(reader);
        }

        // Field: PartitionsByUserEndpoint
        if (version >= 0 and version <= 32767) {
            const raw_len: i32 = if (is_flexible) blk: {
                const v = try types.decodeUnsignedVarInt(reader);
                break :blk if (v == 0) @as(i32, -1) else @as(i32, @intCast(v - 1));
            } else try types.decodeInt32(reader);
            if (raw_len < 0) {
                self.partitions_by_user_endpoint = null;
            } else {
                const array_len: usize = @intCast(raw_len);
                const array = try allocator.alloc(EndpointToPartitions, array_len);
                for (array) |*item| {
                    item.* = try EndpointToPartitions.decode(reader, version, allocator);
                }
                self.partitions_by_user_endpoint = array;
            }
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
