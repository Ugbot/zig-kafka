//! Auto-generated Kafka protocol message
//! Message: GetTelemetrySubscriptionsResponse
//! API Key: 71
//! Type: response
//! Valid Versions: 0
//! Flexible Versions: 0+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// GetTelemetrySubscriptionsResponse
pub const GetTelemetrySubscriptionsResponse = struct {
    const Self = @This();

    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    throttle_time_ms: i32 = 0,
    /// The error code, or 0 if there was no error.
    error_code: i16 = 0,
    /// Assigned client instance id if ClientInstanceId was 0 in the request, else 0.
    client_instance_id: [16]u8 = [_]u8{0} ** 16,
    /// Unique identifier for the current subscription set for this client instance.
    subscription_id: i32 = 0,
    /// Compression types that broker accepts for the PushTelemetryRequest.
    accepted_compression_types: ?[]i8 = null,
    /// Configured push interval, which is the lowest configured interval in the current subscription set.
    push_interval_ms: i32 = 0,
    /// The maximum bytes of binary data the broker accepts in PushTelemetryRequest.
    telemetry_max_bytes: i32 = 0,
    /// Flag to indicate monotonic/counter metrics are to be emitted as deltas or cumulative values.
    delta_temporality: bool = false,
    /// Requested metrics prefix string match. Empty array: No metrics subscribed, Array[0] empty string: All metrics subscribed.
    requested_metrics: ?[][]const u8 = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 0, .max = 0 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 71;
    }

    /// Create a default instance of GetTelemetrySubscriptionsResponse
    pub fn default() Self {
        return .{
            .throttle_time_ms = 0,
            .error_code = 0,
            .client_instance_id = [_]u8{0} ** 16,
            .subscription_id = 0,
            .accepted_compression_types = null,
            .push_interval_ms = 0,
            .telemetry_max_bytes = 0,
            .delta_temporality = false,
            .requested_metrics = null,
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
    /// The error code, or 0 if there was no error.
    pub fn withErrorCode(self: Self, value: i16) Self {
        var result = self;
        result.error_code = value;
        return result;
    }

    /// Sets `client_instance_id` to the passed value.
    /// Assigned client instance id if ClientInstanceId was 0 in the request, else 0.
    pub fn withClientInstanceId(self: Self, value: [16]u8) Self {
        var result = self;
        result.client_instance_id = value;
        return result;
    }

    /// Sets `subscription_id` to the passed value.
    /// Unique identifier for the current subscription set for this client instance.
    pub fn withSubscriptionId(self: Self, value: i32) Self {
        var result = self;
        result.subscription_id = value;
        return result;
    }

    /// Sets `accepted_compression_types` to the passed value.
    /// Compression types that broker accepts for the PushTelemetryRequest.
    pub fn withAcceptedCompressionTypes(self: Self, value: ?[]i8) Self {
        var result = self;
        result.accepted_compression_types = value;
        return result;
    }

    /// Sets `push_interval_ms` to the passed value.
    /// Configured push interval, which is the lowest configured interval in the current subscription set.
    pub fn withPushIntervalMs(self: Self, value: i32) Self {
        var result = self;
        result.push_interval_ms = value;
        return result;
    }

    /// Sets `telemetry_max_bytes` to the passed value.
    /// The maximum bytes of binary data the broker accepts in PushTelemetryRequest.
    pub fn withTelemetryMaxBytes(self: Self, value: i32) Self {
        var result = self;
        result.telemetry_max_bytes = value;
        return result;
    }

    /// Sets `delta_temporality` to the passed value.
    /// Flag to indicate monotonic/counter metrics are to be emitted as deltas or cumulative values.
    pub fn withDeltaTemporality(self: Self, value: bool) Self {
        var result = self;
        result.delta_temporality = value;
        return result;
    }

    /// Sets `requested_metrics` to the passed value.
    /// Requested metrics prefix string match. Empty array: No metrics subscribed, Array[0] empty string: All metrics subscribed.
    pub fn withRequestedMetrics(self: Self, value: ?[][]const u8) Self {
        var result = self;
        result.requested_metrics = value;
        return result;
    }

    /// Encode GetTelemetrySubscriptionsResponse
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

        // Field: ClientInstanceId
        if (version >= 0 and version <= 32767) {
            try types.encodeUuid(writer, self.client_instance_id);
        }

        // Field: SubscriptionId
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.subscription_id);
        }

        // Field: AcceptedCompressionTypes
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayNonNull(i8, writer, self.accepted_compression_types, types.encodeInt8);
            } else {
                try types.encodeArrayNonNull(i8, writer, self.accepted_compression_types, types.encodeInt8);
            }
        }

        // Field: PushIntervalMs
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.push_interval_ms);
        }

        // Field: TelemetryMaxBytes
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.telemetry_max_bytes);
        }

        // Field: DeltaTemporality
        if (version >= 0 and version <= 32767) {
            try types.encodeBoolean(writer, self.delta_temporality);
        }

        // Field: RequestedMetrics
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayNonNull([]const u8, writer, self.requested_metrics, types.encodeCompactString);
            } else {
                try types.encodeArrayNonNull([]const u8, writer, self.requested_metrics, types.encodeCompactString);
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

    /// Compute the size of GetTelemetrySubscriptionsResponse for the given version
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

        // Field: ClientInstanceId
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeUuid(self.client_instance_id);
        }

        // Field: SubscriptionId
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.subscription_id);
        }

        // Field: AcceptedCompressionTypes
        if (version >= 0 and version <= 32767) {
            if (self.accepted_compression_types) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |item| {
                    total_size += types.computeSizeInt8(item);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(1) else 4;
            }
        }

        // Field: PushIntervalMs
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.push_interval_ms);
        }

        // Field: TelemetryMaxBytes
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.telemetry_max_bytes);
        }

        // Field: DeltaTemporality
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeBoolean(self.delta_temporality);
        }

        // Field: RequestedMetrics
        if (version >= 0 and version <= 32767) {
            if (self.requested_metrics) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |item| {
                    total_size += types.computeSizeCompactString(item);
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

    /// Decode GetTelemetrySubscriptionsResponse
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

        // Field: ClientInstanceId
        if (version >= 0 and version <= 32767) {
            self.client_instance_id = try types.decodeUuid(reader);
        }

        // Field: SubscriptionId
        if (version >= 0 and version <= 32767) {
            self.subscription_id = try types.decodeInt32(reader);
        }

        // Field: AcceptedCompressionTypes
        if (version >= 0 and version <= 32767) {
            self.accepted_compression_types = if (is_flexible)
                try types.decodeCompactPrimitiveArray(i8, reader, allocator, types.decodeInt8)
            else
                try types.decodePrimitiveArray(i8, reader, allocator, types.decodeInt8);
        }

        // Field: PushIntervalMs
        if (version >= 0 and version <= 32767) {
            self.push_interval_ms = try types.decodeInt32(reader);
        }

        // Field: TelemetryMaxBytes
        if (version >= 0 and version <= 32767) {
            self.telemetry_max_bytes = try types.decodeInt32(reader);
        }

        // Field: DeltaTemporality
        if (version >= 0 and version <= 32767) {
            self.delta_temporality = try types.decodeBoolean(reader);
        }

        // Field: RequestedMetrics
        if (version >= 0 and version <= 32767) {
            self.requested_metrics = if (is_flexible)
                try types.decodeCompactArray([]const u8, reader, allocator, types.decodeNonNullableCompactString)
            else
                try types.decodeArray([]const u8, reader, allocator, types.decodeNonNullableString);
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
