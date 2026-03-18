//! Auto-generated Kafka protocol message
//! Message: RemoveRaftVoterRequest
//! API Key: 81
//! Type: request
//! Valid Versions: 0
//! Flexible Versions: 0+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// RemoveRaftVoterRequest
pub const RemoveRaftVoterRequest = struct {
    const Self = @This();

    /// The cluster id of the request.
    cluster_id: ?[]const u8 = null,
    /// The replica id of the voter getting removed from the topic partition.
    voter_id: i32 = 0,
    /// The directory id of the voter getting removed from the topic partition.
    voter_directory_id: [16]u8 = [_]u8{0} ** 16,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 0, .max = 0 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 81;
    }

    /// Create a default instance of RemoveRaftVoterRequest
    pub fn default() Self {
        return .{
            .cluster_id = null,
            .voter_id = 0,
            .voter_directory_id = [_]u8{0} ** 16,
            ._tagged_fields = null,
        };
    }

    /// Sets `cluster_id` to the passed value.
    /// The cluster id of the request.
    pub fn withClusterId(self: Self, value: ?[]const u8) Self {
        var result = self;
        result.cluster_id = value;
        return result;
    }

    /// Sets `voter_id` to the passed value.
    /// The replica id of the voter getting removed from the topic partition.
    pub fn withVoterId(self: Self, value: i32) Self {
        var result = self;
        result.voter_id = value;
        return result;
    }

    /// Sets `voter_directory_id` to the passed value.
    /// The directory id of the voter getting removed from the topic partition.
    pub fn withVoterDirectoryId(self: Self, value: [16]u8) Self {
        var result = self;
        result.voter_directory_id = value;
        return result;
    }

    /// Encode RemoveRaftVoterRequest
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

        // Field: VoterId
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.voter_id);
        }

        // Field: VoterDirectoryId
        if (version >= 0 and version <= 32767) {
            try types.encodeUuid(writer, self.voter_directory_id);
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

    /// Compute the size of RemoveRaftVoterRequest for the given version
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

        // Field: VoterId
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.voter_id);
        }

        // Field: VoterDirectoryId
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeUuid(self.voter_directory_id);
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

    /// Decode RemoveRaftVoterRequest
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

        // Field: VoterId
        if (version >= 0 and version <= 32767) {
            self.voter_id = try types.decodeInt32(reader);
        }

        // Field: VoterDirectoryId
        if (version >= 0 and version <= 32767) {
            self.voter_directory_id = try types.decodeUuid(reader);
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
