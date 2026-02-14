//! Auto-generated Kafka protocol message
//! Message: FetchSnapshotResponse
//! API Key: 59
//! Type: response
//! Valid Versions: 0-1
//! Flexible Versions: 0+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// Nested struct: NodeEndpoint
pub const NodeEndpoint = struct {
    const Self = @This();

    /// The ID of the associated node.
    /// Versions: 1+
    node_id: i32 = 0,
    /// The node's hostname.
    /// Versions: 1+
    host: []const u8 = "",
    /// The node's port.
    /// Versions: 1+
    port: u16 = 0,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: NodeId
        if (version >= 1 and version <= 32767) {
            try types.encodeInt32(writer, self.node_id);
        }

        // Field: Host
        if (version >= 1 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.host);
            } else {
                try types.encodeString(writer, self.host);
            }
        }

        // Field: Port
        if (version >= 1 and version <= 32767) {
            try types.encodeUint16(writer, self.port);
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
        if (version >= 1 and version <= 32767) {
            total_size += types.computeSizeInt32(self.node_id);
        }

        // Field: Host
        if (version >= 1 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.host) else types.computeSizeString(self.host);
        }

        // Field: Port
        if (version >= 1 and version <= 32767) {
            total_size += types.computeSizeUint16(self.port);
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
        if (version >= 1 and version <= 32767) {
            self.node_id = try types.decodeInt32(reader);
        }

        // Field: Host
        if (version >= 1 and version <= 32767) {
            self.host = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: Port
        if (version >= 1 and version <= 32767) {
            self.port = try types.decodeUint16(reader);
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
    index: i32 = 0,
    /// The error code, or 0 if there was no fetch error.
    /// Versions: 0+
    error_code: i16 = 0,
    /// The snapshot endOffset and epoch fetched.
    /// Versions: 0+
    snapshot_id: SnapshotId = .{},
    /// The total size of the snapshot.
    /// Versions: 0+
    size: i64 = 0,
    /// The starting byte position within the snapshot included in the Bytes field.
    /// Versions: 0+
    position: i64 = 0,
    /// Snapshot data in records format which may not be aligned on an offset boundary.
    /// Versions: 0+
    unaligned_records: []const u8 = .{},

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: Index
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.index);
        }

        // Field: ErrorCode
        if (version >= 0 and version <= 32767) {
            try types.encodeInt16(writer, self.error_code);
        }

        // Field: SnapshotId
        if (version >= 0 and version <= 32767) {
            try SnapshotId.encode(&self.snapshot_id, writer, version);
        }

        // Field: Size
        if (version >= 0 and version <= 32767) {
            try types.encodeInt64(writer, self.size);
        }

        // Field: Position
        if (version >= 0 and version <= 32767) {
            try types.encodeInt64(writer, self.position);
        }

        // Field: UnalignedRecords
        if (version >= 0 and version <= 32767) {
            try types.encodeBytes(writer, self.unaligned_records);
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

        // Field: ErrorCode
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt16(self.error_code);
        }

        // Field: SnapshotId
        if (version >= 0 and version <= 32767) {
            total_size += try SnapshotId.computeSize(&self.snapshot_id, version);
        }

        // Field: Size
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt64(self.size);
        }

        // Field: Position
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt64(self.position);
        }

        // Field: UnalignedRecords
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeBytes(self.unaligned_records);
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

        // Field: ErrorCode
        if (version >= 0 and version <= 32767) {
            self.error_code = try types.decodeInt16(reader);
        }

        // Field: SnapshotId
        if (version >= 0 and version <= 32767) {
            self.snapshot_id = try SnapshotId.decode(reader, version, allocator);
        }

        // Field: Size
        if (version >= 0 and version <= 32767) {
            self.size = try types.decodeInt64(reader);
        }

        // Field: Position
        if (version >= 0 and version <= 32767) {
            self.position = try types.decodeInt64(reader);
        }

        // Field: UnalignedRecords
        if (version >= 0 and version <= 32767) {
            self.unaligned_records = try types.decodeBytes(reader, allocator) orelse "";
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

/// Nested struct: SnapshotId
pub const SnapshotId = struct {
    const Self = @This();

    /// The snapshot end offset.
    /// Versions: 0+
    end_offset: i64 = 0,
    /// The snapshot epoch.
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

/// FetchSnapshotResponse
pub const FetchSnapshotResponse = struct {
    const Self = @This();

    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    throttle_time_ms: i32 = 0,
    /// The top level response error code.
    error_code: i16 = 0,
    /// The topics to fetch.
    topics: ?[]TopicSnapshot = null,
    /// Endpoints for all current-leaders enumerated in PartitionSnapshot.
    /// Versions: 1+
    node_endpoints: ?[]NodeEndpoint = null,

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

    /// Create a default instance of FetchSnapshotResponse
    pub fn default() Self {
        return .{
            .throttle_time_ms = 0,
            .error_code = 0,
            .topics = null,
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
    /// The top level response error code.
    pub fn withErrorCode(self: Self, value: i16) Self {
        var result = self;
        result.error_code = value;
        return result;
    }

    /// Sets `topics` to the passed value.
    /// The topics to fetch.
    pub fn withTopics(self: Self, value: ?[]TopicSnapshot) Self {
        var result = self;
        result.topics = value;
        return result;
    }

    /// Sets `node_endpoints` to the passed value.
    /// Endpoints for all current-leaders enumerated in PartitionSnapshot.
    /// Versions: 1+
    pub fn withNodeEndpoints(self: Self, value: ?[]NodeEndpoint) Self {
        var result = self;
        result.node_endpoints = value;
        return result;
    }

    /// Encode FetchSnapshotResponse
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
            if (version >= 1 and version <= 32767) {
                if (self.node_endpoints != null) num_tagged_fields += 1;
            }

            // Count unknown tagged fields
            if (self._tagged_fields) |fields| {
                num_tagged_fields += @intCast(fields.len);
            }

            try types.encodeUnsignedVarInt(writer, num_tagged_fields);

            // Tagged field: NodeEndpoints (tag 0)
            if (version >= 1 and version <= 32767) {
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

    /// Compute the size of FetchSnapshotResponse for the given version
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
            if (version >= 1 and version <= 32767) {
                if (self.node_endpoints != null) num_tagged_fields += 1;
            }

            if (self._tagged_fields) |fields| {
                num_tagged_fields += @intCast(fields.len);
            }

            total_size += types.computeSizeUnsignedVarInt(num_tagged_fields);

            // Tagged field: NodeEndpoints (tag 0)
            if (version >= 1 and version <= 32767) {
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

    /// Decode FetchSnapshotResponse
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
                    0 => { // NodeEndpoints
                        if (version >= 1 and version <= 32767) {
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
