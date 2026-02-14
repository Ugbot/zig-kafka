//! Auto-generated Kafka protocol message
//! Message: ProduceRequest
//! API Key: 0
//! Type: request
//! Valid Versions: 3-13
//! Flexible Versions: 9+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// Nested struct: TopicProduceData
pub const TopicProduceData = struct {
    const Self = @This();

    /// The topic name.
    /// Versions: 0-12
    name: []const u8 = "",
    /// The unique topic ID
    /// Versions: 13+
    topic_id: [16]u8 = [_]u8{0} ** 16,
    /// Each partition to produce to.
    /// Versions: 0+
    partition_data: ?[]PartitionProduceData = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: Name
        if (version >= 0 and version <= 12) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.name);
            } else {
                try types.encodeString(writer, self.name);
            }
        }

        // Field: TopicId
        if (version >= 13 and version <= 32767) {
            try types.encodeUuid(writer, self.topic_id);
        }

        // Field: PartitionData
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLen(writer, self.partition_data);
                if (self.partition_data) |arr| {
                    for (arr) |*item| {
                        try PartitionProduceData.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLen(writer, self.partition_data);
                if (self.partition_data) |arr| {
                    for (arr) |*item| {
                        try PartitionProduceData.encode(item, writer, version);
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

        // Field: Name
        if (version >= 0 and version <= 12) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.name) else types.computeSizeString(self.name);
        }

        // Field: TopicId
        if (version >= 13 and version <= 32767) {
            total_size += types.computeSizeUuid(self.topic_id);
        }

        // Field: PartitionData
        if (version >= 0 and version <= 32767) {
            if (self.partition_data) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try PartitionProduceData.computeSize(item, version);
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
        // Field: Name
        if (version >= 0 and version <= 12) {
            self.name = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: TopicId
        if (version >= 13 and version <= 32767) {
            self.topic_id = try types.decodeUuid(reader);
        }

        // Field: PartitionData
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(PartitionProduceData, array_len);
            for (array) |*item| {
                item.* = try PartitionProduceData.decode(reader, version, allocator);
            }
            self.partition_data = array;
        }


        if (is_flexible) {
            const tagged_fields_data = try types.decodeTaggedFields(reader, allocator);
            self._tagged_fields = tagged_fields_data;
        }
        return self;
    }

    fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("9+") catch return false;
        return range.contains(version);
    }
};

/// Nested struct: PartitionProduceData
pub const PartitionProduceData = struct {
    const Self = @This();

    /// The partition index.
    /// Versions: 0+
    index: i32 = 0,
    /// The record data to be produced.
    /// Versions: 0+
    records: ?[]const u8 = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: Index
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.index);
        }

        // Field: Records
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactBytes(writer, self.records);
            } else {
                try types.encodeBytes(writer, self.records);
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

        // Field: Index
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.index);
        }

        // Field: Records
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactBytes(self.records) else types.computeSizeBytes(self.records);
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
        // Field: Index
        if (version >= 0 and version <= 32767) {
            self.index = try types.decodeInt32(reader);
        }

        // Field: Records
        if (version >= 0 and version <= 32767) {
            self.records = if (is_flexible)
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
        const range = types.VersionRange.parse("9+") catch return false;
        return range.contains(version);
    }
};

/// ProduceRequest
pub const ProduceRequest = struct {
    const Self = @This();

    /// The transactional ID, or null if the producer is not transactional.
    /// Versions: 3+
    transactional_id: ?[]const u8 = null,
    /// The number of acknowledgments the producer requires the leader to have received before considering a request complete. Allowed values: 0 for no acknowledgments, 1 for only the leader and -1 for the full ISR.
    acks: i16 = 0,
    /// The timeout to await a response in milliseconds.
    timeout_ms: i32 = 0,
    /// Each topic to produce to.
    topic_data: ?[]TopicProduceData = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 3, .max = 13 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 0;
    }

    /// Create a default instance of ProduceRequest
    pub fn default() Self {
        return .{
            .transactional_id = null,
            .acks = 0,
            .timeout_ms = 0,
            .topic_data = null,
            ._tagged_fields = null,
        };
    }

    /// Sets `transactional_id` to the passed value.
    /// The transactional ID, or null if the producer is not transactional.
    /// Versions: 3+
    pub fn withTransactionalId(self: Self, value: ?[]const u8) Self {
        var result = self;
        result.transactional_id = value;
        return result;
    }

    /// Sets `acks` to the passed value.
    /// The number of acknowledgments the producer requires the leader to have received before considering a request complete. Allowed values: 0 for no acknowledgments, 1 for only the leader and -1 for the full ISR.
    pub fn withAcks(self: Self, value: i16) Self {
        var result = self;
        result.acks = value;
        return result;
    }

    /// Sets `timeout_ms` to the passed value.
    /// The timeout to await a response in milliseconds.
    pub fn withTimeoutMs(self: Self, value: i32) Self {
        var result = self;
        result.timeout_ms = value;
        return result;
    }

    /// Sets `topic_data` to the passed value.
    /// Each topic to produce to.
    pub fn withTopicData(self: Self, value: ?[]TopicProduceData) Self {
        var result = self;
        result.topic_data = value;
        return result;
    }

    /// Encode ProduceRequest
    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: TransactionalId
        if (version >= 3 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.transactional_id);
            } else {
                try types.encodeString(writer, self.transactional_id);
            }
        }

        // Field: Acks
        if (version >= 0 and version <= 32767) {
            try types.encodeInt16(writer, self.acks);
        }

        // Field: TimeoutMs
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.timeout_ms);
        }

        // Field: TopicData
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLen(writer, self.topic_data);
                if (self.topic_data) |arr| {
                    for (arr) |*item| {
                        try TopicProduceData.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLen(writer, self.topic_data);
                if (self.topic_data) |arr| {
                    for (arr) |*item| {
                        try TopicProduceData.encode(item, writer, version);
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

    /// Compute the size of ProduceRequest for the given version
    pub fn computeSize(self: *const Self, version: i16) !usize {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        var total_size: usize = 0;

        // Field: TransactionalId
        if (version >= 3 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.transactional_id) else types.computeSizeString(self.transactional_id);
        }

        // Field: Acks
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt16(self.acks);
        }

        // Field: TimeoutMs
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.timeout_ms);
        }

        // Field: TopicData
        if (version >= 0 and version <= 32767) {
            if (self.topic_data) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try TopicProduceData.computeSize(item, version);
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

    /// Decode ProduceRequest
    pub fn decode(reader: anytype, version: i16, allocator: std.mem.Allocator) !Self {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        var self: Self = .{};

        // Field: TransactionalId
        if (version >= 3 and version <= 32767) {
            self.transactional_id = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: Acks
        if (version >= 0 and version <= 32767) {
            self.acks = try types.decodeInt16(reader);
        }

        // Field: TimeoutMs
        if (version >= 0 and version <= 32767) {
            self.timeout_ms = try types.decodeInt32(reader);
        }

        // Field: TopicData
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(TopicProduceData, array_len);
            for (array) |*item| {
                item.* = try TopicProduceData.decode(reader, version, allocator);
            }
            self.topic_data = array;
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
        const range = types.VersionRange.parse("3-13") catch return false;
        return range.contains(version);
    }
    /// Check if version uses flexible encoding
    pub fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("9+") catch return false;
        return range.contains(version);
    }
    /// Get the header version for this API version
    /// Returns 2 for flexible versions, 1 for classic versions
    pub fn headerVersion(api_version: i16) i16 {
        if (isFlexibleVersion(api_version)) return 2;
        return 1;
    }

};
