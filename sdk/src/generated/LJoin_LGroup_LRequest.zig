//! Auto-generated Kafka protocol message
//! Message: JoinGroupRequest
//! API Key: 11
//! Type: request
//! Valid Versions: 0-9
//! Flexible Versions: 6+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// Nested struct: JoinGroupRequestProtocol
pub const JoinGroupRequestProtocol = struct {
    const Self = @This();

    /// The protocol name.
    /// Versions: 0+
    name: []const u8 = "",
    /// The protocol metadata.
    /// Versions: 0+
    metadata: []const u8 = &[_]u8{},

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

        // Field: Metadata
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactBytes(writer, self.metadata);
            } else {
                try types.encodeBytes(writer, self.metadata);
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

        // Field: Metadata
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactBytes(self.metadata) else types.computeSizeBytes(self.metadata);
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

        // Field: Metadata
        if (version >= 0 and version <= 32767) {
            self.metadata = if (is_flexible)
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
        const range = types.VersionRange.parse("6+") catch return false;
        return range.contains(version);
    }
};

/// JoinGroupRequest
pub const JoinGroupRequest = struct {
    const Self = @This();

    /// The group identifier.
    group_id: []const u8 = "",
    /// The coordinator considers the consumer dead if it receives no heartbeat after this timeout in milliseconds.
    session_timeout_ms: i32 = 0,
    /// The maximum time in milliseconds that the coordinator will wait for each member to rejoin when rebalancing the group.
    /// Versions: 1+
    rebalance_timeout_ms: i32 = -1,
    /// The member id assigned by the group coordinator.
    member_id: []const u8 = "",
    /// The unique identifier of the consumer instance provided by end user.
    /// Versions: 5+
    group_instance_id: ?[]const u8 = null,
    /// The unique name the for class of protocols implemented by the group we want to join.
    protocol_type: []const u8 = "",
    /// The list of protocols that the member supports.
    protocols: ?[]JoinGroupRequestProtocol = null,
    /// The reason why the member (re-)joins the group.
    /// Versions: 8+
    reason: ?[]const u8 = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 0, .max = 9 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 11;
    }

    /// Create a default instance of JoinGroupRequest
    pub fn default() Self {
        return .{
            .group_id = "",
            .session_timeout_ms = 0,
            .rebalance_timeout_ms = -1,
            .member_id = "",
            .group_instance_id = null,
            .protocol_type = "",
            .protocols = null,
            .reason = null,
            ._tagged_fields = null,
        };
    }

    /// Sets `group_id` to the passed value.
    /// The group identifier.
    pub fn withGroupId(self: Self, value: []const u8) Self {
        var result = self;
        result.group_id = value;
        return result;
    }

    /// Sets `session_timeout_ms` to the passed value.
    /// The coordinator considers the consumer dead if it receives no heartbeat after this timeout in milliseconds.
    pub fn withSessionTimeoutMs(self: Self, value: i32) Self {
        var result = self;
        result.session_timeout_ms = value;
        return result;
    }

    /// Sets `rebalance_timeout_ms` to the passed value.
    /// The maximum time in milliseconds that the coordinator will wait for each member to rejoin when rebalancing the group.
    /// Versions: 1+
    pub fn withRebalanceTimeoutMs(self: Self, value: i32) Self {
        var result = self;
        result.rebalance_timeout_ms = value;
        return result;
    }

    /// Sets `member_id` to the passed value.
    /// The member id assigned by the group coordinator.
    pub fn withMemberId(self: Self, value: []const u8) Self {
        var result = self;
        result.member_id = value;
        return result;
    }

    /// Sets `group_instance_id` to the passed value.
    /// The unique identifier of the consumer instance provided by end user.
    /// Versions: 5+
    pub fn withGroupInstanceId(self: Self, value: ?[]const u8) Self {
        var result = self;
        result.group_instance_id = value;
        return result;
    }

    /// Sets `protocol_type` to the passed value.
    /// The unique name the for class of protocols implemented by the group we want to join.
    pub fn withProtocolType(self: Self, value: []const u8) Self {
        var result = self;
        result.protocol_type = value;
        return result;
    }

    /// Sets `protocols` to the passed value.
    /// The list of protocols that the member supports.
    pub fn withProtocols(self: Self, value: ?[]JoinGroupRequestProtocol) Self {
        var result = self;
        result.protocols = value;
        return result;
    }

    /// Sets `reason` to the passed value.
    /// The reason why the member (re-)joins the group.
    /// Versions: 8+
    pub fn withReason(self: Self, value: ?[]const u8) Self {
        var result = self;
        result.reason = value;
        return result;
    }

    /// Encode JoinGroupRequest
    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: GroupId
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.group_id);
            } else {
                try types.encodeString(writer, self.group_id);
            }
        }

        // Field: SessionTimeoutMs
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.session_timeout_ms);
        }

        // Field: RebalanceTimeoutMs
        if (version >= 1 and version <= 32767) {
            try types.encodeInt32(writer, self.rebalance_timeout_ms);
        }

        // Field: MemberId
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.member_id);
            } else {
                try types.encodeString(writer, self.member_id);
            }
        }

        // Field: GroupInstanceId
        if (version >= 5 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.group_instance_id);
            } else {
                try types.encodeString(writer, self.group_instance_id);
            }
        }

        // Field: ProtocolType
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.protocol_type);
            } else {
                try types.encodeString(writer, self.protocol_type);
            }
        }

        // Field: Protocols
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLen(writer, self.protocols);
                if (self.protocols) |arr| {
                    for (arr) |*item| {
                        try JoinGroupRequestProtocol.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLen(writer, self.protocols);
                if (self.protocols) |arr| {
                    for (arr) |*item| {
                        try JoinGroupRequestProtocol.encode(item, writer, version);
                    }
                }
            }
        }

        // Field: Reason
        if (version >= 8 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.reason);
            } else {
                try types.encodeString(writer, self.reason);
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

    /// Compute the size of JoinGroupRequest for the given version
    pub fn computeSize(self: *const Self, version: i16) !usize {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        var total_size: usize = 0;

        // Field: GroupId
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.group_id) else types.computeSizeString(self.group_id);
        }

        // Field: SessionTimeoutMs
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.session_timeout_ms);
        }

        // Field: RebalanceTimeoutMs
        if (version >= 1 and version <= 32767) {
            total_size += types.computeSizeInt32(self.rebalance_timeout_ms);
        }

        // Field: MemberId
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.member_id) else types.computeSizeString(self.member_id);
        }

        // Field: GroupInstanceId
        if (version >= 5 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.group_instance_id) else types.computeSizeString(self.group_instance_id);
        }

        // Field: ProtocolType
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.protocol_type) else types.computeSizeString(self.protocol_type);
        }

        // Field: Protocols
        if (version >= 0 and version <= 32767) {
            if (self.protocols) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try JoinGroupRequestProtocol.computeSize(item, version);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(0) else 4;
            }
        }

        // Field: Reason
        if (version >= 8 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.reason) else types.computeSizeString(self.reason);
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

    /// Decode JoinGroupRequest
    pub fn decode(reader: anytype, version: i16, allocator: std.mem.Allocator) !Self {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        var self: Self = .{};

        // Field: GroupId
        if (version >= 0 and version <= 32767) {
            self.group_id = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: SessionTimeoutMs
        if (version >= 0 and version <= 32767) {
            self.session_timeout_ms = try types.decodeInt32(reader);
        }

        // Field: RebalanceTimeoutMs
        if (version >= 1 and version <= 32767) {
            self.rebalance_timeout_ms = try types.decodeInt32(reader);
        }

        // Field: MemberId
        if (version >= 0 and version <= 32767) {
            self.member_id = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: GroupInstanceId
        if (version >= 5 and version <= 32767) {
            self.group_instance_id = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: ProtocolType
        if (version >= 0 and version <= 32767) {
            self.protocol_type = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: Protocols
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(JoinGroupRequestProtocol, array_len);
            for (array) |*item| {
                item.* = try JoinGroupRequestProtocol.decode(reader, version, allocator);
            }
            self.protocols = array;
        }

        // Field: Reason
        if (version >= 8 and version <= 32767) {
            self.reason = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
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
        const range = types.VersionRange.parse("0-9") catch return false;
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
