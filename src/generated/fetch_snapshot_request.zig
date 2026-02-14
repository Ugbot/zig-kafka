//! Auto-generated Kafka protocol message
//! Message: FetchSnapshotRequest
//! API Key: 59
//! Type: request
//! Valid Versions: 0-1
//! Flexible Versions: 0+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// Nested struct: TopicSnapshot
pub const TopicSnapshot = struct {
    const Self = @This();

    /// The name of the topic to fetch.
    /// Versions: 0+
    name: []const u8 = "",
    /// The partitions to fetch.
    /// Versions: 0+
    partitions: ?[]PartitionSnapshot = null,

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
                        try PartitionSnapshot.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.partitions);
                if (self.partitions) |arr| {
                    for (arr) |*item| {
                        try PartitionSnapshot.encode(item, writer, version);
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
                    total_size += try PartitionSnapshot.computeSize(item, version);
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
            const array = try allocator.alloc(PartitionSnapshot, array_len);
            for (array) |*item| {
                item.* = try PartitionSnapshot.decode(reader, version, allocator);
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

/// Nested struct: PartitionSnapshot
pub const PartitionSnapshot = struct {
    const Self = @This();

    /// The partition index.
    /// Versions: 0+
    partition: i32 = 0,
    /// The current leader epoch of the partition, -1 for unknown leader epoch.
    /// Versions: 0+
    current_leader_epoch: i32 = 0,
    /// The snapshot endOffset and epoch to fetch.
    /// Versions: 0+
    snapshot_id: SnapshotId = .{},
    /// The byte position within the snapshot to start fetching from.
    /// Versions: 0+
    position: i64 = 0,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: Partition
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.partition);
        }

        // Field: CurrentLeaderEpoch
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.current_leader_epoch);
        }

        // Field: SnapshotId
        if (version >= 0 and version <= 32767) {
            try SnapshotId.encode(&self.snapshot_id, writer, version);
        }

        // Field: Position
        if (version >= 0 and version <= 32767) {
            try types.encodeInt64(writer, self.position);
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

        // Field: Partition
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.partition);
        }

        // Field: CurrentLeaderEpoch
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.current_leader_epoch);
        }

        // Field: SnapshotId
        if (version >= 0 and version <= 32767) {
            total_size += try SnapshotId.computeSize(&self.snapshot_id, version);
        }

        // Field: Position
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt64(self.position);
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
        // Field: Partition
        if (version >= 0 and version <= 32767) {
            self.partition = try types.decodeInt32(reader);
        }

        // Field: CurrentLeaderEpoch
        if (version >= 0 and version <= 32767) {
            self.current_leader_epoch = try types.decodeInt32(reader);
        }

        // Field: SnapshotId
        if (version >= 0 and version <= 32767) {
            self.snapshot_id = try SnapshotId.decode(reader, version, allocator);
        }

        // Field: Position
        if (version >= 0 and version <= 32767) {
            self.position = try types.decodeInt64(reader);
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

/// Nested struct: SnapshotId
pub const SnapshotId = struct {
    const Self = @This();

    /// The end offset of the snapshot.
    /// Versions: 0+
    end_offset: i64 = 0,
    /// The epoch of the snapshot.
    /// Versions: 0+
    epoch: i32 = 0,

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
        const range = types.VersionRange.parse("0+") catch return false;
        return range.contains(version);
    }
};

/// FetchSnapshotRequest
pub const FetchSnapshotRequest = struct {
    const Self = @This();

    /// The clusterId if known, this is used to validate metadata fetches prior to broker registration.
    cluster_id: ?[]const u8 = null,
    /// The broker ID of the follower.
    replica_id: i32 = -1,
    /// The maximum bytes to fetch from all of the snapshots.
    max_bytes: i32 = 0x7fffffff,
    /// The topics to fetch.
    topics: ?[]TopicSnapshot = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 0, .max = 1 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 59;
    }

    /// Create a default instance of FetchSnapshotRequest
    pub fn default() Self {
        return .{
            .cluster_id = null,
            .replica_id = -1,
            .max_bytes = 0x7fffffff,
            .topics = null,
            ._tagged_fields = null,
        };
    }

    /// Sets `cluster_id` to the passed value.
    /// The clusterId if known, this is used to validate metadata fetches prior to broker registration.
    pub fn withClusterId(self: Self, value: ?[]const u8) Self {
        var result = self;
        result.cluster_id = value;
        return result;
    }

    /// Sets `replica_id` to the passed value.
    /// The broker ID of the follower.
    pub fn withReplicaId(self: Self, value: i32) Self {
        var result = self;
        result.replica_id = value;
        return result;
    }

    /// Sets `max_bytes` to the passed value.
    /// The maximum bytes to fetch from all of the snapshots.
    pub fn withMaxBytes(self: Self, value: i32) Self {
        var result = self;
        result.max_bytes = value;
        return result;
    }

    /// Sets `topics` to the passed value.
    /// The topics to fetch.
    pub fn withTopics(self: Self, value: ?[]TopicSnapshot) Self {
        var result = self;
        result.topics = value;
        return result;
    }

    /// Encode FetchSnapshotRequest
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

        // Field: MaxBytes
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.max_bytes);
        }

        // Field: Topics
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.topics);
                if (self.topics) |arr| {
                    for (arr) |*item| {
                        try TopicSnapshot.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.topics);
                if (self.topics) |arr| {
                    for (arr) |*item| {
                        try TopicSnapshot.encode(item, writer, version);
                    }
                }
            }
        }


        if (is_flexible) {
            var num_tagged_fields: u32 = 0;
            if (version >= 0 and version <= 32767) {
                if (self.cluster_id != null) num_tagged_fields += 1;
            }

            // Count unknown tagged fields
            if (self._tagged_fields) |fields| {
                num_tagged_fields += @intCast(fields.len);
            }

            try types.encodeUnsignedVarInt(writer, num_tagged_fields);

            // Tagged field: ClusterId (tag 0)
            if (version >= 0 and version <= 32767) {
                if (self.cluster_id) |val| {
                    try types.encodeUnsignedVarInt(writer, 0);
                    const size = types.computeSizeCompactString(val);
                    try types.encodeUnsignedVarInt(writer, @intCast(size));
                    try types.encodeCompactString(writer, val);
                }
            }

            // Encode unknown tagged fields
            if (self._tagged_fields) |fields| {
                try types.encodeTaggedFields(writer, fields);
            }
        }
    }

    /// Compute the size of FetchSnapshotRequest for the given version
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

        // Field: MaxBytes
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.max_bytes);
        }

        // Field: Topics
        if (version >= 0 and version <= 32767) {
            if (self.topics) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try TopicSnapshot.computeSize(item, version);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(1) else 4;
            }
        }

        if (is_flexible) {
            var num_tagged_fields: u32 = 0;
            if (version >= 0 and version <= 32767) {
                if (self.cluster_id != null) num_tagged_fields += 1;
            }

            if (self._tagged_fields) |fields| {
                num_tagged_fields += @intCast(fields.len);
            }

            total_size += types.computeSizeUnsignedVarInt(num_tagged_fields);

            // Tagged field: ClusterId (tag 0)
            if (version >= 0 and version <= 32767) {
                if (self.cluster_id) |val| {
                    total_size += types.computeSizeUnsignedVarInt(0);
                    const size = types.computeSizeCompactString(val);
                    total_size += types.computeSizeUnsignedVarInt(@intCast(size));
                    total_size += size;
                }
            }

            if (self._tagged_fields) |fields| {
                total_size += types.computeSizeTaggedFields(fields);
            }
        }

        return total_size;
    }

    /// Decode FetchSnapshotRequest
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

        // Field: MaxBytes
        if (version >= 0 and version <= 32767) {
            self.max_bytes = try types.decodeInt32(reader);
        }

        // Field: Topics
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(TopicSnapshot, array_len);
            for (array) |*item| {
                item.* = try TopicSnapshot.decode(reader, version, allocator);
            }
            self.topics = array;
        }


        if (is_flexible) {
            const num_tagged_fields = try types.decodeUnsignedVarInt(reader);
            var unknown_tagged_fields = std.ArrayList(types.TaggedField).init(allocator);

            var i: u32 = 0;
            while (i < num_tagged_fields) : (i += 1) {
                const tag = try types.decodeUnsignedVarInt(reader);
                const size = try types.decodeUnsignedVarInt(reader);
                switch (tag) {
                    0 => { // ClusterId
                        if (version >= 0 and version <= 32767) {
                            self.cluster_id = try types.decodeCompactString(reader, allocator);
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
        const range = types.VersionRange.parse("0-1") catch return false;
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
