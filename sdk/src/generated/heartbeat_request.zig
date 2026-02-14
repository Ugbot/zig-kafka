//! Auto-generated Kafka protocol message
//! Message: HeartbeatRequest
//! API Key: 12
//! Type: request
//! Valid Versions: 0-4
//! Flexible Versions: 4+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// HeartbeatRequest
pub const HeartbeatRequest = struct {
    const Self = @This();

    /// The group id.
    group_id: []const u8 = "",
    /// The generation of the group.
    generation_id: i32 = 0,
    /// The member ID.
    member_id: []const u8 = "",
    /// The unique identifier of the consumer instance provided by end user.
    /// Versions: 3+
    group_instance_id: ?[]const u8 = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 0, .max = 4 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 12;
    }

    /// Create a default instance of HeartbeatRequest
    pub fn default() Self {
        return .{
            .group_id = "",
            .generation_id = 0,
            .member_id = "",
            .group_instance_id = null,
            ._tagged_fields = null,
        };
    }

    /// Sets `group_id` to the passed value.
    /// The group id.
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
    /// The member ID.
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

    /// Encode HeartbeatRequest
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

    /// Compute the size of HeartbeatRequest for the given version
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

    /// Decode HeartbeatRequest
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
        const range = types.VersionRange.parse("0-4") catch return false;
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
