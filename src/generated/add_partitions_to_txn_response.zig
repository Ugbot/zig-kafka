//! Auto-generated Kafka protocol message
//! Message: AddPartitionsToTxnResponse
//! API Key: 24
//! Type: response
//! Valid Versions: 0-5
//! Flexible Versions: 3+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// Nested struct: AddPartitionsToTxnPartitionResult
pub const AddPartitionsToTxnPartitionResult = struct {
    const Self = @This();

    partition_index: i32 = 0,
    partition_error_code: i16 = 0,
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        try types.encodeInt32(writer, self.partition_index);
        try types.encodeInt16(writer, self.partition_error_code);
        if (is_flexible) {
            if (self._tagged_fields) |fields| {
                try types.encodeTaggedFields(writer, fields);
            } else {
                try types.encodeUnsignedVarInt(writer, 0);
            }
        }
    }

    pub fn computeSize(self: Self) usize {
        _ = self;
        return 4 + 2; // partition_index + partition_error_code
    }

    pub fn decode(reader: anytype, version: i16, allocator: std.mem.Allocator) !Self {
        const is_flexible = isFlexibleVersion(version);
        var self: Self = .{};
        self.partition_index = try types.decodeInt32(reader);
        self.partition_error_code = try types.decodeInt16(reader);
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

/// Nested struct: AddPartitionsToTxnTopicResult
pub const AddPartitionsToTxnTopicResult = struct {
    const Self = @This();

    name: []const u8 = "",
    results_by_partition: ?[]AddPartitionsToTxnPartitionResult = null,
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        if (is_flexible) {
            try types.encodeCompactString(writer, self.name);
            try types.encodeCompactArrayLenNonNull(writer, self.results_by_partition);
            if (self.results_by_partition) |arr| {
                for (arr) |*item| {
                    try AddPartitionsToTxnPartitionResult.encode(item, writer, version);
                }
            }
        } else {
            try types.encodeString(writer, self.name);
            try types.encodeArrayLenNonNull(writer, self.results_by_partition);
            if (self.results_by_partition) |arr| {
                for (arr) |*item| {
                    try AddPartitionsToTxnPartitionResult.encode(item, writer, version);
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

    pub fn computeSize(self: Self) usize {
        var size: usize = types.computeSizeString(self.name) + 4;
        if (self.results_by_partition) |arr| {
            for (arr) |item| {
                size += item.computeSize();
            }
        }
        return size;
    }

    pub fn decode(reader: anytype, version: i16, allocator: std.mem.Allocator) !Self {
        const is_flexible = isFlexibleVersion(version);
        var self: Self = .{};
        if (is_flexible) {
            self.name = try types.decodeCompactString(reader, allocator) orelse "";
            self.results_by_partition = try types.decodeCompactArray(AddPartitionsToTxnPartitionResult, reader, allocator, AddPartitionsToTxnPartitionResult.decode);
        } else {
            self.name = try types.decodeString(reader, allocator) orelse "";
            self.results_by_partition = try types.decodeArray(AddPartitionsToTxnPartitionResult, reader, allocator, AddPartitionsToTxnPartitionResult.decode);
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

/// Nested struct: AddPartitionsToTxnResult
pub const AddPartitionsToTxnResult = struct {
    const Self = @This();

    /// The transactional id corresponding to the transaction.
    /// Versions: 4+
    transactional_id: []const u8 = "",
    /// The results for each topic.
    /// Versions: 4+
    topic_results: ?[]AddPartitionsToTxnTopicResult = null,

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

        // Field: TopicResults
        if (version >= 4 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.topic_results);
                if (self.topic_results) |arr| {
                    for (arr) |*item| {
                        try AddPartitionsToTxnTopicResult.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.topic_results);
                if (self.topic_results) |arr| {
                    for (arr) |*item| {
                        try AddPartitionsToTxnTopicResult.encode(item, writer, version);
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

        // Field: TopicResults
        if (version >= 4 and version <= 32767) {
            if (self.topic_results) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |item| {
                    total_size += AddPartitionsToTxnTopicResult.computeSize(item);
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

        // Field: TopicResults
        if (version >= 4 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            if (array_len > 0) {
                const array = try allocator.alloc(AddPartitionsToTxnTopicResult, array_len);
                for (array) |*item| {
                    item.* = try AddPartitionsToTxnTopicResult.decode(reader, version, allocator);
                }
                self.topic_results = array;
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

/// AddPartitionsToTxnResponse
pub const AddPartitionsToTxnResponse = struct {
    const Self = @This();

    /// Duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    throttle_time_ms: i32 = 0,
    /// The response top level error code.
    /// Versions: 4+
    error_code: i16 = 0,
    /// Results categorized by transactional ID.
    /// Versions: 4+
    results_by_transaction: ?[]AddPartitionsToTxnResult = null,
    /// The results for each topic.
    /// Versions: 0-3
    results_by_topic_v3_and_below: ?[]AddPartitionsToTxnTopicResult = null,

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

    /// Create a default instance of AddPartitionsToTxnResponse
    pub fn default() Self {
        return .{
            .throttle_time_ms = 0,
            .error_code = 0,
            .results_by_transaction = null,
            .results_by_topic_v3_and_below = null,
            ._tagged_fields = null,
        };
    }

    /// Sets `throttle_time_ms` to the passed value.
    /// Duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    pub fn withThrottleTimeMs(self: Self, value: i32) Self {
        var result = self;
        result.throttle_time_ms = value;
        return result;
    }

    /// Sets `error_code` to the passed value.
    /// The response top level error code.
    /// Versions: 4+
    pub fn withErrorCode(self: Self, value: i16) Self {
        var result = self;
        result.error_code = value;
        return result;
    }

    /// Sets `results_by_transaction` to the passed value.
    /// Results categorized by transactional ID.
    /// Versions: 4+
    pub fn withResultsByTransaction(self: Self, value: ?[]AddPartitionsToTxnResult) Self {
        var result = self;
        result.results_by_transaction = value;
        return result;
    }

    /// Sets `results_by_topic_v3_and_below` to the passed value.
    /// The results for each topic.
    /// Versions: 0-3
    pub fn withResultsByTopicV3AndBelow(self: Self, value: ?[]AddPartitionsToTxnTopicResult) Self {
        var result = self;
        result.results_by_topic_v3_and_below = value;
        return result;
    }

    /// Encode AddPartitionsToTxnResponse
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
        if (version >= 4 and version <= 32767) {
            try types.encodeInt16(writer, self.error_code);
        }

        // Field: ResultsByTransaction
        if (version >= 4 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.results_by_transaction);
                if (self.results_by_transaction) |arr| {
                    for (arr) |*item| {
                        try AddPartitionsToTxnResult.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.results_by_transaction);
                if (self.results_by_transaction) |arr| {
                    for (arr) |*item| {
                        try AddPartitionsToTxnResult.encode(item, writer, version);
                    }
                }
            }
        }

        // Field: ResultsByTopicV3AndBelow
        if (version >= 0 and version <= 3) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.results_by_topic_v3_and_below);
                if (self.results_by_topic_v3_and_below) |arr| {
                    for (arr) |*item| {
                        try AddPartitionsToTxnTopicResult.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.results_by_topic_v3_and_below);
                if (self.results_by_topic_v3_and_below) |arr| {
                    for (arr) |*item| {
                        try AddPartitionsToTxnTopicResult.encode(item, writer, version);
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

    /// Compute the size of AddPartitionsToTxnResponse for the given version
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
        if (version >= 4 and version <= 32767) {
            total_size += types.computeSizeInt16(self.error_code);
        }

        // Field: ResultsByTransaction
        if (version >= 4 and version <= 32767) {
            if (self.results_by_transaction) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try AddPartitionsToTxnResult.computeSize(item, version);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(1) else 4;
            }
        }

        // Field: ResultsByTopicV3AndBelow
        if (version >= 0 and version <= 3) {
            if (self.results_by_topic_v3_and_below) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |item| {
                    total_size += AddPartitionsToTxnTopicResult.computeSize(item);
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

    /// Decode AddPartitionsToTxnResponse
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
        if (version >= 4 and version <= 32767) {
            self.error_code = try types.decodeInt16(reader);
        }

        // Field: ResultsByTransaction
        if (version >= 4 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(AddPartitionsToTxnResult, array_len);
            for (array) |*item| {
                item.* = try AddPartitionsToTxnResult.decode(reader, version, allocator);
            }
            self.results_by_transaction = array;
        }

        // Field: ResultsByTopicV3AndBelow
        if (version >= 0 and version <= 3) {
            self.results_by_topic_v3_and_below = if (is_flexible)
                try types.decodeCompactArray(AddPartitionsToTxnTopicResult, reader, allocator, AddPartitionsToTxnTopicResult.decode)
            else
                try types.decodeArray(AddPartitionsToTxnTopicResult, reader, allocator, AddPartitionsToTxnTopicResult.decode);
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
