//! Auto-generated Kafka protocol message
//! Message: SnapshotHeaderRecord
//! Type: data
//! Valid Versions: 0
//! Flexible Versions: 0+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// SnapshotHeaderRecord
pub const SnapshotHeaderRecord = struct {
    const Self = @This();

    /// The version of the snapshot header record.
    version: i16 = 0,
    /// The append time of the last record from the log contained in this snapshot.
    last_contained_log_timestamp: i64 = 0,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 0, .max = 0 };

    /// Create a default instance of SnapshotHeaderRecord
    pub fn default() Self {
        return .{
            .version = 0,
            .last_contained_log_timestamp = 0,
            ._tagged_fields = null,
        };
    }

    /// Sets `version` to the passed value.
    /// The version of the snapshot header record.
    pub fn withVersion(self: Self, value: i16) Self {
        var result = self;
        result.version = value;
        return result;
    }

    /// Sets `last_contained_log_timestamp` to the passed value.
    /// The append time of the last record from the log contained in this snapshot.
    pub fn withLastContainedLogTimestamp(self: Self, value: i64) Self {
        var result = self;
        result.last_contained_log_timestamp = value;
        return result;
    }

    /// Encode SnapshotHeaderRecord
    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: Version
        if (version >= 0 and version <= 32767) {
            try types.encodeInt16(writer, self.version);
        }

        // Field: LastContainedLogTimestamp
        if (version >= 0 and version <= 32767) {
            try types.encodeInt64(writer, self.last_contained_log_timestamp);
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

    /// Compute the size of SnapshotHeaderRecord for the given version
    pub fn computeSize(self: *const Self, version: i16) !usize {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        var total_size: usize = 0;

        // Field: Version
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt16(self.version);
        }

        // Field: LastContainedLogTimestamp
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt64(self.last_contained_log_timestamp);
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

    /// Decode SnapshotHeaderRecord
    pub fn decode(reader: anytype, version: i16, allocator: std.mem.Allocator) !Self {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        var self: Self = .{};

        // Field: Version
        if (version >= 0 and version <= 32767) {
            self.version = try types.decodeInt16(reader);
        }

        // Field: LastContainedLogTimestamp
        if (version >= 0 and version <= 32767) {
            self.last_contained_log_timestamp = try types.decodeInt64(reader);
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
