//! Auto-generated Kafka protocol message
//! Message: InitProducerIdRequest
//! API Key: 22
//! Type: request
//! Valid Versions: 0-6
//! Flexible Versions: 2+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// InitProducerIdRequest
pub const InitProducerIdRequest = struct {
    const Self = @This();

    /// The transactional id, or null if the producer is not transactional.
    transactional_id: ?[]const u8 = null,
    /// The time in ms to wait before aborting idle transactions sent by this producer. This is only relevant if a TransactionalId has been defined.
    transaction_timeout_ms: i32 = 0,
    /// The producer id. This is used to disambiguate requests if a transactional id is reused following its expiration.
    /// Versions: 3+
    producer_id: i64 = -1,
    /// The producer's current epoch. This will be checked against the producer epoch on the broker, and the request will return an error if they do not match.
    /// Versions: 3+
    producer_epoch: i16 = -1,
    /// True if the client wants to enable two-phase commit (2PC) protocol for transactions.
    /// Versions: 6+
    enable2_pc: bool = false,
    /// True if the client wants to keep the currently ongoing transaction instead of aborting it.
    /// Versions: 6+
    keep_prepared_txn: bool = false,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 0, .max = 6 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 22;
    }

    /// Create a default instance of InitProducerIdRequest
    pub fn default() Self {
        return .{
            .transactional_id = null,
            .transaction_timeout_ms = 0,
            .producer_id = -1,
            .producer_epoch = -1,
            .enable2_pc = false,
            .keep_prepared_txn = false,
            ._tagged_fields = null,
        };
    }

    /// Sets `transactional_id` to the passed value.
    /// The transactional id, or null if the producer is not transactional.
    pub fn withTransactionalId(self: Self, value: ?[]const u8) Self {
        var result = self;
        result.transactional_id = value;
        return result;
    }

    /// Sets `transaction_timeout_ms` to the passed value.
    /// The time in ms to wait before aborting idle transactions sent by this producer. This is only relevant if a TransactionalId has been defined.
    pub fn withTransactionTimeoutMs(self: Self, value: i32) Self {
        var result = self;
        result.transaction_timeout_ms = value;
        return result;
    }

    /// Sets `producer_id` to the passed value.
    /// The producer id. This is used to disambiguate requests if a transactional id is reused following its expiration.
    /// Versions: 3+
    pub fn withProducerId(self: Self, value: i64) Self {
        var result = self;
        result.producer_id = value;
        return result;
    }

    /// Sets `producer_epoch` to the passed value.
    /// The producer's current epoch. This will be checked against the producer epoch on the broker, and the request will return an error if they do not match.
    /// Versions: 3+
    pub fn withProducerEpoch(self: Self, value: i16) Self {
        var result = self;
        result.producer_epoch = value;
        return result;
    }

    /// Sets `enable2_pc` to the passed value.
    /// True if the client wants to enable two-phase commit (2PC) protocol for transactions.
    /// Versions: 6+
    pub fn withEnable2Pc(self: Self, value: bool) Self {
        var result = self;
        result.enable2_pc = value;
        return result;
    }

    /// Sets `keep_prepared_txn` to the passed value.
    /// True if the client wants to keep the currently ongoing transaction instead of aborting it.
    /// Versions: 6+
    pub fn withKeepPreparedTxn(self: Self, value: bool) Self {
        var result = self;
        result.keep_prepared_txn = value;
        return result;
    }

    /// Encode InitProducerIdRequest
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

        // Field: TransactionTimeoutMs
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.transaction_timeout_ms);
        }

        // Field: ProducerId
        if (version >= 3 and version <= 32767) {
            try types.encodeInt64(writer, self.producer_id);
        }

        // Field: ProducerEpoch
        if (version >= 3 and version <= 32767) {
            try types.encodeInt16(writer, self.producer_epoch);
        }

        // Field: Enable2Pc
        if (version >= 6 and version <= 32767) {
            try types.encodeBoolean(writer, self.enable2_pc);
        }

        // Field: KeepPreparedTxn
        if (version >= 6 and version <= 32767) {
            try types.encodeBoolean(writer, self.keep_prepared_txn);
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

    /// Compute the size of InitProducerIdRequest for the given version
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

        // Field: TransactionTimeoutMs
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.transaction_timeout_ms);
        }

        // Field: ProducerId
        if (version >= 3 and version <= 32767) {
            total_size += types.computeSizeInt64(self.producer_id);
        }

        // Field: ProducerEpoch
        if (version >= 3 and version <= 32767) {
            total_size += types.computeSizeInt16(self.producer_epoch);
        }

        // Field: Enable2Pc
        if (version >= 6 and version <= 32767) {
            total_size += types.computeSizeBoolean(self.enable2_pc);
        }

        // Field: KeepPreparedTxn
        if (version >= 6 and version <= 32767) {
            total_size += types.computeSizeBoolean(self.keep_prepared_txn);
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

    /// Decode InitProducerIdRequest
    pub fn decode(reader: anytype, version: i16, allocator: std.mem.Allocator) !Self {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        var self: Self = .{};

        // Field: TransactionalId
        if (version >= 0 and version <= 32767) {
            self.transactional_id = if (is_flexible)
                try types.decodeCompactString(reader, allocator)
            else
                try types.decodeString(reader, allocator);
        }

        // Field: TransactionTimeoutMs
        if (version >= 0 and version <= 32767) {
            self.transaction_timeout_ms = try types.decodeInt32(reader);
        }

        // Field: ProducerId
        if (version >= 3 and version <= 32767) {
            self.producer_id = try types.decodeInt64(reader);
        }

        // Field: ProducerEpoch
        if (version >= 3 and version <= 32767) {
            self.producer_epoch = try types.decodeInt16(reader);
        }

        // Field: Enable2Pc
        if (version >= 6 and version <= 32767) {
            self.enable2_pc = try types.decodeBoolean(reader);
        }

        // Field: KeepPreparedTxn
        if (version >= 6 and version <= 32767) {
            self.keep_prepared_txn = try types.decodeBoolean(reader);
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
        const range = types.VersionRange.parse("2+") catch return false;
        return range.contains(version);
    }
    /// Get the header version for this API version
    /// Returns 2 for flexible versions, 1 for classic versions
    pub fn headerVersion(api_version: i16) i16 {
        if (isFlexibleVersion(api_version)) return 2;
        return 1;
    }

};
