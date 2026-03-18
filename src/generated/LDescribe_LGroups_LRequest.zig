//! Auto-generated Kafka protocol message
//! Message: DescribeGroupsRequest
//! API Key: 15
//! Type: request
//! Valid Versions: 0-6
//! Flexible Versions: 5+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// DescribeGroupsRequest
pub const DescribeGroupsRequest = struct {
    const Self = @This();

    /// The names of the groups to describe.
    groups: ?[][]const u8 = null,
    /// Whether to include authorized operations.
    /// Versions: 3+
    include_authorized_operations: bool = false,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 0, .max = 6 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 15;
    }

    /// Create a default instance of DescribeGroupsRequest
    pub fn default() Self {
        return .{
            .groups = null,
            .include_authorized_operations = false,
            ._tagged_fields = null,
        };
    }

    /// Sets `groups` to the passed value.
    /// The names of the groups to describe.
    pub fn withGroups(self: Self, value: ?[][]const u8) Self {
        var result = self;
        result.groups = value;
        return result;
    }

    /// Sets `include_authorized_operations` to the passed value.
    /// Whether to include authorized operations.
    /// Versions: 3+
    pub fn withIncludeAuthorizedOperations(self: Self, value: bool) Self {
        var result = self;
        result.include_authorized_operations = value;
        return result;
    }

    /// Encode DescribeGroupsRequest
    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: Groups
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArray([]const u8, writer, self.groups, types.encodeCompactString);
            } else {
                try types.encodeArray([]const u8, writer, self.groups, types.encodeCompactString);
            }
        }

        // Field: IncludeAuthorizedOperations
        if (version >= 3 and version <= 32767) {
            try types.encodeBoolean(writer, self.include_authorized_operations);
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

    /// Compute the size of DescribeGroupsRequest for the given version
    pub fn computeSize(self: *const Self, version: i16) !usize {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        var total_size: usize = 0;

        // Field: Groups
        if (version >= 0 and version <= 32767) {
            if (self.groups) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |item| {
                    total_size += types.computeSizeCompactString(item);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(0) else 4;
            }
        }

        // Field: IncludeAuthorizedOperations
        if (version >= 3 and version <= 32767) {
            total_size += types.computeSizeBoolean(self.include_authorized_operations);
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

    /// Decode DescribeGroupsRequest
    pub fn decode(reader: anytype, version: i16, allocator: std.mem.Allocator) !Self {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        var self: Self = .{};

        // Field: Groups
        if (version >= 0 and version <= 32767) {
            self.groups = if (is_flexible)
                try types.decodeCompactArray([]const u8, reader, allocator, types.decodeCompactString)
            else
                try types.decodeArray([]const u8, reader, allocator, types.decodeCompactString);
        }

        // Field: IncludeAuthorizedOperations
        if (version >= 3 and version <= 32767) {
            self.include_authorized_operations = try types.decodeBoolean(reader);
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
        const range = types.VersionRange.parse("0-6") catch return false;
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
