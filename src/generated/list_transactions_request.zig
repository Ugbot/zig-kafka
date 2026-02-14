//! Auto-generated Kafka protocol message
//! Message: ListTransactionsRequest
//! API Key: 66
//! Type: request
//! Valid Versions: 0-2
//! Flexible Versions: 0+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// ListTransactionsRequest
pub const ListTransactionsRequest = struct {
    const Self = @This();

    /// The transaction states to filter by: if empty, all transactions are returned; if non-empty, then only transactions matching one of the filtered states will be returned.
    state_filters: ?[][]const u8 = null,
    /// The producerIds to filter by: if empty, all transactions will be returned; if non-empty, only transactions which match one of the filtered producerIds will be returned.
    producer_id_filters: ?[]i64 = null,
    /// Duration (in millis) to filter by: if < 0, all transactions will be returned; otherwise, only transactions running longer than this duration will be returned.
    /// Versions: 1+
    duration_filter: i64 = -1,
    /// The transactional ID regular expression pattern to filter by: if it is empty or null, all transactions are returned; Otherwise then only the transactions matching the given regular expression will be returned.
    /// Versions: 2+
    transactional_id_pattern: ?[]const u8 = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 0, .max = 2 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 66;
    }

    /// Create a default instance of ListTransactionsRequest
    pub fn default() Self {
        return .{
            .state_filters = null,
            .producer_id_filters = null,
            .duration_filter = -1,
            .transactional_id_pattern = null,
            ._tagged_fields = null,
        };
    }

    /// Sets `state_filters` to the passed value.
    /// The transaction states to filter by: if empty, all transactions are returned; if non-empty, then only transactions matching one of the filtered states will be returned.
    pub fn withStateFilters(self: Self, value: ?[][]const u8) Self {
        var result = self;
        result.state_filters = value;
        return result;
    }

    /// Sets `producer_id_filters` to the passed value.
    /// The producerIds to filter by: if empty, all transactions will be returned; if non-empty, only transactions which match one of the filtered producerIds will be returned.
    pub fn withProducerIdFilters(self: Self, value: ?[]i64) Self {
        var result = self;
        result.producer_id_filters = value;
        return result;
    }

    /// Sets `duration_filter` to the passed value.
    /// Duration (in millis) to filter by: if < 0, all transactions will be returned; otherwise, only transactions running longer than this duration will be returned.
    /// Versions: 1+
    pub fn withDurationFilter(self: Self, value: i64) Self {
        var result = self;
        result.duration_filter = value;
        return result;
    }

    /// Sets `transactional_id_pattern` to the passed value.
    /// The transactional ID regular expression pattern to filter by: if it is empty or null, all transactions are returned; Otherwise then only the transactions matching the given regular expression will be returned.
    /// Versions: 2+
    pub fn withTransactionalIdPattern(self: Self, value: ?[]const u8) Self {
        var result = self;
        result.transactional_id_pattern = value;
        return result;
    }

    /// Encode ListTransactionsRequest
    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: StateFilters
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayNonNull([]const u8, writer, self.state_filters, types.encodeCompactString);
            } else {
                try types.encodeArrayNonNull([]const u8, writer, self.state_filters, types.encodeCompactString);
            }
        }

        // Field: ProducerIdFilters
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayNonNull(i64, writer, self.producer_id_filters, types.encodeInt64);
            } else {
                try types.encodeArrayNonNull(i64, writer, self.producer_id_filters, types.encodeInt64);
            }
        }

        // Field: DurationFilter
        if (version >= 1 and version <= 32767) {
            try types.encodeInt64(writer, self.duration_filter);
        }

        // Field: TransactionalIdPattern
        if (version >= 2 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.transactional_id_pattern);
            } else {
                try types.encodeString(writer, self.transactional_id_pattern);
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

    /// Compute the size of ListTransactionsRequest for the given version
    pub fn computeSize(self: *const Self, version: i16) !usize {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        var total_size: usize = 0;

        // Field: StateFilters
        if (version >= 0 and version <= 32767) {
            if (self.state_filters) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |item| {
                    total_size += types.computeSizeCompactString(item);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(1) else 4;
            }
        }

        // Field: ProducerIdFilters
        if (version >= 0 and version <= 32767) {
            if (self.producer_id_filters) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |item| {
                    total_size += types.computeSizeInt64(item);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(1) else 4;
            }
        }

        // Field: DurationFilter
        if (version >= 1 and version <= 32767) {
            total_size += types.computeSizeInt64(self.duration_filter);
        }

        // Field: TransactionalIdPattern
        if (version >= 2 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.transactional_id_pattern) else types.computeSizeString(self.transactional_id_pattern);
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

    /// Decode ListTransactionsRequest
    pub fn decode(reader: anytype, version: i16, allocator: std.mem.Allocator) !Self {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        var self: Self = .{};

        // Field: StateFilters
        if (version >= 0 and version <= 32767) {
            self.state_filters = if (is_flexible)
                try types.decodeCompactArray([]const u8, reader, allocator, types.decodeNonNullableCompactString)
            else
                try types.decodeArray([]const u8, reader, allocator, types.decodeNonNullableString);
        }

        // Field: ProducerIdFilters
        if (version >= 0 and version <= 32767) {
            self.producer_id_filters = if (is_flexible)
                try types.decodeCompactPrimitiveArray(i64, reader, allocator, types.decodeInt64)
            else
                try types.decodePrimitiveArray(i64, reader, allocator, types.decodeInt64);
        }

        // Field: DurationFilter
        if (version >= 1 and version <= 32767) {
            self.duration_filter = try types.decodeInt64(reader);
        }

        // Field: TransactionalIdPattern
        if (version >= 2 and version <= 32767) {
            self.transactional_id_pattern = if (is_flexible)
                try types.decodeCompactString(reader, allocator)
            else
                try types.decodeString(reader, allocator);
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
