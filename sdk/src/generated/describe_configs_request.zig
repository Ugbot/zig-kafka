//! Auto-generated Kafka protocol message
//! Message: DescribeConfigsRequest
//! API Key: 32
//! Type: request
//! Valid Versions: 1-4
//! Flexible Versions: 4+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// Nested struct: DescribeConfigsResource
pub const DescribeConfigsResource = struct {
    const Self = @This();

    /// The resource type.
    /// Versions: 0+
    resource_type: i8 = 0,
    /// The resource name.
    /// Versions: 0+
    resource_name: []const u8 = "",
    /// The configuration keys to list, or null to list all configuration keys.
    /// Versions: 0+
    configuration_keys: ?[][]const u8 = null,

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

        // Field: ConfigurationKeys
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArray([]const u8, writer, self.configuration_keys, types.encodeCompactString);
            } else {
                try types.encodeArray([]const u8, writer, self.configuration_keys, types.encodeCompactString);
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

        // Field: ResourceType
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt8(self.resource_type);
        }

        // Field: ResourceName
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.resource_name) else types.computeSizeString(self.resource_name);
        }

        // Field: ConfigurationKeys
        if (version >= 0 and version <= 32767) {
            if (self.configuration_keys) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |item| {
                    total_size += types.computeSizeCompactString(item);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(0) else 4;
            }
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

        // Field: ConfigurationKeys
        if (version >= 0 and version <= 32767) {
            self.configuration_keys = if (is_flexible)
                try types.decodeCompactArray([]const u8, reader, allocator, types.decodeNonNullableCompactString)
            else
                try types.decodeArray([]const u8, reader, allocator, types.decodeNonNullableString);
        }


        if (is_flexible) {
            const tagged_fields_data = try types.decodeTaggedFields(reader, allocator);
            self._tagged_fields = tagged_fields_data;
        }
        return self;
    }

    fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("4+") catch return false;
        return range.contains(version);
    }
};

/// DescribeConfigsRequest
pub const DescribeConfigsRequest = struct {
    const Self = @This();

    /// The resources whose configurations we want to describe.
    resources: ?[]DescribeConfigsResource = null,
    /// True if we should include all synonyms.
    /// Versions: 1+
    include_synonyms: bool = false,
    /// True if we should include configuration documentation.
    /// Versions: 3+
    include_documentation: bool = false,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 1, .max = 4 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 32;
    }

    /// Create a default instance of DescribeConfigsRequest
    pub fn default() Self {
        return .{
            .resources = null,
            .include_synonyms = false,
            .include_documentation = false,
            ._tagged_fields = null,
        };
    }

    /// Sets `resources` to the passed value.
    /// The resources whose configurations we want to describe.
    pub fn withResources(self: Self, value: ?[]DescribeConfigsResource) Self {
        var result = self;
        result.resources = value;
        return result;
    }

    /// Sets `include_synonyms` to the passed value.
    /// True if we should include all synonyms.
    /// Versions: 1+
    pub fn withIncludeSynonyms(self: Self, value: bool) Self {
        var result = self;
        result.include_synonyms = value;
        return result;
    }

    /// Sets `include_documentation` to the passed value.
    /// True if we should include configuration documentation.
    /// Versions: 3+
    pub fn withIncludeDocumentation(self: Self, value: bool) Self {
        var result = self;
        result.include_documentation = value;
        return result;
    }

    /// Encode DescribeConfigsRequest
    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: Resources
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.resources);
                if (self.resources) |arr| {
                    for (arr) |*item| {
                        try DescribeConfigsResource.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.resources);
                if (self.resources) |arr| {
                    for (arr) |*item| {
                        try DescribeConfigsResource.encode(item, writer, version);
                    }
                }
            }
        }

        // Field: IncludeSynonyms
        if (version >= 1 and version <= 32767) {
            try types.encodeBoolean(writer, self.include_synonyms);
        }

        // Field: IncludeDocumentation
        if (version >= 3 and version <= 32767) {
            try types.encodeBoolean(writer, self.include_documentation);
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

    /// Compute the size of DescribeConfigsRequest for the given version
    pub fn computeSize(self: *const Self, version: i16) !usize {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        var total_size: usize = 0;

        // Field: Resources
        if (version >= 0 and version <= 32767) {
            if (self.resources) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try DescribeConfigsResource.computeSize(item, version);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(1) else 4;
            }
        }

        // Field: IncludeSynonyms
        if (version >= 1 and version <= 32767) {
            total_size += types.computeSizeBoolean(self.include_synonyms);
        }

        // Field: IncludeDocumentation
        if (version >= 3 and version <= 32767) {
            total_size += types.computeSizeBoolean(self.include_documentation);
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

    /// Decode DescribeConfigsRequest
    pub fn decode(reader: anytype, version: i16, allocator: std.mem.Allocator) !Self {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        var self: Self = .{};

        // Field: Resources
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(DescribeConfigsResource, array_len);
            for (array) |*item| {
                item.* = try DescribeConfigsResource.decode(reader, version, allocator);
            }
            self.resources = array;
        }

        // Field: IncludeSynonyms
        if (version >= 1 and version <= 32767) {
            self.include_synonyms = try types.decodeBoolean(reader);
        }

        // Field: IncludeDocumentation
        if (version >= 3 and version <= 32767) {
            self.include_documentation = try types.decodeBoolean(reader);
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
        const range = types.VersionRange.parse("1-4") catch return false;
        return range.contains(version);
    }
    /// Check if version uses flexible encoding
    pub fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("4+") catch return false;
        return range.contains(version);
    }
    /// Get the header version for this API version
    /// Returns 2 for flexible versions, 1 for classic versions
    pub fn headerVersion(api_version: i16) i16 {
        if (isFlexibleVersion(api_version)) return 2;
        return 1;
    }

};
