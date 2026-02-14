//! Auto-generated Kafka protocol message
//! Message: CreateTopicsRequest
//! API Key: 19
//! Type: request
//! Valid Versions: 2-7
//! Flexible Versions: 5+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// Nested struct: CreatableTopic
pub const CreatableTopic = struct {
    const Self = @This();

    /// The topic name.
    /// Versions: 0+
    name: []const u8 = "",
    /// The number of partitions to create in the topic, or -1 if we are either specifying a manual partition assignment or using the default partitions.
    /// Versions: 0+
    num_partitions: i32 = 0,
    /// The number of replicas to create for each partition in the topic, or -1 if we are either specifying a manual partition assignment or using the default replication factor.
    /// Versions: 0+
    replication_factor: i16 = 0,
    /// The manual partition assignment, or the empty array if we are using automatic assignment.
    /// Versions: 0+
    assignments: ?[]CreatableReplicaAssignment = null,
    /// The custom topic configurations to set.
    /// Versions: 0+
    configs: ?[]CreatableTopicConfig = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: Name
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.name);
            } else {
                try types.encodeString(writer, self.name);
            }
        }

        // Field: NumPartitions
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.num_partitions);
        }

        // Field: ReplicationFactor
        if (version >= 0 and version <= 32767) {
            try types.encodeInt16(writer, self.replication_factor);
        }

        // Field: Assignments
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLen(writer, self.assignments);
                if (self.assignments) |arr| {
                    for (arr) |*item| {
                        try CreatableReplicaAssignment.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLen(writer, self.assignments);
                if (self.assignments) |arr| {
                    for (arr) |*item| {
                        try CreatableReplicaAssignment.encode(item, writer, version);
                    }
                }
            }
        }

        // Field: Configs
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLen(writer, self.configs);
                if (self.configs) |arr| {
                    for (arr) |*item| {
                        try CreatableTopicConfig.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLen(writer, self.configs);
                if (self.configs) |arr| {
                    for (arr) |*item| {
                        try CreatableTopicConfig.encode(item, writer, version);
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
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.name) else types.computeSizeString(self.name);
        }

        // Field: NumPartitions
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.num_partitions);
        }

        // Field: ReplicationFactor
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt16(self.replication_factor);
        }

        // Field: Assignments
        if (version >= 0 and version <= 32767) {
            if (self.assignments) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try CreatableReplicaAssignment.computeSize(item, version);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(0) else 4;
            }
        }

        // Field: Configs
        if (version >= 0 and version <= 32767) {
            if (self.configs) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try CreatableTopicConfig.computeSize(item, version);
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
        if (version >= 0 and version <= 32767) {
            self.name = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: NumPartitions
        if (version >= 0 and version <= 32767) {
            self.num_partitions = try types.decodeInt32(reader);
        }

        // Field: ReplicationFactor
        if (version >= 0 and version <= 32767) {
            self.replication_factor = try types.decodeInt16(reader);
        }

        // Field: Assignments
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(CreatableReplicaAssignment, array_len);
            for (array) |*item| {
                item.* = try CreatableReplicaAssignment.decode(reader, version, allocator);
            }
            self.assignments = array;
        }

        // Field: Configs
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(CreatableTopicConfig, array_len);
            for (array) |*item| {
                item.* = try CreatableTopicConfig.decode(reader, version, allocator);
            }
            self.configs = array;
        }


        if (is_flexible) {
            const tagged_fields_data = try types.decodeTaggedFields(reader, allocator);
            self._tagged_fields = tagged_fields_data;
        }
        return self;
    }

    fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("5+") catch return false;
        return range.contains(version);
    }
};

/// Nested struct: CreatableTopicConfig
pub const CreatableTopicConfig = struct {
    const Self = @This();

    /// The configuration name.
    /// Versions: 0+
    name: []const u8 = "",
    /// The configuration value.
    /// Versions: 0+
    value: ?[]const u8 = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: Name
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.name);
            } else {
                try types.encodeString(writer, self.name);
            }
        }

        // Field: Value
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.value);
            } else {
                try types.encodeString(writer, self.value);
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
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.name) else types.computeSizeString(self.name);
        }

        // Field: Value
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.value) else types.computeSizeString(self.value);
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
        if (version >= 0 and version <= 32767) {
            self.name = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: Value
        if (version >= 0 and version <= 32767) {
            self.value = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }


        if (is_flexible) {
            const tagged_fields_data = try types.decodeTaggedFields(reader, allocator);
            self._tagged_fields = tagged_fields_data;
        }
        return self;
    }

    fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("5+") catch return false;
        return range.contains(version);
    }
};

/// Nested struct: CreatableReplicaAssignment
pub const CreatableReplicaAssignment = struct {
    const Self = @This();

    /// The partition index.
    /// Versions: 0+
    partition_index: i32 = 0,
    /// The brokers to place the partition on.
    /// Versions: 0+
    broker_ids: ?[]i32 = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: PartitionIndex
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.partition_index);
        }

        // Field: BrokerIds
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArray(i32, writer, self.broker_ids, types.encodeInt32);
            } else {
                try types.encodeArray(i32, writer, self.broker_ids, types.encodeInt32);
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

        // Field: BrokerIds
        if (version >= 0 and version <= 32767) {
            if (self.broker_ids) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |item| {
                    total_size += types.computeSizeInt32(item);
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
        // Field: PartitionIndex
        if (version >= 0 and version <= 32767) {
            self.partition_index = try types.decodeInt32(reader);
        }

        // Field: BrokerIds
        if (version >= 0 and version <= 32767) {
            self.broker_ids = if (is_flexible)
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
        const range = types.VersionRange.parse("5+") catch return false;
        return range.contains(version);
    }
};

/// CreateTopicsRequest
pub const CreateTopicsRequest = struct {
    const Self = @This();

    /// The topics to create.
    topics: ?[]CreatableTopic = null,
    /// How long to wait in milliseconds before timing out the request.
    timeout_ms: i32 = 60000,
    /// If true, check that the topics can be created as specified, but don't create anything.
    /// Versions: 1+
    validate_only: bool = false,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 2, .max = 7 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 19;
    }

    /// Create a default instance of CreateTopicsRequest
    pub fn default() Self {
        return .{
            .topics = null,
            .timeout_ms = 60000,
            .validate_only = false,
            ._tagged_fields = null,
        };
    }

    /// Sets `topics` to the passed value.
    /// The topics to create.
    pub fn withTopics(self: Self, value: ?[]CreatableTopic) Self {
        var result = self;
        result.topics = value;
        return result;
    }

    /// Sets `timeout_ms` to the passed value.
    /// How long to wait in milliseconds before timing out the request.
    pub fn withtimeoutMs(self: Self, value: i32) Self {
        var result = self;
        result.timeout_ms = value;
        return result;
    }

    /// Sets `validate_only` to the passed value.
    /// If true, check that the topics can be created as specified, but don't create anything.
    /// Versions: 1+
    pub fn withvalidateOnly(self: Self, value: bool) Self {
        var result = self;
        result.validate_only = value;
        return result;
    }

    /// Encode CreateTopicsRequest
    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: Topics
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLen(writer, self.topics);
                if (self.topics) |arr| {
                    for (arr) |*item| {
                        try CreatableTopic.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLen(writer, self.topics);
                if (self.topics) |arr| {
                    for (arr) |*item| {
                        try CreatableTopic.encode(item, writer, version);
                    }
                }
            }
        }

        // Field: timeoutMs
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.timeout_ms);
        }

        // Field: validateOnly
        if (version >= 1 and version <= 32767) {
            try types.encodeBoolean(writer, self.validate_only);
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

    /// Compute the size of CreateTopicsRequest for the given version
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
                for (arr) |*item| {
                    total_size += try CreatableTopic.computeSize(item, version);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(0) else 4;
            }
        }

        // Field: timeoutMs
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.timeout_ms);
        }

        // Field: validateOnly
        if (version >= 1 and version <= 32767) {
            total_size += types.computeSizeBoolean(self.validate_only);
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

    /// Decode CreateTopicsRequest
    pub fn decode(reader: anytype, version: i16, allocator: std.mem.Allocator) !Self {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        var self: Self = .{};

        // Field: Topics
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(CreatableTopic, array_len);
            for (array) |*item| {
                item.* = try CreatableTopic.decode(reader, version, allocator);
            }
            self.topics = array;
        }

        // Field: timeoutMs
        if (version >= 0 and version <= 32767) {
            self.timeout_ms = try types.decodeInt32(reader);
        }

        // Field: validateOnly
        if (version >= 1 and version <= 32767) {
            self.validate_only = try types.decodeBoolean(reader);
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
        const range = types.VersionRange.parse("2-7") catch return false;
        return range.contains(version);
    }
    /// Check if version uses flexible encoding
    pub fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("5+") catch return false;
        return range.contains(version);
    }
    /// Get the header version for this API version
    /// Returns 2 for flexible versions, 1 for classic versions
    pub fn headerVersion(api_version: i16) i16 {
        if (isFlexibleVersion(api_version)) return 2;
        return 1;
    }

};
