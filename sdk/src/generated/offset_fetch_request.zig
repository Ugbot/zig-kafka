//! Auto-generated Kafka protocol message
//! Message: OffsetFetchRequest
//! API Key: 9
//! Type: request
//! Valid Versions: 1-10
//! Flexible Versions: 6+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// Nested struct: OffsetFetchRequestGroup
pub const OffsetFetchRequestGroup = struct {
    const Self = @This();

    /// The group ID.
    /// Versions: 8+
    group_id: []const u8 = "",
    /// The member id.
    /// Versions: 9+
    member_id: ?[]const u8 = null,
    /// The member epoch if using the new consumer protocol (KIP-848).
    /// Versions: 9+
    member_epoch: i32 = -1,
    /// Each topic we would like to fetch offsets for, or null to fetch offsets for all topics.
    /// Versions: 8+
    topics: ?[]OffsetFetchRequestTopics = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: GroupId
        if (version >= 8 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.group_id);
            } else {
                try types.encodeString(writer, self.group_id);
            }
        }

        // Field: MemberId
        if (version >= 9 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.member_id);
            } else {
                try types.encodeString(writer, self.member_id);
            }
        }

        // Field: MemberEpoch
        if (version >= 9 and version <= 32767) {
            try types.encodeInt32(writer, self.member_epoch);
        }

        // Field: Topics
        if (version >= 8 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLen(writer, self.topics);
                if (self.topics) |arr| {
                    for (arr) |*item| {
                        try OffsetFetchRequestTopics.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLen(writer, self.topics);
                if (self.topics) |arr| {
                    for (arr) |*item| {
                        try OffsetFetchRequestTopics.encode(item, writer, version);
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

        // Field: GroupId
        if (version >= 8 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.group_id) else types.computeSizeString(self.group_id);
        }

        // Field: MemberId
        if (version >= 9 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.member_id) else types.computeSizeString(self.member_id);
        }

        // Field: MemberEpoch
        if (version >= 9 and version <= 32767) {
            total_size += types.computeSizeInt32(self.member_epoch);
        }

        // Field: Topics
        if (version >= 8 and version <= 32767) {
            if (self.topics) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try OffsetFetchRequestTopics.computeSize(item, version);
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
        // Field: GroupId
        if (version >= 8 and version <= 32767) {
            self.group_id = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: MemberId
        if (version >= 9 and version <= 32767) {
            self.member_id = if (is_flexible)
                try types.decodeCompactString(reader, allocator)
            else
                try types.decodeString(reader, allocator);
        }

        // Field: MemberEpoch
        if (version >= 9 and version <= 32767) {
            self.member_epoch = try types.decodeInt32(reader);
        }

        // Field: Topics
        if (version >= 8 and version <= 32767) {
            const raw_len: i32 = if (is_flexible) blk: {
                const v = try types.decodeUnsignedVarInt(reader);
                break :blk if (v == 0) @as(i32, -1) else @as(i32, @intCast(v - 1));
            } else try types.decodeInt32(reader);
            if (raw_len < 0) {
                self.topics = null;
            } else {
                const array_len: usize = @intCast(raw_len);
                const array = try allocator.alloc(OffsetFetchRequestTopics, array_len);
                for (array) |*item| {
                    item.* = try OffsetFetchRequestTopics.decode(reader, version, allocator);
                }
                self.topics = array;
            }
        }


        if (is_flexible) {
            const tagged_fields_data = try types.decodeTaggedFields(reader, allocator);
            self._tagged_fields = tagged_fields_data;
        }
        return self;
    }

    fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("6+") catch return false;
        return range.contains(version);
    }
};

/// Nested struct: OffsetFetchRequestTopics
pub const OffsetFetchRequestTopics = struct {
    const Self = @This();

    /// The topic name.
    /// Versions: 8-9
    name: []const u8 = "",
    /// The topic ID.
    /// Versions: 10+
    topic_id: [16]u8 = [_]u8{0} ** 16,
    /// The partition indexes we would like to fetch offsets for.
    /// Versions: 8+
    partition_indexes: ?[]i32 = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: Name
        if (version >= 8 and version <= 9) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.name);
            } else {
                try types.encodeString(writer, self.name);
            }
        }

        // Field: TopicId
        if (version >= 10 and version <= 32767) {
            try types.encodeUuid(writer, self.topic_id);
        }

        // Field: PartitionIndexes
        if (version >= 8 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayNonNull(i32, writer, self.partition_indexes, types.encodeInt32);
            } else {
                try types.encodeArrayNonNull(i32, writer, self.partition_indexes, types.encodeInt32);
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

        // Field: Name
        if (version >= 8 and version <= 9) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.name) else types.computeSizeString(self.name);
        }

        // Field: TopicId
        if (version >= 10 and version <= 32767) {
            total_size += types.computeSizeUuid(self.topic_id);
        }

        // Field: PartitionIndexes
        if (version >= 8 and version <= 32767) {
            if (self.partition_indexes) |arr| {
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
        // Field: Name
        if (version >= 8 and version <= 9) {
            self.name = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: TopicId
        if (version >= 10 and version <= 32767) {
            self.topic_id = try types.decodeUuid(reader);
        }

        // Field: PartitionIndexes
        if (version >= 8 and version <= 32767) {
            self.partition_indexes = if (is_flexible)
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
        const range = types.VersionRange.parse("6+") catch return false;
        return range.contains(version);
    }
};

/// Nested struct: OffsetFetchRequestTopic
pub const OffsetFetchRequestTopic = struct {
    const Self = @This();

    /// The topic name.
    /// Versions: 0-7
    name: []const u8 = "",
    /// The partition indexes we would like to fetch offsets for.
    /// Versions: 0-7
    partition_indexes: ?[]i32 = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: Name
        if (version >= 0 and version <= 7) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.name);
            } else {
                try types.encodeString(writer, self.name);
            }
        }

        // Field: PartitionIndexes
        if (version >= 0 and version <= 7) {
            if (is_flexible) {
                try types.encodeCompactArrayNonNull(i32, writer, self.partition_indexes, types.encodeInt32);
            } else {
                try types.encodeArrayNonNull(i32, writer, self.partition_indexes, types.encodeInt32);
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

        // Field: Name
        if (version >= 0 and version <= 7) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.name) else types.computeSizeString(self.name);
        }

        // Field: PartitionIndexes
        if (version >= 0 and version <= 7) {
            if (self.partition_indexes) |arr| {
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
        // Field: Name
        if (version >= 0 and version <= 7) {
            self.name = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: PartitionIndexes
        if (version >= 0 and version <= 7) {
            self.partition_indexes = if (is_flexible)
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
        const range = types.VersionRange.parse("6+") catch return false;
        return range.contains(version);
    }
};

/// OffsetFetchRequest
pub const OffsetFetchRequest = struct {
    const Self = @This();

    /// The group to fetch offsets for.
    /// Versions: 0-7
    group_id: []const u8 = "",
    /// Each topic we would like to fetch offsets for, or null to fetch offsets for all topics.
    /// Versions: 0-7
    topics: ?[]OffsetFetchRequestTopic = null,
    /// Each group we would like to fetch offsets for.
    /// Versions: 8+
    groups: ?[]OffsetFetchRequestGroup = null,
    /// Whether broker should hold on returning unstable offsets but set a retriable error code for the partitions.
    /// Versions: 7+
    require_stable: bool = false,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 1, .max = 10 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 9;
    }

    /// Create a default instance of OffsetFetchRequest
    pub fn default() Self {
        return .{
            .group_id = "",
            .topics = null,
            .groups = null,
            .require_stable = false,
            ._tagged_fields = null,
        };
    }

    /// Sets `group_id` to the passed value.
    /// The group to fetch offsets for.
    /// Versions: 0-7
    pub fn withGroupId(self: Self, value: []const u8) Self {
        var result = self;
        result.group_id = value;
        return result;
    }

    /// Sets `topics` to the passed value.
    /// Each topic we would like to fetch offsets for, or null to fetch offsets for all topics.
    /// Versions: 0-7
    pub fn withTopics(self: Self, value: ?[]OffsetFetchRequestTopic) Self {
        var result = self;
        result.topics = value;
        return result;
    }

    /// Sets `groups` to the passed value.
    /// Each group we would like to fetch offsets for.
    /// Versions: 8+
    pub fn withGroups(self: Self, value: ?[]OffsetFetchRequestGroup) Self {
        var result = self;
        result.groups = value;
        return result;
    }

    /// Sets `require_stable` to the passed value.
    /// Whether broker should hold on returning unstable offsets but set a retriable error code for the partitions.
    /// Versions: 7+
    pub fn withRequireStable(self: Self, value: bool) Self {
        var result = self;
        result.require_stable = value;
        return result;
    }

    /// Encode OffsetFetchRequest
    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: GroupId
        if (version >= 0 and version <= 7) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.group_id);
            } else {
                try types.encodeString(writer, self.group_id);
            }
        }

        // Field: Topics
        if (version >= 0 and version <= 7) {
            if (is_flexible) {
                try types.encodeCompactArrayLen(writer, self.topics);
                if (self.topics) |arr| {
                    for (arr) |*item| {
                        try OffsetFetchRequestTopic.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLen(writer, self.topics);
                if (self.topics) |arr| {
                    for (arr) |*item| {
                        try OffsetFetchRequestTopic.encode(item, writer, version);
                    }
                }
            }
        }

        // Field: Groups
        if (version >= 8 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.groups);
                if (self.groups) |arr| {
                    for (arr) |*item| {
                        try OffsetFetchRequestGroup.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.groups);
                if (self.groups) |arr| {
                    for (arr) |*item| {
                        try OffsetFetchRequestGroup.encode(item, writer, version);
                    }
                }
            }
        }

        // Field: RequireStable
        if (version >= 7 and version <= 32767) {
            try types.encodeBoolean(writer, self.require_stable);
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

    /// Compute the size of OffsetFetchRequest for the given version
    pub fn computeSize(self: *const Self, version: i16) !usize {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        var total_size: usize = 0;

        // Field: GroupId
        if (version >= 0 and version <= 7) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.group_id) else types.computeSizeString(self.group_id);
        }

        // Field: Topics
        if (version >= 0 and version <= 7) {
            if (self.topics) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try OffsetFetchRequestTopic.computeSize(item, version);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(0) else 4;
            }
        }

        // Field: Groups
        if (version >= 8 and version <= 32767) {
            if (self.groups) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try OffsetFetchRequestGroup.computeSize(item, version);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(1) else 4;
            }
        }

        // Field: RequireStable
        if (version >= 7 and version <= 32767) {
            total_size += types.computeSizeBoolean(self.require_stable);
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

    /// Decode OffsetFetchRequest
    pub fn decode(reader: anytype, version: i16, allocator: std.mem.Allocator) !Self {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        var self: Self = .{};

        // Field: GroupId
        if (version >= 0 and version <= 7) {
            self.group_id = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: Topics
        if (version >= 0 and version <= 7) {
            const raw_len: i32 = if (is_flexible) blk: {
                const v = try types.decodeUnsignedVarInt(reader);
                break :blk if (v == 0) @as(i32, -1) else @as(i32, @intCast(v - 1));
            } else try types.decodeInt32(reader);
            if (raw_len < 0) {
                self.topics = null;
            } else {
                const array_len: usize = @intCast(raw_len);
                const array = try allocator.alloc(OffsetFetchRequestTopic, array_len);
                for (array) |*item| {
                    item.* = try OffsetFetchRequestTopic.decode(reader, version, allocator);
                }
                self.topics = array;
            }
        }

        // Field: Groups
        if (version >= 8 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(OffsetFetchRequestGroup, array_len);
            for (array) |*item| {
                item.* = try OffsetFetchRequestGroup.decode(reader, version, allocator);
            }
            self.groups = array;
        }

        // Field: RequireStable
        if (version >= 7 and version <= 32767) {
            self.require_stable = try types.decodeBoolean(reader);
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
        const range = types.VersionRange.parse("1-10") catch return false;
        return range.contains(version);
    }
    /// Check if version uses flexible encoding
    pub fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("6+") catch return false;
        return range.contains(version);
    }
    /// Get the header version for this API version
    /// Returns 2 for flexible versions, 1 for classic versions
    pub fn headerVersion(api_version: i16) i16 {
        if (isFlexibleVersion(api_version)) return 2;
        return 1;
    }

};
