//! Auto-generated Kafka protocol message
//! Message: AddPartitionsToTxnRequest
//! API Key: 24
//! Type: request
//! Valid Versions: 0-5
//! Flexible Versions: 3+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// Nested struct: AddPartitionsToTxnTopic
pub const AddPartitionsToTxnTopic = struct {
    const Self = @This();

    name: []const u8 = "",
    partitions: ?[]i32 = null,
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        if (is_flexible) {
            try types.encodeCompactString(writer, self.name);
            if (self.partitions) |parts| {
                const len: u32 = @intCast(parts.len + 1);
                try types.encodeUnsignedVarInt(writer, len);
                for (parts) |p| {
                    try types.encodeInt32(writer, p);
                }
            } else {
                try types.encodeUnsignedVarInt(writer, 0);
            }
        } else {
            try types.encodeString(writer, self.name);
            if (self.partitions) |parts| {
                try types.encodeInt32(writer, @intCast(parts.len));
                for (parts) |p| {
                    try types.encodeInt32(writer, p);
                }
            } else {
                try types.encodeInt32(writer, -1);
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

    pub fn computeSize(self: Self) usize {
        var size: usize = types.computeSizeString(self.name);

        if (self.partitions) |parts| {
            size += 4; // array length
            size += parts.len * 4; // partition IDs
        } else {
            size += 4;
        }

        return size;
    }

    pub fn decode(reader: anytype, version: i16, allocator: std.mem.Allocator) !Self {
        const is_flexible = isFlexibleVersion(version);
        var self: Self = .{};

        if (is_flexible) {
            self.name = try types.decodeCompactString(reader, allocator) orelse "";
            const array_len = try types.decodeCompactArrayLen(reader);
            if (array_len > 0) {
                const array = try allocator.alloc(i32, array_len);
                for (array) |*item| {
                    item.* = try types.decodeInt32(reader);
                }
                self.partitions = array;
            }
        } else {
            self.name = try types.decodeString(reader, allocator) orelse "";
            const array_len = try types.decodeArrayLen(reader);
            if (array_len > 0) {
                const array = try allocator.alloc(i32, array_len);
                for (array) |*item| {
                    item.* = try types.decodeInt32(reader);
                }
                self.partitions = array;
            }
        }

        if (is_flexible) {
            const tagged_fields_data = try types.decodeTaggedFields(reader, allocator);
            self._tagged_fields = tagged_fields_data;
        }
        return self;
    }

    fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("3+") catch return false;
        return range.contains(version);
    }
};

/// Nested struct: AddPartitionsToTxnTransaction
pub const AddPartitionsToTxnTransaction = struct {
    const Self = @This();

    /// The transactional id corresponding to the transaction.
    /// Versions: 4+
    transactional_id: []const u8 = "",
    /// Current producer id in use by the transactional id.
    /// Versions: 4+
    producer_id: i64 = 0,
    /// Current epoch associated with the producer id.
    /// Versions: 4+
    producer_epoch: i16 = 0,
    /// Boolean to signify if we want to check if the partition is in the transaction rather than add it.
    /// Versions: 4+
    verify_only: bool = false,
    /// The partitions to add to the transaction.
    /// Versions: 4+
    topics: ?[]AddPartitionsToTxnTopic = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: TransactionalId
        if (version >= 4 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.transactional_id);
            } else {
                try types.encodeString(writer, self.transactional_id);
            }
        }

        // Field: ProducerId
        if (version >= 4 and version <= 32767) {
            try types.encodeInt64(writer, self.producer_id);
        }

        // Field: ProducerEpoch
        if (version >= 4 and version <= 32767) {
            try types.encodeInt16(writer, self.producer_epoch);
        }

        // Field: VerifyOnly
        if (version >= 4 and version <= 32767) {
            try types.encodeBoolean(writer, self.verify_only);
        }

        // Field: Topics
        if (version >= 4 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.topics);
                if (self.topics) |arr| {
                    for (arr) |*item| {
                        try AddPartitionsToTxnTopic.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.topics);
                if (self.topics) |arr| {
                    for (arr) |*item| {
                        try AddPartitionsToTxnTopic.encode(item, writer, version);
                    }
                }
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

        // Field: TransactionalId
        if (version >= 4 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.transactional_id) else types.computeSizeString(self.transactional_id);
        }

        // Field: ProducerId
        if (version >= 4 and version <= 32767) {
            total_size += types.computeSizeInt64(self.producer_id);
        }

        // Field: ProducerEpoch
        if (version >= 4 and version <= 32767) {
            total_size += types.computeSizeInt16(self.producer_epoch);
        }

        // Field: VerifyOnly
        if (version >= 4 and version <= 32767) {
            total_size += types.computeSizeBoolean(self.verify_only);
        }

        // Field: Topics
        if (version >= 4 and version <= 32767) {
            if (self.topics) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |item| {
                    total_size += AddPartitionsToTxnTopic.computeSize(item);
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
        // Field: TransactionalId
        if (version >= 4 and version <= 32767) {
            self.transactional_id = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: ProducerId
        if (version >= 4 and version <= 32767) {
            self.producer_id = try types.decodeInt64(reader);
        }

        // Field: ProducerEpoch
        if (version >= 4 and version <= 32767) {
            self.producer_epoch = try types.decodeInt16(reader);
        }

        // Field: VerifyOnly
        if (version >= 4 and version <= 32767) {
            self.verify_only = try types.decodeBoolean(reader);
        }

        // Field: Topics
        if (version >= 4 and version <= 32767) {
            self.topics = if (is_flexible)
                try types.decodeCompactArray(AddPartitionsToTxnTopic, reader, allocator, AddPartitionsToTxnTopic.decode)
            else
                try types.decodeArray(AddPartitionsToTxnTopic, reader, allocator, AddPartitionsToTxnTopic.decode);
        }


        if (is_flexible) {
            const tagged_fields_data = try types.decodeTaggedFields(reader, allocator);
            self._tagged_fields = tagged_fields_data;
        }
        return self;
    }

    fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("3+") catch return false;
        return range.contains(version);
    }
};

/// AddPartitionsToTxnRequest
pub const AddPartitionsToTxnRequest = struct {
    const Self = @This();

    /// List of transactions to add partitions to.
    /// Versions: 4+
    transactions: ?[]AddPartitionsToTxnTransaction = null,
    /// The transactional id corresponding to the transaction.
    /// Versions: 0-3
    v3_and_below_transactional_id: []const u8 = "",
    /// Current producer id in use by the transactional id.
    /// Versions: 0-3
    v3_and_below_producer_id: i64 = 0,
    /// Current epoch associated with the producer id.
    /// Versions: 0-3
    v3_and_below_producer_epoch: i16 = 0,
    /// The partitions to add to the transaction.
    /// Versions: 0-3
    v3_and_below_topics: ?[]AddPartitionsToTxnTopic = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 0, .max = 5 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 24;
    }

    /// Create a default instance of AddPartitionsToTxnRequest
    pub fn default() Self {
        return .{
            .transactions = null,
            .v3_and_below_transactional_id = "",
            .v3_and_below_producer_id = 0,
            .v3_and_below_producer_epoch = 0,
            .v3_and_below_topics = null,
            ._tagged_fields = null,
        };
    }

    /// Sets `transactions` to the passed value.
    /// List of transactions to add partitions to.
    /// Versions: 4+
    pub fn withTransactions(self: Self, value: ?[]AddPartitionsToTxnTransaction) Self {
        var result = self;
        result.transactions = value;
        return result;
    }

    /// Sets `v3_and_below_transactional_id` to the passed value.
    /// The transactional id corresponding to the transaction.
    /// Versions: 0-3
    pub fn withV3AndBelowTransactionalId(self: Self, value: []const u8) Self {
        var result = self;
        result.v3_and_below_transactional_id = value;
        return result;
    }

    /// Sets `v3_and_below_producer_id` to the passed value.
    /// Current producer id in use by the transactional id.
    /// Versions: 0-3
    pub fn withV3AndBelowProducerId(self: Self, value: i64) Self {
        var result = self;
        result.v3_and_below_producer_id = value;
        return result;
    }

    /// Sets `v3_and_below_producer_epoch` to the passed value.
    /// Current epoch associated with the producer id.
    /// Versions: 0-3
    pub fn withV3AndBelowProducerEpoch(self: Self, value: i16) Self {
        var result = self;
        result.v3_and_below_producer_epoch = value;
        return result;
    }

    /// Sets `v3_and_below_topics` to the passed value.
    /// The partitions to add to the transaction.
    /// Versions: 0-3
    pub fn withV3AndBelowTopics(self: Self, value: ?[]AddPartitionsToTxnTopic) Self {
        var result = self;
        result.v3_and_below_topics = value;
        return result;
    }

    /// Encode AddPartitionsToTxnRequest
    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: Transactions
        if (version >= 4 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.transactions);
                if (self.transactions) |arr| {
                    for (arr) |*item| {
                        try AddPartitionsToTxnTransaction.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.transactions);
                if (self.transactions) |arr| {
                    for (arr) |*item| {
                        try AddPartitionsToTxnTransaction.encode(item, writer, version);
                    }
                }
            }
        }

        // Field: V3AndBelowTransactionalId
        if (version >= 0 and version <= 3) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.v3_and_below_transactional_id);
            } else {
                try types.encodeString(writer, self.v3_and_below_transactional_id);
            }
        }

        // Field: V3AndBelowProducerId
        if (version >= 0 and version <= 3) {
            try types.encodeInt64(writer, self.v3_and_below_producer_id);
        }

        // Field: V3AndBelowProducerEpoch
        if (version >= 0 and version <= 3) {
            try types.encodeInt16(writer, self.v3_and_below_producer_epoch);
        }

        // Field: V3AndBelowTopics
        if (version >= 0 and version <= 3) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.v3_and_below_topics);
                if (self.v3_and_below_topics) |arr| {
                    for (arr) |*item| {
                        try AddPartitionsToTxnTopic.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.v3_and_below_topics);
                if (self.v3_and_below_topics) |arr| {
                    for (arr) |*item| {
                        try AddPartitionsToTxnTopic.encode(item, writer, version);
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

    /// Compute the size of AddPartitionsToTxnRequest for the given version
    pub fn computeSize(self: *const Self, version: i16) !usize {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        var total_size: usize = 0;

        // Field: Transactions
        if (version >= 4 and version <= 32767) {
            if (self.transactions) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try AddPartitionsToTxnTransaction.computeSize(item, version);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(1) else 4;
            }
        }

        // Field: V3AndBelowTransactionalId
        if (version >= 0 and version <= 3) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.v3_and_below_transactional_id) else types.computeSizeString(self.v3_and_below_transactional_id);
        }

        // Field: V3AndBelowProducerId
        if (version >= 0 and version <= 3) {
            total_size += types.computeSizeInt64(self.v3_and_below_producer_id);
        }

        // Field: V3AndBelowProducerEpoch
        if (version >= 0 and version <= 3) {
            total_size += types.computeSizeInt16(self.v3_and_below_producer_epoch);
        }

        // Field: V3AndBelowTopics
        if (version >= 0 and version <= 3) {
            if (self.v3_and_below_topics) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |item| {
                    total_size += AddPartitionsToTxnTopic.computeSize(item);
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

    /// Decode AddPartitionsToTxnRequest
    pub fn decode(reader: anytype, version: i16, allocator: std.mem.Allocator) !Self {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        var self: Self = .{};

        // Field: Transactions
        if (version >= 4 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(AddPartitionsToTxnTransaction, array_len);
            for (array) |*item| {
                item.* = try AddPartitionsToTxnTransaction.decode(reader, version, allocator);
            }
            self.transactions = array;
        }

        // Field: V3AndBelowTransactionalId
        if (version >= 0 and version <= 3) {
            self.v3_and_below_transactional_id = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: V3AndBelowProducerId
        if (version >= 0 and version <= 3) {
            self.v3_and_below_producer_id = try types.decodeInt64(reader);
        }

        // Field: V3AndBelowProducerEpoch
        if (version >= 0 and version <= 3) {
            self.v3_and_below_producer_epoch = try types.decodeInt16(reader);
        }

        // Field: V3AndBelowTopics
        if (version >= 0 and version <= 3) {
            self.v3_and_below_topics = if (is_flexible)
                try types.decodeCompactArray(AddPartitionsToTxnTopic, reader, allocator, AddPartitionsToTxnTopic.decode)
            else
                try types.decodeArray(AddPartitionsToTxnTopic, reader, allocator, AddPartitionsToTxnTopic.decode);
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
