//! Auto-generated Kafka protocol message
//! Message: AlterClientQuotasRequest
//! API Key: 49
//! Type: request
//! Valid Versions: 0-1
//! Flexible Versions: 1+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// Nested struct: EntryData
pub const EntryData = struct {
    const Self = @This();

    /// The quota entity to alter.
    /// Versions: 0+
    entity: ?[]EntityData = null,
    /// An individual quota configuration entry to alter.
    /// Versions: 0+
    ops: ?[]OpData = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: Entity
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.entity);
                if (self.entity) |arr| {
                    for (arr) |*item| {
                        try EntityData.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.entity);
                if (self.entity) |arr| {
                    for (arr) |*item| {
                        try EntityData.encode(item, writer, version);
                    }
                }
            }
        }

        // Field: Ops
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.ops);
                if (self.ops) |arr| {
                    for (arr) |*item| {
                        try OpData.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.ops);
                if (self.ops) |arr| {
                    for (arr) |*item| {
                        try OpData.encode(item, writer, version);
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

        // Field: Entity
        if (version >= 0 and version <= 32767) {
            if (self.entity) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try EntityData.computeSize(item, version);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(1) else 4;
            }
        }

        // Field: Ops
        if (version >= 0 and version <= 32767) {
            if (self.ops) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try OpData.computeSize(item, version);
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
        // Field: Entity
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(EntityData, array_len);
            for (array) |*item| {
                item.* = try EntityData.decode(reader, version, allocator);
            }
            self.entity = array;
        }

        // Field: Ops
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(OpData, array_len);
            for (array) |*item| {
                item.* = try OpData.decode(reader, version, allocator);
            }
            self.ops = array;
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

/// Nested struct: OpData
pub const OpData = struct {
    const Self = @This();

    /// The quota configuration key.
    /// Versions: 0+
    key: []const u8 = "",
    /// The value to set, otherwise ignored if the value is to be removed.
    /// Versions: 0+
    value: f64 = 0.0,
    /// Whether the quota configuration value should be removed, otherwise set.
    /// Versions: 0+
    remove: bool = false,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: Key
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.key);
            } else {
                try types.encodeString(writer, self.key);
            }
        }

        // Field: Value
        if (version >= 0 and version <= 32767) {
            try types.encodeFloat64(writer, self.value);
        }

        // Field: Remove
        if (version >= 0 and version <= 32767) {
            try types.encodeBoolean(writer, self.remove);
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

        // Field: Key
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.key) else types.computeSizeString(self.key);
        }

        // Field: Value
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeFloat64(self.value);
        }

        // Field: Remove
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeBoolean(self.remove);
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
        // Field: Key
        if (version >= 0 and version <= 32767) {
            self.key = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: Value
        if (version >= 0 and version <= 32767) {
            self.value = try types.decodeFloat64(reader);
        }

        // Field: Remove
        if (version >= 0 and version <= 32767) {
            self.remove = try types.decodeBoolean(reader);
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

/// Nested struct: EntityData
pub const EntityData = struct {
    const Self = @This();

    /// The entity type.
    /// Versions: 0+
    entity_type: []const u8 = "",
    /// The name of the entity, or null if the default.
    /// Versions: 0+
    entity_name: ?[]const u8 = null,

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

        // Field: EntityName
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.entity_name);
            } else {
                try types.encodeString(writer, self.entity_name);
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

        // Field: EntityName
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.entity_name) else types.computeSizeString(self.entity_name);
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

        // Field: EntityName
        if (version >= 0 and version <= 32767) {
            self.entity_name = if (is_flexible)
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

/// AlterClientQuotasRequest
pub const AlterClientQuotasRequest = struct {
    const Self = @This();

    /// The quota configuration entries to alter.
    entries: ?[]EntryData = null,
    /// Whether the alteration should be validated, but not performed.
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
        return 49;
    }

    /// Create a default instance of AlterClientQuotasRequest
    pub fn default() Self {
        return .{
            .entries = null,
            .validate_only = false,
            ._tagged_fields = null,
        };
    }

    /// Sets `entries` to the passed value.
    /// The quota configuration entries to alter.
    pub fn withEntries(self: Self, value: ?[]EntryData) Self {
        var result = self;
        result.entries = value;
        return result;
    }

    /// Sets `validate_only` to the passed value.
    /// Whether the alteration should be validated, but not performed.
    pub fn withValidateOnly(self: Self, value: bool) Self {
        var result = self;
        result.validate_only = value;
        return result;
    }

    /// Encode AlterClientQuotasRequest
    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: Entries
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.entries);
                if (self.entries) |arr| {
                    for (arr) |*item| {
                        try EntryData.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.entries);
                if (self.entries) |arr| {
                    for (arr) |*item| {
                        try EntryData.encode(item, writer, version);
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

    /// Compute the size of AlterClientQuotasRequest for the given version
    pub fn computeSize(self: *const Self, version: i16) !usize {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        var total_size: usize = 0;

        // Field: Entries
        if (version >= 0 and version <= 32767) {
            if (self.entries) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try EntryData.computeSize(item, version);
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

    /// Decode AlterClientQuotasRequest
    pub fn decode(reader: anytype, version: i16, allocator: std.mem.Allocator) !Self {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        var self: Self = .{};

        // Field: Entries
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(EntryData, array_len);
            for (array) |*item| {
                item.* = try EntryData.decode(reader, version, allocator);
            }
            self.entries = array;
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
