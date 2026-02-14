//! Auto-generated Kafka protocol message
//! Message: DescribeDelegationTokenRequest
//! API Key: 41
//! Type: request
//! Valid Versions: 1-3
//! Flexible Versions: 2+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// Nested struct: DescribeDelegationTokenOwner
pub const DescribeDelegationTokenOwner = struct {
    const Self = @This();

    /// The owner principal type.
    /// Versions: 0+
    principal_type: []const u8 = "",
    /// The owner principal name.
    /// Versions: 0+
    principal_name: []const u8 = "",

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: PrincipalType
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.principal_type);
            } else {
                try types.encodeString(writer, self.principal_type);
            }
        }

        // Field: PrincipalName
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.principal_name);
            } else {
                try types.encodeString(writer, self.principal_name);
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

        // Field: PrincipalType
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.principal_type) else types.computeSizeString(self.principal_type);
        }

        // Field: PrincipalName
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.principal_name) else types.computeSizeString(self.principal_name);
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
        // Field: PrincipalType
        if (version >= 0 and version <= 32767) {
            self.principal_type = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: PrincipalName
        if (version >= 0 and version <= 32767) {
            self.principal_name = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }


        if (is_flexible) {
            const tagged_fields_data = try types.decodeTaggedFields(reader, allocator);
            self._tagged_fields = tagged_fields_data;
        }
        return self;
    }

    fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("2+") catch return false;
        return range.contains(version);
    }
};

/// DescribeDelegationTokenRequest
pub const DescribeDelegationTokenRequest = struct {
    const Self = @This();

    /// Each owner that we want to describe delegation tokens for, or null to describe all tokens.
    owners: ?[]DescribeDelegationTokenOwner = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 1, .max = 3 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 41;
    }

    /// Create a default instance of DescribeDelegationTokenRequest
    pub fn default() Self {
        return .{
            .owners = null,
            ._tagged_fields = null,
        };
    }

    /// Sets `owners` to the passed value.
    /// Each owner that we want to describe delegation tokens for, or null to describe all tokens.
    pub fn withOwners(self: Self, value: ?[]DescribeDelegationTokenOwner) Self {
        var result = self;
        result.owners = value;
        return result;
    }

    /// Encode DescribeDelegationTokenRequest
    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: Owners
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLen(writer, self.owners);
                if (self.owners) |arr| {
                    for (arr) |*item| {
                        try DescribeDelegationTokenOwner.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLen(writer, self.owners);
                if (self.owners) |arr| {
                    for (arr) |*item| {
                        try DescribeDelegationTokenOwner.encode(item, writer, version);
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

    /// Compute the size of DescribeDelegationTokenRequest for the given version
    pub fn computeSize(self: *const Self, version: i16) !usize {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        var total_size: usize = 0;

        // Field: Owners
        if (version >= 0 and version <= 32767) {
            if (self.owners) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try DescribeDelegationTokenOwner.computeSize(item, version);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(0) else 4;
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

    /// Decode DescribeDelegationTokenRequest
    pub fn decode(reader: anytype, version: i16, allocator: std.mem.Allocator) !Self {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        var self: Self = .{};

        // Field: Owners
        if (version >= 0 and version <= 32767) {
            const raw_len: i32 = if (is_flexible) blk: {
                const v = try types.decodeUnsignedVarInt(reader);
                break :blk if (v == 0) @as(i32, -1) else @as(i32, @intCast(v - 1));
            } else try types.decodeInt32(reader);
            if (raw_len < 0) {
                self.owners = null;
            } else {
                const array_len: usize = @intCast(raw_len);
                const array = try allocator.alloc(DescribeDelegationTokenOwner, array_len);
                for (array) |*item| {
                    item.* = try DescribeDelegationTokenOwner.decode(reader, version, allocator);
                }
                self.owners = array;
            }
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
        const range = types.VersionRange.parse("1-3") catch return false;
        return range.contains(version);
    }
    /// Check if version uses flexible encoding
    pub fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("2+") catch return false;
        return range.contains(version);
    }
    /// Get the header version for this API version
    /// Returns 2 for flexible versions, 1 for classic versions
    pub fn headerVersion(api_version: i16) i16 {
        if (isFlexibleVersion(api_version)) return 2;
        return 1;
    }

};
