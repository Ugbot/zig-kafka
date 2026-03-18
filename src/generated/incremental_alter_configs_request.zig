//! Auto-generated Kafka protocol message
//! Message: IncrementalAlterConfigsRequest
//! API Key: 44
//! Type: request
//! Valid Versions: 0-1
//! Flexible Versions: 1+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// Nested struct: AlterConfigsResource
pub const AlterConfigsResource = struct {
    const Self = @This();

    /// The resource type.
    /// Versions: 0+
    resource_type: i8 = 0,
    /// The resource name.
    /// Versions: 0+
    resource_name: []const u8 = "",
    /// The configurations.
    /// Versions: 0+
    configs: ?[]AlterableConfig = null,

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

        // Field: Configs
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.configs);
                if (self.configs) |arr| {
                    for (arr) |*item| {
                        try AlterableConfig.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.configs);
                if (self.configs) |arr| {
                    for (arr) |*item| {
                        try AlterableConfig.encode(item, writer, version);
                    }
                }
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

        // Field: Configs
        if (version >= 0 and version <= 32767) {
            if (self.configs) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try AlterableConfig.computeSize(item, version);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(1) else 4;
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

        // Field: Configs
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(AlterableConfig, array_len);
            for (array) |*item| {
                item.* = try AlterableConfig.decode(reader, version, allocator);
            }
            self.configs = array;
        }


        if (is_flexible) {
            const tagged_fields_data = try types.decodeTaggedFields(reader, allocator);
            self._tagged_fields = tagged_fields_data;
        }
        return self;
    }

    fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("1+") catch return false;
        return range.contains(version);
    }
};

/// Nested struct: AlterableConfig
pub const AlterableConfig = struct {
    const Self = @This();

    /// The configuration key name.
    /// Versions: 0+
    name: []const u8 = "",
    /// The type (Set, Delete, Append, Subtract) of operation.
    /// Versions: 0+
    config_operation: i8 = 0,
    /// The value to set for the configuration key.
    /// Versions: 0+
    value: ?[]const u8 = null,

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

        // Field: ConfigOperation
        if (version >= 0 and version <= 32767) {
            try types.encodeInt8(writer, self.config_operation);
        }

        // Field: Value
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.value);
            } else {
                try types.encodeString(writer, self.value);
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

        // Field: Name
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.name) else types.computeSizeString(self.name);
        }

        // Field: ConfigOperation
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt8(self.config_operation);
        }

        // Field: Value
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.value) else types.computeSizeString(self.value);
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

        // Field: ConfigOperation
        if (version >= 0 and version <= 32767) {
            self.config_operation = try types.decodeInt8(reader);
        }

        // Field: Value
        if (version >= 0 and version <= 32767) {
            self.value = if (is_flexible)
                try types.decodeCompactString(reader, allocator)
            else
                try types.decodeString(reader, allocator);
        }


        if (is_flexible) {
            const tagged_fields_data = try types.decodeTaggedFields(reader, allocator);
            self._tagged_fields = tagged_fields_data;
        }
        return self;
    }

    fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("1+") catch return false;
        return range.contains(version);
    }
};

/// IncrementalAlterConfigsRequest
pub const IncrementalAlterConfigsRequest = struct {
    const Self = @This();

    /// The incremental updates for each resource.
    resources: ?[]AlterConfigsResource = null,
    /// True if we should validate the request, but not change the configurations.
    validate_only: bool = false,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 0, .max = 1 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 44;
    }

    /// Create a default instance of IncrementalAlterConfigsRequest
    pub fn default() Self {
        return .{
            .resources = null,
            .validate_only = false,
            ._tagged_fields = null,
        };
    }

    /// Sets `resources` to the passed value.
    /// The incremental updates for each resource.
    pub fn withResources(self: Self, value: ?[]AlterConfigsResource) Self {
        var result = self;
        result.resources = value;
        return result;
    }

    /// Sets `validate_only` to the passed value.
    /// True if we should validate the request, but not change the configurations.
    pub fn withValidateOnly(self: Self, value: bool) Self {
        var result = self;
        result.validate_only = value;
        return result;
    }

    /// Encode IncrementalAlterConfigsRequest
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
                        try AlterConfigsResource.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.resources);
                if (self.resources) |arr| {
                    for (arr) |*item| {
                        try AlterConfigsResource.encode(item, writer, version);
                    }
                }
            }
        }

        // Field: ValidateOnly
        if (version >= 0 and version <= 32767) {
            try types.encodeBoolean(writer, self.validate_only);
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

    /// Compute the size of IncrementalAlterConfigsRequest for the given version
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
                    total_size += try AlterConfigsResource.computeSize(item, version);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(1) else 4;
            }
        }

        // Field: ValidateOnly
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeBoolean(self.validate_only);
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

    /// Decode IncrementalAlterConfigsRequest
    pub fn decode(reader: anytype, version: i16, allocator: std.mem.Allocator) !Self {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        var self: Self = .{};

        // Field: Resources
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(AlterConfigsResource, array_len);
            for (array) |*item| {
                item.* = try AlterConfigsResource.decode(reader, version, allocator);
            }
            self.resources = array;
        }

        // Field: ValidateOnly
        if (version >= 0 and version <= 32767) {
            self.validate_only = try types.decodeBoolean(reader);
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
        const range = types.VersionRange.parse("0-1") catch return false;
        return range.contains(version);
    }
    /// Check if version uses flexible encoding
    pub fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("1+") catch return false;
        return range.contains(version);
    }
    /// Get the header version for this API version
    /// Returns 2 for flexible versions, 1 for classic versions
    pub fn headerVersion(api_version: i16) i16 {
        if (isFlexibleVersion(api_version)) return 2;
        return 1;
    }

};
