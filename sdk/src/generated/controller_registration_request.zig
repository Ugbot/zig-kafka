//! Auto-generated Kafka protocol message
//! Message: ControllerRegistrationRequest
//! API Key: 70
//! Type: request
//! Valid Versions: 0
//! Flexible Versions: 0+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// Nested struct: Feature
pub const Feature = struct {
    const Self = @This();

    /// The feature name.
    /// Versions: 0+
    name: []const u8 = "",
    /// The minimum supported feature level.
    /// Versions: 0+
    min_supported_version: i16 = 0,
    /// The maximum supported feature level.
    /// Versions: 0+
    max_supported_version: i16 = 0,

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

        // Field: MinSupportedVersion
        if (version >= 0 and version <= 32767) {
            try types.encodeInt16(writer, self.min_supported_version);
        }

        // Field: MaxSupportedVersion
        if (version >= 0 and version <= 32767) {
            try types.encodeInt16(writer, self.max_supported_version);
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

        // Field: MinSupportedVersion
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt16(self.min_supported_version);
        }

        // Field: MaxSupportedVersion
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt16(self.max_supported_version);
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

        // Field: MinSupportedVersion
        if (version >= 0 and version <= 32767) {
            self.min_supported_version = try types.decodeInt16(reader);
        }

        // Field: MaxSupportedVersion
        if (version >= 0 and version <= 32767) {
            self.max_supported_version = try types.decodeInt16(reader);
        }


        if (is_flexible) {
            const tagged_fields_data = try types.decodeTaggedFields(reader, allocator);
            self._tagged_fields = tagged_fields_data;
        }
        return self;
    }

    fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("0+") catch return false;
        return range.contains(version);
    }
};

/// Nested struct: Listener
pub const Listener = struct {
    const Self = @This();

    /// The name of the endpoint.
    /// Versions: 0+
    name: []const u8 = "",
    /// The hostname.
    /// Versions: 0+
    host: []const u8 = "",
    /// The port.
    /// Versions: 0+
    port: u16 = 0,
    /// The security protocol.
    /// Versions: 0+
    security_protocol: i16 = 0,

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

        // Field: Host
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.host);
            } else {
                try types.encodeString(writer, self.host);
            }
        }

        // Field: Port
        if (version >= 0 and version <= 32767) {
            try types.encodeUint16(writer, self.port);
        }

        // Field: SecurityProtocol
        if (version >= 0 and version <= 32767) {
            try types.encodeInt16(writer, self.security_protocol);
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

        // Field: Host
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.host) else types.computeSizeString(self.host);
        }

        // Field: Port
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeUint16(self.port);
        }

        // Field: SecurityProtocol
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt16(self.security_protocol);
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

        // Field: Host
        if (version >= 0 and version <= 32767) {
            self.host = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: Port
        if (version >= 0 and version <= 32767) {
            self.port = try types.decodeUint16(reader);
        }

        // Field: SecurityProtocol
        if (version >= 0 and version <= 32767) {
            self.security_protocol = try types.decodeInt16(reader);
        }


        if (is_flexible) {
            const tagged_fields_data = try types.decodeTaggedFields(reader, allocator);
            self._tagged_fields = tagged_fields_data;
        }
        return self;
    }

    fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("0+") catch return false;
        return range.contains(version);
    }
};

/// ControllerRegistrationRequest
pub const ControllerRegistrationRequest = struct {
    const Self = @This();

    /// The ID of the controller to register.
    controller_id: i32 = 0,
    /// The controller incarnation ID, which is unique to each process run.
    incarnation_id: [16]u8 = [_]u8{0} ** 16,
    /// Set if the required configurations for ZK migration are present.
    zk_migration_ready: bool = false,
    /// The listeners of this controller.
    listeners: ?[]Listener = null,
    /// The features on this controller.
    features: ?[]Feature = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 0, .max = 0 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 70;
    }

    /// Create a default instance of ControllerRegistrationRequest
    pub fn default() Self {
        return .{
            .controller_id = 0,
            .incarnation_id = [_]u8{0} ** 16,
            .zk_migration_ready = false,
            .listeners = null,
            .features = null,
            ._tagged_fields = null,
        };
    }

    /// Sets `controller_id` to the passed value.
    /// The ID of the controller to register.
    pub fn withControllerId(self: Self, value: i32) Self {
        var result = self;
        result.controller_id = value;
        return result;
    }

    /// Sets `incarnation_id` to the passed value.
    /// The controller incarnation ID, which is unique to each process run.
    pub fn withIncarnationId(self: Self, value: [16]u8) Self {
        var result = self;
        result.incarnation_id = value;
        return result;
    }

    /// Sets `zk_migration_ready` to the passed value.
    /// Set if the required configurations for ZK migration are present.
    pub fn withZkMigrationReady(self: Self, value: bool) Self {
        var result = self;
        result.zk_migration_ready = value;
        return result;
    }

    /// Sets `listeners` to the passed value.
    /// The listeners of this controller.
    pub fn withListeners(self: Self, value: ?[]Listener) Self {
        var result = self;
        result.listeners = value;
        return result;
    }

    /// Sets `features` to the passed value.
    /// The features on this controller.
    pub fn withFeatures(self: Self, value: ?[]Feature) Self {
        var result = self;
        result.features = value;
        return result;
    }

    /// Encode ControllerRegistrationRequest
    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: ControllerId
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.controller_id);
        }

        // Field: IncarnationId
        if (version >= 0 and version <= 32767) {
            try types.encodeUuid(writer, self.incarnation_id);
        }

        // Field: ZkMigrationReady
        if (version >= 0 and version <= 32767) {
            try types.encodeBoolean(writer, self.zk_migration_ready);
        }

        // Field: Listeners
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.listeners);
                if (self.listeners) |arr| {
                    for (arr) |*item| {
                        try Listener.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.listeners);
                if (self.listeners) |arr| {
                    for (arr) |*item| {
                        try Listener.encode(item, writer, version);
                    }
                }
            }
        }

        // Field: Features
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.features);
                if (self.features) |arr| {
                    for (arr) |*item| {
                        try Feature.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.features);
                if (self.features) |arr| {
                    for (arr) |*item| {
                        try Feature.encode(item, writer, version);
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

    /// Compute the size of ControllerRegistrationRequest for the given version
    pub fn computeSize(self: *const Self, version: i16) !usize {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        var total_size: usize = 0;

        // Field: ControllerId
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.controller_id);
        }

        // Field: IncarnationId
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeUuid(self.incarnation_id);
        }

        // Field: ZkMigrationReady
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeBoolean(self.zk_migration_ready);
        }

        // Field: Listeners
        if (version >= 0 and version <= 32767) {
            if (self.listeners) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try Listener.computeSize(item, version);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(1) else 4;
            }
        }

        // Field: Features
        if (version >= 0 and version <= 32767) {
            if (self.features) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try Feature.computeSize(item, version);
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

    /// Decode ControllerRegistrationRequest
    pub fn decode(reader: anytype, version: i16, allocator: std.mem.Allocator) !Self {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        var self: Self = .{};

        // Field: ControllerId
        if (version >= 0 and version <= 32767) {
            self.controller_id = try types.decodeInt32(reader);
        }

        // Field: IncarnationId
        if (version >= 0 and version <= 32767) {
            self.incarnation_id = try types.decodeUuid(reader);
        }

        // Field: ZkMigrationReady
        if (version >= 0 and version <= 32767) {
            self.zk_migration_ready = try types.decodeBoolean(reader);
        }

        // Field: Listeners
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(Listener, array_len);
            for (array) |*item| {
                item.* = try Listener.decode(reader, version, allocator);
            }
            self.listeners = array;
        }

        // Field: Features
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(Feature, array_len);
            for (array) |*item| {
                item.* = try Feature.decode(reader, version, allocator);
            }
            self.features = array;
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
        const range = types.VersionRange.parse("0") catch return false;
        return range.contains(version);
    }
    /// Check if version uses flexible encoding
    pub fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("0+") catch return false;
        return range.contains(version);
    }
    /// Get the header version for this API version
    /// Returns 2 for flexible versions, 1 for classic versions
    pub fn headerVersion(api_version: i16) i16 {
        if (isFlexibleVersion(api_version)) return 2;
        return 1;
    }

};
