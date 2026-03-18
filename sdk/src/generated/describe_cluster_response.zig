//! Auto-generated Kafka protocol message
//! Message: DescribeClusterResponse
//! API Key: 60
//! Type: response
//! Valid Versions: 0-2
//! Flexible Versions: 0+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// Nested struct: DescribeClusterBroker
pub const DescribeClusterBroker = struct {
    const Self = @This();

    /// The broker ID.
    /// Versions: 0+
    broker_id: i32 = 0,
    /// The broker hostname.
    /// Versions: 0+
    host: []const u8 = "",
    /// The broker port.
    /// Versions: 0+
    port: i32 = 0,
    /// The rack of the broker, or null if it has not been assigned to a rack.
    /// Versions: 0+
    rack: ?[]const u8 = null,
    /// Whether the broker is fenced
    /// Versions: 2+
    is_fenced: bool = false,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: BrokerId
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.broker_id);
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
            try types.encodeInt32(writer, self.port);
        }

        // Field: Rack
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.rack);
            } else {
                try types.encodeString(writer, self.rack);
            }
        }

        // Field: IsFenced
        if (version >= 2 and version <= 32767) {
            try types.encodeBoolean(writer, self.is_fenced);
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

        // Field: BrokerId
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.broker_id);
        }

        // Field: Host
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.host) else types.computeSizeString(self.host);
        }

        // Field: Port
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.port);
        }

        // Field: Rack
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.rack) else types.computeSizeString(self.rack);
        }

        // Field: IsFenced
        if (version >= 2 and version <= 32767) {
            total_size += types.computeSizeBoolean(self.is_fenced);
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
        // Field: BrokerId
        if (version >= 0 and version <= 32767) {
            self.broker_id = try types.decodeInt32(reader);
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
            self.port = try types.decodeInt32(reader);
        }

        // Field: Rack
        if (version >= 0 and version <= 32767) {
            self.rack = if (is_flexible)
                try types.decodeCompactString(reader, allocator)
            else
                try types.decodeString(reader, allocator);
        }

        // Field: IsFenced
        if (version >= 2 and version <= 32767) {
            self.is_fenced = try types.decodeBoolean(reader);
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

/// DescribeClusterResponse
pub const DescribeClusterResponse = struct {
    const Self = @This();

    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    throttle_time_ms: i32 = 0,
    /// The top-level error code, or 0 if there was no error.
    error_code: i16 = 0,
    /// The top-level error message, or null if there was no error.
    error_message: ?[]const u8 = null,
    /// The endpoint type that was described. 1=brokers, 2=controllers.
    /// Versions: 1+
    endpoint_type: i8 = 1,
    /// The cluster ID that responding broker belongs to.
    cluster_id: []const u8 = "",
    /// The ID of the controller. When handled by a controller, returns the current voter leader ID. When handled by a broker, returns a random alive broker ID as a fallback.
    controller_id: i32 = -1,
    /// Each broker in the response.
    brokers: ?[]DescribeClusterBroker = null,
    /// 32-bit bitfield to represent authorized operations for this cluster.
    cluster_authorized_operations: i32 = -2147483648,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 0, .max = 2 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 60;
    }

    /// Create a default instance of DescribeClusterResponse
    pub fn default() Self {
        return .{
            .throttle_time_ms = 0,
            .error_code = 0,
            .error_message = null,
            .endpoint_type = 1,
            .cluster_id = "",
            .controller_id = -1,
            .brokers = null,
            .cluster_authorized_operations = -2147483648,
            ._tagged_fields = null,
        };
    }

    /// Sets `throttle_time_ms` to the passed value.
    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    pub fn withThrottleTimeMs(self: Self, value: i32) Self {
        var result = self;
        result.throttle_time_ms = value;
        return result;
    }

    /// Sets `error_code` to the passed value.
    /// The top-level error code, or 0 if there was no error.
    pub fn withErrorCode(self: Self, value: i16) Self {
        var result = self;
        result.error_code = value;
        return result;
    }

    /// Sets `error_message` to the passed value.
    /// The top-level error message, or null if there was no error.
    pub fn withErrorMessage(self: Self, value: ?[]const u8) Self {
        var result = self;
        result.error_message = value;
        return result;
    }

    /// Sets `endpoint_type` to the passed value.
    /// The endpoint type that was described. 1=brokers, 2=controllers.
    /// Versions: 1+
    pub fn withEndpointType(self: Self, value: i8) Self {
        var result = self;
        result.endpoint_type = value;
        return result;
    }

    /// Sets `cluster_id` to the passed value.
    /// The cluster ID that responding broker belongs to.
    pub fn withClusterId(self: Self, value: []const u8) Self {
        var result = self;
        result.cluster_id = value;
        return result;
    }

    /// Sets `controller_id` to the passed value.
    /// The ID of the controller. When handled by a controller, returns the current voter leader ID. When handled by a broker, returns a random alive broker ID as a fallback.
    pub fn withControllerId(self: Self, value: i32) Self {
        var result = self;
        result.controller_id = value;
        return result;
    }

    /// Sets `brokers` to the passed value.
    /// Each broker in the response.
    pub fn withBrokers(self: Self, value: ?[]DescribeClusterBroker) Self {
        var result = self;
        result.brokers = value;
        return result;
    }

    /// Sets `cluster_authorized_operations` to the passed value.
    /// 32-bit bitfield to represent authorized operations for this cluster.
    pub fn withClusterAuthorizedOperations(self: Self, value: i32) Self {
        var result = self;
        result.cluster_authorized_operations = value;
        return result;
    }

    /// Encode DescribeClusterResponse
    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: ThrottleTimeMs
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.throttle_time_ms);
        }

        // Field: ErrorCode
        if (version >= 0 and version <= 32767) {
            try types.encodeInt16(writer, self.error_code);
        }

        // Field: ErrorMessage
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.error_message);
            } else {
                try types.encodeString(writer, self.error_message);
            }
        }

        // Field: EndpointType
        if (version >= 1 and version <= 32767) {
            try types.encodeInt8(writer, self.endpoint_type);
        }

        // Field: ClusterId
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.cluster_id);
            } else {
                try types.encodeString(writer, self.cluster_id);
            }
        }

        // Field: ControllerId
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.controller_id);
        }

        // Field: Brokers
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.brokers);
                if (self.brokers) |arr| {
                    for (arr) |*item| {
                        try DescribeClusterBroker.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.brokers);
                if (self.brokers) |arr| {
                    for (arr) |*item| {
                        try DescribeClusterBroker.encode(item, writer, version);
                    }
                }
            }
        }

        // Field: ClusterAuthorizedOperations
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.cluster_authorized_operations);
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

    /// Compute the size of DescribeClusterResponse for the given version
    pub fn computeSize(self: *const Self, version: i16) !usize {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        var total_size: usize = 0;

        // Field: ThrottleTimeMs
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.throttle_time_ms);
        }

        // Field: ErrorCode
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt16(self.error_code);
        }

        // Field: ErrorMessage
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.error_message) else types.computeSizeString(self.error_message);
        }

        // Field: EndpointType
        if (version >= 1 and version <= 32767) {
            total_size += types.computeSizeInt8(self.endpoint_type);
        }

        // Field: ClusterId
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.cluster_id) else types.computeSizeString(self.cluster_id);
        }

        // Field: ControllerId
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.controller_id);
        }

        // Field: Brokers
        if (version >= 0 and version <= 32767) {
            if (self.brokers) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try DescribeClusterBroker.computeSize(item, version);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(1) else 4;
            }
        }

        // Field: ClusterAuthorizedOperations
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.cluster_authorized_operations);
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

    /// Decode DescribeClusterResponse
    pub fn decode(reader: anytype, version: i16, allocator: std.mem.Allocator) !Self {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        var self: Self = .{};

        // Field: ThrottleTimeMs
        if (version >= 0 and version <= 32767) {
            self.throttle_time_ms = try types.decodeInt32(reader);
        }

        // Field: ErrorCode
        if (version >= 0 and version <= 32767) {
            self.error_code = try types.decodeInt16(reader);
        }

        // Field: ErrorMessage
        if (version >= 0 and version <= 32767) {
            self.error_message = if (is_flexible)
                try types.decodeCompactString(reader, allocator)
            else
                try types.decodeString(reader, allocator);
        }

        // Field: EndpointType
        if (version >= 1 and version <= 32767) {
            self.endpoint_type = try types.decodeInt8(reader);
        }

        // Field: ClusterId
        if (version >= 0 and version <= 32767) {
            self.cluster_id = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: ControllerId
        if (version >= 0 and version <= 32767) {
            self.controller_id = try types.decodeInt32(reader);
        }

        // Field: Brokers
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(DescribeClusterBroker, array_len);
            for (array) |*item| {
                item.* = try DescribeClusterBroker.decode(reader, version, allocator);
            }
            self.brokers = array;
        }

        // Field: ClusterAuthorizedOperations
        if (version >= 0 and version <= 32767) {
            self.cluster_authorized_operations = try types.decodeInt32(reader);
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
        const range = types.VersionRange.parse("0-2") catch return false;
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
