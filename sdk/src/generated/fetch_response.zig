//! Auto-generated Kafka protocol message
//! Message: FetchResponse
//! API Key: 1
//! Type: response
//! Valid Versions: 4-18
//! Flexible Versions: 12+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// Nested struct: NodeEndpoint
pub const NodeEndpoint = struct {
    const Self = @This();

    /// The ID of the associated node.
    /// Versions: 16+
    node_id: i32 = 0,
    /// The node's hostname.
    /// Versions: 16+
    host: []const u8 = "",
    /// The node's port.
    /// Versions: 16+
    port: i32 = 0,
    /// The rack of the node, or null if it has not been assigned to a rack.
    /// Versions: 16+
    rack: ?[]const u8 = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: NodeId
        if (version >= 16 and version <= 32767) {
            try types.encodeInt32(writer, self.node_id);
        }

        // Field: Host
        if (version >= 16 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.host);
            } else {
                try types.encodeString(writer, self.host);
            }
        }

        // Field: Port
        if (version >= 16 and version <= 32767) {
            try types.encodeInt32(writer, self.port);
        }

        // Field: Rack
        if (version >= 16 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.rack);
            } else {
                try types.encodeString(writer, self.rack);
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

        // Field: NodeId
        if (version >= 16 and version <= 32767) {
            total_size += types.computeSizeInt32(self.node_id);
        }

        // Field: Host
        if (version >= 16 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.host) else types.computeSizeString(self.host);
        }

        // Field: Port
        if (version >= 16 and version <= 32767) {
            total_size += types.computeSizeInt32(self.port);
        }

        // Field: Rack
        if (version >= 16 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.rack) else types.computeSizeString(self.rack);
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
        // Field: NodeId
        if (version >= 16 and version <= 32767) {
            self.node_id = try types.decodeInt32(reader);
        }

        // Field: Host
        if (version >= 16 and version <= 32767) {
            self.host = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: Port
        if (version >= 16 and version <= 32767) {
            self.port = try types.decodeInt32(reader);
        }

        // Field: Rack
        if (version >= 16 and version <= 32767) {
            self.rack = if (is_flexible)
                try types.decodeCompactString(reader, allocator)
            else
                try types.decodeString(reader, allocator);
        }


        if (is_flexible) {
            const tagged_fields_data = try types.decodeTaggedFields(reader, allocator);
            self._tagged_fields = tagged_fields_data;
        }
        return self;
    }

    fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("12+") catch return false;
        return range.contains(version);
    }
};

/// Nested struct: FetchableTopicResponse
pub const FetchableTopicResponse = struct {
    const Self = @This();

    /// The topic name.
    /// Versions: 0-12
    topic: []const u8 = "",
    /// The unique topic ID.
    /// Versions: 13+
    topic_id: [16]u8 = [_]u8{0} ** 16,
    /// The topic partitions.
    /// Versions: 0+
    partitions: ?[]PartitionData = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: Topic
        if (version >= 0 and version <= 12) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.topic);
            } else {
                try types.encodeString(writer, self.topic);
            }
        }

        // Field: TopicId
        if (version >= 13 and version <= 32767) {
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

        // Field: Topic
        if (version >= 0 and version <= 12) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.topic) else types.computeSizeString(self.topic);
        }

        // Field: TopicId
        if (version >= 13 and version <= 32767) {
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
        // Field: Topic
        if (version >= 0 and version <= 12) {
            self.topic = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: TopicId
        if (version >= 13 and version <= 32767) {
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
        const range = types.VersionRange.parse("12+") catch return false;
        return range.contains(version);
    }
};

/// Nested struct: PartitionData
pub const PartitionData = struct {
    const Self = @This();

    /// The partition index.
    /// Versions: 0+
    partition_index: i32 = 0,
    /// The error code, or 0 if there was no fetch error.
    /// Versions: 0+
    error_code: i16 = 0,
    /// The current high water mark.
    /// Versions: 0+
    high_watermark: i64 = 0,
    /// The last stable offset (or LSO) of the partition. This is the last offset such that the state of all transactional records prior to this offset have been decided (ABORTED or COMMITTED).
    /// Versions: 4+
    last_stable_offset: i64 = -1,
    /// The current log start offset.
    /// Versions: 5+
    log_start_offset: i64 = -1,
    /// The aborted transactions.
    /// Versions: 4+
    aborted_transactions: ?[]AbortedTransaction = null,
    /// The preferred read replica for the consumer to use on its next fetch request.
    /// Versions: 11+
    preferred_read_replica: i32 = -1,
    /// The record data.
    /// Versions: 0+
    records: ?[]const u8 = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: PartitionIndex
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.partition_index);
        }

        // Field: ErrorCode
        if (version >= 0 and version <= 32767) {
            try types.encodeInt16(writer, self.error_code);
        }

        // Field: HighWatermark
        if (version >= 0 and version <= 32767) {
            try types.encodeInt64(writer, self.high_watermark);
        }

        // Field: LastStableOffset
        if (version >= 4 and version <= 32767) {
            try types.encodeInt64(writer, self.last_stable_offset);
        }

        // Field: LogStartOffset
        if (version >= 5 and version <= 32767) {
            try types.encodeInt64(writer, self.log_start_offset);
        }

        // Field: AbortedTransactions
        if (version >= 4 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLen(writer, self.aborted_transactions);
                if (self.aborted_transactions) |arr| {
                    for (arr) |*item| {
                        try AbortedTransaction.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLen(writer, self.aborted_transactions);
                if (self.aborted_transactions) |arr| {
                    for (arr) |*item| {
                        try AbortedTransaction.encode(item, writer, version);
                    }
                }
            }
        }

        // Field: PreferredReadReplica
        if (version >= 11 and version <= 32767) {
            try types.encodeInt32(writer, self.preferred_read_replica);
        }

        // Field: Records
        if (version >= 0 and version <= 32767) {
            // BUGFIX: Use compact encoding for flexible versions (v12+)
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

        // Field: PartitionIndex
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.partition_index);
        }

        // Field: ErrorCode
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt16(self.error_code);
        }

        // Field: HighWatermark
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt64(self.high_watermark);
        }

        // Field: LastStableOffset
        if (version >= 4 and version <= 32767) {
            total_size += types.computeSizeInt64(self.last_stable_offset);
        }

        // Field: LogStartOffset
        if (version >= 5 and version <= 32767) {
            total_size += types.computeSizeInt64(self.log_start_offset);
        }

        // Field: AbortedTransactions
        if (version >= 4 and version <= 32767) {
            if (self.aborted_transactions) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try AbortedTransaction.computeSize(item, version);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(0) else 4;
            }
        }

        // Field: PreferredReadReplica
        if (version >= 11 and version <= 32767) {
            total_size += types.computeSizeInt32(self.preferred_read_replica);
        }

        // Field: Records
        if (version >= 0 and version <= 32767) {
            // BUGFIX: Use compact encoding for flexible versions (v12+)
            if (is_flexible) {
                total_size += types.computeSizeCompactBytes(self.records);
            } else {
                total_size += types.computeSizeBytes(self.records);
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
        // Field: PartitionIndex
        if (version >= 0 and version <= 32767) {
            self.partition_index = try types.decodeInt32(reader);
        }

        // Field: ErrorCode
        if (version >= 0 and version <= 32767) {
            self.error_code = try types.decodeInt16(reader);
        }

        // Field: HighWatermark
        if (version >= 0 and version <= 32767) {
            self.high_watermark = try types.decodeInt64(reader);
        }

        // Field: LastStableOffset
        if (version >= 4 and version <= 32767) {
            self.last_stable_offset = try types.decodeInt64(reader);
        }

        // Field: LogStartOffset
        if (version >= 5 and version <= 32767) {
            self.log_start_offset = try types.decodeInt64(reader);
        }

        // Field: AbortedTransactions
        if (version >= 4 and version <= 32767) {
            const raw_len: i32 = if (is_flexible) blk: {
                const v = try types.decodeUnsignedVarInt(reader);
                break :blk if (v == 0) @as(i32, -1) else @as(i32, @intCast(v - 1));
            } else try types.decodeInt32(reader);
            if (raw_len < 0) {
                self.aborted_transactions = null;
            } else {
                const array_len: usize = @intCast(raw_len);
                const array = try allocator.alloc(AbortedTransaction, array_len);
                for (array) |*item| {
                    item.* = try AbortedTransaction.decode(reader, version, allocator);
                }
                self.aborted_transactions = array;
            }
        }

        // Field: PreferredReadReplica
        if (version >= 11 and version <= 32767) {
            self.preferred_read_replica = try types.decodeInt32(reader);
        }

        // Field: Records
        if (version >= 0 and version <= 32767) {
            // BUGFIX: Use compact encoding for flexible versions (v12+)
            // See: https://github.com/apache/kafka/blob/trunk/clients/src/main/resources/common/message/FetchResponse.json
            // Records field should use compact bytes in flexible versions
            if (is_flexible) {
                self.records = try types.decodeCompactBytes(reader, allocator);
            } else {
                self.records = try types.decodeBytes(reader, allocator);
            }
        }


        if (is_flexible) {
            const tagged_fields_data = try types.decodeTaggedFields(reader, allocator);
            self._tagged_fields = tagged_fields_data;
        }
        return self;
    }

    fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("12+") catch return false;
        return range.contains(version);
    }
};

/// Nested struct: AbortedTransaction
pub const AbortedTransaction = struct {
    const Self = @This();

    /// The producer id associated with the aborted transaction.
    /// Versions: 4+
    producer_id: i64 = 0,
    /// The first offset in the aborted transaction.
    /// Versions: 4+
    first_offset: i64 = 0,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: ProducerId
        if (version >= 4 and version <= 32767) {
            try types.encodeInt64(writer, self.producer_id);
        }

        // Field: FirstOffset
        if (version >= 4 and version <= 32767) {
            try types.encodeInt64(writer, self.first_offset);
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

        // Field: ProducerId
        if (version >= 4 and version <= 32767) {
            total_size += types.computeSizeInt64(self.producer_id);
        }

        // Field: FirstOffset
        if (version >= 4 and version <= 32767) {
            total_size += types.computeSizeInt64(self.first_offset);
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
        // Field: ProducerId
        if (version >= 4 and version <= 32767) {
            self.producer_id = try types.decodeInt64(reader);
        }

        // Field: FirstOffset
        if (version >= 4 and version <= 32767) {
            self.first_offset = try types.decodeInt64(reader);
        }


        if (is_flexible) {
            const tagged_fields_data = try types.decodeTaggedFields(reader, allocator);
            self._tagged_fields = tagged_fields_data;
        }
        return self;
    }

    fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("12+") catch return false;
        return range.contains(version);
    }
};

/// Nested struct: SnapshotId
pub const SnapshotId = struct {
    const Self = @This();

    /// The end offset of the epoch.
    /// Versions: 0+
    end_offset: i64 = -1,
    /// The largest epoch.
    /// Versions: 0+
    epoch: i32 = -1,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: EndOffset
        if (version >= 0 and version <= 32767) {
            try types.encodeInt64(writer, self.end_offset);
        }

        // Field: Epoch
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.epoch);
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

        // Field: EndOffset
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt64(self.end_offset);
        }

        // Field: Epoch
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.epoch);
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
        // Field: EndOffset
        if (version >= 0 and version <= 32767) {
            self.end_offset = try types.decodeInt64(reader);
        }

        // Field: Epoch
        if (version >= 0 and version <= 32767) {
            self.epoch = try types.decodeInt32(reader);
        }


        if (is_flexible) {
            const tagged_fields_data = try types.decodeTaggedFields(reader, allocator);
            self._tagged_fields = tagged_fields_data;
        }
        return self;
    }

    fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("12+") catch return false;
        return range.contains(version);
    }
};

/// Nested struct: LeaderIdAndEpoch
pub const LeaderIdAndEpoch = struct {
    const Self = @This();

    /// The ID of the current leader or -1 if the leader is unknown.
    /// Versions: 12+
    leader_id: i32 = -1,
    /// The latest known leader epoch.
    /// Versions: 12+
    leader_epoch: i32 = -1,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: LeaderId
        if (version >= 12 and version <= 32767) {
            try types.encodeInt32(writer, self.leader_id);
        }

        // Field: LeaderEpoch
        if (version >= 12 and version <= 32767) {
            try types.encodeInt32(writer, self.leader_epoch);
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

        // Field: LeaderId
        if (version >= 12 and version <= 32767) {
            total_size += types.computeSizeInt32(self.leader_id);
        }

        // Field: LeaderEpoch
        if (version >= 12 and version <= 32767) {
            total_size += types.computeSizeInt32(self.leader_epoch);
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
        // Field: LeaderId
        if (version >= 12 and version <= 32767) {
            self.leader_id = try types.decodeInt32(reader);
        }

        // Field: LeaderEpoch
        if (version >= 12 and version <= 32767) {
            self.leader_epoch = try types.decodeInt32(reader);
        }


        if (is_flexible) {
            const tagged_fields_data = try types.decodeTaggedFields(reader, allocator);
            self._tagged_fields = tagged_fields_data;
        }
        return self;
    }

    fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("12+") catch return false;
        return range.contains(version);
    }
};

/// Nested struct: EpochEndOffset
pub const EpochEndOffset = struct {
    const Self = @This();

    /// The largest epoch.
    /// Versions: 12+
    epoch: i32 = -1,
    /// The end offset of the epoch.
    /// Versions: 12+
    end_offset: i64 = -1,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: Epoch
        if (version >= 12 and version <= 32767) {
            try types.encodeInt32(writer, self.epoch);
        }

        // Field: EndOffset
        if (version >= 12 and version <= 32767) {
            try types.encodeInt64(writer, self.end_offset);
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
        if (version >= 12 and version <= 32767) {
            total_size += types.computeSizeInt32(self.epoch);
        }

        // Field: EndOffset
        if (version >= 12 and version <= 32767) {
            total_size += types.computeSizeInt64(self.end_offset);
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
        if (version >= 12 and version <= 32767) {
            self.epoch = try types.decodeInt32(reader);
        }

        // Field: EndOffset
        if (version >= 12 and version <= 32767) {
            self.end_offset = try types.decodeInt64(reader);
        }


        if (is_flexible) {
            const tagged_fields_data = try types.decodeTaggedFields(reader, allocator);
            self._tagged_fields = tagged_fields_data;
        }
        return self;
    }

    fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("12+") catch return false;
        return range.contains(version);
    }
};

/// FetchResponse
pub const FetchResponse = struct {
    const Self = @This();

    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    /// Versions: 1+
    throttle_time_ms: i32 = 0,
    /// The top level response error code.
    /// Versions: 7+
    error_code: i16 = 0,
    /// The fetch session ID, or 0 if this is not part of a fetch session.
    /// Versions: 7+
    session_id: i32 = 0,
    /// The response topics.
    responses: ?[]FetchableTopicResponse = null,
    /// Endpoints for all current-leaders enumerated in PartitionData, with errors NOT_LEADER_OR_FOLLOWER & FENCED_LEADER_EPOCH.
    /// Versions: 16+
    node_endpoints: ?[]NodeEndpoint = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 4, .max = 18 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 1;
    }

    /// Create a default instance of FetchResponse
    pub fn default() Self {
        return .{
            .throttle_time_ms = 0,
            .error_code = 0,
            .session_id = 0,
            .responses = null,
            .node_endpoints = null,
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

    /// Sets `error_code` to the passed value.
    /// The top level response error code.
    /// Versions: 7+
    pub fn withErrorCode(self: Self, value: i16) Self {
        var result = self;
        result.error_code = value;
        return result;
    }

    /// Sets `session_id` to the passed value.
    /// The fetch session ID, or 0 if this is not part of a fetch session.
    /// Versions: 7+
    pub fn withSessionId(self: Self, value: i32) Self {
        var result = self;
        result.session_id = value;
        return result;
    }

    /// Sets `responses` to the passed value.
    /// The response topics.
    pub fn withResponses(self: Self, value: ?[]FetchableTopicResponse) Self {
        var result = self;
        result.responses = value;
        return result;
    }

    /// Sets `node_endpoints` to the passed value.
    /// Endpoints for all current-leaders enumerated in PartitionData, with errors NOT_LEADER_OR_FOLLOWER & FENCED_LEADER_EPOCH.
    /// Versions: 16+
    pub fn withNodeEndpoints(self: Self, value: ?[]NodeEndpoint) Self {
        var result = self;
        result.node_endpoints = value;
        return result;
    }

    /// Encode FetchResponse
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

        // Field: ErrorCode
        if (version >= 7 and version <= 32767) {
            try types.encodeInt16(writer, self.error_code);
        }

        // Field: SessionId
        if (version >= 7 and version <= 32767) {
            try types.encodeInt32(writer, self.session_id);
        }

        // Field: Responses
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.responses);
                if (self.responses) |arr| {
                    for (arr) |*item| {
                        try FetchableTopicResponse.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.responses);
                if (self.responses) |arr| {
                    for (arr) |*item| {
                        try FetchableTopicResponse.encode(item, writer, version);
                    }
                }
            }
        }


        if (is_flexible) {
            var num_tagged_fields: u32 = 0;
            if (version >= 16 and version <= 32767) {
                if (self.node_endpoints != null) num_tagged_fields += 1;
            }

            // Count unknown tagged fields
            if (self._tagged_fields) |fields| {
                num_tagged_fields += @intCast(fields.len);
            }

            try types.encodeUnsignedVarInt(writer, num_tagged_fields);

            // Tagged field: NodeEndpoints (tag 0)
            if (version >= 16 and version <= 32767) {
                if (self.node_endpoints) |val| {
                    try types.encodeUnsignedVarInt(writer, 0);
                    // Compute size of array
                    var array_size: usize = types.computeSizeUnsignedVarInt(@intCast(val.len + 1));
                    for (val) |*item| {
                        array_size += try NodeEndpoint.computeSize(item, version);
                    }
                    try types.encodeUnsignedVarInt(writer, @intCast(array_size));
                    try types.encodeUnsignedVarInt(writer, @intCast(val.len + 1));
                    for (val) |*item| {
                        try NodeEndpoint.encode(item, writer, version);
                    }
                }
            }

            // Encode unknown tagged fields
            if (self._tagged_fields) |fields| {
                try types.encodeTaggedFields(writer, fields);
            }
        }
    }

    /// Compute the size of FetchResponse for the given version
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

        // Field: ErrorCode
        if (version >= 7 and version <= 32767) {
            total_size += types.computeSizeInt16(self.error_code);
        }

        // Field: SessionId
        if (version >= 7 and version <= 32767) {
            total_size += types.computeSizeInt32(self.session_id);
        }

        // Field: Responses
        if (version >= 0 and version <= 32767) {
            if (self.responses) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try FetchableTopicResponse.computeSize(item, version);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(1) else 4;
            }
        }

        if (is_flexible) {
            var num_tagged_fields: u32 = 0;
            if (version >= 16 and version <= 32767) {
                if (self.node_endpoints != null) num_tagged_fields += 1;
            }

            if (self._tagged_fields) |fields| {
                num_tagged_fields += @intCast(fields.len);
            }

            total_size += types.computeSizeUnsignedVarInt(num_tagged_fields);

            // Tagged field: NodeEndpoints (tag 0)
            if (version >= 16 and version <= 32767) {
                if (self.node_endpoints) |val| {
                    total_size += types.computeSizeUnsignedVarInt(0);
                    var array_size: usize = types.computeSizeUnsignedVarInt(@intCast(val.len + 1));
                    for (val) |*item| {
                        array_size += try NodeEndpoint.computeSize(item, version);
                    }
                    total_size += types.computeSizeUnsignedVarInt(@intCast(array_size));
                    total_size += array_size;
                }
            }

            if (self._tagged_fields) |fields| {
                total_size += types.computeSizeTaggedFields(fields);
            }
        }

        return total_size;
    }

    /// Decode FetchResponse
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

        // Field: ErrorCode
        if (version >= 7 and version <= 32767) {
            self.error_code = try types.decodeInt16(reader);
        }

        // Field: SessionId
        if (version >= 7 and version <= 32767) {
            self.session_id = try types.decodeInt32(reader);
        }

        // Field: Responses
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(FetchableTopicResponse, array_len);
            for (array) |*item| {
                item.* = try FetchableTopicResponse.decode(reader, version, allocator);
            }
            self.responses = array;
        }


        if (is_flexible) {
            const num_tagged_fields = try types.decodeUnsignedVarInt(reader);
            var unknown_tagged_fields = std.array_list.Managed(types.TaggedField).init(allocator);

            var i: u32 = 0;
            while (i < num_tagged_fields) : (i += 1) {
                const tag = try types.decodeUnsignedVarInt(reader);
                const size = try types.decodeUnsignedVarInt(reader);
                switch (tag) {
                    0 => { // NodeEndpoints
                        if (version >= 16 and version <= 32767) {
                            const array_len = try types.decodeCompactArrayLen(reader);
                            const array = try allocator.alloc(NodeEndpoint, array_len);
                            for (array) |*item| {
                                item.* = try NodeEndpoint.decode(reader, version, allocator);
                            }
                            self.node_endpoints = array;
                        } else {
                            try reader.skipBytes(size, .{});
                        }
                    },
                    else => {
                        const field_data = try allocator.alloc(u8, size);
                        _ = try reader.readAll(field_data);
                        try unknown_tagged_fields.append(.{ .tag = tag, .data = field_data });
                    },
                }
            }

            if (unknown_tagged_fields.items.len > 0) {
                self._tagged_fields = try unknown_tagged_fields.toOwnedSlice();
            }
        }

        return self;
    }

    /// Check if version is valid
    pub fn isValidVersion(version: i16) bool {
        const range = types.VersionRange.parse("4-18") catch return false;
        return range.contains(version);
    }
    /// Check if version uses flexible encoding
    pub fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("12+") catch return false;
        return range.contains(version);
    }
    /// Get the header version for this API version
    /// Returns 2 for flexible versions, 1 for classic versions
    pub fn headerVersion(api_version: i16) i16 {
        if (isFlexibleVersion(api_version)) return 2;
        return 1;
    }

};
