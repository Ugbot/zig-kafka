//! Auto-generated Kafka protocol message
//! Message: ListOffsetsRequest
//! API Key: 2
//! Type: request
//! Valid Versions: 1-11
//! Flexible Versions: 6+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// Nested struct: ListOffsetsTopic
pub const ListOffsetsTopic = struct {
    const Self = @This();

    /// The topic name.
    /// Versions: 0+
    name: []const u8 = "",
    /// Each partition in the request.
    /// Versions: 0+
    partitions: ?[]ListOffsetsPartition = null,

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

        // Field: Partitions
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.partitions);
                if (self.partitions) |arr| {
                    for (arr) |*item| {
                        try ListOffsetsPartition.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.partitions);
                if (self.partitions) |arr| {
                    for (arr) |*item| {
                        try ListOffsetsPartition.encode(item, writer, version);
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

        // Field: Partitions
        if (version >= 0 and version <= 32767) {
            if (self.partitions) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try ListOffsetsPartition.computeSize(item, version);
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
        if (version >= 0 and version <= 32767) {
            self.name = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: Partitions
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(ListOffsetsPartition, array_len);
            for (array) |*item| {
                item.* = try ListOffsetsPartition.decode(reader, version, allocator);
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
        const range = types.VersionRange.parse("6+") catch return false;
        return range.contains(version);
    }
};

/// Nested struct: ListOffsetsPartition
pub const ListOffsetsPartition = struct {
    const Self = @This();

    /// The partition index.
    /// Versions: 0+
    partition_index: i32 = 0,
    /// The current leader epoch.
    /// Versions: 4+
    current_leader_epoch: i32 = -1,
    /// The current timestamp.
    /// Versions: 0+
    timestamp: i64 = 0,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: PartitionIndex
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.partition_index);
        }

        // Field: CurrentLeaderEpoch
        if (version >= 4 and version <= 32767) {
            try types.encodeInt32(writer, self.current_leader_epoch);
        }

        // Field: Timestamp
        if (version >= 0 and version <= 32767) {
            try types.encodeInt64(writer, self.timestamp);
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

        // Field: CurrentLeaderEpoch
        if (version >= 4 and version <= 32767) {
            total_size += types.computeSizeInt32(self.current_leader_epoch);
        }

        // Field: Timestamp
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt64(self.timestamp);
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

        // Field: CurrentLeaderEpoch
        if (version >= 4 and version <= 32767) {
            self.current_leader_epoch = try types.decodeInt32(reader);
        }

        // Field: Timestamp
        if (version >= 0 and version <= 32767) {
            self.timestamp = try types.decodeInt64(reader);
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

/// ListOffsetsRequest
pub const ListOffsetsRequest = struct {
    const Self = @This();

    /// The broker ID of the requester, or -1 if this request is being made by a normal consumer.
    replica_id: i32 = 0,
    /// This setting controls the visibility of transactional records. Using READ_UNCOMMITTED (isolation_level = 0) makes all records visible. With READ_COMMITTED (isolation_level = 1), non-transactional and COMMITTED transactional records are visible. To be more concrete, READ_COMMITTED returns all data from offsets smaller than the current LSO (last stable offset), and enables the inclusion of the list of aborted transactions in the result, which allows consumers to discard ABORTED transactional records.
    /// Versions: 2+
    isolation_level: i8 = 0,
    /// Each topic in the request.
    topics: ?[]ListOffsetsTopic = null,
    /// The timeout to await a response in milliseconds for requests that require reading from remote storage for topics enabled with tiered storage.
    /// Versions: 10+
    timeout_ms: i32 = 0,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 1, .max = 11 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 2;
    }

    /// Create a default instance of ListOffsetsRequest
    pub fn default() Self {
        return .{
            .replica_id = 0,
            .isolation_level = 0,
            .topics = null,
            .timeout_ms = 0,
            ._tagged_fields = null,
        };
    }

    /// Sets `replica_id` to the passed value.
    /// The broker ID of the requester, or -1 if this request is being made by a normal consumer.
    pub fn withReplicaId(self: Self, value: i32) Self {
        var result = self;
        result.replica_id = value;
        return result;
    }

    /// Sets `isolation_level` to the passed value.
    /// This setting controls the visibility of transactional records. Using READ_UNCOMMITTED (isolation_level = 0) makes all records visible. With READ_COMMITTED (isolation_level = 1), non-transactional and COMMITTED transactional records are visible. To be more concrete, READ_COMMITTED returns all data from offsets smaller than the current LSO (last stable offset), and enables the inclusion of the list of aborted transactions in the result, which allows consumers to discard ABORTED transactional records.
    /// Versions: 2+
    pub fn withIsolationLevel(self: Self, value: i8) Self {
        var result = self;
        result.isolation_level = value;
        return result;
    }

    /// Sets `topics` to the passed value.
    /// Each topic in the request.
    pub fn withTopics(self: Self, value: ?[]ListOffsetsTopic) Self {
        var result = self;
        result.topics = value;
        return result;
    }

    /// Sets `timeout_ms` to the passed value.
    /// The timeout to await a response in milliseconds for requests that require reading from remote storage for topics enabled with tiered storage.
    /// Versions: 10+
    pub fn withTimeoutMs(self: Self, value: i32) Self {
        var result = self;
        result.timeout_ms = value;
        return result;
    }

    /// Encode ListOffsetsRequest
    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: ReplicaId
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.replica_id);
        }

        // Field: IsolationLevel
        if (version >= 2 and version <= 32767) {
            try types.encodeInt8(writer, self.isolation_level);
        }

        // Field: Topics
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.topics);
                if (self.topics) |arr| {
                    for (arr) |*item| {
                        try ListOffsetsTopic.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.topics);
                if (self.topics) |arr| {
                    for (arr) |*item| {
                        try ListOffsetsTopic.encode(item, writer, version);
                    }
                }
            }
        }

        // Field: TimeoutMs
        if (version >= 10 and version <= 32767) {
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

    /// Compute the size of ListOffsetsRequest for the given version
    pub fn computeSize(self: *const Self, version: i16) !usize {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        var total_size: usize = 0;

        // Field: ReplicaId
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.replica_id);
        }

        // Field: IsolationLevel
        if (version >= 2 and version <= 32767) {
            total_size += types.computeSizeInt8(self.isolation_level);
        }

        // Field: Topics
        if (version >= 0 and version <= 32767) {
            if (self.topics) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try ListOffsetsTopic.computeSize(item, version);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(1) else 4;
            }
        }

        // Field: TimeoutMs
        if (version >= 10 and version <= 32767) {
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

    /// Decode ListOffsetsRequest
    pub fn decode(reader: anytype, version: i16, allocator: std.mem.Allocator) !Self {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        var self: Self = .{};

        // Field: ReplicaId
        if (version >= 0 and version <= 32767) {
            self.replica_id = try types.decodeInt32(reader);
        }

        // Field: IsolationLevel
        if (version >= 2 and version <= 32767) {
            self.isolation_level = try types.decodeInt8(reader);
        }

        // Field: Topics
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(ListOffsetsTopic, array_len);
            for (array) |*item| {
                item.* = try ListOffsetsTopic.decode(reader, version, allocator);
            }
            self.topics = array;
        }

        // Field: TimeoutMs
        if (version >= 10 and version <= 32767) {
            self.timeout_ms = try types.decodeInt32(reader);
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
        const range = types.VersionRange.parse("1-11") catch return false;
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
