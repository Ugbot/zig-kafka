//! Auto-generated Kafka protocol message
//! Message: StreamsGroupHeartbeatRequest
//! API Key: 88
//! Type: request
//! Valid Versions: 0
//! Flexible Versions: 0+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// Nested struct: Topology
pub const Topology = struct {
    const Self = @This();

    /// The epoch of the topology. Used to check if the topology corresponds to the topology initialized on the brokers.
    /// Versions: 0+
    epoch: i32 = 0,
    /// The sub-topologies of the streams application.
    /// Versions: 0+
    subtopologies: ?[]Subtopology = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: Epoch
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.epoch);
        }

        // Field: Subtopologies
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.subtopologies);
                if (self.subtopologies) |arr| {
                    for (arr) |*item| {
                        try Subtopology.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.subtopologies);
                if (self.subtopologies) |arr| {
                    for (arr) |*item| {
                        try Subtopology.encode(item, writer, version);
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

        // Field: Epoch
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.epoch);
        }

        // Field: Subtopologies
        if (version >= 0 and version <= 32767) {
            if (self.subtopologies) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try Subtopology.computeSize(item, version);
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
        // Field: Epoch
        if (version >= 0 and version <= 32767) {
            self.epoch = try types.decodeInt32(reader);
        }

        // Field: Subtopologies
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(Subtopology, array_len);
            for (array) |*item| {
                item.* = try Subtopology.decode(reader, version, allocator);
            }
            self.subtopologies = array;
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

/// Nested struct: Subtopology
pub const Subtopology = struct {
    const Self = @This();

    /// String to uniquely identify the subtopology. Deterministically generated from the topology
    /// Versions: 0+
    subtopology_id: []const u8 = "",
    /// The topics the topology reads from.
    /// Versions: 0+
    source_topics: ?[][]const u8 = null,
    /// The regular expressions identifying topics the subtopology reads from.
    /// Versions: 0+
    source_topic_regex: ?[][]const u8 = null,
    /// The set of state changelog topics associated with this subtopology. Created automatically.
    /// Versions: 0+
    state_changelog_topics: ?[]TopicInfo = null,
    /// The repartition topics the subtopology writes to.
    /// Versions: 0+
    repartition_sink_topics: ?[][]const u8 = null,
    /// The set of source topics that are internally created repartition topics. Created automatically.
    /// Versions: 0+
    repartition_source_topics: ?[]TopicInfo = null,
    /// A subset of source topics that must be copartitioned.
    /// Versions: 0+
    copartition_groups: ?[]CopartitionGroup = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: SubtopologyId
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.subtopology_id);
            } else {
                try types.encodeString(writer, self.subtopology_id);
            }
        }

        // Field: SourceTopics
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayNonNull([]const u8, writer, self.source_topics, types.encodeCompactString);
            } else {
                try types.encodeArrayNonNull([]const u8, writer, self.source_topics, types.encodeCompactString);
            }
        }

        // Field: SourceTopicRegex
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayNonNull([]const u8, writer, self.source_topic_regex, types.encodeCompactString);
            } else {
                try types.encodeArrayNonNull([]const u8, writer, self.source_topic_regex, types.encodeCompactString);
            }
        }

        // Field: StateChangelogTopics
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayNonNull(TopicInfo, writer, self.state_changelog_topics, TopicInfo.encode);
            } else {
                try types.encodeArrayNonNull(TopicInfo, writer, self.state_changelog_topics, TopicInfo.encode);
            }
        }

        // Field: RepartitionSinkTopics
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayNonNull([]const u8, writer, self.repartition_sink_topics, types.encodeCompactString);
            } else {
                try types.encodeArrayNonNull([]const u8, writer, self.repartition_sink_topics, types.encodeCompactString);
            }
        }

        // Field: RepartitionSourceTopics
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayNonNull(TopicInfo, writer, self.repartition_source_topics, TopicInfo.encode);
            } else {
                try types.encodeArrayNonNull(TopicInfo, writer, self.repartition_source_topics, TopicInfo.encode);
            }
        }

        // Field: CopartitionGroups
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.copartition_groups);
                if (self.copartition_groups) |arr| {
                    for (arr) |*item| {
                        try CopartitionGroup.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.copartition_groups);
                if (self.copartition_groups) |arr| {
                    for (arr) |*item| {
                        try CopartitionGroup.encode(item, writer, version);
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

        // Field: SubtopologyId
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.subtopology_id) else types.computeSizeString(self.subtopology_id);
        }

        // Field: SourceTopics
        if (version >= 0 and version <= 32767) {
            if (self.source_topics) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |item| {
                    total_size += types.computeSizeCompactString(item);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(1) else 4;
            }
        }

        // Field: SourceTopicRegex
        if (version >= 0 and version <= 32767) {
            if (self.source_topic_regex) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |item| {
                    total_size += types.computeSizeCompactString(item);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(1) else 4;
            }
        }

        // Field: StateChangelogTopics
        if (version >= 0 and version <= 32767) {
            if (self.state_changelog_topics) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |item| {
                    total_size += TopicInfo.computeSize(item);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(1) else 4;
            }
        }

        // Field: RepartitionSinkTopics
        if (version >= 0 and version <= 32767) {
            if (self.repartition_sink_topics) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |item| {
                    total_size += types.computeSizeCompactString(item);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(1) else 4;
            }
        }

        // Field: RepartitionSourceTopics
        if (version >= 0 and version <= 32767) {
            if (self.repartition_source_topics) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |item| {
                    total_size += TopicInfo.computeSize(item);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(1) else 4;
            }
        }

        // Field: CopartitionGroups
        if (version >= 0 and version <= 32767) {
            if (self.copartition_groups) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try CopartitionGroup.computeSize(item, version);
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
        // Field: SubtopologyId
        if (version >= 0 and version <= 32767) {
            self.subtopology_id = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: SourceTopics
        if (version >= 0 and version <= 32767) {
            self.source_topics = if (is_flexible)
                try types.decodeCompactArray([]const u8, reader, allocator, types.decodeNonNullableCompactString)
            else
                try types.decodeArray([]const u8, reader, allocator, types.decodeNonNullableString);
        }

        // Field: SourceTopicRegex
        if (version >= 0 and version <= 32767) {
            self.source_topic_regex = if (is_flexible)
                try types.decodeCompactArray([]const u8, reader, allocator, types.decodeNonNullableCompactString)
            else
                try types.decodeArray([]const u8, reader, allocator, types.decodeNonNullableString);
        }

        // Field: StateChangelogTopics
        if (version >= 0 and version <= 32767) {
            self.state_changelog_topics = if (is_flexible)
                try types.decodeCompactArray(TopicInfo, reader, allocator, TopicInfo.decode)
            else
                try types.decodeArray(TopicInfo, reader, allocator, TopicInfo.decode);
        }

        // Field: RepartitionSinkTopics
        if (version >= 0 and version <= 32767) {
            self.repartition_sink_topics = if (is_flexible)
                try types.decodeCompactArray([]const u8, reader, allocator, types.decodeNonNullableCompactString)
            else
                try types.decodeArray([]const u8, reader, allocator, types.decodeNonNullableString);
        }

        // Field: RepartitionSourceTopics
        if (version >= 0 and version <= 32767) {
            self.repartition_source_topics = if (is_flexible)
                try types.decodeCompactArray(TopicInfo, reader, allocator, TopicInfo.decode)
            else
                try types.decodeArray(TopicInfo, reader, allocator, TopicInfo.decode);
        }

        // Field: CopartitionGroups
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(CopartitionGroup, array_len);
            for (array) |*item| {
                item.* = try CopartitionGroup.decode(reader, version, allocator);
            }
            self.copartition_groups = array;
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

/// Nested struct: CopartitionGroup
pub const CopartitionGroup = struct {
    const Self = @This();

    /// The topics the topology reads from. Index into the array on the subtopology level.
    /// Versions: 0+
    source_topics: ?[]i16 = null,
    /// Regular expressions identifying topics the subtopology reads from. Index into the array on the subtopology level.
    /// Versions: 0+
    source_topic_regex: ?[]i16 = null,
    /// The set of source topics that are internally created repartition topics. Index into the array on the subtopology level.
    /// Versions: 0+
    repartition_source_topics: ?[]i16 = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: SourceTopics
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayNonNull(i16, writer, self.source_topics, types.encodeInt16);
            } else {
                try types.encodeArrayNonNull(i16, writer, self.source_topics, types.encodeInt16);
            }
        }

        // Field: SourceTopicRegex
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayNonNull(i16, writer, self.source_topic_regex, types.encodeInt16);
            } else {
                try types.encodeArrayNonNull(i16, writer, self.source_topic_regex, types.encodeInt16);
            }
        }

        // Field: RepartitionSourceTopics
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayNonNull(i16, writer, self.repartition_source_topics, types.encodeInt16);
            } else {
                try types.encodeArrayNonNull(i16, writer, self.repartition_source_topics, types.encodeInt16);
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

        // Field: SourceTopics
        if (version >= 0 and version <= 32767) {
            if (self.source_topics) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |item| {
                    total_size += types.computeSizeInt16(item);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(1) else 4;
            }
        }

        // Field: SourceTopicRegex
        if (version >= 0 and version <= 32767) {
            if (self.source_topic_regex) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |item| {
                    total_size += types.computeSizeInt16(item);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(1) else 4;
            }
        }

        // Field: RepartitionSourceTopics
        if (version >= 0 and version <= 32767) {
            if (self.repartition_source_topics) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |item| {
                    total_size += types.computeSizeInt16(item);
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
        // Field: SourceTopics
        if (version >= 0 and version <= 32767) {
            self.source_topics = if (is_flexible)
                try types.decodeCompactPrimitiveArray(i16, reader, allocator, types.decodeInt16)
            else
                try types.decodePrimitiveArray(i16, reader, allocator, types.decodeInt16);
        }

        // Field: SourceTopicRegex
        if (version >= 0 and version <= 32767) {
            self.source_topic_regex = if (is_flexible)
                try types.decodeCompactPrimitiveArray(i16, reader, allocator, types.decodeInt16)
            else
                try types.decodePrimitiveArray(i16, reader, allocator, types.decodeInt16);
        }

        // Field: RepartitionSourceTopics
        if (version >= 0 and version <= 32767) {
            self.repartition_source_topics = if (is_flexible)
                try types.decodeCompactPrimitiveArray(i16, reader, allocator, types.decodeInt16)
            else
                try types.decodePrimitiveArray(i16, reader, allocator, types.decodeInt16);
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

/// StreamsGroupHeartbeatRequest
pub const StreamsGroupHeartbeatRequest = struct {
    const Self = @This();

    /// The group identifier.
    group_id: []const u8 = "",
    /// The member ID generated by the streams consumer. The member ID must be kept during the entire lifetime of the streams consumer process.
    member_id: []const u8 = "",
    /// The current member epoch; 0 to join the group; -1 to leave the group; -2 to indicate that the static member will rejoin.
    member_epoch: i32 = 0,
    /// The current endpoint epoch of this client, represents the latest endpoint epoch this client received
    endpoint_information_epoch: i32 = 0,
    /// null if not provided or if it didn't change since the last heartbeat; the instance ID for static membership otherwise.
    instance_id: ?[]const u8 = null,
    /// null if not provided or if it didn't change since the last heartbeat; the rack ID of the member otherwise.
    rack_id: ?[]const u8 = null,
    /// -1 if it didn't change since the last heartbeat; the maximum time in milliseconds that the coordinator will wait on the member to revoke its tasks otherwise.
    rebalance_timeout_ms: i32 = -1,
    /// The topology metadata of the streams application. Used to initialize the topology of the group and to check if the topology corresponds to the topology initialized for the group. Only sent when memberEpoch = 0, must be non-empty. Null otherwise.
    topology: ?Topology = null,
    /// Currently owned active tasks for this client. Null if unchanged since last heartbeat.
    active_tasks: ?[]TaskIds = null,
    /// Currently owned standby tasks for this client. Null if unchanged since last heartbeat.
    standby_tasks: ?[]TaskIds = null,
    /// Currently owned warm-up tasks for this client. Null if unchanged since last heartbeat.
    warmup_tasks: ?[]TaskIds = null,
    /// Identity of the streams instance that may have multiple consumers. Null if unchanged since last heartbeat.
    process_id: ?[]const u8 = null,
    /// User-defined endpoint for Interactive Queries. Null if unchanged since last heartbeat, or if not defined on the client.
    user_endpoint: ?Endpoint = null,
    /// Used for rack-aware assignment algorithm. Null if unchanged since last heartbeat.
    client_tags: ?[]KeyValue = null,
    /// Cumulative changelog offsets for tasks. Only updated when a warm-up task has caught up, and according to the task offset interval. Null if unchanged since last heartbeat.
    task_offsets: ?[]TaskOffset = null,
    /// Cumulative changelog end-offsets for tasks. Only updated when a warm-up task has caught up, and according to the task offset interval. Null if unchanged since last heartbeat.
    task_end_offsets: ?[]TaskOffset = null,
    /// Whether all Streams clients in the group should shut down.
    shutdown_application: bool = false,

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

    /// Create a default instance of StreamsGroupHeartbeatRequest
    pub fn default() Self {
        return .{
            .group_id = "",
            .member_id = "",
            .member_epoch = 0,
            .endpoint_information_epoch = 0,
            .instance_id = null,
            .rack_id = null,
            .rebalance_timeout_ms = -1,
            .topology = null,
            .active_tasks = null,
            .standby_tasks = null,
            .warmup_tasks = null,
            .process_id = null,
            .user_endpoint = null,
            .client_tags = null,
            .task_offsets = null,
            .task_end_offsets = null,
            .shutdown_application = false,
            ._tagged_fields = null,
        };
    }

    /// Sets `group_id` to the passed value.
    /// The group identifier.
    pub fn withGroupId(self: Self, value: []const u8) Self {
        var result = self;
        result.group_id = value;
        return result;
    }

    /// Sets `member_id` to the passed value.
    /// The member ID generated by the streams consumer. The member ID must be kept during the entire lifetime of the streams consumer process.
    pub fn withMemberId(self: Self, value: []const u8) Self {
        var result = self;
        result.member_id = value;
        return result;
    }

    /// Sets `member_epoch` to the passed value.
    /// The current member epoch; 0 to join the group; -1 to leave the group; -2 to indicate that the static member will rejoin.
    pub fn withMemberEpoch(self: Self, value: i32) Self {
        var result = self;
        result.member_epoch = value;
        return result;
    }

    /// Sets `endpoint_information_epoch` to the passed value.
    /// The current endpoint epoch of this client, represents the latest endpoint epoch this client received
    pub fn withEndpointInformationEpoch(self: Self, value: i32) Self {
        var result = self;
        result.endpoint_information_epoch = value;
        return result;
    }

    /// Sets `instance_id` to the passed value.
    /// null if not provided or if it didn't change since the last heartbeat; the instance ID for static membership otherwise.
    pub fn withInstanceId(self: Self, value: ?[]const u8) Self {
        var result = self;
        result.instance_id = value;
        return result;
    }

    /// Sets `rack_id` to the passed value.
    /// null if not provided or if it didn't change since the last heartbeat; the rack ID of the member otherwise.
    pub fn withRackId(self: Self, value: ?[]const u8) Self {
        var result = self;
        result.rack_id = value;
        return result;
    }

    /// Sets `rebalance_timeout_ms` to the passed value.
    /// -1 if it didn't change since the last heartbeat; the maximum time in milliseconds that the coordinator will wait on the member to revoke its tasks otherwise.
    pub fn withRebalanceTimeoutMs(self: Self, value: i32) Self {
        var result = self;
        result.rebalance_timeout_ms = value;
        return result;
    }

    /// Sets `topology` to the passed value.
    /// The topology metadata of the streams application. Used to initialize the topology of the group and to check if the topology corresponds to the topology initialized for the group. Only sent when memberEpoch = 0, must be non-empty. Null otherwise.
    pub fn withTopology(self: Self, value: ?Topology) Self {
        var result = self;
        result.topology = value;
        return result;
    }

    /// Sets `active_tasks` to the passed value.
    /// Currently owned active tasks for this client. Null if unchanged since last heartbeat.
    pub fn withActiveTasks(self: Self, value: ?[]TaskIds) Self {
        var result = self;
        result.active_tasks = value;
        return result;
    }

    /// Sets `standby_tasks` to the passed value.
    /// Currently owned standby tasks for this client. Null if unchanged since last heartbeat.
    pub fn withStandbyTasks(self: Self, value: ?[]TaskIds) Self {
        var result = self;
        result.standby_tasks = value;
        return result;
    }

    /// Sets `warmup_tasks` to the passed value.
    /// Currently owned warm-up tasks for this client. Null if unchanged since last heartbeat.
    pub fn withWarmupTasks(self: Self, value: ?[]TaskIds) Self {
        var result = self;
        result.warmup_tasks = value;
        return result;
    }

    /// Sets `process_id` to the passed value.
    /// Identity of the streams instance that may have multiple consumers. Null if unchanged since last heartbeat.
    pub fn withProcessId(self: Self, value: ?[]const u8) Self {
        var result = self;
        result.process_id = value;
        return result;
    }

    /// Sets `user_endpoint` to the passed value.
    /// User-defined endpoint for Interactive Queries. Null if unchanged since last heartbeat, or if not defined on the client.
    pub fn withUserEndpoint(self: Self, value: ?Endpoint) Self {
        var result = self;
        result.user_endpoint = value;
        return result;
    }

    /// Sets `client_tags` to the passed value.
    /// Used for rack-aware assignment algorithm. Null if unchanged since last heartbeat.
    pub fn withClientTags(self: Self, value: ?[]KeyValue) Self {
        var result = self;
        result.client_tags = value;
        return result;
    }

    /// Sets `task_offsets` to the passed value.
    /// Cumulative changelog offsets for tasks. Only updated when a warm-up task has caught up, and according to the task offset interval. Null if unchanged since last heartbeat.
    pub fn withTaskOffsets(self: Self, value: ?[]TaskOffset) Self {
        var result = self;
        result.task_offsets = value;
        return result;
    }

    /// Sets `task_end_offsets` to the passed value.
    /// Cumulative changelog end-offsets for tasks. Only updated when a warm-up task has caught up, and according to the task offset interval. Null if unchanged since last heartbeat.
    pub fn withTaskEndOffsets(self: Self, value: ?[]TaskOffset) Self {
        var result = self;
        result.task_end_offsets = value;
        return result;
    }

    /// Sets `shutdown_application` to the passed value.
    /// Whether all Streams clients in the group should shut down.
    pub fn withShutdownApplication(self: Self, value: bool) Self {
        var result = self;
        result.shutdown_application = value;
        return result;
    }

    /// Encode StreamsGroupHeartbeatRequest
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

        // Field: MemberEpoch
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.member_epoch);
        }

        // Field: EndpointInformationEpoch
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.endpoint_information_epoch);
        }

        // Field: InstanceId
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.instance_id);
            } else {
                try types.encodeString(writer, self.instance_id);
            }
        }

        // Field: RackId
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.rack_id);
            } else {
                try types.encodeString(writer, self.rack_id);
            }
        }

        // Field: RebalanceTimeoutMs
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.rebalance_timeout_ms);
        }

        // Field: Topology
        if (version >= 0 and version <= 32767) {
            try Topology.encode(&self.topology, writer, version);
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

        // Field: ProcessId
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.process_id);
            } else {
                try types.encodeString(writer, self.process_id);
            }
        }

        // Field: UserEndpoint
        if (version >= 0 and version <= 32767) {
            try Endpoint.encode(&self.user_endpoint, writer, version);
        }

        // Field: ClientTags
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArray(KeyValue, writer, self.client_tags, KeyValue.encode);
            } else {
                try types.encodeArray(KeyValue, writer, self.client_tags, KeyValue.encode);
            }
        }

        // Field: TaskOffsets
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArray(TaskOffset, writer, self.task_offsets, TaskOffset.encode);
            } else {
                try types.encodeArray(TaskOffset, writer, self.task_offsets, TaskOffset.encode);
            }
        }

        // Field: TaskEndOffsets
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArray(TaskOffset, writer, self.task_end_offsets, TaskOffset.encode);
            } else {
                try types.encodeArray(TaskOffset, writer, self.task_end_offsets, TaskOffset.encode);
            }
        }

        // Field: ShutdownApplication
        if (version >= 0 and version <= 32767) {
            try types.encodeBoolean(writer, self.shutdown_application);
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

    /// Compute the size of StreamsGroupHeartbeatRequest for the given version
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

        // Field: MemberEpoch
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.member_epoch);
        }

        // Field: EndpointInformationEpoch
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.endpoint_information_epoch);
        }

        // Field: InstanceId
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.instance_id) else types.computeSizeString(self.instance_id);
        }

        // Field: RackId
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.rack_id) else types.computeSizeString(self.rack_id);
        }

        // Field: RebalanceTimeoutMs
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.rebalance_timeout_ms);
        }

        // Field: Topology
        if (version >= 0 and version <= 32767) {
            total_size += try Topology.computeSize(&self.topology, version);
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

        // Field: ProcessId
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.process_id) else types.computeSizeString(self.process_id);
        }

        // Field: UserEndpoint
        if (version >= 0 and version <= 32767) {
            total_size += try Endpoint.computeSize(&self.user_endpoint, version);
        }

        // Field: ClientTags
        if (version >= 0 and version <= 32767) {
            if (self.client_tags) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |item| {
                    total_size += KeyValue.computeSize(item);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(0) else 4;
            }
        }

        // Field: TaskOffsets
        if (version >= 0 and version <= 32767) {
            if (self.task_offsets) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |item| {
                    total_size += TaskOffset.computeSize(item);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(0) else 4;
            }
        }

        // Field: TaskEndOffsets
        if (version >= 0 and version <= 32767) {
            if (self.task_end_offsets) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |item| {
                    total_size += TaskOffset.computeSize(item);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(0) else 4;
            }
        }

        // Field: ShutdownApplication
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeBoolean(self.shutdown_application);
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

    /// Decode StreamsGroupHeartbeatRequest
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

        // Field: EndpointInformationEpoch
        if (version >= 0 and version <= 32767) {
            self.endpoint_information_epoch = try types.decodeInt32(reader);
        }

        // Field: InstanceId
        if (version >= 0 and version <= 32767) {
            self.instance_id = if (is_flexible)
                try types.decodeCompactString(reader, allocator)
            else
                try types.decodeString(reader, allocator);
        }

        // Field: RackId
        if (version >= 0 and version <= 32767) {
            self.rack_id = if (is_flexible)
                try types.decodeCompactString(reader, allocator)
            else
                try types.decodeString(reader, allocator);
        }

        // Field: RebalanceTimeoutMs
        if (version >= 0 and version <= 32767) {
            self.rebalance_timeout_ms = try types.decodeInt32(reader);
        }

        // Field: Topology
        if (version >= 0 and version <= 32767) {
            self.topology = try Topology.decode(reader, version, allocator);
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

        // Field: ProcessId
        if (version >= 0 and version <= 32767) {
            self.process_id = if (is_flexible)
                try types.decodeCompactString(reader, allocator)
            else
                try types.decodeString(reader, allocator);
        }

        // Field: UserEndpoint
        if (version >= 0 and version <= 32767) {
            self.user_endpoint = try Endpoint.decode(reader, version, allocator);
        }

        // Field: ClientTags
        if (version >= 0 and version <= 32767) {
            self.client_tags = if (is_flexible)
                try types.decodeCompactArray(KeyValue, reader, allocator, KeyValue.decode)
            else
                try types.decodeArray(KeyValue, reader, allocator, KeyValue.decode);
        }

        // Field: TaskOffsets
        if (version >= 0 and version <= 32767) {
            self.task_offsets = if (is_flexible)
                try types.decodeCompactArray(TaskOffset, reader, allocator, TaskOffset.decode)
            else
                try types.decodeArray(TaskOffset, reader, allocator, TaskOffset.decode);
        }

        // Field: TaskEndOffsets
        if (version >= 0 and version <= 32767) {
            self.task_end_offsets = if (is_flexible)
                try types.decodeCompactArray(TaskOffset, reader, allocator, TaskOffset.decode)
            else
                try types.decodeArray(TaskOffset, reader, allocator, TaskOffset.decode);
        }

        // Field: ShutdownApplication
        if (version >= 0 and version <= 32767) {
            self.shutdown_application = try types.decodeBoolean(reader);
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
