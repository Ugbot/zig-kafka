//! Auto-generated Kafka protocol message
//! Message: ConsumerProtocolSubscription
//! Type: data
//! Valid Versions: 0-3
//! Flexible Versions: none
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// Nested struct: TopicPartition
pub const TopicPartition = struct {
    const Self = @This();

    /// The topic name.
    /// Versions: 1+
    topic: []const u8 = "",
    /// The partition ids.
    /// Versions: 1+
    partitions: ?[]i32 = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: Topic
        if (version >= 1 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.topic);
            } else {
                try types.encodeString(writer, self.topic);
            }
        }

        // Field: Partitions
        if (version >= 1 and version <= 32767) {
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
        if (version >= 1 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.topic) else types.computeSizeString(self.topic);
        }

        // Field: Partitions
        if (version >= 1 and version <= 32767) {
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
        if (version >= 1 and version <= 32767) {
            self.topic = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: Partitions
        if (version >= 1 and version <= 32767) {
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
        const range = types.VersionRange.parse("none") catch return false;
        return range.contains(version);
    }
};

/// ConsumerProtocolSubscription
pub const ConsumerProtocolSubscription = struct {
    const Self = @This();

    /// The topics that the member wants to consume.
    topics: ?[][]const u8 = null,
    /// User data that will be passed back to the consumer.
    user_data: ?[]const u8 = null,
    /// The partitions that the member owns.
    /// Versions: 1+
    owned_partitions: ?[]TopicPartition = null,
    /// The generation id of the member.
    /// Versions: 2+
    generation_id: i32 = -1,
    /// The rack id of the member.
    /// Versions: 3+
    rack_id: ?[]const u8 = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 0, .max = 3 };

    /// Create a default instance of ConsumerProtocolSubscription
    pub fn default() Self {
        return .{
            .topics = null,
            .user_data = null,
            .owned_partitions = null,
            .generation_id = -1,
            .rack_id = null,
            ._tagged_fields = null,
        };
    }

    /// Sets `topics` to the passed value.
    /// The topics that the member wants to consume.
    pub fn withTopics(self: Self, value: ?[][]const u8) Self {
        var result = self;
        result.topics = value;
        return result;
    }

    /// Sets `user_data` to the passed value.
    /// User data that will be passed back to the consumer.
    pub fn withUserData(self: Self, value: ?[]const u8) Self {
        var result = self;
        result.user_data = value;
        return result;
    }

    /// Sets `owned_partitions` to the passed value.
    /// The partitions that the member owns.
    /// Versions: 1+
    pub fn withOwnedPartitions(self: Self, value: ?[]TopicPartition) Self {
        var result = self;
        result.owned_partitions = value;
        return result;
    }

    /// Sets `generation_id` to the passed value.
    /// The generation id of the member.
    /// Versions: 2+
    pub fn withGenerationId(self: Self, value: i32) Self {
        var result = self;
        result.generation_id = value;
        return result;
    }

    /// Sets `rack_id` to the passed value.
    /// The rack id of the member.
    /// Versions: 3+
    pub fn withRackId(self: Self, value: ?[]const u8) Self {
        var result = self;
        result.rack_id = value;
        return result;
    }

    /// Encode ConsumerProtocolSubscription
    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: Topics
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayNonNull([]const u8, writer, self.topics, types.encodeCompactString);
            } else {
                try types.encodeArrayNonNull([]const u8, writer, self.topics, types.encodeCompactString);
            }
        }

        // Field: UserData
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactBytes(writer, self.user_data);
            } else {
                try types.encodeBytes(writer, self.user_data);
            }
        }

        // Field: OwnedPartitions
        if (version >= 1 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.owned_partitions);
                if (self.owned_partitions) |arr| {
                    for (arr) |*item| {
                        try TopicPartition.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.owned_partitions);
                if (self.owned_partitions) |arr| {
                    for (arr) |*item| {
                        try TopicPartition.encode(item, writer, version);
                    }
                }
            }
        }

        // Field: GenerationId
        if (version >= 2 and version <= 32767) {
            try types.encodeInt32(writer, self.generation_id);
        }

        // Field: RackId
        if (version >= 3 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.rack_id);
            } else {
                try types.encodeString(writer, self.rack_id);
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

    /// Compute the size of ConsumerProtocolSubscription for the given version
    pub fn computeSize(self: *const Self, version: i16) !usize {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        var total_size: usize = 0;

        // Field: Topics
        if (version >= 0 and version <= 32767) {
            if (self.topics) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |item| {
                    total_size += types.computeSizeCompactString(item);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(1) else 4;
            }
        }

        // Field: UserData
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactBytes(self.user_data) else types.computeSizeBytes(self.user_data);
        }

        // Field: OwnedPartitions
        if (version >= 1 and version <= 32767) {
            if (self.owned_partitions) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try TopicPartition.computeSize(item, version);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(1) else 4;
            }
        }

        // Field: GenerationId
        if (version >= 2 and version <= 32767) {
            total_size += types.computeSizeInt32(self.generation_id);
        }

        // Field: RackId
        if (version >= 3 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.rack_id) else types.computeSizeString(self.rack_id);
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

    /// Decode ConsumerProtocolSubscription
    pub fn decode(reader: anytype, version: i16, allocator: std.mem.Allocator) !Self {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        var self: Self = .{};

        // Field: Topics
        if (version >= 0 and version <= 32767) {
            self.topics = if (is_flexible)
                try types.decodeCompactArray([]const u8, reader, allocator, types.decodeNonNullableCompactString)
            else
                try types.decodeArray([]const u8, reader, allocator, types.decodeNonNullableString);
        }

        // Field: UserData
        if (version >= 0 and version <= 32767) {
            self.user_data = if (is_flexible)
                try types.decodeCompactBytes(reader, allocator)
            else
                try types.decodeBytes(reader, allocator);
        }

        // Field: OwnedPartitions
        if (version >= 1 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(TopicPartition, array_len);
            for (array) |*item| {
                item.* = try TopicPartition.decode(reader, version, allocator);
            }
            self.owned_partitions = array;
        }

        // Field: GenerationId
        if (version >= 2 and version <= 32767) {
            self.generation_id = try types.decodeInt32(reader);
        }

        // Field: RackId
        if (version >= 3 and version <= 32767) {
            self.rack_id = if (is_flexible)
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
        const range = types.VersionRange.parse("0-3") catch return false;
        return range.contains(version);
    }
    /// Check if version uses flexible encoding
    pub fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("none") catch return false;
        return range.contains(version);
    }
    /// Get the header version for this API version
    /// Returns 2 for flexible versions, 1 for classic versions
    pub fn headerVersion(api_version: i16) i16 {
        if (isFlexibleVersion(api_version)) return 2;
        return 1;
    }

};
