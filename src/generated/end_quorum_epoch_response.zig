//! Auto-generated Kafka protocol message
//! Message: EndQuorumEpochResponse
//! API Key: 54
//! Type: response
//! Valid Versions: 0-1
//! Flexible Versions: 1+
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
        const range = types.VersionRange.parse("1+") catch return false;
        return range.contains(version);
    }
};

/// Nested struct: TopicData
pub const TopicData = struct {
    const Self = @This();

    /// The topic name.
    /// Versions: 0+
    topic_name: []const u8 = "",
    /// The partition data.
    /// Versions: 0+
    partitions: ?[]PartitionData = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: TopicName
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.topic_name);
            } else {
                try types.encodeString(writer, self.topic_name);
            }
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

        // Field: TopicName
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.topic_name) else types.computeSizeString(self.topic_name);
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
        // Field: TopicName
        if (version >= 0 and version <= 32767) {
            self.topic_name = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
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
        const range = types.VersionRange.parse("1+") catch return false;
        return range.contains(version);
    }
};

/// Nested struct: PartitionData
pub const PartitionData = struct {
    const Self = @This();

    /// The partition index.
    /// Versions: 0+
    partition_index: i32 = 0,
    /// The partition level error code.
    /// Versions: 0+
    error_code: i16 = 0,
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

        // Field: PartitionIndex
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.partition_index);
        }

        // Field: ErrorCode
        if (version >= 0 and version <= 32767) {
            try types.encodeInt16(writer, self.error_code);
        }

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

        // Field: PartitionIndex
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.partition_index);
        }

        // Field: ErrorCode
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt16(self.error_code);
        }

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
        // Field: PartitionIndex
        if (version >= 0 and version <= 32767) {
            self.partition_index = try types.decodeInt32(reader);
        }

        // Field: ErrorCode
        if (version >= 0 and version <= 32767) {
            self.error_code = try types.decodeInt16(reader);
        }

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
        const range = types.VersionRange.parse("1+") catch return false;
        return range.contains(version);
    }
};

/// EndQuorumEpochResponse
pub const EndQuorumEpochResponse = struct {
    const Self = @This();

    /// The top level error code.
    error_code: i16 = 0,
    /// The topic data.
    topics: ?[]TopicData = null,
    /// Endpoints for all leaders enumerated in PartitionData.
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
        return 54;
    }

    /// Create a default instance of EndQuorumEpochResponse
    pub fn default() Self {
        return .{
            .error_code = 0,
            .topics = null,
            .node_endpoints = null,
            ._tagged_fields = null,
        };
    }

    /// Sets `error_code` to the passed value.
    /// The top level error code.
    pub fn withErrorCode(self: Self, value: i16) Self {
        var result = self;
        result.error_code = value;
        return result;
    }

    /// Sets `topics` to the passed value.
    /// The topic data.
    pub fn withTopics(self: Self, value: ?[]TopicData) Self {
        var result = self;
        result.topics = value;
        return result;
    }

    /// Sets `node_endpoints` to the passed value.
    /// Endpoints for all leaders enumerated in PartitionData.
    /// Versions: 1+
    pub fn withNodeEndpoints(self: Self, value: ?[]NodeEndpoint) Self {
        var result = self;
        result.node_endpoints = value;
        return result;
    }

    /// Encode EndQuorumEpochResponse
    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

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

    /// Compute the size of EndQuorumEpochResponse for the given version
    pub fn computeSize(self: *const Self, version: i16) !usize {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        var total_size: usize = 0;

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
                    total_size += try TopicData.computeSize(item, version);
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

    /// Decode EndQuorumEpochResponse
    pub fn decode(reader: anytype, version: i16, allocator: std.mem.Allocator) !Self {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        var self: Self = .{};

        // Field: ErrorCode
        if (version >= 0 and version <= 32767) {
            self.error_code = try types.decodeInt16(reader);
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
        const range = types.VersionRange.parse("1+") catch return false;
        return range.contains(version);
    }
    /// Get the header version for this API version
    /// Returns 2 for flexible versions, 1 for classic versions
    pub fn headerVersion(api_version: i16) i16 {
        if (isFlexibleVersion(api_version)) return 2;
        return 1;
    }

};
