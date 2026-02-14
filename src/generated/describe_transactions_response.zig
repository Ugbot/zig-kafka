//! Auto-generated Kafka protocol message
//! Message: DescribeTransactionsResponse
//! API Key: 65
//! Type: response
//! Valid Versions: 0
//! Flexible Versions: 0+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// Nested struct: TransactionState
pub const TransactionState = struct {
    const Self = @This();

    /// The error code.
    /// Versions: 0+
    error_code: i16 = 0,
    /// The transactional id.
    /// Versions: 0+
    transactional_id: []const u8 = "",
    /// The current transaction state of the producer.
    /// Versions: 0+
    transaction_state: []const u8 = "",
    /// The timeout in milliseconds for the transaction.
    /// Versions: 0+
    transaction_timeout_ms: i32 = 0,
    /// The start time of the transaction in milliseconds.
    /// Versions: 0+
    transaction_start_time_ms: i64 = 0,
    /// The current producer id associated with the transaction.
    /// Versions: 0+
    producer_id: i64 = 0,
    /// The current epoch associated with the producer id.
    /// Versions: 0+
    producer_epoch: i16 = 0,
    /// The set of partitions included in the current transaction (if active). When a transaction is preparing to commit or abort, this will include only partitions which do not have markers.
    /// Versions: 0+
    topics: ?[]TopicData = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: ErrorCode
        if (version >= 0 and version <= 32767) {
            try types.encodeInt16(writer, self.error_code);
        }

        // Field: TransactionalId
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.transactional_id);
            } else {
                try types.encodeString(writer, self.transactional_id);
            }
        }

        // Field: TransactionState
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.transaction_state);
            } else {
                try types.encodeString(writer, self.transaction_state);
            }
        }

        // Field: TransactionTimeoutMs
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.transaction_timeout_ms);
        }

        // Field: TransactionStartTimeMs
        if (version >= 0 and version <= 32767) {
            try types.encodeInt64(writer, self.transaction_start_time_ms);
        }

        // Field: ProducerId
        if (version >= 0 and version <= 32767) {
            try types.encodeInt64(writer, self.producer_id);
        }

        // Field: ProducerEpoch
        if (version >= 0 and version <= 32767) {
            try types.encodeInt16(writer, self.producer_epoch);
        }

        // Field: Topics
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.topics);
                if (self.topics) |arr| {
                    for (arr) |*item| {
                        try TopicData.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.topics);
                if (self.topics) |arr| {
                    for (arr) |*item| {
                        try TopicData.encode(item, writer, version);
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

        // Field: ErrorCode
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt16(self.error_code);
        }

        // Field: TransactionalId
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.transactional_id) else types.computeSizeString(self.transactional_id);
        }

        // Field: TransactionState
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.transaction_state) else types.computeSizeString(self.transaction_state);
        }

        // Field: TransactionTimeoutMs
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.transaction_timeout_ms);
        }

        // Field: TransactionStartTimeMs
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt64(self.transaction_start_time_ms);
        }

        // Field: ProducerId
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt64(self.producer_id);
        }

        // Field: ProducerEpoch
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt16(self.producer_epoch);
        }

        // Field: Topics
        if (version >= 0 and version <= 32767) {
            if (self.topics) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try TopicData.computeSize(item, version);
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
        // Field: ErrorCode
        if (version >= 0 and version <= 32767) {
            self.error_code = try types.decodeInt16(reader);
        }

        // Field: TransactionalId
        if (version >= 0 and version <= 32767) {
            self.transactional_id = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: TransactionState
        if (version >= 0 and version <= 32767) {
            self.transaction_state = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: TransactionTimeoutMs
        if (version >= 0 and version <= 32767) {
            self.transaction_timeout_ms = try types.decodeInt32(reader);
        }

        // Field: TransactionStartTimeMs
        if (version >= 0 and version <= 32767) {
            self.transaction_start_time_ms = try types.decodeInt64(reader);
        }

        // Field: ProducerId
        if (version >= 0 and version <= 32767) {
            self.producer_id = try types.decodeInt64(reader);
        }

        // Field: ProducerEpoch
        if (version >= 0 and version <= 32767) {
            self.producer_epoch = try types.decodeInt16(reader);
        }

        // Field: Topics
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(TopicData, array_len);
            for (array) |*item| {
                item.* = try TopicData.decode(reader, version, allocator);
            }
            self.topics = array;
        }


        if (is_flexible) {
            const tagged_fields_data = try types.decodeTaggedFields(reader, allocator);
            self._tagged_fields = tagged_fields_data;
        }
        return self;
    }

    fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("0+") catch return false;
        return range.contains(version);
    }
};

/// Nested struct: TopicData
pub const TopicData = struct {
    const Self = @This();

    /// The topic name.
    /// Versions: 0+
    topic: []const u8 = "",
    /// The partition ids included in the current transaction.
    /// Versions: 0+
    partitions: ?[]i32 = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: Topic
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.topic);
            } else {
                try types.encodeString(writer, self.topic);
            }
        }

        // Field: Partitions
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayNonNull(i32, writer, self.partitions, types.encodeInt32);
            } else {
                try types.encodeArrayNonNull(i32, writer, self.partitions, types.encodeInt32);
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

        // Field: Topic
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.topic) else types.computeSizeString(self.topic);
        }

        // Field: Partitions
        if (version >= 0 and version <= 32767) {
            if (self.partitions) |arr| {
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
        // Field: Topic
        if (version >= 0 and version <= 32767) {
            self.topic = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: Partitions
        if (version >= 0 and version <= 32767) {
            self.partitions = if (is_flexible)
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
        const range = types.VersionRange.parse("0+") catch return false;
        return range.contains(version);
    }
};

/// DescribeTransactionsResponse
pub const DescribeTransactionsResponse = struct {
    const Self = @This();

    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    throttle_time_ms: i32 = 0,
    /// The current state of the transaction.
    transaction_states: ?[]TransactionState = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 0, .max = 0 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 65;
    }

    /// Create a default instance of DescribeTransactionsResponse
    pub fn default() Self {
        return .{
            .throttle_time_ms = 0,
            .transaction_states = null,
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

    /// Sets `transaction_states` to the passed value.
    /// The current state of the transaction.
    pub fn withTransactionStates(self: Self, value: ?[]TransactionState) Self {
        var result = self;
        result.transaction_states = value;
        return result;
    }

    /// Encode DescribeTransactionsResponse
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

        // Field: TransactionStates
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.transaction_states);
                if (self.transaction_states) |arr| {
                    for (arr) |*item| {
                        try TransactionState.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.transaction_states);
                if (self.transaction_states) |arr| {
                    for (arr) |*item| {
                        try TransactionState.encode(item, writer, version);
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

    /// Compute the size of DescribeTransactionsResponse for the given version
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

        // Field: TransactionStates
        if (version >= 0 and version <= 32767) {
            if (self.transaction_states) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try TransactionState.computeSize(item, version);
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

    /// Decode DescribeTransactionsResponse
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

        // Field: TransactionStates
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(TransactionState, array_len);
            for (array) |*item| {
                item.* = try TransactionState.decode(reader, version, allocator);
            }
            self.transaction_states = array;
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
