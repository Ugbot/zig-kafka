//! Auto-generated Kafka protocol message
//! Message: ConsumerGroupDescribeResponse
//! API Key: 69
//! Type: response
//! Valid Versions: 0-1
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
    /// The selected assignor.
    /// Versions: 0+
    assignor_name: []const u8 = "",
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

        // Field: AssignorName
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.assignor_name);
            } else {
                try types.encodeString(writer, self.assignor_name);
            }
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

        // Field: AssignorName
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.assignor_name) else types.computeSizeString(self.assignor_name);
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

        // Field: AssignorName
        if (version >= 0 and version <= 32767) {
            self.assignor_name = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
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
    /// The member instance ID.
    /// Versions: 0+
    instance_id: ?[]const u8 = null,
    /// The member rack ID.
    /// Versions: 0+
    rack_id: ?[]const u8 = null,
    /// The current member epoch.
    /// Versions: 0+
    member_epoch: i32 = 0,
    /// The client ID.
    /// Versions: 0+
    client_id: []const u8 = "",
    /// The client host.
    /// Versions: 0+
    client_host: []const u8 = "",
    /// The subscribed topic names.
    /// Versions: 0+
    subscribed_topic_names: ?[][]const u8 = null,
    /// the subscribed topic regex otherwise or null of not provided.
    /// Versions: 0+
    subscribed_topic_regex: ?[]const u8 = null,
    /// The current assignment.
    /// Versions: 0+
    assignment: Assignment = .{},
    /// The target assignment.
    /// Versions: 0+
    target_assignment: Assignment = .{},
    /// -1 for unknown. 0 for classic member. +1 for consumer member.
    /// Versions: 1+
    member_type: i8 = -1,

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

        // Field: MemberEpoch
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.member_epoch);
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

        // Field: SubscribedTopicNames
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayNonNull([]const u8, writer, self.subscribed_topic_names, types.encodeCompactString);
            } else {
                try types.encodeArrayNonNull([]const u8, writer, self.subscribed_topic_names, types.encodeCompactString);
            }
        }

        // Field: SubscribedTopicRegex
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.subscribed_topic_regex);
            } else {
                try types.encodeString(writer, self.subscribed_topic_regex);
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

        // Field: MemberType
        if (version >= 1 and version <= 32767) {
            try types.encodeInt8(writer, self.member_type);
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

        // Field: InstanceId
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.instance_id) else types.computeSizeString(self.instance_id);
        }

        // Field: RackId
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.rack_id) else types.computeSizeString(self.rack_id);
        }

        // Field: MemberEpoch
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.member_epoch);
        }

        // Field: ClientId
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.client_id) else types.computeSizeString(self.client_id);
        }

        // Field: ClientHost
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.client_host) else types.computeSizeString(self.client_host);
        }

        // Field: SubscribedTopicNames
        if (version >= 0 and version <= 32767) {
            if (self.subscribed_topic_names) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |item| {
                    total_size += types.computeSizeCompactString(item);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(1) else 4;
            }
        }

        // Field: SubscribedTopicRegex
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.subscribed_topic_regex) else types.computeSizeString(self.subscribed_topic_regex);
        }

        // Field: Assignment
        if (version >= 0 and version <= 32767) {
            total_size += try Assignment.computeSize(&self.assignment, version);
        }

        // Field: TargetAssignment
        if (version >= 0 and version <= 32767) {
            total_size += try Assignment.computeSize(&self.target_assignment, version);
        }

        // Field: MemberType
        if (version >= 1 and version <= 32767) {
            total_size += types.computeSizeInt8(self.member_type);
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

        // Field: MemberEpoch
        if (version >= 0 and version <= 32767) {
            self.member_epoch = try types.decodeInt32(reader);
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

        // Field: SubscribedTopicNames
        if (version >= 0 and version <= 32767) {
            self.subscribed_topic_names = if (is_flexible)
                try types.decodeCompactArray([]const u8, reader, allocator, types.decodeNonNullableCompactString)
            else
                try types.decodeArray([]const u8, reader, allocator, types.decodeNonNullableString);
        }

        // Field: SubscribedTopicRegex
        if (version >= 0 and version <= 32767) {
            self.subscribed_topic_regex = if (is_flexible)
                try types.decodeCompactString(reader, allocator)
            else
                try types.decodeString(reader, allocator);
        }

        // Field: Assignment
        if (version >= 0 and version <= 32767) {
            self.assignment = try Assignment.decode(reader, version, allocator);
        }

        // Field: TargetAssignment
        if (version >= 0 and version <= 32767) {
            self.target_assignment = try Assignment.decode(reader, version, allocator);
        }

        // Field: MemberType
        if (version >= 1 and version <= 32767) {
            self.member_type = try types.decodeInt8(reader);
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

/// ConsumerGroupDescribeResponse
pub const ConsumerGroupDescribeResponse = struct {
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
    pub const VERSIONS = types.VersionRange{ .min = 0, .max = 1 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 69;
    }

    /// Create a default instance of ConsumerGroupDescribeResponse
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

    /// Encode ConsumerGroupDescribeResponse
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

    /// Compute the size of ConsumerGroupDescribeResponse for the given version
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

    /// Decode ConsumerGroupDescribeResponse
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
        const range = types.VersionRange.parse("0-1") catch return false;
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
