//! Auto-generated Kafka protocol message
//! Message: DescribeGroupsResponse
//! API Key: 15
//! Type: response
//! Valid Versions: 0-6
//! Flexible Versions: 5+
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
    /// The describe error message, or null if there was no error.
    /// Versions: 6+
    error_message: ?[]const u8 = null,
    /// The group ID string.
    /// Versions: 0+
    group_id: []const u8 = "",
    /// The group state string, or the empty string.
    /// Versions: 0+
    group_state: []const u8 = "",
    /// The group protocol type, or the empty string.
    /// Versions: 0+
    protocol_type: []const u8 = "",
    /// The group protocol data, or the empty string.
    /// Versions: 0+
    protocol_data: []const u8 = "",
    /// The group members.
    /// Versions: 0+
    members: ?[]DescribedGroupMember = null,
    /// 32-bit bitfield to represent authorized operations for this group.
    /// Versions: 3+
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
        if (version >= 6 and version <= 32767) {
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

        // Field: ProtocolType
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.protocol_type);
            } else {
                try types.encodeString(writer, self.protocol_type);
            }
        }

        // Field: ProtocolData
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.protocol_data);
            } else {
                try types.encodeString(writer, self.protocol_data);
            }
        }

        // Field: Members
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLen(writer, self.members);
                if (self.members) |arr| {
                    for (arr) |*item| {
                        try DescribedGroupMember.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLen(writer, self.members);
                if (self.members) |arr| {
                    for (arr) |*item| {
                        try DescribedGroupMember.encode(item, writer, version);
                    }
                }
            }
        }

        // Field: AuthorizedOperations
        if (version >= 3 and version <= 32767) {
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
        if (version >= 6 and version <= 32767) {
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

        // Field: ProtocolType
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.protocol_type) else types.computeSizeString(self.protocol_type);
        }

        // Field: ProtocolData
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.protocol_data) else types.computeSizeString(self.protocol_data);
        }

        // Field: Members
        if (version >= 0 and version <= 32767) {
            if (self.members) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try DescribedGroupMember.computeSize(item, version);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(0) else 4;
            }
        }

        // Field: AuthorizedOperations
        if (version >= 3 and version <= 32767) {
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
        if (version >= 6 and version <= 32767) {
            self.error_message = if (is_flexible)
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

        // Field: GroupState
        if (version >= 0 and version <= 32767) {
            self.group_state = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: ProtocolType
        if (version >= 0 and version <= 32767) {
            self.protocol_type = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: ProtocolData
        if (version >= 0 and version <= 32767) {
            self.protocol_data = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: Members
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(DescribedGroupMember, array_len);
            for (array) |*item| {
                item.* = try DescribedGroupMember.decode(reader, version, allocator);
            }
            self.members = array;
        }

        // Field: AuthorizedOperations
        if (version >= 3 and version <= 32767) {
            self.authorized_operations = try types.decodeInt32(reader);
        }


        if (is_flexible) {
            const tagged_fields_data = try types.decodeTaggedFields(reader, allocator);
            self._tagged_fields = tagged_fields_data;
        }
        return self;
    }

    fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("5+") catch return false;
        return range.contains(version);
    }
};

/// Nested struct: DescribedGroupMember
pub const DescribedGroupMember = struct {
    const Self = @This();

    /// The member id.
    /// Versions: 0+
    member_id: []const u8 = "",
    /// The unique identifier of the consumer instance provided by end user.
    /// Versions: 4+
    group_instance_id: ?[]const u8 = null,
    /// The client ID used in the member's latest join group request.
    /// Versions: 0+
    client_id: []const u8 = "",
    /// The client host.
    /// Versions: 0+
    client_host: []const u8 = "",
    /// The metadata corresponding to the current group protocol in use.
    /// Versions: 0+
    member_metadata: []const u8 = &[_]u8{},
    /// The current assignment provided by the group leader.
    /// Versions: 0+
    member_assignment: []const u8 = &[_]u8{},

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

        // Field: GroupInstanceId
        if (version >= 4 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.group_instance_id);
            } else {
                try types.encodeString(writer, self.group_instance_id);
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

        // Field: MemberMetadata
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactBytes(writer, self.member_metadata);
            } else {
                try types.encodeBytes(writer, self.member_metadata);
            }
        }

        // Field: MemberAssignment
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactBytes(writer, self.member_assignment);
            } else {
                try types.encodeBytes(writer, self.member_assignment);
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

        // Field: MemberId
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.member_id) else types.computeSizeString(self.member_id);
        }

        // Field: GroupInstanceId
        if (version >= 4 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.group_instance_id) else types.computeSizeString(self.group_instance_id);
        }

        // Field: ClientId
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.client_id) else types.computeSizeString(self.client_id);
        }

        // Field: ClientHost
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.client_host) else types.computeSizeString(self.client_host);
        }

        // Field: MemberMetadata
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactBytes(self.member_metadata) else types.computeSizeBytes(self.member_metadata);
        }

        // Field: MemberAssignment
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactBytes(self.member_assignment) else types.computeSizeBytes(self.member_assignment);
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

        // Field: GroupInstanceId
        if (version >= 4 and version <= 32767) {
            self.group_instance_id = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
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

        // Field: MemberMetadata
        if (version >= 0 and version <= 32767) {
            self.member_metadata = if (is_flexible)
                try types.decodeCompactBytes(reader, allocator) orelse ""
            else
                try types.decodeBytes(reader, allocator) orelse "";
        }

        // Field: MemberAssignment
        if (version >= 0 and version <= 32767) {
            self.member_assignment = if (is_flexible)
                try types.decodeCompactBytes(reader, allocator) orelse ""
            else
                try types.decodeBytes(reader, allocator) orelse "";
        }


        if (is_flexible) {
            const tagged_fields_data = try types.decodeTaggedFields(reader, allocator);
            self._tagged_fields = tagged_fields_data;
        }
        return self;
    }

    fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("5+") catch return false;
        return range.contains(version);
    }
};

/// DescribeGroupsResponse
pub const DescribeGroupsResponse = struct {
    const Self = @This();

    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    /// Versions: 1+
    throttle_time_ms: i32 = 0,
    /// Each described group.
    groups: ?[]DescribedGroup = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 0, .max = 6 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 15;
    }

    /// Create a default instance of DescribeGroupsResponse
    pub fn default() Self {
        return .{
            .throttle_time_ms = 0,
            .groups = null,
            ._tagged_fields = null,
        };
    }

    /// Sets `throttle_time_ms` to the passed value.
    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    /// Versions: 1+
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

    /// Encode DescribeGroupsResponse
    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: ThrottleTimeMs
        if (version >= 1 and version <= 32767) {
            try types.encodeInt32(writer, self.throttle_time_ms);
        }

        // Field: Groups
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLen(writer, self.groups);
                if (self.groups) |arr| {
                    for (arr) |*item| {
                        try DescribedGroup.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLen(writer, self.groups);
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

    /// Compute the size of DescribeGroupsResponse for the given version
    pub fn computeSize(self: *const Self, version: i16) !usize {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        var total_size: usize = 0;

        // Field: ThrottleTimeMs
        if (version >= 1 and version <= 32767) {
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

    /// Decode DescribeGroupsResponse
    pub fn decode(reader: anytype, version: i16, allocator: std.mem.Allocator) !Self {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        var self: Self = .{};

        // Field: ThrottleTimeMs
        if (version >= 1 and version <= 32767) {
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
        const range = types.VersionRange.parse("0-6") catch return false;
        return range.contains(version);
    }
    /// Check if version uses flexible encoding
    pub fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("5+") catch return false;
        return range.contains(version);
    }
    /// Get the header version for this API version
    /// Returns 2 for flexible versions, 1 for classic versions
    pub fn headerVersion(api_version: i16) i16 {
        if (isFlexibleVersion(api_version)) return 2;
        return 1;
    }

};
