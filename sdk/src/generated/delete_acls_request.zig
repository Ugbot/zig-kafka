//! Auto-generated Kafka protocol message
//! Message: DeleteAclsRequest
//! API Key: 31
//! Type: request
//! Valid Versions: 1-3
//! Flexible Versions: 2+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// Nested struct: DeleteAclsFilter
pub const DeleteAclsFilter = struct {
    const Self = @This();

    /// The resource type.
    /// Versions: 0+
    resource_type_filter: i8 = 0,
    /// The resource name, or null to match any resource name.
    /// Versions: 0+
    resource_name_filter: ?[]const u8 = null,
    /// The pattern type.
    /// Versions: 1+
    pattern_type_filter: i8 = 3,
    /// The principal filter, or null to accept all principals.
    /// Versions: 0+
    principal_filter: ?[]const u8 = null,
    /// The host filter, or null to accept all hosts.
    /// Versions: 0+
    host_filter: ?[]const u8 = null,
    /// The ACL operation.
    /// Versions: 0+
    operation: i8 = 0,
    /// The permission type.
    /// Versions: 0+
    permission_type: i8 = 0,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: ResourceTypeFilter
        if (version >= 0 and version <= 32767) {
            try types.encodeInt8(writer, self.resource_type_filter);
        }

        // Field: ResourceNameFilter
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.resource_name_filter);
            } else {
                try types.encodeString(writer, self.resource_name_filter);
            }
        }

        // Field: PatternTypeFilter
        if (version >= 1 and version <= 32767) {
            try types.encodeInt8(writer, self.pattern_type_filter);
        }

        // Field: PrincipalFilter
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.principal_filter);
            } else {
                try types.encodeString(writer, self.principal_filter);
            }
        }

        // Field: HostFilter
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.host_filter);
            } else {
                try types.encodeString(writer, self.host_filter);
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

        // Field: ResourceTypeFilter
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt8(self.resource_type_filter);
        }

        // Field: ResourceNameFilter
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.resource_name_filter) else types.computeSizeString(self.resource_name_filter);
        }

        // Field: PatternTypeFilter
        if (version >= 1 and version <= 32767) {
            total_size += types.computeSizeInt8(self.pattern_type_filter);
        }

        // Field: PrincipalFilter
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.principal_filter) else types.computeSizeString(self.principal_filter);
        }

        // Field: HostFilter
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.host_filter) else types.computeSizeString(self.host_filter);
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
        // Field: ResourceTypeFilter
        if (version >= 0 and version <= 32767) {
            self.resource_type_filter = try types.decodeInt8(reader);
        }

        // Field: ResourceNameFilter
        if (version >= 0 and version <= 32767) {
            self.resource_name_filter = if (is_flexible)
                try types.decodeCompactString(reader, allocator)
            else
                try types.decodeString(reader, allocator);
        }

        // Field: PatternTypeFilter
        if (version >= 1 and version <= 32767) {
            self.pattern_type_filter = try types.decodeInt8(reader);
        }

        // Field: PrincipalFilter
        if (version >= 0 and version <= 32767) {
            self.principal_filter = if (is_flexible)
                try types.decodeCompactString(reader, allocator)
            else
                try types.decodeString(reader, allocator);
        }

        // Field: HostFilter
        if (version >= 0 and version <= 32767) {
            self.host_filter = if (is_flexible)
                try types.decodeCompactString(reader, allocator)
            else
                try types.decodeString(reader, allocator);
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

/// DeleteAclsRequest
pub const DeleteAclsRequest = struct {
    const Self = @This();

    /// The filters to use when deleting ACLs.
    filters: ?[]DeleteAclsFilter = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 1, .max = 3 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 31;
    }

    /// Create a default instance of DeleteAclsRequest
    pub fn default() Self {
        return .{
            .filters = null,
            ._tagged_fields = null,
        };
    }

    /// Sets `filters` to the passed value.
    /// The filters to use when deleting ACLs.
    pub fn withFilters(self: Self, value: ?[]DeleteAclsFilter) Self {
        var result = self;
        result.filters = value;
        return result;
    }

    /// Encode DeleteAclsRequest
    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: Filters
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.filters);
                if (self.filters) |arr| {
                    for (arr) |*item| {
                        try DeleteAclsFilter.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.filters);
                if (self.filters) |arr| {
                    for (arr) |*item| {
                        try DeleteAclsFilter.encode(item, writer, version);
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

    /// Compute the size of DeleteAclsRequest for the given version
    pub fn computeSize(self: *const Self, version: i16) !usize {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        var total_size: usize = 0;

        // Field: Filters
        if (version >= 0 and version <= 32767) {
            if (self.filters) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try DeleteAclsFilter.computeSize(item, version);
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

    /// Decode DeleteAclsRequest
    pub fn decode(reader: anytype, version: i16, allocator: std.mem.Allocator) !Self {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        var self: Self = .{};

        // Field: Filters
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(DeleteAclsFilter, array_len);
            for (array) |*item| {
                item.* = try DeleteAclsFilter.decode(reader, version, allocator);
            }
            self.filters = array;
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
