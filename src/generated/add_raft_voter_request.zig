//! Auto-generated Kafka protocol message
//! Message: AddRaftVoterRequest
//! API Key: 80
//! Type: request
//! Valid Versions: 0-1
//! Flexible Versions: 0+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// Nested struct: Listener
pub const Listener = struct {
    const Self = @This();

    /// The name of the endpoint.
    /// Versions: 0+
    name: []const u8 = "",
    /// The hostname.
    /// Versions: 0+
    host: []const u8 = "",
    /// The port.
    /// Versions: 0+
    port: u16 = 0,

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

        // Field: Name
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.name) else types.computeSizeString(self.name);
        }

        // Field: Host
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.host) else types.computeSizeString(self.host);
        }

        // Field: Port
        if (version >= 0 and version <= 32767) {
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
        // Field: Name
        if (version >= 0 and version <= 32767) {
            self.name = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
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

/// AddRaftVoterRequest
pub const AddRaftVoterRequest = struct {
    const Self = @This();

    /// The cluster id.
    cluster_id: ?[]const u8 = null,
    /// The maximum time to wait for the request to complete before returning.
    timeout_ms: i32 = 0,
    /// The replica id of the voter getting added to the topic partition.
    voter_id: i32 = 0,
    /// The directory id of the voter getting added to the topic partition.
    voter_directory_id: [16]u8 = [_]u8{0} ** 16,
    /// The endpoints that can be used to communicate with the voter.
    listeners: ?[]Listener = null,
    /// When true, return a response after the new voter set is committed. Otherwise, return after the leader writes the changes locally.
    /// Versions: 1+
    ack_when_committed: bool = true,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 0, .max = 1 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 80;
    }

    /// Create a default instance of AddRaftVoterRequest
    pub fn default() Self {
        return .{
            .cluster_id = null,
            .timeout_ms = 0,
            .voter_id = 0,
            .voter_directory_id = [_]u8{0} ** 16,
            .listeners = null,
            .ack_when_committed = true,
            ._tagged_fields = null,
        };
    }

    /// Sets `cluster_id` to the passed value.
    /// The cluster id.
    pub fn withClusterId(self: Self, value: ?[]const u8) Self {
        var result = self;
        result.cluster_id = value;
        return result;
    }

    /// Sets `timeout_ms` to the passed value.
    /// The maximum time to wait for the request to complete before returning.
    pub fn withTimeoutMs(self: Self, value: i32) Self {
        var result = self;
        result.timeout_ms = value;
        return result;
    }

    /// Sets `voter_id` to the passed value.
    /// The replica id of the voter getting added to the topic partition.
    pub fn withVoterId(self: Self, value: i32) Self {
        var result = self;
        result.voter_id = value;
        return result;
    }

    /// Sets `voter_directory_id` to the passed value.
    /// The directory id of the voter getting added to the topic partition.
    pub fn withVoterDirectoryId(self: Self, value: [16]u8) Self {
        var result = self;
        result.voter_directory_id = value;
        return result;
    }

    /// Sets `listeners` to the passed value.
    /// The endpoints that can be used to communicate with the voter.
    pub fn withListeners(self: Self, value: ?[]Listener) Self {
        var result = self;
        result.listeners = value;
        return result;
    }

    /// Sets `ack_when_committed` to the passed value.
    /// When true, return a response after the new voter set is committed. Otherwise, return after the leader writes the changes locally.
    /// Versions: 1+
    pub fn withAckWhenCommitted(self: Self, value: bool) Self {
        var result = self;
        result.ack_when_committed = value;
        return result;
    }

    /// Encode AddRaftVoterRequest
    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: ClusterId
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.cluster_id);
            } else {
                try types.encodeString(writer, self.cluster_id);
            }
        }

        // Field: TimeoutMs
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.timeout_ms);
        }

        // Field: VoterId
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.voter_id);
        }

        // Field: VoterDirectoryId
        if (version >= 0 and version <= 32767) {
            try types.encodeUuid(writer, self.voter_directory_id);
        }

        // Field: Listeners
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.listeners);
                if (self.listeners) |arr| {
                    for (arr) |*item| {
                        try Listener.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.listeners);
                if (self.listeners) |arr| {
                    for (arr) |*item| {
                        try Listener.encode(item, writer, version);
                    }
                }
            }
        }

        // Field: AckWhenCommitted
        if (version >= 1 and version <= 32767) {
            try types.encodeBoolean(writer, self.ack_when_committed);
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

    /// Compute the size of AddRaftVoterRequest for the given version
    pub fn computeSize(self: *const Self, version: i16) !usize {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        var total_size: usize = 0;

        // Field: ClusterId
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.cluster_id) else types.computeSizeString(self.cluster_id);
        }

        // Field: TimeoutMs
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.timeout_ms);
        }

        // Field: VoterId
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.voter_id);
        }

        // Field: VoterDirectoryId
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeUuid(self.voter_directory_id);
        }

        // Field: Listeners
        if (version >= 0 and version <= 32767) {
            if (self.listeners) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try Listener.computeSize(item, version);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(1) else 4;
            }
        }

        // Field: AckWhenCommitted
        if (version >= 1 and version <= 32767) {
            total_size += types.computeSizeBoolean(self.ack_when_committed);
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

    /// Decode AddRaftVoterRequest
    pub fn decode(reader: anytype, version: i16, allocator: std.mem.Allocator) !Self {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        var self: Self = .{};

        // Field: ClusterId
        if (version >= 0 and version <= 32767) {
            self.cluster_id = if (is_flexible)
                try types.decodeCompactString(reader, allocator)
            else
                try types.decodeString(reader, allocator);
        }

        // Field: TimeoutMs
        if (version >= 0 and version <= 32767) {
            self.timeout_ms = try types.decodeInt32(reader);
        }

        // Field: VoterId
        if (version >= 0 and version <= 32767) {
            self.voter_id = try types.decodeInt32(reader);
        }

        // Field: VoterDirectoryId
        if (version >= 0 and version <= 32767) {
            self.voter_directory_id = try types.decodeUuid(reader);
        }

        // Field: Listeners
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(Listener, array_len);
            for (array) |*item| {
                item.* = try Listener.decode(reader, version, allocator);
            }
            self.listeners = array;
        }

        // Field: AckWhenCommitted
        if (version >= 1 and version <= 32767) {
            self.ack_when_committed = try types.decodeBoolean(reader);
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
