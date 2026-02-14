//! Auto-generated Kafka protocol message
//! Message: LeaderChangeMessage
//! Type: data
//! Valid Versions: 0-1
//! Flexible Versions: 0+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// LeaderChangeMessage
pub const LeaderChangeMessage = struct {
    const Self = @This();

    /// The version of the leader change message.
    version: i16 = 0,
    /// The ID of the newly elected leader.
    leader_id: i32 = 0,
    /// The set of voters in the quorum for this epoch.
    voters: ?[]Voter = null,
    /// The voters who voted for the leader at the time of election.
    granting_voters: ?[]Voter = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 0, .max = 1 };

    /// Create a default instance of LeaderChangeMessage
    pub fn default() Self {
        return .{
            .version = 0,
            .leader_id = 0,
            .voters = null,
            .granting_voters = null,
            ._tagged_fields = null,
        };
    }

    /// Sets `version` to the passed value.
    /// The version of the leader change message.
    pub fn withVersion(self: Self, value: i16) Self {
        var result = self;
        result.version = value;
        return result;
    }

    /// Sets `leader_id` to the passed value.
    /// The ID of the newly elected leader.
    pub fn withLeaderId(self: Self, value: i32) Self {
        var result = self;
        result.leader_id = value;
        return result;
    }

    /// Sets `voters` to the passed value.
    /// The set of voters in the quorum for this epoch.
    pub fn withVoters(self: Self, value: ?[]Voter) Self {
        var result = self;
        result.voters = value;
        return result;
    }

    /// Sets `granting_voters` to the passed value.
    /// The voters who voted for the leader at the time of election.
    pub fn withGrantingVoters(self: Self, value: ?[]Voter) Self {
        var result = self;
        result.granting_voters = value;
        return result;
    }

    /// Encode LeaderChangeMessage
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

        // Field: LeaderId
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.leader_id);
        }

        // Field: Voters
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayNonNull(Voter, writer, self.voters, Voter.encode);
            } else {
                try types.encodeArrayNonNull(Voter, writer, self.voters, Voter.encode);
            }
        }

        // Field: GrantingVoters
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayNonNull(Voter, writer, self.granting_voters, Voter.encode);
            } else {
                try types.encodeArrayNonNull(Voter, writer, self.granting_voters, Voter.encode);
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

    /// Compute the size of LeaderChangeMessage for the given version
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

        // Field: LeaderId
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.leader_id);
        }

        // Field: Voters
        if (version >= 0 and version <= 32767) {
            if (self.voters) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |item| {
                    total_size += Voter.computeSize(item);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(1) else 4;
            }
        }

        // Field: GrantingVoters
        if (version >= 0 and version <= 32767) {
            if (self.granting_voters) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |item| {
                    total_size += Voter.computeSize(item);
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

    /// Decode LeaderChangeMessage
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

        // Field: LeaderId
        if (version >= 0 and version <= 32767) {
            self.leader_id = try types.decodeInt32(reader);
        }

        // Field: Voters
        if (version >= 0 and version <= 32767) {
            self.voters = if (is_flexible)
                try types.decodeCompactArray(Voter, reader, allocator, Voter.decode)
            else
                try types.decodeArray(Voter, reader, allocator, Voter.decode);
        }

        // Field: GrantingVoters
        if (version >= 0 and version <= 32767) {
            self.granting_voters = if (is_flexible)
                try types.decodeCompactArray(Voter, reader, allocator, Voter.decode)
            else
                try types.decodeArray(Voter, reader, allocator, Voter.decode);
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
