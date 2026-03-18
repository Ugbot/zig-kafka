//! Auto-generated Kafka protocol message
//! Message: FindCoordinatorResponse
//! API Key: 10
//! Type: response
//! Valid Versions: 0-6
//! Flexible Versions: 3+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// Nested struct: Coordinator
pub const Coordinator = struct {
    const Self = @This();

    /// The coordinator key.
    /// Versions: 4+
    key: []const u8 = "",
    /// The node id.
    /// Versions: 4+
    node_id: i32 = 0,
    /// The host name.
    /// Versions: 4+
    host: []const u8 = "",
    /// The port.
    /// Versions: 4+
    port: i32 = 0,
    /// The error code, or 0 if there was no error.
    /// Versions: 4+
    error_code: i16 = 0,
    /// The error message, or null if there was no error.
    /// Versions: 4+
    error_message: ?[]const u8 = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: Key
        if (version >= 4 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.key);
            } else {
                try types.encodeString(writer, self.key);
            }
        }

        // Field: NodeId
        if (version >= 4 and version <= 32767) {
            try types.encodeInt32(writer, self.node_id);
        }

        // Field: Host
        if (version >= 4 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.host);
            } else {
                try types.encodeString(writer, self.host);
            }
        }

        // Field: Port
        if (version >= 4 and version <= 32767) {
            try types.encodeInt32(writer, self.port);
        }

        // Field: ErrorCode
        if (version >= 4 and version <= 32767) {
            try types.encodeInt16(writer, self.error_code);
        }

        // Field: ErrorMessage
        if (version >= 4 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.error_message);
            } else {
                try types.encodeString(writer, self.error_message);
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

        // Field: Key
        if (version >= 4 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.key) else types.computeSizeString(self.key);
        }

        // Field: NodeId
        if (version >= 4 and version <= 32767) {
            total_size += types.computeSizeInt32(self.node_id);
        }

        // Field: Host
        if (version >= 4 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.host) else types.computeSizeString(self.host);
        }

        // Field: Port
        if (version >= 4 and version <= 32767) {
            total_size += types.computeSizeInt32(self.port);
        }

        // Field: ErrorCode
        if (version >= 4 and version <= 32767) {
            total_size += types.computeSizeInt16(self.error_code);
        }

        // Field: ErrorMessage
        if (version >= 4 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.error_message) else types.computeSizeString(self.error_message);
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
        if (version >= 4 and version <= 32767) {
            self.key = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: NodeId
        if (version >= 4 and version <= 32767) {
            self.node_id = try types.decodeInt32(reader);
        }

        // Field: Host
        if (version >= 4 and version <= 32767) {
            self.host = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: Port
        if (version >= 4 and version <= 32767) {
            self.port = try types.decodeInt32(reader);
        }

        // Field: ErrorCode
        if (version >= 4 and version <= 32767) {
            self.error_code = try types.decodeInt16(reader);
        }

        // Field: ErrorMessage
        if (version >= 4 and version <= 32767) {
            self.error_message = if (is_flexible)
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
        const range = types.VersionRange.parse("3+") catch return false;
        return range.contains(version);
    }
};

/// FindCoordinatorResponse
pub const FindCoordinatorResponse = struct {
    const Self = @This();

    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    /// Versions: 1+
    throttle_time_ms: i32 = 0,
    /// The error code, or 0 if there was no error.
    /// Versions: 0-3
    error_code: i16 = 0,
    /// The error message, or null if there was no error.
    /// Versions: 1-3
    error_message: ?[]const u8 = null,
    /// The node id.
    /// Versions: 0-3
    node_id: i32 = 0,
    /// The host name.
    /// Versions: 0-3
    host: []const u8 = "",
    /// The port.
    /// Versions: 0-3
    port: i32 = 0,
    /// Each coordinator result in the response.
    /// Versions: 4+
    coordinators: ?[]Coordinator = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 0, .max = 6 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 10;
    }

    /// Create a default instance of FindCoordinatorResponse
    pub fn default() Self {
        return .{
            .throttle_time_ms = 0,
            .error_code = 0,
            .error_message = null,
            .node_id = 0,
            .host = "",
            .port = 0,
            .coordinators = null,
            ._tagged_fields = null,
        };
    }

    /// Sets `throttle_time_ms` to the passed value.
    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    /// Versions: 1+
    pub fn withThrottleTimeMs(self: Self, value: i32) Self {
        var result = self;
        result.throttle_time_ms = value;
        return result;
    }

    /// Sets `error_code` to the passed value.
    /// The error code, or 0 if there was no error.
    /// Versions: 0-3
    pub fn withErrorCode(self: Self, value: i16) Self {
        var result = self;
        result.error_code = value;
        return result;
    }

    /// Sets `error_message` to the passed value.
    /// The error message, or null if there was no error.
    /// Versions: 1-3
    pub fn withErrorMessage(self: Self, value: ?[]const u8) Self {
        var result = self;
        result.error_message = value;
        return result;
    }

    /// Sets `node_id` to the passed value.
    /// The node id.
    /// Versions: 0-3
    pub fn withNodeId(self: Self, value: i32) Self {
        var result = self;
        result.node_id = value;
        return result;
    }

    /// Sets `host` to the passed value.
    /// The host name.
    /// Versions: 0-3
    pub fn withHost(self: Self, value: []const u8) Self {
        var result = self;
        result.host = value;
        return result;
    }

    /// Sets `port` to the passed value.
    /// The port.
    /// Versions: 0-3
    pub fn withPort(self: Self, value: i32) Self {
        var result = self;
        result.port = value;
        return result;
    }

    /// Sets `coordinators` to the passed value.
    /// Each coordinator result in the response.
    /// Versions: 4+
    pub fn withCoordinators(self: Self, value: ?[]Coordinator) Self {
        var result = self;
        result.coordinators = value;
        return result;
    }

    /// Encode FindCoordinatorResponse
    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: ThrottleTimeMs
        if (version >= 1 and version <= 32767) {
            try types.encodeInt32(writer, self.throttle_time_ms);
        }

        // Field: ErrorCode
        if (version >= 0 and version <= 3) {
            try types.encodeInt16(writer, self.error_code);
        }

        // Field: ErrorMessage
        if (version >= 1 and version <= 3) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.error_message);
            } else {
                try types.encodeString(writer, self.error_message);
            }
        }

        // Field: NodeId
        if (version >= 0 and version <= 3) {
            try types.encodeInt32(writer, self.node_id);
        }

        // Field: Host
        if (version >= 0 and version <= 3) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.host);
            } else {
                try types.encodeString(writer, self.host);
            }
        }

        // Field: Port
        if (version >= 0 and version <= 3) {
            try types.encodeInt32(writer, self.port);
        }

        // Field: Coordinators
        if (version >= 4 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLen(writer, self.coordinators);
                if (self.coordinators) |arr| {
                    for (arr) |*item| {
                        try Coordinator.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLen(writer, self.coordinators);
                if (self.coordinators) |arr| {
                    for (arr) |*item| {
                        try Coordinator.encode(item, writer, version);
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

    /// Compute the size of FindCoordinatorResponse for the given version
    pub fn computeSize(self: *const Self, version: i16) !usize {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        var total_size: usize = 0;

        // Field: ThrottleTimeMs
        if (version >= 1 and version <= 32767) {
            total_size += types.computeSizeInt32(self.throttle_time_ms);
        }

        // Field: ErrorCode
        if (version >= 0 and version <= 3) {
            total_size += types.computeSizeInt16(self.error_code);
        }

        // Field: ErrorMessage
        if (version >= 1 and version <= 3) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.error_message) else types.computeSizeString(self.error_message);
        }

        // Field: NodeId
        if (version >= 0 and version <= 3) {
            total_size += types.computeSizeInt32(self.node_id);
        }

        // Field: Host
        if (version >= 0 and version <= 3) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.host) else types.computeSizeString(self.host);
        }

        // Field: Port
        if (version >= 0 and version <= 3) {
            total_size += types.computeSizeInt32(self.port);
        }

        // Field: Coordinators
        if (version >= 4 and version <= 32767) {
            if (self.coordinators) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try Coordinator.computeSize(item, version);
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

    /// Decode FindCoordinatorResponse
    pub fn decode(reader: anytype, version: i16, allocator: std.mem.Allocator) !Self {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        var self: Self = .{};

        // Field: ThrottleTimeMs
        if (version >= 1 and version <= 32767) {
            self.throttle_time_ms = try types.decodeInt32(reader);
        }

        // Field: ErrorCode
        if (version >= 0 and version <= 3) {
            self.error_code = try types.decodeInt16(reader);
        }

        // Field: ErrorMessage
        if (version >= 1 and version <= 3) {
            self.error_message = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: NodeId
        if (version >= 0 and version <= 3) {
            self.node_id = try types.decodeInt32(reader);
        }

        // Field: Host
        if (version >= 0 and version <= 3) {
            self.host = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: Port
        if (version >= 0 and version <= 3) {
            self.port = try types.decodeInt32(reader);
        }

        // Field: Coordinators
        if (version >= 4 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(Coordinator, array_len);
            for (array) |*item| {
                item.* = try Coordinator.decode(reader, version, allocator);
            }
            self.coordinators = array;
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
        const range = types.VersionRange.parse("0-6") catch return false;
        return range.contains(version);
    }
    /// Check if version uses flexible encoding
    pub fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("3+") catch return false;
        return range.contains(version);
    }
    /// Get the header version for this API version
    /// Returns 2 for flexible versions, 1 for classic versions
    pub fn headerVersion(api_version: i16) i16 {
        if (isFlexibleVersion(api_version)) return 2;
        return 1;
    }

};
