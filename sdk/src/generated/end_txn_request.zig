//! Auto-generated Kafka protocol message
//! Message: EndTxnRequest
//! API Key: 26
//! Type: request
//! Valid Versions: 0-5
//! Flexible Versions: 3+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// EndTxnRequest
pub const EndTxnRequest = struct {
    const Self = @This();

    /// The ID of the transaction to end.
    transactional_id: []const u8 = "",
    /// The producer ID.
    producer_id: i64 = 0,
    /// The current epoch associated with the producer.
    producer_epoch: i16 = 0,
    /// True if the transaction was committed, false if it was aborted.
    committed: bool = false,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 0, .max = 5 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 26;
    }

    /// Create a default instance of EndTxnRequest
    pub fn default() Self {
        return .{
            .transactional_id = "",
            .producer_id = 0,
            .producer_epoch = 0,
            .committed = false,
            ._tagged_fields = null,
        };
    }

    /// Sets `transactional_id` to the passed value.
    /// The ID of the transaction to end.
    pub fn withTransactionalId(self: Self, value: []const u8) Self {
        var result = self;
        result.transactional_id = value;
        return result;
    }

    /// Sets `producer_id` to the passed value.
    /// The producer ID.
    pub fn withProducerId(self: Self, value: i64) Self {
        var result = self;
        result.producer_id = value;
        return result;
    }

    /// Sets `producer_epoch` to the passed value.
    /// The current epoch associated with the producer.
    pub fn withProducerEpoch(self: Self, value: i16) Self {
        var result = self;
        result.producer_epoch = value;
        return result;
    }

    /// Sets `committed` to the passed value.
    /// True if the transaction was committed, false if it was aborted.
    pub fn withCommitted(self: Self, value: bool) Self {
        var result = self;
        result.committed = value;
        return result;
    }

    /// Encode EndTxnRequest
    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: TransactionalId
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.transactional_id);
            } else {
                try types.encodeString(writer, self.transactional_id);
            }
        }

        // Field: ProducerId
        if (version >= 0 and version <= 32767) {
            try types.encodeInt64(writer, self.producer_id);
        }

        // Field: ProducerEpoch
        if (version >= 0 and version <= 32767) {
            try types.encodeInt16(writer, self.producer_epoch);
        }

        // Field: Committed
        if (version >= 0 and version <= 32767) {
            try types.encodeBoolean(writer, self.committed);
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

    /// Compute the size of EndTxnRequest for the given version
    pub fn computeSize(self: *const Self, version: i16) !usize {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        var total_size: usize = 0;

        // Field: TransactionalId
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.transactional_id) else types.computeSizeString(self.transactional_id);
        }

        // Field: ProducerId
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt64(self.producer_id);
        }

        // Field: ProducerEpoch
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt16(self.producer_epoch);
        }

        // Field: Committed
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeBoolean(self.committed);
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

    /// Decode EndTxnRequest
    pub fn decode(reader: anytype, version: i16, allocator: std.mem.Allocator) !Self {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        var self: Self = .{};

        // Field: TransactionalId
        if (version >= 0 and version <= 32767) {
            self.transactional_id = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: ProducerId
        if (version >= 0 and version <= 32767) {
            self.producer_id = try types.decodeInt64(reader);
        }

        // Field: ProducerEpoch
        if (version >= 0 and version <= 32767) {
            self.producer_epoch = try types.decodeInt16(reader);
        }

        // Field: Committed
        if (version >= 0 and version <= 32767) {
            self.committed = try types.decodeBoolean(reader);
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
        const range = types.VersionRange.parse("0-5") catch return false;
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
