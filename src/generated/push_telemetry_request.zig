//! Auto-generated Kafka protocol message
//! Message: PushTelemetryRequest
//! API Key: 72
//! Type: request
//! Valid Versions: 0
//! Flexible Versions: 0+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// PushTelemetryRequest
pub const PushTelemetryRequest = struct {
    const Self = @This();

    /// Unique id for this client instance.
    client_instance_id: [16]u8 = [_]u8{0} ** 16,
    /// Unique identifier for the current subscription.
    subscription_id: i32 = 0,
    /// Client is terminating the connection.
    terminating: bool = false,
    /// Compression codec used to compress the metrics.
    compression_type: i8 = 0,
    /// Metrics encoded in OpenTelemetry MetricsData v1 protobuf format.
    metrics: []const u8 = &[_]u8{},

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 0, .max = 0 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 72;
    }

    /// Create a default instance of PushTelemetryRequest
    pub fn default() Self {
        return .{
            .client_instance_id = [_]u8{0} ** 16,
            .subscription_id = 0,
            .terminating = false,
            .compression_type = 0,
            .metrics = &[_]u8{},
            ._tagged_fields = null,
        };
    }

    /// Sets `client_instance_id` to the passed value.
    /// Unique id for this client instance.
    pub fn withClientInstanceId(self: Self, value: [16]u8) Self {
        var result = self;
        result.client_instance_id = value;
        return result;
    }

    /// Sets `subscription_id` to the passed value.
    /// Unique identifier for the current subscription.
    pub fn withSubscriptionId(self: Self, value: i32) Self {
        var result = self;
        result.subscription_id = value;
        return result;
    }

    /// Sets `terminating` to the passed value.
    /// Client is terminating the connection.
    pub fn withTerminating(self: Self, value: bool) Self {
        var result = self;
        result.terminating = value;
        return result;
    }

    /// Sets `compression_type` to the passed value.
    /// Compression codec used to compress the metrics.
    pub fn withCompressionType(self: Self, value: i8) Self {
        var result = self;
        result.compression_type = value;
        return result;
    }

    /// Sets `metrics` to the passed value.
    /// Metrics encoded in OpenTelemetry MetricsData v1 protobuf format.
    pub fn withMetrics(self: Self, value: []const u8) Self {
        var result = self;
        result.metrics = value;
        return result;
    }

    /// Encode PushTelemetryRequest
    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: ClientInstanceId
        if (version >= 0 and version <= 32767) {
            try types.encodeUuid(writer, self.client_instance_id);
        }

        // Field: SubscriptionId
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.subscription_id);
        }

        // Field: Terminating
        if (version >= 0 and version <= 32767) {
            try types.encodeBoolean(writer, self.terminating);
        }

        // Field: CompressionType
        if (version >= 0 and version <= 32767) {
            try types.encodeInt8(writer, self.compression_type);
        }

        // Field: Metrics
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactBytes(writer, self.metrics);
            } else {
                try types.encodeBytes(writer, self.metrics);
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

    /// Compute the size of PushTelemetryRequest for the given version
    pub fn computeSize(self: *const Self, version: i16) !usize {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        var total_size: usize = 0;

        // Field: ClientInstanceId
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeUuid(self.client_instance_id);
        }

        // Field: SubscriptionId
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.subscription_id);
        }

        // Field: Terminating
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeBoolean(self.terminating);
        }

        // Field: CompressionType
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt8(self.compression_type);
        }

        // Field: Metrics
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactBytes(self.metrics) else types.computeSizeBytes(self.metrics);
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

    /// Decode PushTelemetryRequest
    pub fn decode(reader: anytype, version: i16, allocator: std.mem.Allocator) !Self {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        var self: Self = .{};

        // Field: ClientInstanceId
        if (version >= 0 and version <= 32767) {
            self.client_instance_id = try types.decodeUuid(reader);
        }

        // Field: SubscriptionId
        if (version >= 0 and version <= 32767) {
            self.subscription_id = try types.decodeInt32(reader);
        }

        // Field: Terminating
        if (version >= 0 and version <= 32767) {
            self.terminating = try types.decodeBoolean(reader);
        }

        // Field: CompressionType
        if (version >= 0 and version <= 32767) {
            self.compression_type = try types.decodeInt8(reader);
        }

        // Field: Metrics
        if (version >= 0 and version <= 32767) {
            self.metrics = if (is_flexible)
                try types.decodeCompactBytes(reader, allocator) orelse ""
            else
                try types.decodeBytes(reader, allocator) orelse "";
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
