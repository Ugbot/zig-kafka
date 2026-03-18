//! Auto-generated Kafka protocol message
//! Message: DescribeClientQuotasRequest
//! API Key: 48
//! Type: request
//! Valid Versions: 0-1
//! Flexible Versions: 1+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// Nested struct: ComponentData
pub const ComponentData = struct {
    const Self = @This();

    /// The entity type that the filter component applies to.
    /// Versions: 0+
    entity_type: []const u8 = "",
    /// How to match the entity {0 = exact name, 1 = default name, 2 = any specified name}.
    /// Versions: 0+
    match_type: i8 = 0,
    /// The string to match against, or null if unused for the match type.
    /// Versions: 0+
    match: ?[]const u8 = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: EntityType
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.entity_type);
            } else {
                try types.encodeString(writer, self.entity_type);
            }
        }

        // Field: MatchType
        if (version >= 0 and version <= 32767) {
            try types.encodeInt8(writer, self.match_type);
        }

        // Field: Match
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.match);
            } else {
                try types.encodeString(writer, self.match);
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

        // Field: EntityType
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.entity_type) else types.computeSizeString(self.entity_type);
        }

        // Field: MatchType
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt8(self.match_type);
        }

        // Field: Match
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.match) else types.computeSizeString(self.match);
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
        // Field: EntityType
        if (version >= 0 and version <= 32767) {
            self.entity_type = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: MatchType
        if (version >= 0 and version <= 32767) {
            self.match_type = try types.decodeInt8(reader);
        }

        // Field: Match
        if (version >= 0 and version <= 32767) {
            self.match = if (is_flexible)
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

/// DescribeClientQuotasRequest
pub const DescribeClientQuotasRequest = struct {
    const Self = @This();

    /// Filter components to apply to quota entities.
    components: ?[]ComponentData = null,
    /// Whether the match is strict, i.e. should exclude entities with unspecified entity types.
    strict: bool = false,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 0, .max = 1 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 48;
    }

    /// Create a default instance of DescribeClientQuotasRequest
    pub fn default() Self {
        return .{
            .components = null,
            .strict = false,
            ._tagged_fields = null,
        };
    }

    /// Sets `components` to the passed value.
    /// Filter components to apply to quota entities.
    pub fn withComponents(self: Self, value: ?[]ComponentData) Self {
        var result = self;
        result.components = value;
        return result;
    }

    /// Sets `strict` to the passed value.
    /// Whether the match is strict, i.e. should exclude entities with unspecified entity types.
    pub fn withStrict(self: Self, value: bool) Self {
        var result = self;
        result.strict = value;
        return result;
    }

    /// Encode DescribeClientQuotasRequest
    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: Components
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.components);
                if (self.components) |arr| {
                    for (arr) |*item| {
                        try ComponentData.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.components);
                if (self.components) |arr| {
                    for (arr) |*item| {
                        try ComponentData.encode(item, writer, version);
                    }
                }
            }
        }

        // Field: Strict
        if (version >= 0 and version <= 32767) {
            try types.encodeBoolean(writer, self.strict);
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

    /// Compute the size of DescribeClientQuotasRequest for the given version
    pub fn computeSize(self: *const Self, version: i16) !usize {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        var total_size: usize = 0;

        // Field: Components
        if (version >= 0 and version <= 32767) {
            if (self.components) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try ComponentData.computeSize(item, version);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(1) else 4;
            }
        }

        // Field: Strict
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeBoolean(self.strict);
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

    /// Decode DescribeClientQuotasRequest
    pub fn decode(reader: anytype, version: i16, allocator: std.mem.Allocator) !Self {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        var self: Self = .{};

        // Field: Components
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(ComponentData, array_len);
            for (array) |*item| {
                item.* = try ComponentData.decode(reader, version, allocator);
            }
            self.components = array;
        }

        // Field: Strict
        if (version >= 0 and version <= 32767) {
            self.strict = try types.decodeBoolean(reader);
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
