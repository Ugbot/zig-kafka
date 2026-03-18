//! Auto-generated Kafka protocol message
//! Message: CreateAclsRequest
//! API Key: 30
//! Type: request
//! Valid Versions: 1-3
//! Flexible Versions: 2+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// Nested struct: AclCreation
pub const AclCreation = struct {
    const Self = @This();

    /// The type of the resource.
    /// Versions: 0+
    resource_type: i8 = 0,
    /// The resource name for the ACL.
    /// Versions: 0+
    resource_name: []const u8 = "",
    /// The pattern type for the ACL.
    /// Versions: 1+
    resource_pattern_type: i8 = 3,
    /// The principal for the ACL.
    /// Versions: 0+
    principal: []const u8 = "",
    /// The host for the ACL.
    /// Versions: 0+
    host: []const u8 = "",
    /// The operation type for the ACL (read, write, etc.).
    /// Versions: 0+
    operation: i8 = 0,
    /// The permission type for the ACL (allow, deny, etc.).
    /// Versions: 0+
    permission_type: i8 = 0,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: ResourceType
        if (version >= 0 and version <= 32767) {
            try types.encodeInt8(writer, self.resource_type);
        }

        // Field: ResourceName
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.resource_name);
            } else {
                try types.encodeString(writer, self.resource_name);
            }
        }

        // Field: ResourcePatternType
        if (version >= 1 and version <= 32767) {
            try types.encodeInt8(writer, self.resource_pattern_type);
        }

        // Field: Principal
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.principal);
            } else {
                try types.encodeString(writer, self.principal);
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

        // Field: Operation
        if (version >= 0 and version <= 32767) {
            try types.encodeInt8(writer, self.operation);
        }

        // Field: PermissionType
        if (version >= 0 and version <= 32767) {
            try types.encodeInt8(writer, self.permission_type);
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

        // Field: ResourceType
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt8(self.resource_type);
        }

        // Field: ResourceName
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.resource_name) else types.computeSizeString(self.resource_name);
        }

        // Field: ResourcePatternType
        if (version >= 1 and version <= 32767) {
            total_size += types.computeSizeInt8(self.resource_pattern_type);
        }

        // Field: Principal
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.principal) else types.computeSizeString(self.principal);
        }

        // Field: Host
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.host) else types.computeSizeString(self.host);
        }

        // Field: Operation
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt8(self.operation);
        }

        // Field: PermissionType
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt8(self.permission_type);
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
        // Field: ResourceType
        if (version >= 0 and version <= 32767) {
            self.resource_type = try types.decodeInt8(reader);
        }

        // Field: ResourceName
        if (version >= 0 and version <= 32767) {
            self.resource_name = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: ResourcePatternType
        if (version >= 1 and version <= 32767) {
            self.resource_pattern_type = try types.decodeInt8(reader);
        }

        // Field: Principal
        if (version >= 0 and version <= 32767) {
            self.principal = if (is_flexible)
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

        // Field: Operation
        if (version >= 0 and version <= 32767) {
            self.operation = try types.decodeInt8(reader);
        }

        // Field: PermissionType
        if (version >= 0 and version <= 32767) {
            self.permission_type = try types.decodeInt8(reader);
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

/// CreateAclsRequest
pub const CreateAclsRequest = struct {
    const Self = @This();

    /// The ACLs that we want to create.
    creations: ?[]AclCreation = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 1, .max = 3 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 30;
    }

    /// Create a default instance of CreateAclsRequest
    pub fn default() Self {
        return .{
            .creations = null,
            ._tagged_fields = null,
        };
    }

    /// Sets `creations` to the passed value.
    /// The ACLs that we want to create.
    pub fn withCreations(self: Self, value: ?[]AclCreation) Self {
        var result = self;
        result.creations = value;
        return result;
    }

    /// Encode CreateAclsRequest
    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: Creations
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.creations);
                if (self.creations) |arr| {
                    for (arr) |*item| {
                        try AclCreation.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.creations);
                if (self.creations) |arr| {
                    for (arr) |*item| {
                        try AclCreation.encode(item, writer, version);
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

    /// Compute the size of CreateAclsRequest for the given version
    pub fn computeSize(self: *const Self, version: i16) !usize {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        var total_size: usize = 0;

        // Field: Creations
        if (version >= 0 and version <= 32767) {
            if (self.creations) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try AclCreation.computeSize(item, version);
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

    /// Decode CreateAclsRequest
    pub fn decode(reader: anytype, version: i16, allocator: std.mem.Allocator) !Self {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        var self: Self = .{};

        // Field: Creations
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(AclCreation, array_len);
            for (array) |*item| {
                item.* = try AclCreation.decode(reader, version, allocator);
            }
            self.creations = array;
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
