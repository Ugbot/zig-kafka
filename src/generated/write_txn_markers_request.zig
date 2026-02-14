//! Auto-generated Kafka protocol message
//! Message: WriteTxnMarkersRequest
//! API Key: 27
//! Type: request
//! Valid Versions: 1
//! Flexible Versions: 1+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// Nested struct: WritableTxnMarker
pub const WritableTxnMarker = struct {
    const Self = @This();

    /// The current producer ID.
    /// Versions: 0+
    producer_id: i64 = 0,
    /// The current epoch associated with the producer ID.
    /// Versions: 0+
    producer_epoch: i16 = 0,
    /// The result of the transaction to write to the partitions (false = ABORT, true = COMMIT).
    /// Versions: 0+
    transaction_result: bool = false,
    /// Each topic that we want to write transaction marker(s) for.
    /// Versions: 0+
    topics: ?[]WritableTxnMarkerTopic = null,
    /// Epoch associated with the transaction state partition hosted by this transaction coordinator.
    /// Versions: 0+
    coordinator_epoch: i32 = 0,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: ProducerId
        if (version >= 0 and version <= 32767) {
            try types.encodeInt64(writer, self.producer_id);
        }

        // Field: ProducerEpoch
        if (version >= 0 and version <= 32767) {
            try types.encodeInt16(writer, self.producer_epoch);
        }

        // Field: TransactionResult
        if (version >= 0 and version <= 32767) {
            try types.encodeBoolean(writer, self.transaction_result);
        }

        // Field: Topics
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.topics);
                if (self.topics) |arr| {
                    for (arr) |*item| {
                        try WritableTxnMarkerTopic.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.topics);
                if (self.topics) |arr| {
                    for (arr) |*item| {
                        try WritableTxnMarkerTopic.encode(item, writer, version);
                    }
                }
            }
        }

        // Field: CoordinatorEpoch
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.coordinator_epoch);
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

        // Field: ProducerId
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt64(self.producer_id);
        }

        // Field: ProducerEpoch
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt16(self.producer_epoch);
        }

        // Field: TransactionResult
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeBoolean(self.transaction_result);
        }

        // Field: Topics
        if (version >= 0 and version <= 32767) {
            if (self.topics) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try WritableTxnMarkerTopic.computeSize(item, version);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(1) else 4;
            }
        }

        // Field: CoordinatorEpoch
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.coordinator_epoch);
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
        // Field: ProducerId
        if (version >= 0 and version <= 32767) {
            self.producer_id = try types.decodeInt64(reader);
        }

        // Field: ProducerEpoch
        if (version >= 0 and version <= 32767) {
            self.producer_epoch = try types.decodeInt16(reader);
        }

        // Field: TransactionResult
        if (version >= 0 and version <= 32767) {
            self.transaction_result = try types.decodeBoolean(reader);
        }

        // Field: Topics
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(WritableTxnMarkerTopic, array_len);
            for (array) |*item| {
                item.* = try WritableTxnMarkerTopic.decode(reader, version, allocator);
            }
            self.topics = array;
        }

        // Field: CoordinatorEpoch
        if (version >= 0 and version <= 32767) {
            self.coordinator_epoch = try types.decodeInt32(reader);
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

/// Nested struct: WritableTxnMarkerTopic
pub const WritableTxnMarkerTopic = struct {
    const Self = @This();

    /// The topic name.
    /// Versions: 0+
    name: []const u8 = "",
    /// The indexes of the partitions to write transaction markers for.
    /// Versions: 0+
    partition_indexes: ?[]i32 = null,

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

        // Field: PartitionIndexes
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayNonNull(i32, writer, self.partition_indexes, types.encodeInt32);
            } else {
                try types.encodeArrayNonNull(i32, writer, self.partition_indexes, types.encodeInt32);
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

        // Field: Name
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.name) else types.computeSizeString(self.name);
        }

        // Field: PartitionIndexes
        if (version >= 0 and version <= 32767) {
            if (self.partition_indexes) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |item| {
                    total_size += types.computeSizeInt32(item);
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
        // Field: Name
        if (version >= 0 and version <= 32767) {
            self.name = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: PartitionIndexes
        if (version >= 0 and version <= 32767) {
            self.partition_indexes = if (is_flexible)
                try types.decodeCompactPrimitiveArray(i32, reader, allocator, types.decodeInt32)
            else
                try types.decodePrimitiveArray(i32, reader, allocator, types.decodeInt32);
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

/// WriteTxnMarkersRequest
pub const WriteTxnMarkersRequest = struct {
    const Self = @This();

    /// The transaction markers to be written.
    markers: ?[]WritableTxnMarker = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 1, .max = 1 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 27;
    }

    /// Create a default instance of WriteTxnMarkersRequest
    pub fn default() Self {
        return .{
            .markers = null,
            ._tagged_fields = null,
        };
    }

    /// Sets `markers` to the passed value.
    /// The transaction markers to be written.
    pub fn withMarkers(self: Self, value: ?[]WritableTxnMarker) Self {
        var result = self;
        result.markers = value;
        return result;
    }

    /// Encode WriteTxnMarkersRequest
    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: Markers
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.markers);
                if (self.markers) |arr| {
                    for (arr) |*item| {
                        try WritableTxnMarker.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.markers);
                if (self.markers) |arr| {
                    for (arr) |*item| {
                        try WritableTxnMarker.encode(item, writer, version);
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

    /// Compute the size of WriteTxnMarkersRequest for the given version
    pub fn computeSize(self: *const Self, version: i16) !usize {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        var total_size: usize = 0;

        // Field: Markers
        if (version >= 0 and version <= 32767) {
            if (self.markers) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try WritableTxnMarker.computeSize(item, version);
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

    /// Decode WriteTxnMarkersRequest
    pub fn decode(reader: anytype, version: i16, allocator: std.mem.Allocator) !Self {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        var self: Self = .{};

        // Field: Markers
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(WritableTxnMarker, array_len);
            for (array) |*item| {
                item.* = try WritableTxnMarker.decode(reader, version, allocator);
            }
            self.markers = array;
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
        const range = types.VersionRange.parse("1") catch return false;
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
