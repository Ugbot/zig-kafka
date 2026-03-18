//! Auto-generated Kafka protocol message
//! Message: ElectLeadersRequest
//! API Key: 43
//! Type: request
//! Valid Versions: 0-2
//! Flexible Versions: 2+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// Nested struct: TopicPartitions
pub const TopicPartitions = struct {
    const Self = @This();

    /// The name of a topic.
    /// Versions: 0+
    topic: []const u8 = "",
    /// The partitions of this topic whose leader should be elected.
    /// Versions: 0+
    partitions: ?[]i32 = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: Topic
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.topic);
            } else {
                try types.encodeString(writer, self.topic);
            }
        }

        // Field: Partitions
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayNonNull(i32, writer, self.partitions, types.encodeInt32);
            } else {
                try types.encodeArrayNonNull(i32, writer, self.partitions, types.encodeInt32);
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
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.topic) else types.computeSizeString(self.topic);
        }

        // Field: Partitions
        if (version >= 0 and version <= 32767) {
            if (self.partitions) |arr| {
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
        // Field: Topic
        if (version >= 0 and version <= 32767) {
            self.topic = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: Partitions
        if (version >= 0 and version <= 32767) {
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
        const range = types.VersionRange.parse("2+") catch return false;
        return range.contains(version);
    }
};

/// ElectLeadersRequest
pub const ElectLeadersRequest = struct {
    const Self = @This();

    /// Type of elections to conduct for the partition. A value of '0' elects the preferred replica. A value of '1' elects the first live replica if there are no in-sync replica.
    /// Versions: 1+
    election_type: i8 = 0,
    /// The topic partitions to elect leaders.
    topic_partitions: ?[]TopicPartitions = null,
    /// The time in ms to wait for the election to complete.
    timeout_ms: i32 = 60000,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 0, .max = 2 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 43;
    }

    /// Create a default instance of ElectLeadersRequest
    pub fn default() Self {
        return .{
            .election_type = 0,
            .topic_partitions = null,
            .timeout_ms = 60000,
            ._tagged_fields = null,
        };
    }

    /// Sets `election_type` to the passed value.
    /// Type of elections to conduct for the partition. A value of '0' elects the preferred replica. A value of '1' elects the first live replica if there are no in-sync replica.
    /// Versions: 1+
    pub fn withElectionType(self: Self, value: i8) Self {
        var result = self;
        result.election_type = value;
        return result;
    }

    /// Sets `topic_partitions` to the passed value.
    /// The topic partitions to elect leaders.
    pub fn withTopicPartitions(self: Self, value: ?[]TopicPartitions) Self {
        var result = self;
        result.topic_partitions = value;
        return result;
    }

    /// Sets `timeout_ms` to the passed value.
    /// The time in ms to wait for the election to complete.
    pub fn withTimeoutMs(self: Self, value: i32) Self {
        var result = self;
        result.timeout_ms = value;
        return result;
    }

    /// Encode ElectLeadersRequest
    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: ElectionType
        if (version >= 1 and version <= 32767) {
            try types.encodeInt8(writer, self.election_type);
        }

        // Field: TopicPartitions
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLen(writer, self.topic_partitions);
                if (self.topic_partitions) |arr| {
                    for (arr) |*item| {
                        try TopicPartitions.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLen(writer, self.topic_partitions);
                if (self.topic_partitions) |arr| {
                    for (arr) |*item| {
                        try TopicPartitions.encode(item, writer, version);
                    }
                }
            }
        }

        // Field: TimeoutMs
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.timeout_ms);
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

    /// Compute the size of ElectLeadersRequest for the given version
    pub fn computeSize(self: *const Self, version: i16) !usize {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        var total_size: usize = 0;

        // Field: ElectionType
        if (version >= 1 and version <= 32767) {
            total_size += types.computeSizeInt8(self.election_type);
        }

        // Field: TopicPartitions
        if (version >= 0 and version <= 32767) {
            if (self.topic_partitions) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try TopicPartitions.computeSize(item, version);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(0) else 4;
            }
        }

        // Field: TimeoutMs
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.timeout_ms);
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

    /// Decode ElectLeadersRequest
    pub fn decode(reader: anytype, version: i16, allocator: std.mem.Allocator) !Self {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        var self: Self = .{};

        // Field: ElectionType
        if (version >= 1 and version <= 32767) {
            self.election_type = try types.decodeInt8(reader);
        }

        // Field: TopicPartitions
        if (version >= 0 and version <= 32767) {
            const raw_len: i32 = if (is_flexible) blk: {
                const v = try types.decodeUnsignedVarInt(reader);
                break :blk if (v == 0) @as(i32, -1) else @as(i32, @intCast(v - 1));
            } else try types.decodeInt32(reader);
            if (raw_len < 0) {
                self.topic_partitions = null;
            } else {
                const array_len: usize = @intCast(raw_len);
                const array = try allocator.alloc(TopicPartitions, array_len);
                for (array) |*item| {
                    item.* = try TopicPartitions.decode(reader, version, allocator);
                }
                self.topic_partitions = array;
            }
        }

        // Field: TimeoutMs
        if (version >= 0 and version <= 32767) {
            self.timeout_ms = try types.decodeInt32(reader);
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
        const range = types.VersionRange.parse("0-2") catch return false;
        return range.contains(version);
    }
    /// Check if version uses flexible encoding
    pub fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("2+") catch return false;
        return range.contains(version);
    }
    /// Get the header version for this API version
    /// Returns 2 for flexible versions, 1 for classic versions
    pub fn headerVersion(api_version: i16) i16 {
        if (isFlexibleVersion(api_version)) return 2;
        return 1;
    }

};
