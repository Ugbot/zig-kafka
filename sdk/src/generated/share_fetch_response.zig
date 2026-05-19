//! Auto-generated Kafka protocol message
//! Message: ShareFetchResponse
//! API Key: 78
//! Type: response
//! Valid Versions: 1
//! Flexible Versions: 0+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// Nested struct: NodeEndpoint
pub const NodeEndpoint = struct {
    const Self = @This();

    /// The ID of the associated node.
    /// Versions: 0+
    node_id: i32 = 0,
    /// The node's hostname.
    /// Versions: 0+
    host: []const u8 = "",
    /// The node's port.
    /// Versions: 0+
    port: i32 = 0,
    /// The rack of the node, or null if it has not been assigned to a rack.
    /// Versions: 0+
    rack: ?[]const u8 = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: NodeId
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.node_id);
        }

        // Field: Host
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.host);
            } else {
                try types.encodeString(writer, self.host);
            }
        }

        // Field: Port
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.port);
        }

        // Field: Rack
        if (version >= 0 and version <= 32767) {
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
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.node_id);
        }

        // Field: Host
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.host) else types.computeSizeString(self.host);
        }

        // Field: Port
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.port);
        }

        // Field: Rack
        if (version >= 0 and version <= 32767) {
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
        if (version >= 0 and version <= 32767) {
            self.node_id = try types.decodeInt32(reader);
        }

        // Field: Host
        if (version >= 0 and version <= 32767) {
            self.host = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: Port
        if (version >= 0 and version <= 32767) {
            self.port = try types.decodeInt32(reader);
        }

        // Field: Rack
        if (version >= 0 and version <= 32767) {
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
        const range = types.VersionRange.parse("0+") catch return false;
        return range.contains(version);
    }
};

/// Nested struct: ShareFetchableTopicResponse
pub const ShareFetchableTopicResponse = struct {
    const Self = @This();

    /// The unique topic ID.
    /// Versions: 0+
    topic_id: [16]u8 = [_]u8{0} ** 16,
    /// The topic partitions.
    /// Versions: 0+
    partitions: ?[]PartitionData = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: TopicId
        if (version >= 0 and version <= 32767) {
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
        if (version >= 0 and version <= 32767) {
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
        if (version >= 0 and version <= 32767) {
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
    /// The fetch error code, or 0 if there was no fetch error.
    /// Versions: 0+
    error_code: i16 = 0,
    /// The fetch error message, or null if there was no fetch error.
    /// Versions: 0+
    error_message: ?[]const u8 = null,
    /// The acknowledge error code, or 0 if there was no acknowledge error.
    /// Versions: 0+
    acknowledge_error_code: i16 = 0,
    /// The acknowledge error message, or null if there was no acknowledge error.
    /// Versions: 0+
    acknowledge_error_message: ?[]const u8 = null,
    /// The current leader of the partition.
    /// Versions: 0+
    current_leader: LeaderIdAndEpoch = .{},
    /// The record data.
    /// Versions: 0+
    records: ?[]const u8 = null,
    /// The acquired records.
    /// Versions: 0+
    acquired_records: ?[]AcquiredRecords = null,

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

        // Field: ErrorMessage
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.error_message);
            } else {
                try types.encodeString(writer, self.error_message);
            }
        }

        // Field: AcknowledgeErrorCode
        if (version >= 0 and version <= 32767) {
            try types.encodeInt16(writer, self.acknowledge_error_code);
        }

        // Field: AcknowledgeErrorMessage
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.acknowledge_error_message);
            } else {
                try types.encodeString(writer, self.acknowledge_error_message);
            }
        }

        // Field: CurrentLeader
        if (version >= 0 and version <= 32767) {
            try LeaderIdAndEpoch.encode(&self.current_leader, writer, version);
        }

        // Field: Records
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactBytes(writer, self.records);
            } else {
                try types.encodeBytes(writer, self.records);
            }
        }

        // Field: AcquiredRecords
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.acquired_records);
                if (self.acquired_records) |arr| {
                    for (arr) |*item| {
                        try AcquiredRecords.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.acquired_records);
                if (self.acquired_records) |arr| {
                    for (arr) |*item| {
                        try AcquiredRecords.encode(item, writer, version);
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

        // Field: PartitionIndex
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.partition_index);
        }

        // Field: ErrorCode
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt16(self.error_code);
        }

        // Field: ErrorMessage
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.error_message) else types.computeSizeString(self.error_message);
        }

        // Field: AcknowledgeErrorCode
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt16(self.acknowledge_error_code);
        }

        // Field: AcknowledgeErrorMessage
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.acknowledge_error_message) else types.computeSizeString(self.acknowledge_error_message);
        }

        // Field: CurrentLeader
        if (version >= 0 and version <= 32767) {
            total_size += try LeaderIdAndEpoch.computeSize(&self.current_leader, version);
        }

        // Field: Records
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactBytes(self.records) else types.computeSizeBytes(self.records);
        }

        // Field: AcquiredRecords
        if (version >= 0 and version <= 32767) {
            if (self.acquired_records) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try AcquiredRecords.computeSize(item, version);
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
        // Field: PartitionIndex
        if (version >= 0 and version <= 32767) {
            self.partition_index = try types.decodeInt32(reader);
        }

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

        // Field: AcknowledgeErrorCode
        if (version >= 0 and version <= 32767) {
            self.acknowledge_error_code = try types.decodeInt16(reader);
        }

        // Field: AcknowledgeErrorMessage
        if (version >= 0 and version <= 32767) {
            self.acknowledge_error_message = if (is_flexible)
                try types.decodeCompactString(reader, allocator)
            else
                try types.decodeString(reader, allocator);
        }

        // Field: CurrentLeader
        if (version >= 0 and version <= 32767) {
            self.current_leader = try LeaderIdAndEpoch.decode(reader, version, allocator);
        }

        // Field: Records
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                self.records = try types.decodeCompactBytes(reader, allocator);
            } else {
                self.records = try types.decodeBytes(reader, allocator);
            }
        }

        // Field: AcquiredRecords
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(AcquiredRecords, array_len);
            for (array) |*item| {
                item.* = try AcquiredRecords.decode(reader, version, allocator);
            }
            self.acquired_records = array;
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

/// Nested struct: AcquiredRecords
pub const AcquiredRecords = struct {
    const Self = @This();

    /// The earliest offset in this batch of acquired records.
    /// Versions: 0+
    first_offset: i64 = 0,
    /// The last offset of this batch of acquired records.
    /// Versions: 0+
    last_offset: i64 = 0,
    /// The delivery count of this batch of acquired records.
    /// Versions: 0+
    delivery_count: i16 = 0,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: FirstOffset
        if (version >= 0 and version <= 32767) {
            try types.encodeInt64(writer, self.first_offset);
        }

        // Field: LastOffset
        if (version >= 0 and version <= 32767) {
            try types.encodeInt64(writer, self.last_offset);
        }

        // Field: DeliveryCount
        if (version >= 0 and version <= 32767) {
            try types.encodeInt16(writer, self.delivery_count);
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

        // Field: FirstOffset
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt64(self.first_offset);
        }

        // Field: LastOffset
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt64(self.last_offset);
        }

        // Field: DeliveryCount
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt16(self.delivery_count);
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
        // Field: FirstOffset
        if (version >= 0 and version <= 32767) {
            self.first_offset = try types.decodeInt64(reader);
        }

        // Field: LastOffset
        if (version >= 0 and version <= 32767) {
            self.last_offset = try types.decodeInt64(reader);
        }

        // Field: DeliveryCount
        if (version >= 0 and version <= 32767) {
            self.delivery_count = try types.decodeInt16(reader);
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

/// Nested struct: LeaderIdAndEpoch
pub const LeaderIdAndEpoch = struct {
    const Self = @This();

    /// The ID of the current leader or -1 if the leader is unknown.
    /// Versions: 0+
    leader_id: i32 = 0,
    /// The latest known leader epoch.
    /// Versions: 0+
    leader_epoch: i32 = 0,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: LeaderId
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.leader_id);
        }

        // Field: LeaderEpoch
        if (version >= 0 and version <= 32767) {
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
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.leader_id);
        }

        // Field: LeaderEpoch
        if (version >= 0 and version <= 32767) {
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
        if (version >= 0 and version <= 32767) {
            self.leader_id = try types.decodeInt32(reader);
        }

        // Field: LeaderEpoch
        if (version >= 0 and version <= 32767) {
            self.leader_epoch = try types.decodeInt32(reader);
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

/// ShareFetchResponse
pub const ShareFetchResponse = struct {
    const Self = @This();

    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    throttle_time_ms: i32 = 0,
    /// The top-level response error code.
    error_code: i16 = 0,
    /// The top-level error message, or null if there was no error.
    error_message: ?[]const u8 = null,
    /// The time in milliseconds for which the acquired records are locked.
    /// Versions: 1+
    acquisition_lock_timeout_ms: i32 = 0,
    /// The response topics.
    responses: ?[]ShareFetchableTopicResponse = null,
    /// Endpoints for all current leaders enumerated in PartitionData with error NOT_LEADER_OR_FOLLOWER.
    node_endpoints: ?[]NodeEndpoint = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 1, .max = 1 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 78;
    }

    /// Create a default instance of ShareFetchResponse
    pub fn default() Self {
        return .{
            .throttle_time_ms = 0,
            .error_code = 0,
            .error_message = null,
            .acquisition_lock_timeout_ms = 0,
            .responses = null,
            .node_endpoints = null,
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

    /// Sets `error_code` to the passed value.
    /// The top-level response error code.
    pub fn withErrorCode(self: Self, value: i16) Self {
        var result = self;
        result.error_code = value;
        return result;
    }

    /// Sets `error_message` to the passed value.
    /// The top-level error message, or null if there was no error.
    pub fn withErrorMessage(self: Self, value: ?[]const u8) Self {
        var result = self;
        result.error_message = value;
        return result;
    }

    /// Sets `acquisition_lock_timeout_ms` to the passed value.
    /// The time in milliseconds for which the acquired records are locked.
    /// Versions: 1+
    pub fn withAcquisitionLockTimeoutMs(self: Self, value: i32) Self {
        var result = self;
        result.acquisition_lock_timeout_ms = value;
        return result;
    }

    /// Sets `responses` to the passed value.
    /// The response topics.
    pub fn withResponses(self: Self, value: ?[]ShareFetchableTopicResponse) Self {
        var result = self;
        result.responses = value;
        return result;
    }

    /// Sets `node_endpoints` to the passed value.
    /// Endpoints for all current leaders enumerated in PartitionData with error NOT_LEADER_OR_FOLLOWER.
    pub fn withNodeEndpoints(self: Self, value: ?[]NodeEndpoint) Self {
        var result = self;
        result.node_endpoints = value;
        return result;
    }

    /// Encode ShareFetchResponse
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

        // Field: AcquisitionLockTimeoutMs
        if (version >= 1 and version <= 32767) {
            try types.encodeInt32(writer, self.acquisition_lock_timeout_ms);
        }

        // Field: Responses
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.responses);
                if (self.responses) |arr| {
                    for (arr) |*item| {
                        try ShareFetchableTopicResponse.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.responses);
                if (self.responses) |arr| {
                    for (arr) |*item| {
                        try ShareFetchableTopicResponse.encode(item, writer, version);
                    }
                }
            }
        }

        // Field: NodeEndpoints
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.node_endpoints);
                if (self.node_endpoints) |arr| {
                    for (arr) |*item| {
                        try NodeEndpoint.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.node_endpoints);
                if (self.node_endpoints) |arr| {
                    for (arr) |*item| {
                        try NodeEndpoint.encode(item, writer, version);
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

    /// Compute the size of ShareFetchResponse for the given version
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

        // Field: ErrorCode
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt16(self.error_code);
        }

        // Field: ErrorMessage
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.error_message) else types.computeSizeString(self.error_message);
        }

        // Field: AcquisitionLockTimeoutMs
        if (version >= 1 and version <= 32767) {
            total_size += types.computeSizeInt32(self.acquisition_lock_timeout_ms);
        }

        // Field: Responses
        if (version >= 0 and version <= 32767) {
            if (self.responses) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try ShareFetchableTopicResponse.computeSize(item, version);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(1) else 4;
            }
        }

        // Field: NodeEndpoints
        if (version >= 0 and version <= 32767) {
            if (self.node_endpoints) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try NodeEndpoint.computeSize(item, version);
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

    /// Decode ShareFetchResponse
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

        // Field: AcquisitionLockTimeoutMs
        if (version >= 1 and version <= 32767) {
            self.acquisition_lock_timeout_ms = try types.decodeInt32(reader);
        }

        // Field: Responses
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(ShareFetchableTopicResponse, array_len);
            for (array) |*item| {
                item.* = try ShareFetchableTopicResponse.decode(reader, version, allocator);
            }
            self.responses = array;
        }

        // Field: NodeEndpoints
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(NodeEndpoint, array_len);
            for (array) |*item| {
                item.* = try NodeEndpoint.decode(reader, version, allocator);
            }
            self.node_endpoints = array;
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
        const range = types.VersionRange.parse("1") catch return false;
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
