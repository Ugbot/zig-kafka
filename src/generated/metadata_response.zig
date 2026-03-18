//! Auto-generated Kafka protocol message
//! Message: MetadataResponse
//! API Key: 3
//! Type: response
//! Valid Versions: 0-13
//! Flexible Versions: 9+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// Nested struct: MetadataResponseTopic
pub const MetadataResponseTopic = struct {
    const Self = @This();

    /// The topic error, or 0 if there was no error.
    /// Versions: 0+
    error_code: i16 = 0,
    /// The topic name. Null for non-existing topics queried by ID. This is never null when ErrorCode is zero. One of Name and TopicId is always populated.
    /// Versions: 0+
    name: ?[]const u8 = null,
    /// The topic id. Zero for non-existing topics queried by name. This is never zero when ErrorCode is zero. One of Name and TopicId is always populated.
    /// Versions: 10+
    topic_id: [16]u8 = [_]u8{0} ** 16,
    /// True if the topic is internal.
    /// Versions: 1+
    is_internal: bool = false,
    /// Each partition in the topic.
    /// Versions: 0+
    partitions: ?[]MetadataResponsePartition = null,
    /// 32-bit bitfield to represent authorized operations for this topic.
    /// Versions: 8+
    topic_authorized_operations: i32 = -2147483648,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: ErrorCode
        if (version >= 0 and version <= 32767) {
            try types.encodeInt16(writer, self.error_code);
        }

        // Field: Name
        if (version >= 0 and version <= 32767) {
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

        // Field: IsInternal
        if (version >= 1 and version <= 32767) {
            try types.encodeBoolean(writer, self.is_internal);
        }

        // Field: Partitions
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.partitions);
                if (self.partitions) |arr| {
                    for (arr) |*item| {
                        try MetadataResponsePartition.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.partitions);
                if (self.partitions) |arr| {
                    for (arr) |*item| {
                        try MetadataResponsePartition.encode(item, writer, version);
                    }
                }
            }
        }

        // Field: TopicAuthorizedOperations
        if (version >= 8 and version <= 32767) {
            try types.encodeInt32(writer, self.topic_authorized_operations);
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

        // Field: Name
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.name) else types.computeSizeString(self.name);
        }

        // Field: TopicId
        if (version >= 10 and version <= 32767) {
            total_size += types.computeSizeUuid(self.topic_id);
        }

        // Field: IsInternal
        if (version >= 1 and version <= 32767) {
            total_size += types.computeSizeBoolean(self.is_internal);
        }

        // Field: Partitions
        if (version >= 0 and version <= 32767) {
            if (self.partitions) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try MetadataResponsePartition.computeSize(item, version);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(1) else 4;
            }
        }

        // Field: TopicAuthorizedOperations
        if (version >= 8 and version <= 32767) {
            total_size += types.computeSizeInt32(self.topic_authorized_operations);
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

        // Field: Name
        if (version >= 0 and version <= 32767) {
            self.name = if (is_flexible)
                try types.decodeCompactString(reader, allocator)
            else
                try types.decodeString(reader, allocator);
        }

        // Field: TopicId
        if (version >= 10 and version <= 32767) {
            self.topic_id = try types.decodeUuid(reader);
        }

        // Field: IsInternal
        if (version >= 1 and version <= 32767) {
            self.is_internal = try types.decodeBoolean(reader);
        }

        // Field: Partitions
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(MetadataResponsePartition, array_len);
            for (array) |*item| {
                item.* = try MetadataResponsePartition.decode(reader, version, allocator);
            }
            self.partitions = array;
        }

        // Field: TopicAuthorizedOperations
        if (version >= 8 and version <= 32767) {
            self.topic_authorized_operations = try types.decodeInt32(reader);
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

/// Nested struct: MetadataResponsePartition
pub const MetadataResponsePartition = struct {
    const Self = @This();

    /// The partition error, or 0 if there was no error.
    /// Versions: 0+
    error_code: i16 = 0,
    /// The partition index.
    /// Versions: 0+
    partition_index: i32 = 0,
    /// The ID of the leader broker.
    /// Versions: 0+
    leader_id: i32 = 0,
    /// The leader epoch of this partition.
    /// Versions: 7+
    leader_epoch: i32 = -1,
    /// The set of all nodes that host this partition.
    /// Versions: 0+
    replica_nodes: ?[]i32 = null,
    /// The set of nodes that are in sync with the leader for this partition.
    /// Versions: 0+
    isr_nodes: ?[]i32 = null,
    /// The set of offline replicas of this partition.
    /// Versions: 5+
    offline_replicas: ?[]i32 = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: ErrorCode
        if (version >= 0 and version <= 32767) {
            try types.encodeInt16(writer, self.error_code);
        }

        // Field: PartitionIndex
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.partition_index);
        }

        // Field: LeaderId
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.leader_id);
        }

        // Field: LeaderEpoch
        if (version >= 7 and version <= 32767) {
            try types.encodeInt32(writer, self.leader_epoch);
        }

        // Field: ReplicaNodes
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayNonNull(i32, writer, self.replica_nodes, types.encodeInt32);
            } else {
                try types.encodeArrayNonNull(i32, writer, self.replica_nodes, types.encodeInt32);
            }
        }

        // Field: IsrNodes
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayNonNull(i32, writer, self.isr_nodes, types.encodeInt32);
            } else {
                try types.encodeArrayNonNull(i32, writer, self.isr_nodes, types.encodeInt32);
            }
        }

        // Field: OfflineReplicas
        if (version >= 5 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayNonNull(i32, writer, self.offline_replicas, types.encodeInt32);
            } else {
                try types.encodeArrayNonNull(i32, writer, self.offline_replicas, types.encodeInt32);
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

        // Field: ErrorCode
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt16(self.error_code);
        }

        // Field: PartitionIndex
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.partition_index);
        }

        // Field: LeaderId
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.leader_id);
        }

        // Field: LeaderEpoch
        if (version >= 7 and version <= 32767) {
            total_size += types.computeSizeInt32(self.leader_epoch);
        }

        // Field: ReplicaNodes
        if (version >= 0 and version <= 32767) {
            if (self.replica_nodes) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |item| {
                    total_size += types.computeSizeInt32(item);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(1) else 4;
            }
        }

        // Field: IsrNodes
        if (version >= 0 and version <= 32767) {
            if (self.isr_nodes) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |item| {
                    total_size += types.computeSizeInt32(item);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(1) else 4;
            }
        }

        // Field: OfflineReplicas
        if (version >= 5 and version <= 32767) {
            if (self.offline_replicas) |arr| {
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
        // Field: ErrorCode
        if (version >= 0 and version <= 32767) {
            self.error_code = try types.decodeInt16(reader);
        }

        // Field: PartitionIndex
        if (version >= 0 and version <= 32767) {
            self.partition_index = try types.decodeInt32(reader);
        }

        // Field: LeaderId
        if (version >= 0 and version <= 32767) {
            self.leader_id = try types.decodeInt32(reader);
        }

        // Field: LeaderEpoch
        if (version >= 7 and version <= 32767) {
            self.leader_epoch = try types.decodeInt32(reader);
        }

        // Field: ReplicaNodes
        if (version >= 0 and version <= 32767) {
            self.replica_nodes = if (is_flexible)
                try types.decodeCompactPrimitiveArray(i32, reader, allocator, types.decodeInt32)
            else
                try types.decodePrimitiveArray(i32, reader, allocator, types.decodeInt32);
        }

        // Field: IsrNodes
        if (version >= 0 and version <= 32767) {
            self.isr_nodes = if (is_flexible)
                try types.decodeCompactPrimitiveArray(i32, reader, allocator, types.decodeInt32)
            else
                try types.decodePrimitiveArray(i32, reader, allocator, types.decodeInt32);
        }

        // Field: OfflineReplicas
        if (version >= 5 and version <= 32767) {
            self.offline_replicas = if (is_flexible)
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
        const range = types.VersionRange.parse("9+") catch return false;
        return range.contains(version);
    }
};

/// Nested struct: MetadataResponseBroker
pub const MetadataResponseBroker = struct {
    const Self = @This();

    /// The broker ID.
    /// Versions: 0+
    node_id: i32 = 0,
    /// The broker hostname.
    /// Versions: 0+
    host: []const u8 = "",
    /// The broker port.
    /// Versions: 0+
    port: i32 = 0,
    /// The rack of the broker, or null if it has not been assigned to a rack.
    /// Versions: 1+
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
        if (version >= 1 and version <= 32767) {
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
        if (version >= 1 and version <= 32767) {
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
        if (version >= 1 and version <= 32767) {
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
        const range = types.VersionRange.parse("9+") catch return false;
        return range.contains(version);
    }
};

/// MetadataResponse
pub const MetadataResponse = struct {
    const Self = @This();

    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    /// Versions: 3+
    throttle_time_ms: i32 = 0,
    /// A list of brokers present in the cluster.
    brokers: ?[]MetadataResponseBroker = null,
    /// The cluster ID that responding broker belongs to.
    /// Versions: 2+
    cluster_id: ?[]const u8 = null,
    /// The ID of the controller broker.
    /// Versions: 1+
    controller_id: i32 = -1,
    /// Each topic in the response.
    topics: ?[]MetadataResponseTopic = null,
    /// 32-bit bitfield to represent authorized operations for this cluster.
    /// Versions: 8-10
    cluster_authorized_operations: i32 = -2147483648,
    /// The top-level error code, or 0 if there was no error.
    /// Versions: 13+
    error_code: i16 = 0,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 0, .max = 13 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 3;
    }

    /// Create a default instance of MetadataResponse
    pub fn default() Self {
        return .{
            .throttle_time_ms = 0,
            .brokers = null,
            .cluster_id = null,
            .controller_id = -1,
            .topics = null,
            .cluster_authorized_operations = -2147483648,
            .error_code = 0,
            ._tagged_fields = null,
        };
    }

    /// Sets `throttle_time_ms` to the passed value.
    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    /// Versions: 3+
    pub fn withThrottleTimeMs(self: Self, value: i32) Self {
        var result = self;
        result.throttle_time_ms = value;
        return result;
    }

    /// Sets `brokers` to the passed value.
    /// A list of brokers present in the cluster.
    pub fn withBrokers(self: Self, value: ?[]MetadataResponseBroker) Self {
        var result = self;
        result.brokers = value;
        return result;
    }

    /// Sets `cluster_id` to the passed value.
    /// The cluster ID that responding broker belongs to.
    /// Versions: 2+
    pub fn withClusterId(self: Self, value: ?[]const u8) Self {
        var result = self;
        result.cluster_id = value;
        return result;
    }

    /// Sets `controller_id` to the passed value.
    /// The ID of the controller broker.
    /// Versions: 1+
    pub fn withControllerId(self: Self, value: i32) Self {
        var result = self;
        result.controller_id = value;
        return result;
    }

    /// Sets `topics` to the passed value.
    /// Each topic in the response.
    pub fn withTopics(self: Self, value: ?[]MetadataResponseTopic) Self {
        var result = self;
        result.topics = value;
        return result;
    }

    /// Sets `cluster_authorized_operations` to the passed value.
    /// 32-bit bitfield to represent authorized operations for this cluster.
    /// Versions: 8-10
    pub fn withClusterAuthorizedOperations(self: Self, value: i32) Self {
        var result = self;
        result.cluster_authorized_operations = value;
        return result;
    }

    /// Sets `error_code` to the passed value.
    /// The top-level error code, or 0 if there was no error.
    /// Versions: 13+
    pub fn withErrorCode(self: Self, value: i16) Self {
        var result = self;
        result.error_code = value;
        return result;
    }

    /// Encode MetadataResponse
    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: ThrottleTimeMs
        if (version >= 3 and version <= 32767) {
            try types.encodeInt32(writer, self.throttle_time_ms);
        }

        // Field: Brokers
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.brokers);
                if (self.brokers) |arr| {
                    for (arr) |*item| {
                        try MetadataResponseBroker.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.brokers);
                if (self.brokers) |arr| {
                    for (arr) |*item| {
                        try MetadataResponseBroker.encode(item, writer, version);
                    }
                }
            }
        }

        // Field: ClusterId
        if (version >= 2 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.cluster_id);
            } else {
                try types.encodeString(writer, self.cluster_id);
            }
        }

        // Field: ControllerId
        if (version >= 1 and version <= 32767) {
            try types.encodeInt32(writer, self.controller_id);
        }

        // Field: Topics
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.topics);
                if (self.topics) |arr| {
                    for (arr) |*item| {
                        try MetadataResponseTopic.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.topics);
                if (self.topics) |arr| {
                    for (arr) |*item| {
                        try MetadataResponseTopic.encode(item, writer, version);
                    }
                }
            }
        }

        // Field: ClusterAuthorizedOperations
        if (version >= 8 and version <= 10) {
            try types.encodeInt32(writer, self.cluster_authorized_operations);
        }

        // Field: ErrorCode
        if (version >= 13 and version <= 32767) {
            try types.encodeInt16(writer, self.error_code);
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

    /// Compute the size of MetadataResponse for the given version
    pub fn computeSize(self: *const Self, version: i16) !usize {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        var total_size: usize = 0;

        // Field: ThrottleTimeMs
        if (version >= 3 and version <= 32767) {
            total_size += types.computeSizeInt32(self.throttle_time_ms);
        }

        // Field: Brokers
        if (version >= 0 and version <= 32767) {
            if (self.brokers) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try MetadataResponseBroker.computeSize(item, version);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(1) else 4;
            }
        }

        // Field: ClusterId
        if (version >= 2 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.cluster_id) else types.computeSizeString(self.cluster_id);
        }

        // Field: ControllerId
        if (version >= 1 and version <= 32767) {
            total_size += types.computeSizeInt32(self.controller_id);
        }

        // Field: Topics
        if (version >= 0 and version <= 32767) {
            if (self.topics) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try MetadataResponseTopic.computeSize(item, version);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(1) else 4;
            }
        }

        // Field: ClusterAuthorizedOperations
        if (version >= 8 and version <= 10) {
            total_size += types.computeSizeInt32(self.cluster_authorized_operations);
        }

        // Field: ErrorCode
        if (version >= 13 and version <= 32767) {
            total_size += types.computeSizeInt16(self.error_code);
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

    /// Decode MetadataResponse
    pub fn decode(reader: anytype, version: i16, allocator: std.mem.Allocator) !Self {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        var self: Self = .{};

        // Field: ThrottleTimeMs
        if (version >= 3 and version <= 32767) {
            self.throttle_time_ms = try types.decodeInt32(reader);
        }

        // Field: Brokers
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(MetadataResponseBroker, array_len);
            for (array) |*item| {
                item.* = try MetadataResponseBroker.decode(reader, version, allocator);
            }
            self.brokers = array;
        }

        // Field: ClusterId
        if (version >= 2 and version <= 32767) {
            self.cluster_id = if (is_flexible)
                try types.decodeCompactString(reader, allocator)
            else
                try types.decodeString(reader, allocator);
        }

        // Field: ControllerId
        if (version >= 1 and version <= 32767) {
            self.controller_id = try types.decodeInt32(reader);
        }

        // Field: Topics
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(MetadataResponseTopic, array_len);
            for (array) |*item| {
                item.* = try MetadataResponseTopic.decode(reader, version, allocator);
            }
            self.topics = array;
        }

        // Field: ClusterAuthorizedOperations
        if (version >= 8 and version <= 10) {
            self.cluster_authorized_operations = try types.decodeInt32(reader);
        }

        // Field: ErrorCode
        if (version >= 13 and version <= 32767) {
            self.error_code = try types.decodeInt16(reader);
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
        const range = types.VersionRange.parse("0-13") catch return false;
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
