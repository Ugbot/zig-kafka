//! Auto-generated Kafka protocol message
//! Message: StreamsGroupDescribeResponse
//! API Key: 89
//! Type: response
//! Valid Versions: 0
//! Flexible Versions: 0+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// Nested struct: DescribedGroup
pub const DescribedGroup = struct {
    const Self = @This();

    /// The describe error, or 0 if there was no error.
    /// Versions: 0+
    error_code: i16 = 0,
    /// The top-level error message, or null if there was no error.
    /// Versions: 0+
    error_message: ?[]const u8 = null,
    /// The group ID string.
    /// Versions: 0+
    group_id: []const u8 = "",
    /// The group state string, or the empty string.
    /// Versions: 0+
    group_state: []const u8 = "",
    /// The group epoch.
    /// Versions: 0+
    group_epoch: i32 = 0,
    /// The assignment epoch.
    /// Versions: 0+
    assignment_epoch: i32 = 0,
    /// The topology metadata currently initialized for the streams application. Can be null in case of a describe error.
    /// Versions: 0+
    topology: ?Topology = null,
    /// The members.
    /// Versions: 0+
    members: ?[]Member = null,
    /// 32-bit bitfield to represent authorized operations for this group.
    /// Versions: 0+
    authorized_operations: i32 = -2147483648,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

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

        // Field: GroupId
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.group_id);
            } else {
                try types.encodeString(writer, self.group_id);
            }
        }

        // Field: GroupState
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.group_state);
            } else {
                try types.encodeString(writer, self.group_state);
            }
        }

        // Field: GroupEpoch
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.group_epoch);
        }

        // Field: AssignmentEpoch
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.assignment_epoch);
        }

        // Field: Topology
        if (version >= 0 and version <= 32767) {
            try Topology.encode(&self.topology, writer, version);
        }

        // Field: Members
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.members);
                if (self.members) |arr| {
                    for (arr) |*item| {
                        try Member.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.members);
                if (self.members) |arr| {
                    for (arr) |*item| {
                        try Member.encode(item, writer, version);
                    }
                }
            }
        }

        // Field: AuthorizedOperations
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.authorized_operations);
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

        // Field: ErrorMessage
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.error_message) else types.computeSizeString(self.error_message);
        }

        // Field: GroupId
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.group_id) else types.computeSizeString(self.group_id);
        }

        // Field: GroupState
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.group_state) else types.computeSizeString(self.group_state);
        }

        // Field: GroupEpoch
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.group_epoch);
        }

        // Field: AssignmentEpoch
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.assignment_epoch);
        }

        // Field: Topology
        if (version >= 0 and version <= 32767) {
            total_size += try Topology.computeSize(&self.topology, version);
        }

        // Field: Members
        if (version >= 0 and version <= 32767) {
            if (self.members) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try Member.computeSize(item, version);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(1) else 4;
            }
        }

        // Field: AuthorizedOperations
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.authorized_operations);
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

        // Field: ErrorMessage
        if (version >= 0 and version <= 32767) {
            self.error_message = if (is_flexible)
                try types.decodeCompactString(reader, allocator)
            else
                try types.decodeString(reader, allocator);
        }

        // Field: GroupId
        if (version >= 0 and version <= 32767) {
            self.group_id = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: GroupState
        if (version >= 0 and version <= 32767) {
            self.group_state = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: GroupEpoch
        if (version >= 0 and version <= 32767) {
            self.group_epoch = try types.decodeInt32(reader);
        }

        // Field: AssignmentEpoch
        if (version >= 0 and version <= 32767) {
            self.assignment_epoch = try types.decodeInt32(reader);
        }

        // Field: Topology
        if (version >= 0 and version <= 32767) {
            self.topology = try Topology.decode(reader, version, allocator);
        }

        // Field: Members
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(Member, array_len);
            for (array) |*item| {
                item.* = try Member.decode(reader, version, allocator);
            }
            self.members = array;
        }

        // Field: AuthorizedOperations
        if (version >= 0 and version <= 32767) {
            self.authorized_operations = try types.decodeInt32(reader);
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

/// Nested struct: Member
pub const Member = struct {
    const Self = @This();

    /// The member ID.
    /// Versions: 0+
    member_id: []const u8 = "",
    /// The member epoch.
    /// Versions: 0+
    member_epoch: i32 = 0,
    /// The member instance ID for static membership.
    /// Versions: 0+
    instance_id: ?[]const u8 = null,
    /// The rack ID.
    /// Versions: 0+
    rack_id: ?[]const u8 = null,
    /// The client ID.
    /// Versions: 0+
    client_id: []const u8 = "",
    /// The client host.
    /// Versions: 0+
    client_host: []const u8 = "",
    /// The epoch of the topology on the client.
    /// Versions: 0+
    topology_epoch: i32 = 0,
    /// Identity of the streams instance that may have multiple clients. 
    /// Versions: 0+
    process_id: []const u8 = "",
    /// User-defined endpoint for Interactive Queries. Null if not defined for this client.
    /// Versions: 0+
    user_endpoint: ?Endpoint = null,
    /// Used for rack-aware assignment algorithm.
    /// Versions: 0+
    client_tags: ?[]KeyValue = null,
    /// Cumulative changelog offsets for tasks.
    /// Versions: 0+
    task_offsets: ?[]TaskOffset = null,
    /// Cumulative changelog end offsets for tasks.
    /// Versions: 0+
    task_end_offsets: ?[]TaskOffset = null,
    /// The current assignment.
    /// Versions: 0+
    assignment: Assignment = .{},
    /// The target assignment.
    /// Versions: 0+
    target_assignment: Assignment = .{},
    /// True for classic members that have not been upgraded yet.
    /// Versions: 0+
    is_classic: bool = false,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

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

        // Field: ClientId
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.client_id);
            } else {
                try types.encodeString(writer, self.client_id);
            }
        }

        // Field: ClientHost
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.client_host);
            } else {
                try types.encodeString(writer, self.client_host);
            }
        }

        // Field: TopologyEpoch
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.topology_epoch);
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
                try types.encodeCompactArrayNonNull(KeyValue, writer, self.client_tags, KeyValue.encode);
            } else {
                try types.encodeArrayNonNull(KeyValue, writer, self.client_tags, KeyValue.encode);
            }
        }

        // Field: TaskOffsets
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayNonNull(TaskOffset, writer, self.task_offsets, TaskOffset.encode);
            } else {
                try types.encodeArrayNonNull(TaskOffset, writer, self.task_offsets, TaskOffset.encode);
            }
        }

        // Field: TaskEndOffsets
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayNonNull(TaskOffset, writer, self.task_end_offsets, TaskOffset.encode);
            } else {
                try types.encodeArrayNonNull(TaskOffset, writer, self.task_end_offsets, TaskOffset.encode);
            }
        }

        // Field: Assignment
        if (version >= 0 and version <= 32767) {
            try Assignment.encode(&self.assignment, writer, version);
        }

        // Field: TargetAssignment
        if (version >= 0 and version <= 32767) {
            try Assignment.encode(&self.target_assignment, writer, version);
        }

        // Field: IsClassic
        if (version >= 0 and version <= 32767) {
            try types.encodeBoolean(writer, self.is_classic);
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

        // Field: MemberId
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.member_id) else types.computeSizeString(self.member_id);
        }

        // Field: MemberEpoch
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.member_epoch);
        }

        // Field: InstanceId
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.instance_id) else types.computeSizeString(self.instance_id);
        }

        // Field: RackId
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.rack_id) else types.computeSizeString(self.rack_id);
        }

        // Field: ClientId
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.client_id) else types.computeSizeString(self.client_id);
        }

        // Field: ClientHost
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.client_host) else types.computeSizeString(self.client_host);
        }

        // Field: TopologyEpoch
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.topology_epoch);
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
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(1) else 4;
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
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(1) else 4;
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
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(1) else 4;
            }
        }

        // Field: Assignment
        if (version >= 0 and version <= 32767) {
            total_size += try Assignment.computeSize(&self.assignment, version);
        }

        // Field: TargetAssignment
        if (version >= 0 and version <= 32767) {
            total_size += try Assignment.computeSize(&self.target_assignment, version);
        }

        // Field: IsClassic
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeBoolean(self.is_classic);
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

        // Field: ClientId
        if (version >= 0 and version <= 32767) {
            self.client_id = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: ClientHost
        if (version >= 0 and version <= 32767) {
            self.client_host = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: TopologyEpoch
        if (version >= 0 and version <= 32767) {
            self.topology_epoch = try types.decodeInt32(reader);
        }

        // Field: ProcessId
        if (version >= 0 and version <= 32767) {
            self.process_id = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
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

        // Field: Assignment
        if (version >= 0 and version <= 32767) {
            self.assignment = try Assignment.decode(reader, version, allocator);
        }

        // Field: TargetAssignment
        if (version >= 0 and version <= 32767) {
            self.target_assignment = try Assignment.decode(reader, version, allocator);
        }

        // Field: IsClassic
        if (version >= 0 and version <= 32767) {
            self.is_classic = try types.decodeBoolean(reader);
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

/// Nested struct: Topology
pub const Topology = struct {
    const Self = @This();

    /// The epoch of the currently initialized topology for this group.
    /// Versions: 0+
    epoch: i32 = 0,
    /// The subtopologies of the streams application. This contains the configured subtopologies, where the number of partitions are set and any regular expressions are resolved to actual topics. Null if the group is uninitialized, source topics are missing or incorrectly partitioned.
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
                try types.encodeCompactArrayLen(writer, self.subtopologies);
                if (self.subtopologies) |arr| {
                    for (arr) |*item| {
                        try Subtopology.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLen(writer, self.subtopologies);
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
        // Field: Epoch
        if (version >= 0 and version <= 32767) {
            self.epoch = try types.decodeInt32(reader);
        }

        // Field: Subtopologies
        if (version >= 0 and version <= 32767) {
            const raw_len: i32 = if (is_flexible) blk: {
                const v = try types.decodeUnsignedVarInt(reader);
                break :blk if (v == 0) @as(i32, -1) else @as(i32, @intCast(v - 1));
            } else try types.decodeInt32(reader);
            if (raw_len < 0) {
                self.subtopologies = null;
            } else {
                const array_len: usize = @intCast(raw_len);
                const array = try allocator.alloc(Subtopology, array_len);
                for (array) |*item| {
                    item.* = try Subtopology.decode(reader, version, allocator);
                }
                self.subtopologies = array;
            }
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

    /// String to uniquely identify the subtopology.
    /// Versions: 0+
    subtopology_id: []const u8 = "",
    /// The topics the subtopology reads from.
    /// Versions: 0+
    source_topics: ?[][]const u8 = null,
    /// The repartition topics the subtopology writes to.
    /// Versions: 0+
    repartition_sink_topics: ?[][]const u8 = null,
    /// The set of state changelog topics associated with this subtopology. Created automatically.
    /// Versions: 0+
    state_changelog_topics: ?[]TopicInfo = null,
    /// The set of source topics that are internally created repartition topics. Created automatically.
    /// Versions: 0+
    repartition_source_topics: ?[]TopicInfo = null,

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

        // Field: RepartitionSinkTopics
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayNonNull([]const u8, writer, self.repartition_sink_topics, types.encodeCompactString);
            } else {
                try types.encodeArrayNonNull([]const u8, writer, self.repartition_sink_topics, types.encodeCompactString);
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

        // Field: RepartitionSourceTopics
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayNonNull(TopicInfo, writer, self.repartition_source_topics, TopicInfo.encode);
            } else {
                try types.encodeArrayNonNull(TopicInfo, writer, self.repartition_source_topics, TopicInfo.encode);
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

        // Field: RepartitionSinkTopics
        if (version >= 0 and version <= 32767) {
            self.repartition_sink_topics = if (is_flexible)
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

        // Field: RepartitionSourceTopics
        if (version >= 0 and version <= 32767) {
            self.repartition_source_topics = if (is_flexible)
                try types.decodeCompactArray(TopicInfo, reader, allocator, TopicInfo.decode)
            else
                try types.decodeArray(TopicInfo, reader, allocator, TopicInfo.decode);
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

/// StreamsGroupDescribeResponse
pub const StreamsGroupDescribeResponse = struct {
    const Self = @This();

    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    throttle_time_ms: i32 = 0,
    /// Each described group.
    groups: ?[]DescribedGroup = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 0, .max = 0 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 89;
    }

    /// Create a default instance of StreamsGroupDescribeResponse
    pub fn default() Self {
        return .{
            .throttle_time_ms = 0,
            .groups = null,
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

    /// Sets `groups` to the passed value.
    /// Each described group.
    pub fn withGroups(self: Self, value: ?[]DescribedGroup) Self {
        var result = self;
        result.groups = value;
        return result;
    }

    /// Encode StreamsGroupDescribeResponse
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

        // Field: Groups
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.groups);
                if (self.groups) |arr| {
                    for (arr) |*item| {
                        try DescribedGroup.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.groups);
                if (self.groups) |arr| {
                    for (arr) |*item| {
                        try DescribedGroup.encode(item, writer, version);
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

    /// Compute the size of StreamsGroupDescribeResponse for the given version
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

        // Field: Groups
        if (version >= 0 and version <= 32767) {
            if (self.groups) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try DescribedGroup.computeSize(item, version);
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

    /// Decode StreamsGroupDescribeResponse
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

        // Field: Groups
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(DescribedGroup, array_len);
            for (array) |*item| {
                item.* = try DescribedGroup.decode(reader, version, allocator);
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
