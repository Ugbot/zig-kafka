//! Auto-generated Kafka protocol message
//! Message: VotersRecord
//! Type: data
//! Valid Versions: 0
//! Flexible Versions: 0+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// Nested struct: Voter
pub const Voter = struct {
    const Self = @This();

    /// The replica id of the voter in the topic partition.
    /// Versions: 0+
    voter_id: i32 = 0,
    /// The directory id of the voter in the topic partition.
    /// Versions: 0+
    voter_directory_id: [16]u8 = [_]u8{0} ** 16,
    /// The endpoint that can be used to communicate with the voter.
    /// Versions: 0+
    endpoints: ?[]Endpoint = null,
    /// The range of versions of the protocol that the replica supports.
    /// Versions: 0+
    k_raft_version_feature: KRaftVersionFeature = .{},

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: VoterId
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.voter_id);
        }

        // Field: VoterDirectoryId
        if (version >= 0 and version <= 32767) {
            try types.encodeUuid(writer, self.voter_directory_id);
        }

        // Field: Endpoints
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.endpoints);
                if (self.endpoints) |arr| {
                    for (arr) |*item| {
                        try Endpoint.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.endpoints);
                if (self.endpoints) |arr| {
                    for (arr) |*item| {
                        try Endpoint.encode(item, writer, version);
                    }
                }
            }
        }

        // Field: KRaftVersionFeature
        if (version >= 0 and version <= 32767) {
            try KRaftVersionFeature.encode(&self.k_raft_version_feature, writer, version);
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

        // Field: VoterId
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.voter_id);
        }

        // Field: VoterDirectoryId
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeUuid(self.voter_directory_id);
        }

        // Field: Endpoints
        if (version >= 0 and version <= 32767) {
            if (self.endpoints) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try Endpoint.computeSize(item, version);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(1) else 4;
            }
        }

        // Field: KRaftVersionFeature
        if (version >= 0 and version <= 32767) {
            total_size += try KRaftVersionFeature.computeSize(&self.k_raft_version_feature, version);
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
        // Field: VoterId
        if (version >= 0 and version <= 32767) {
            self.voter_id = try types.decodeInt32(reader);
        }

        // Field: VoterDirectoryId
        if (version >= 0 and version <= 32767) {
            self.voter_directory_id = try types.decodeUuid(reader);
        }

        // Field: Endpoints
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(Endpoint, array_len);
            for (array) |*item| {
                item.* = try Endpoint.decode(reader, version, allocator);
            }
            self.endpoints = array;
        }

        // Field: KRaftVersionFeature
        if (version >= 0 and version <= 32767) {
            self.k_raft_version_feature = try KRaftVersionFeature.decode(reader, version, allocator);
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

/// Nested struct: KRaftVersionFeature
pub const KRaftVersionFeature = struct {
    const Self = @This();

    /// The minimum supported KRaft protocol version.
    /// Versions: 0+
    min_supported_version: i16 = 0,
    /// The maximum supported KRaft protocol version.
    /// Versions: 0+
    max_supported_version: i16 = 0,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: MinSupportedVersion
        if (version >= 0 and version <= 32767) {
            try types.encodeInt16(writer, self.min_supported_version);
        }

        // Field: MaxSupportedVersion
        if (version >= 0 and version <= 32767) {
            try types.encodeInt16(writer, self.max_supported_version);
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

        // Field: MinSupportedVersion
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt16(self.min_supported_version);
        }

        // Field: MaxSupportedVersion
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt16(self.max_supported_version);
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
        // Field: MinSupportedVersion
        if (version >= 0 and version <= 32767) {
            self.min_supported_version = try types.decodeInt16(reader);
        }

        // Field: MaxSupportedVersion
        if (version >= 0 and version <= 32767) {
            self.max_supported_version = try types.decodeInt16(reader);
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

/// Nested struct: Endpoint
pub const Endpoint = struct {
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

/// VotersRecord
pub const VotersRecord = struct {
    const Self = @This();

    /// The version of the voters record.
    version: i16 = 0,
    /// The set of voters in the quorum for this epoch.
    voters: ?[]Voter = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 0, .max = 0 };

    /// Create a default instance of VotersRecord
    pub fn default() Self {
        return .{
            .version = 0,
            .voters = null,
            ._tagged_fields = null,
        };
    }

    /// Sets `version` to the passed value.
    /// The version of the voters record.
    pub fn withVersion(self: Self, value: i16) Self {
        var result = self;
        result.version = value;
        return result;
    }

    /// Sets `voters` to the passed value.
    /// The set of voters in the quorum for this epoch.
    pub fn withVoters(self: Self, value: ?[]Voter) Self {
        var result = self;
        result.voters = value;
        return result;
    }

    /// Encode VotersRecord
    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: Version
        if (version >= 0 and version <= 32767) {
            try types.encodeInt16(writer, self.version);
        }

        // Field: Voters
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.voters);
                if (self.voters) |arr| {
                    for (arr) |*item| {
                        try Voter.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.voters);
                if (self.voters) |arr| {
                    for (arr) |*item| {
                        try Voter.encode(item, writer, version);
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

    /// Compute the size of VotersRecord for the given version
    pub fn computeSize(self: *const Self, version: i16) !usize {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        var total_size: usize = 0;

        // Field: Version
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt16(self.version);
        }

        // Field: Voters
        if (version >= 0 and version <= 32767) {
            if (self.voters) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try Voter.computeSize(item, version);
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

    /// Decode VotersRecord
    pub fn decode(reader: anytype, version: i16, allocator: std.mem.Allocator) !Self {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        var self: Self = .{};

        // Field: Version
        if (version >= 0 and version <= 32767) {
            self.version = try types.decodeInt16(reader);
        }

        // Field: Voters
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(Voter, array_len);
            for (array) |*item| {
                item.* = try Voter.decode(reader, version, allocator);
            }
            self.voters = array;
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
        const range = types.VersionRange.parse("0") catch return false;
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
