//! Auto-generated Kafka protocol message
//! Message: AlterPartitionRequest
//! API Key: 56
//! Type: request
//! Valid Versions: 2-3
//! Flexible Versions: 0+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// Nested struct: TopicData
pub const TopicData = struct {
    const Self = @This();

    /// The ID of the topic to alter ISRs for.
    /// Versions: 2+
    topic_id: [16]u8 = [_]u8{0} ** 16,
    /// The partitions to alter ISRs for.
    /// Versions: 0+
    partitions: ?[]PartitionData = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: TopicId
        if (version >= 2 and version <= 32767) {
            try types.encodeUuid(writer, self.topic_id);
        }

        // Field: Partitions
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.partitions);
                if (self.partitions) |arr| {
                    for (arr) |*item| {
                        try PartitionData.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.partitions);
                if (self.partitions) |arr| {
                    for (arr) |*item| {
                        try PartitionData.encode(item, writer, version);
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

        // Field: TopicId
        if (version >= 2 and version <= 32767) {
            total_size += types.computeSizeUuid(self.topic_id);
        }

        // Field: Partitions
        if (version >= 0 and version <= 32767) {
            if (self.partitions) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try PartitionData.computeSize(item, version);
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
        // Field: TopicId
        if (version >= 2 and version <= 32767) {
            self.topic_id = try types.decodeUuid(reader);
        }

        // Field: Partitions
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(PartitionData, array_len);
            for (array) |*item| {
                item.* = try PartitionData.decode(reader, version, allocator);
            }
            self.partitions = array;
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

/// Nested struct: PartitionData
pub const PartitionData = struct {
    const Self = @This();

    /// The partition index.
    /// Versions: 0+
    partition_index: i32 = 0,
    /// The leader epoch of this partition.
    /// Versions: 0+
    leader_epoch: i32 = 0,
    /// The ISR for this partition. Deprecated since version 3.
    /// Versions: 0-2
    new_isr: ?[]i32 = null,
    /// The ISR for this partition.
    /// Versions: 3+
    new_isr_with_epochs: ?[]BrokerState = null,
    /// 1 if the partition is recovering from an unclean leader election; 0 otherwise.
    /// Versions: 1+
    leader_recovery_state: i8 = 0,
    /// The expected epoch of the partition which is being updated.
    /// Versions: 0+
    partition_epoch: i32 = 0,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: PartitionIndex
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.partition_index);
        }

        // Field: LeaderEpoch
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.leader_epoch);
        }

        // Field: NewIsr
        if (version >= 0 and version <= 2) {
            if (is_flexible) {
                try types.encodeCompactArrayNonNull(i32, writer, self.new_isr, types.encodeInt32);
            } else {
                try types.encodeArrayNonNull(i32, writer, self.new_isr, types.encodeInt32);
            }
        }

        // Field: NewIsrWithEpochs
        if (version >= 3 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.new_isr_with_epochs);
                if (self.new_isr_with_epochs) |arr| {
                    for (arr) |*item| {
                        try BrokerState.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.new_isr_with_epochs);
                if (self.new_isr_with_epochs) |arr| {
                    for (arr) |*item| {
                        try BrokerState.encode(item, writer, version);
                    }
                }
            }
        }

        // Field: LeaderRecoveryState
        if (version >= 1 and version <= 32767) {
            try types.encodeInt8(writer, self.leader_recovery_state);
        }

        // Field: PartitionEpoch
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.partition_epoch);
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

        // Field: PartitionIndex
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.partition_index);
        }

        // Field: LeaderEpoch
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.leader_epoch);
        }

        // Field: NewIsr
        if (version >= 0 and version <= 2) {
            if (self.new_isr) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |item| {
                    total_size += types.computeSizeInt32(item);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(1) else 4;
            }
        }

        // Field: NewIsrWithEpochs
        if (version >= 3 and version <= 32767) {
            if (self.new_isr_with_epochs) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try BrokerState.computeSize(item, version);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(1) else 4;
            }
        }

        // Field: LeaderRecoveryState
        if (version >= 1 and version <= 32767) {
            total_size += types.computeSizeInt8(self.leader_recovery_state);
        }

        // Field: PartitionEpoch
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.partition_epoch);
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
        // Field: PartitionIndex
        if (version >= 0 and version <= 32767) {
            self.partition_index = try types.decodeInt32(reader);
        }

        // Field: LeaderEpoch
        if (version >= 0 and version <= 32767) {
            self.leader_epoch = try types.decodeInt32(reader);
        }

        // Field: NewIsr
        if (version >= 0 and version <= 2) {
            self.new_isr = if (is_flexible)
                try types.decodeCompactPrimitiveArray(i32, reader, allocator, types.decodeInt32)
            else
                try types.decodePrimitiveArray(i32, reader, allocator, types.decodeInt32);
        }

        // Field: NewIsrWithEpochs
        if (version >= 3 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(BrokerState, array_len);
            for (array) |*item| {
                item.* = try BrokerState.decode(reader, version, allocator);
            }
            self.new_isr_with_epochs = array;
        }

        // Field: LeaderRecoveryState
        if (version >= 1 and version <= 32767) {
            self.leader_recovery_state = try types.decodeInt8(reader);
        }

        // Field: PartitionEpoch
        if (version >= 0 and version <= 32767) {
            self.partition_epoch = try types.decodeInt32(reader);
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

/// Nested struct: BrokerState
pub const BrokerState = struct {
    const Self = @This();

    /// The ID of the broker.
    /// Versions: 3+
    broker_id: i32 = 0,
    /// The epoch of the broker. It will be -1 if the epoch check is not supported.
    /// Versions: 3+
    broker_epoch: i64 = -1,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: BrokerId
        if (version >= 3 and version <= 32767) {
            try types.encodeInt32(writer, self.broker_id);
        }

        // Field: BrokerEpoch
        if (version >= 3 and version <= 32767) {
            try types.encodeInt64(writer, self.broker_epoch);
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

        // Field: BrokerId
        if (version >= 3 and version <= 32767) {
            total_size += types.computeSizeInt32(self.broker_id);
        }

        // Field: BrokerEpoch
        if (version >= 3 and version <= 32767) {
            total_size += types.computeSizeInt64(self.broker_epoch);
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
        // Field: BrokerId
        if (version >= 3 and version <= 32767) {
            self.broker_id = try types.decodeInt32(reader);
        }

        // Field: BrokerEpoch
        if (version >= 3 and version <= 32767) {
            self.broker_epoch = try types.decodeInt64(reader);
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

/// AlterPartitionRequest
pub const AlterPartitionRequest = struct {
    const Self = @This();

    /// The ID of the requesting broker.
    broker_id: i32 = 0,
    /// The epoch of the requesting broker.
    broker_epoch: i64 = -1,
    /// The topics to alter ISRs for.
    topics: ?[]TopicData = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 2, .max = 3 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 56;
    }

    /// Create a default instance of AlterPartitionRequest
    pub fn default() Self {
        return .{
            .broker_id = 0,
            .broker_epoch = -1,
            .topics = null,
            ._tagged_fields = null,
        };
    }

    /// Sets `broker_id` to the passed value.
    /// The ID of the requesting broker.
    pub fn withBrokerId(self: Self, value: i32) Self {
        var result = self;
        result.broker_id = value;
        return result;
    }

    /// Sets `broker_epoch` to the passed value.
    /// The epoch of the requesting broker.
    pub fn withBrokerEpoch(self: Self, value: i64) Self {
        var result = self;
        result.broker_epoch = value;
        return result;
    }

    /// Sets `topics` to the passed value.
    /// The topics to alter ISRs for.
    pub fn withTopics(self: Self, value: ?[]TopicData) Self {
        var result = self;
        result.topics = value;
        return result;
    }

    /// Encode AlterPartitionRequest
    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: BrokerId
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.broker_id);
        }

        // Field: BrokerEpoch
        if (version >= 0 and version <= 32767) {
            try types.encodeInt64(writer, self.broker_epoch);
        }

        // Field: Topics
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.topics);
                if (self.topics) |arr| {
                    for (arr) |*item| {
                        try TopicData.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.topics);
                if (self.topics) |arr| {
                    for (arr) |*item| {
                        try TopicData.encode(item, writer, version);
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

    /// Compute the size of AlterPartitionRequest for the given version
    pub fn computeSize(self: *const Self, version: i16) !usize {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        var total_size: usize = 0;

        // Field: BrokerId
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.broker_id);
        }

        // Field: BrokerEpoch
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt64(self.broker_epoch);
        }

        // Field: Topics
        if (version >= 0 and version <= 32767) {
            if (self.topics) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try TopicData.computeSize(item, version);
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

    /// Decode AlterPartitionRequest
    pub fn decode(reader: anytype, version: i16, allocator: std.mem.Allocator) !Self {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        var self: Self = .{};

        // Field: BrokerId
        if (version >= 0 and version <= 32767) {
            self.broker_id = try types.decodeInt32(reader);
        }

        // Field: BrokerEpoch
        if (version >= 0 and version <= 32767) {
            self.broker_epoch = try types.decodeInt64(reader);
        }

        // Field: Topics
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(TopicData, array_len);
            for (array) |*item| {
                item.* = try TopicData.decode(reader, version, allocator);
            }
            self.topics = array;
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
        const range = types.VersionRange.parse("2-3") catch return false;
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
