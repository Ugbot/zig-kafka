//! Auto-generated Kafka protocol message
//! Message: AddOffsetsToTxnRequest
//! API Key: 25
//! Type: request
//! Valid Versions: 0-4
//! Flexible Versions: 3+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// AddOffsetsToTxnRequest
pub const AddOffsetsToTxnRequest = struct {
    const Self = @This();

    /// The transactional id corresponding to the transaction.
    transactional_id: []const u8 = "",
    /// Current producer id in use by the transactional id.
    producer_id: i64 = 0,
    /// Current epoch associated with the producer id.
    producer_epoch: i16 = 0,
    /// The unique group identifier.
    group_id: []const u8 = "",

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 0, .max = 4 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 25;
    }

    /// Create a default instance of AddOffsetsToTxnRequest
    pub fn default() Self {
        return .{
            .transactional_id = "",
            .producer_id = 0,
            .producer_epoch = 0,
            .group_id = "",
            ._tagged_fields = null,
        };
    }

    /// Sets `transactional_id` to the passed value.
    /// The transactional id corresponding to the transaction.
    pub fn withTransactionalId(self: Self, value: []const u8) Self {
        var result = self;
        result.transactional_id = value;
        return result;
    }

    /// Sets `producer_id` to the passed value.
    /// Current producer id in use by the transactional id.
    pub fn withProducerId(self: Self, value: i64) Self {
        var result = self;
        result.producer_id = value;
        return result;
    }

    /// Sets `producer_epoch` to the passed value.
    /// Current epoch associated with the producer id.
    pub fn withProducerEpoch(self: Self, value: i16) Self {
        var result = self;
        result.producer_epoch = value;
        return result;
    }

    /// Sets `group_id` to the passed value.
    /// The unique group identifier.
    pub fn withGroupId(self: Self, value: []const u8) Self {
        var result = self;
        result.group_id = value;
        return result;
    }

    /// Encode AddOffsetsToTxnRequest
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

        // Field: GroupId
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.group_id);
            } else {
                try types.encodeString(writer, self.group_id);
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

    /// Compute the size of AddOffsetsToTxnRequest for the given version
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

        // Field: GroupId
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.group_id) else types.computeSizeString(self.group_id);
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

    /// Decode AddOffsetsToTxnRequest
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

        // Field: GroupId
        if (version >= 0 and version <= 32767) {
            self.group_id = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
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
        const range = types.VersionRange.parse("0-4") catch return false;
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
