//! Auto-generated Kafka protocol message
//! Message: DescribeAclsRequest
//! API Key: 29
//! Type: request
//! Valid Versions: 1-3
//! Flexible Versions: 2+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// DescribeAclsRequest
pub const DescribeAclsRequest = struct {
    const Self = @This();

    /// The resource type.
    resource_type_filter: i8 = 0,
    /// The resource name, or null to match any resource name.
    resource_name_filter: ?[]const u8 = null,
    /// The resource pattern to match.
    /// Versions: 1+
    pattern_type_filter: i8 = 3,
    /// The principal to match, or null to match any principal.
    principal_filter: ?[]const u8 = null,
    /// The host to match, or null to match any host.
    host_filter: ?[]const u8 = null,
    /// The operation to match.
    operation: i8 = 0,
    /// The permission type to match.
    permission_type: i8 = 0,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 1, .max = 3 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 29;
    }

    /// Create a default instance of DescribeAclsRequest
    pub fn default() Self {
        return .{
            .resource_type_filter = 0,
            .resource_name_filter = null,
            .pattern_type_filter = 3,
            .principal_filter = null,
            .host_filter = null,
            .operation = 0,
            .permission_type = 0,
            ._tagged_fields = null,
        };
    }

    /// Sets `resource_type_filter` to the passed value.
    /// The resource type.
    pub fn withResourceTypeFilter(self: Self, value: i8) Self {
        var result = self;
        result.resource_type_filter = value;
        return result;
    }

    /// Sets `resource_name_filter` to the passed value.
    /// The resource name, or null to match any resource name.
    pub fn withResourceNameFilter(self: Self, value: ?[]const u8) Self {
        var result = self;
        result.resource_name_filter = value;
        return result;
    }

    /// Sets `pattern_type_filter` to the passed value.
    /// The resource pattern to match.
    /// Versions: 1+
    pub fn withPatternTypeFilter(self: Self, value: i8) Self {
        var result = self;
        result.pattern_type_filter = value;
        return result;
    }

    /// Sets `principal_filter` to the passed value.
    /// The principal to match, or null to match any principal.
    pub fn withPrincipalFilter(self: Self, value: ?[]const u8) Self {
        var result = self;
        result.principal_filter = value;
        return result;
    }

    /// Sets `host_filter` to the passed value.
    /// The host to match, or null to match any host.
    pub fn withHostFilter(self: Self, value: ?[]const u8) Self {
        var result = self;
        result.host_filter = value;
        return result;
    }

    /// Sets `operation` to the passed value.
    /// The operation to match.
    pub fn withOperation(self: Self, value: i8) Self {
        var result = self;
        result.operation = value;
        return result;
    }

    /// Sets `permission_type` to the passed value.
    /// The permission type to match.
    pub fn withPermissionType(self: Self, value: i8) Self {
        var result = self;
        result.permission_type = value;
        return result;
    }

    /// Encode DescribeAclsRequest
    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
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

    /// Compute the size of DescribeAclsRequest for the given version
    pub fn computeSize(self: *const Self, version: i16) !usize {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
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

    /// Decode DescribeAclsRequest
    pub fn decode(reader: anytype, version: i16, allocator: std.mem.Allocator) !Self {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
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
