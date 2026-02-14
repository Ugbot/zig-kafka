//! Auto-generated Kafka protocol message
//! Message: CreateDelegationTokenRequest
//! API Key: 38
//! Type: request
//! Valid Versions: 1-3
//! Flexible Versions: 2+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// Nested struct: CreatableRenewers
pub const CreatableRenewers = struct {
    const Self = @This();

    /// The type of the Kafka principal.
    /// Versions: 0+
    principal_type: []const u8 = "",
    /// The name of the Kafka principal.
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

/// CreateDelegationTokenRequest
pub const CreateDelegationTokenRequest = struct {
    const Self = @This();

    /// The principal type of the owner of the token. If it's null it defaults to the token request principal.
    /// Versions: 3+
    owner_principal_type: ?[]const u8 = null,
    /// The principal name of the owner of the token. If it's null it defaults to the token request principal.
    /// Versions: 3+
    owner_principal_name: ?[]const u8 = null,
    /// A list of those who are allowed to renew this token before it expires.
    renewers: ?[]CreatableRenewers = null,
    /// The maximum lifetime of the token in milliseconds, or -1 to use the server side default.
    max_lifetime_ms: i64 = 0,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 1, .max = 3 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 38;
    }

    /// Create a default instance of CreateDelegationTokenRequest
    pub fn default() Self {
        return .{
            .owner_principal_type = null,
            .owner_principal_name = null,
            .renewers = null,
            .max_lifetime_ms = 0,
            ._tagged_fields = null,
        };
    }

    /// Sets `owner_principal_type` to the passed value.
    /// The principal type of the owner of the token. If it's null it defaults to the token request principal.
    /// Versions: 3+
    pub fn withOwnerPrincipalType(self: Self, value: ?[]const u8) Self {
        var result = self;
        result.owner_principal_type = value;
        return result;
    }

    /// Sets `owner_principal_name` to the passed value.
    /// The principal name of the owner of the token. If it's null it defaults to the token request principal.
    /// Versions: 3+
    pub fn withOwnerPrincipalName(self: Self, value: ?[]const u8) Self {
        var result = self;
        result.owner_principal_name = value;
        return result;
    }

    /// Sets `renewers` to the passed value.
    /// A list of those who are allowed to renew this token before it expires.
    pub fn withRenewers(self: Self, value: ?[]CreatableRenewers) Self {
        var result = self;
        result.renewers = value;
        return result;
    }

    /// Sets `max_lifetime_ms` to the passed value.
    /// The maximum lifetime of the token in milliseconds, or -1 to use the server side default.
    pub fn withMaxLifetimeMs(self: Self, value: i64) Self {
        var result = self;
        result.max_lifetime_ms = value;
        return result;
    }

    /// Encode CreateDelegationTokenRequest
    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: OwnerPrincipalType
        if (version >= 3 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.owner_principal_type);
            } else {
                try types.encodeString(writer, self.owner_principal_type);
            }
        }

        // Field: OwnerPrincipalName
        if (version >= 3 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.owner_principal_name);
            } else {
                try types.encodeString(writer, self.owner_principal_name);
            }
        }

        // Field: Renewers
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.renewers);
                if (self.renewers) |arr| {
                    for (arr) |*item| {
                        try CreatableRenewers.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.renewers);
                if (self.renewers) |arr| {
                    for (arr) |*item| {
                        try CreatableRenewers.encode(item, writer, version);
                    }
                }
            }
        }

        // Field: MaxLifetimeMs
        if (version >= 0 and version <= 32767) {
            try types.encodeInt64(writer, self.max_lifetime_ms);
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

    /// Compute the size of CreateDelegationTokenRequest for the given version
    pub fn computeSize(self: *const Self, version: i16) !usize {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        var total_size: usize = 0;

        // Field: OwnerPrincipalType
        if (version >= 3 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.owner_principal_type) else types.computeSizeString(self.owner_principal_type);
        }

        // Field: OwnerPrincipalName
        if (version >= 3 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.owner_principal_name) else types.computeSizeString(self.owner_principal_name);
        }

        // Field: Renewers
        if (version >= 0 and version <= 32767) {
            if (self.renewers) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try CreatableRenewers.computeSize(item, version);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(1) else 4;
            }
        }

        // Field: MaxLifetimeMs
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt64(self.max_lifetime_ms);
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

    /// Decode CreateDelegationTokenRequest
    pub fn decode(reader: anytype, version: i16, allocator: std.mem.Allocator) !Self {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        var self: Self = .{};

        // Field: OwnerPrincipalType
        if (version >= 3 and version <= 32767) {
            self.owner_principal_type = if (is_flexible)
                try types.decodeCompactString(reader, allocator)
            else
                try types.decodeString(reader, allocator);
        }

        // Field: OwnerPrincipalName
        if (version >= 3 and version <= 32767) {
            self.owner_principal_name = if (is_flexible)
                try types.decodeCompactString(reader, allocator)
            else
                try types.decodeString(reader, allocator);
        }

        // Field: Renewers
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(CreatableRenewers, array_len);
            for (array) |*item| {
                item.* = try CreatableRenewers.decode(reader, version, allocator);
            }
            self.renewers = array;
        }

        // Field: MaxLifetimeMs
        if (version >= 0 and version <= 32767) {
            self.max_lifetime_ms = try types.decodeInt64(reader);
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
