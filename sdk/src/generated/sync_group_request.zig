//! Auto-generated Kafka protocol message
//! Message: SyncGroupRequest
//! API Key: 14
//! Type: request
//! Valid Versions: 0-5
//! Flexible Versions: 4+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// Nested struct: SyncGroupRequestAssignment
pub const SyncGroupRequestAssignment = struct {
    const Self = @This();

    /// The ID of the member to assign.
    /// Versions: 0+
    member_id: []const u8 = "",
    /// The member assignment.
    /// Versions: 0+
    assignment: []const u8 = &[_]u8{},

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

        // Field: Assignment
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactBytes(writer, self.assignment);
            } else {
                try types.encodeBytes(writer, self.assignment);
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

        // Field: Assignment
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactBytes(self.assignment) else types.computeSizeBytes(self.assignment);
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

        // Field: Assignment
        if (version >= 0 and version <= 32767) {
            self.assignment = if (is_flexible)
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
        const range = types.VersionRange.parse("4+") catch return false;
        return range.contains(version);
    }
};

/// SyncGroupRequest
pub const SyncGroupRequest = struct {
    const Self = @This();

    /// The unique group identifier.
    group_id: []const u8 = "",
    /// The generation of the group.
    generation_id: i32 = 0,
    /// The member ID assigned by the group.
    member_id: []const u8 = "",
    /// The unique identifier of the consumer instance provided by end user.
    /// Versions: 3+
    group_instance_id: ?[]const u8 = null,
    /// The group protocol type.
    /// Versions: 5+
    protocol_type: ?[]const u8 = null,
    /// The group protocol name.
    /// Versions: 5+
    protocol_name: ?[]const u8 = null,
    /// Each assignment.
    assignments: ?[]SyncGroupRequestAssignment = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 0, .max = 5 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 14;
    }

    /// Create a default instance of SyncGroupRequest
    pub fn default() Self {
        return .{
            .group_id = "",
            .generation_id = 0,
            .member_id = "",
            .group_instance_id = null,
            .protocol_type = null,
            .protocol_name = null,
            .assignments = null,
            ._tagged_fields = null,
        };
    }

    /// Sets `group_id` to the passed value.
    /// The unique group identifier.
    pub fn withGroupId(self: Self, value: []const u8) Self {
        var result = self;
        result.group_id = value;
        return result;
    }

    /// Sets `generation_id` to the passed value.
    /// The generation of the group.
    pub fn withGenerationId(self: Self, value: i32) Self {
        var result = self;
        result.generation_id = value;
        return result;
    }

    /// Sets `member_id` to the passed value.
    /// The member ID assigned by the group.
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

    /// Sets `protocol_type` to the passed value.
    /// The group protocol type.
    /// Versions: 5+
    pub fn withProtocolType(self: Self, value: ?[]const u8) Self {
        var result = self;
        result.protocol_type = value;
        return result;
    }

    /// Sets `protocol_name` to the passed value.
    /// The group protocol name.
    /// Versions: 5+
    pub fn withProtocolName(self: Self, value: ?[]const u8) Self {
        var result = self;
        result.protocol_name = value;
        return result;
    }

    /// Sets `assignments` to the passed value.
    /// Each assignment.
    pub fn withAssignments(self: Self, value: ?[]SyncGroupRequestAssignment) Self {
        var result = self;
        result.assignments = value;
        return result;
    }

    /// Encode SyncGroupRequest
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

        // Field: GenerationId
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.generation_id);
        }

        // Field: MemberId
        if (version >= 0 and version <= 32767) {
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

        // Field: ProtocolType
        if (version >= 5 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.protocol_type);
            } else {
                try types.encodeString(writer, self.protocol_type);
            }
        }

        // Field: ProtocolName
        if (version >= 5 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.protocol_name);
            } else {
                try types.encodeString(writer, self.protocol_name);
            }
        }

        // Field: Assignments
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.assignments);
                if (self.assignments) |arr| {
                    for (arr) |*item| {
                        try SyncGroupRequestAssignment.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.assignments);
                if (self.assignments) |arr| {
                    for (arr) |*item| {
                        try SyncGroupRequestAssignment.encode(item, writer, version);
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

    /// Compute the size of SyncGroupRequest for the given version
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

        // Field: GenerationId
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.generation_id);
        }

        // Field: MemberId
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.member_id) else types.computeSizeString(self.member_id);
        }

        // Field: GroupInstanceId
        if (version >= 3 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.group_instance_id) else types.computeSizeString(self.group_instance_id);
        }

        // Field: ProtocolType
        if (version >= 5 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.protocol_type) else types.computeSizeString(self.protocol_type);
        }

        // Field: ProtocolName
        if (version >= 5 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.protocol_name) else types.computeSizeString(self.protocol_name);
        }

        // Field: Assignments
        if (version >= 0 and version <= 32767) {
            if (self.assignments) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try SyncGroupRequestAssignment.computeSize(item, version);
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

    /// Decode SyncGroupRequest
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

        // Field: GenerationId
        if (version >= 0 and version <= 32767) {
            self.generation_id = try types.decodeInt32(reader);
        }

        // Field: MemberId
        if (version >= 0 and version <= 32767) {
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

        // Field: ProtocolType
        if (version >= 5 and version <= 32767) {
            self.protocol_type = if (is_flexible)
                try types.decodeCompactString(reader, allocator)
            else
                try types.decodeString(reader, allocator);
        }

        // Field: ProtocolName
        if (version >= 5 and version <= 32767) {
            self.protocol_name = if (is_flexible)
                try types.decodeCompactString(reader, allocator)
            else
                try types.decodeString(reader, allocator);
        }

        // Field: Assignments
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(SyncGroupRequestAssignment, array_len);
            for (array) |*item| {
                item.* = try SyncGroupRequestAssignment.decode(reader, version, allocator);
            }
            self.assignments = array;
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
        const range = types.VersionRange.parse("0-5") catch return false;
        return range.contains(version);
    }
    /// Check if version uses flexible encoding
    pub fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("4+") catch return false;
        return range.contains(version);
    }
    /// Get the header version for this API version
    /// Returns 2 for flexible versions, 1 for classic versions
    pub fn headerVersion(api_version: i16) i16 {
        if (isFlexibleVersion(api_version)) return 2;
        return 1;
    }

};
