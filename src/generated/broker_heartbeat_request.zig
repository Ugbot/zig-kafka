//! Auto-generated Kafka protocol message
//! Message: BrokerHeartbeatRequest
//! API Key: 63
//! Type: request
//! Valid Versions: 0-1
//! Flexible Versions: 0+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// BrokerHeartbeatRequest
pub const BrokerHeartbeatRequest = struct {
    const Self = @This();

    /// The broker ID.
    broker_id: i32 = 0,
    /// The broker epoch.
    broker_epoch: i64 = -1,
    /// The highest metadata offset which the broker has reached.
    current_metadata_offset: i64 = 0,
    /// True if the broker wants to be fenced, false otherwise.
    want_fence: bool = false,
    /// True if the broker wants to be shut down, false otherwise.
    want_shut_down: bool = false,
    /// Log directories that failed and went offline.
    /// Versions: 1+
    offline_log_dirs: ?[][16]u8 = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 0, .max = 1 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 63;
    }

    /// Create a default instance of BrokerHeartbeatRequest
    pub fn default() Self {
        return .{
            .broker_id = 0,
            .broker_epoch = -1,
            .current_metadata_offset = 0,
            .want_fence = false,
            .want_shut_down = false,
            .offline_log_dirs = null,
            ._tagged_fields = null,
        };
    }

    /// Sets `broker_id` to the passed value.
    /// The broker ID.
    pub fn withBrokerId(self: Self, value: i32) Self {
        var result = self;
        result.broker_id = value;
        return result;
    }

    /// Sets `broker_epoch` to the passed value.
    /// The broker epoch.
    pub fn withBrokerEpoch(self: Self, value: i64) Self {
        var result = self;
        result.broker_epoch = value;
        return result;
    }

    /// Sets `current_metadata_offset` to the passed value.
    /// The highest metadata offset which the broker has reached.
    pub fn withCurrentMetadataOffset(self: Self, value: i64) Self {
        var result = self;
        result.current_metadata_offset = value;
        return result;
    }

    /// Sets `want_fence` to the passed value.
    /// True if the broker wants to be fenced, false otherwise.
    pub fn withWantFence(self: Self, value: bool) Self {
        var result = self;
        result.want_fence = value;
        return result;
    }

    /// Sets `want_shut_down` to the passed value.
    /// True if the broker wants to be shut down, false otherwise.
    pub fn withWantShutDown(self: Self, value: bool) Self {
        var result = self;
        result.want_shut_down = value;
        return result;
    }

    /// Sets `offline_log_dirs` to the passed value.
    /// Log directories that failed and went offline.
    /// Versions: 1+
    pub fn withOfflineLogDirs(self: Self, value: ?[][16]u8) Self {
        var result = self;
        result.offline_log_dirs = value;
        return result;
    }

    /// Encode BrokerHeartbeatRequest
    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: BrokerId
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.broker_id);
        }

        // Field: BrokerEpoch
        if (version >= 0 and version <= 32767) {
            try types.encodeInt64(writer, self.broker_epoch);
        }

        // Field: CurrentMetadataOffset
        if (version >= 0 and version <= 32767) {
            try types.encodeInt64(writer, self.current_metadata_offset);
        }

        // Field: WantFence
        if (version >= 0 and version <= 32767) {
            try types.encodeBoolean(writer, self.want_fence);
        }

        // Field: WantShutDown
        if (version >= 0 and version <= 32767) {
            try types.encodeBoolean(writer, self.want_shut_down);
        }


        if (is_flexible) {
            var num_tagged_fields: u32 = 0;
            if (version >= 1 and version <= 32767) {
                if (self.offline_log_dirs != null) num_tagged_fields += 1;
            }

            // Count unknown tagged fields
            if (self._tagged_fields) |fields| {
                num_tagged_fields += @intCast(fields.len);
            }

            try types.encodeUnsignedVarInt(writer, num_tagged_fields);

            // Tagged field: OfflineLogDirs (tag 0)
            if (version >= 1 and version <= 32767) {
                if (self.offline_log_dirs) |val| {
                    try types.encodeUnsignedVarInt(writer, 0);
                    // TODO: Handle array of primitives in tagged fields
                }
            }

            // Encode unknown tagged fields
            if (self._tagged_fields) |fields| {
                try types.encodeTaggedFields(writer, fields);
            }
        }
    }

    /// Compute the size of BrokerHeartbeatRequest for the given version
    pub fn computeSize(self: *const Self, version: i16) !usize {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        var total_size: usize = 0;

        // Field: BrokerId
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.broker_id);
        }

        // Field: BrokerEpoch
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt64(self.broker_epoch);
        }

        // Field: CurrentMetadataOffset
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt64(self.current_metadata_offset);
        }

        // Field: WantFence
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeBoolean(self.want_fence);
        }

        // Field: WantShutDown
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeBoolean(self.want_shut_down);
        }

        if (is_flexible) {
            var num_tagged_fields: u32 = 0;
            if (version >= 1 and version <= 32767) {
                if (self.offline_log_dirs != null) num_tagged_fields += 1;
            }

            if (self._tagged_fields) |fields| {
                num_tagged_fields += @intCast(fields.len);
            }

            total_size += types.computeSizeUnsignedVarInt(num_tagged_fields);

            // Tagged field: OfflineLogDirs (tag 0)
            if (version >= 1 and version <= 32767) {
                if (self.offline_log_dirs) |val| {
                    total_size += types.computeSizeUnsignedVarInt(0);
                    // TODO: Array of primitives
                }
            }

            if (self._tagged_fields) |fields| {
                total_size += types.computeSizeTaggedFields(fields);
            }
        }

        return total_size;
    }

    /// Decode BrokerHeartbeatRequest
    pub fn decode(reader: anytype, version: i16, allocator: std.mem.Allocator) !Self {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        var self: Self = .{};

        // Field: BrokerId
        if (version >= 0 and version <= 32767) {
            self.broker_id = try types.decodeInt32(reader);
        }

        // Field: BrokerEpoch
        if (version >= 0 and version <= 32767) {
            self.broker_epoch = try types.decodeInt64(reader);
        }

        // Field: CurrentMetadataOffset
        if (version >= 0 and version <= 32767) {
            self.current_metadata_offset = try types.decodeInt64(reader);
        }

        // Field: WantFence
        if (version >= 0 and version <= 32767) {
            self.want_fence = try types.decodeBoolean(reader);
        }

        // Field: WantShutDown
        if (version >= 0 and version <= 32767) {
            self.want_shut_down = try types.decodeBoolean(reader);
        }


        if (is_flexible) {
            const num_tagged_fields = try types.decodeUnsignedVarInt(reader);
            var unknown_tagged_fields = std.array_list.Managed(types.TaggedField).init(allocator);

            var i: u32 = 0;
            while (i < num_tagged_fields) : (i += 1) {
                const tag = try types.decodeUnsignedVarInt(reader);
                const size = try types.decodeUnsignedVarInt(reader);
                switch (tag) {
                    0 => { // OfflineLogDirs
                        if (version >= 1 and version <= 32767) {
                            // TODO: Decode array of primitives
                        } else {
                            try reader.skipBytes(size, .{});
                        }
                    },
                    else => {
                        const field_data = try allocator.alloc(u8, size);
                        _ = try reader.readAll(field_data);
                        try unknown_tagged_fields.append(.{ .tag = tag, .data = field_data });
                    },
                }
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
