//! Auto-generated Kafka protocol message
//! Message: DescribeDelegationTokenResponse
//! API Key: 41
//! Type: response
//! Valid Versions: 1-3
//! Flexible Versions: 2+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// Nested struct: DescribedDelegationToken
pub const DescribedDelegationToken = struct {
    const Self = @This();

    /// The token principal type.
    /// Versions: 0+
    principal_type: []const u8 = "",
    /// The token principal name.
    /// Versions: 0+
    principal_name: []const u8 = "",
    /// The principal type of the requester of the token.
    /// Versions: 3+
    token_requester_principal_type: []const u8 = "",
    /// The principal type of the requester of the token.
    /// Versions: 3+
    token_requester_principal_name: []const u8 = "",
    /// The token issue timestamp in milliseconds.
    /// Versions: 0+
    issue_timestamp: i64 = 0,
    /// The token expiry timestamp in milliseconds.
    /// Versions: 0+
    expiry_timestamp: i64 = 0,
    /// The token maximum timestamp length in milliseconds.
    /// Versions: 0+
    max_timestamp: i64 = 0,
    /// The token ID.
    /// Versions: 0+
    token_id: []const u8 = "",
    /// The token HMAC.
    /// Versions: 0+
    hmac: []const u8 = &[_]u8{},
    /// Those who are able to renew this token before it expires.
    /// Versions: 0+
    renewers: ?[]DescribedDelegationTokenRenewer = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: PrincipalType
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.principal_type);
            } else {
                try types.encodeString(writer, self.principal_type);
            }
        }

        // Field: PrincipalName
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.principal_name);
            } else {
                try types.encodeString(writer, self.principal_name);
            }
        }

        // Field: TokenRequesterPrincipalType
        if (version >= 3 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.token_requester_principal_type);
            } else {
                try types.encodeString(writer, self.token_requester_principal_type);
            }
        }

        // Field: TokenRequesterPrincipalName
        if (version >= 3 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.token_requester_principal_name);
            } else {
                try types.encodeString(writer, self.token_requester_principal_name);
            }
        }

        // Field: IssueTimestamp
        if (version >= 0 and version <= 32767) {
            try types.encodeInt64(writer, self.issue_timestamp);
        }

        // Field: ExpiryTimestamp
        if (version >= 0 and version <= 32767) {
            try types.encodeInt64(writer, self.expiry_timestamp);
        }

        // Field: MaxTimestamp
        if (version >= 0 and version <= 32767) {
            try types.encodeInt64(writer, self.max_timestamp);
        }

        // Field: TokenId
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.token_id);
            } else {
                try types.encodeString(writer, self.token_id);
            }
        }

        // Field: Hmac
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactBytes(writer, self.hmac);
            } else {
                try types.encodeBytes(writer, self.hmac);
            }
        }

        // Field: Renewers
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.renewers);
                if (self.renewers) |arr| {
                    for (arr) |*item| {
                        try DescribedDelegationTokenRenewer.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.renewers);
                if (self.renewers) |arr| {
                    for (arr) |*item| {
                        try DescribedDelegationTokenRenewer.encode(item, writer, version);
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

        // Field: PrincipalType
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.principal_type) else types.computeSizeString(self.principal_type);
        }

        // Field: PrincipalName
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.principal_name) else types.computeSizeString(self.principal_name);
        }

        // Field: TokenRequesterPrincipalType
        if (version >= 3 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.token_requester_principal_type) else types.computeSizeString(self.token_requester_principal_type);
        }

        // Field: TokenRequesterPrincipalName
        if (version >= 3 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.token_requester_principal_name) else types.computeSizeString(self.token_requester_principal_name);
        }

        // Field: IssueTimestamp
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt64(self.issue_timestamp);
        }

        // Field: ExpiryTimestamp
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt64(self.expiry_timestamp);
        }

        // Field: MaxTimestamp
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt64(self.max_timestamp);
        }

        // Field: TokenId
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.token_id) else types.computeSizeString(self.token_id);
        }

        // Field: Hmac
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactBytes(self.hmac) else types.computeSizeBytes(self.hmac);
        }

        // Field: Renewers
        if (version >= 0 and version <= 32767) {
            if (self.renewers) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try DescribedDelegationTokenRenewer.computeSize(item, version);
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
        // Field: PrincipalType
        if (version >= 0 and version <= 32767) {
            self.principal_type = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: PrincipalName
        if (version >= 0 and version <= 32767) {
            self.principal_name = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: TokenRequesterPrincipalType
        if (version >= 3 and version <= 32767) {
            self.token_requester_principal_type = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: TokenRequesterPrincipalName
        if (version >= 3 and version <= 32767) {
            self.token_requester_principal_name = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: IssueTimestamp
        if (version >= 0 and version <= 32767) {
            self.issue_timestamp = try types.decodeInt64(reader);
        }

        // Field: ExpiryTimestamp
        if (version >= 0 and version <= 32767) {
            self.expiry_timestamp = try types.decodeInt64(reader);
        }

        // Field: MaxTimestamp
        if (version >= 0 and version <= 32767) {
            self.max_timestamp = try types.decodeInt64(reader);
        }

        // Field: TokenId
        if (version >= 0 and version <= 32767) {
            self.token_id = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: Hmac
        if (version >= 0 and version <= 32767) {
            self.hmac = if (is_flexible)
                try types.decodeCompactBytes(reader, allocator) orelse ""
            else
                try types.decodeBytes(reader, allocator) orelse "";
        }

        // Field: Renewers
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(DescribedDelegationTokenRenewer, array_len);
            for (array) |*item| {
                item.* = try DescribedDelegationTokenRenewer.decode(reader, version, allocator);
            }
            self.renewers = array;
        }


        if (is_flexible) {
            const tagged_fields_data = try types.decodeTaggedFields(reader, allocator);
            self._tagged_fields = tagged_fields_data;
        }
        return self;
    }

    fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("2+") catch return false;
        return range.contains(version);
    }
};

/// Nested struct: DescribedDelegationTokenRenewer
pub const DescribedDelegationTokenRenewer = struct {
    const Self = @This();

    /// The renewer principal type.
    /// Versions: 0+
    principal_type: []const u8 = "",
    /// The renewer principal name.
    /// Versions: 0+
    principal_name: []const u8 = "",

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: PrincipalType
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.principal_type);
            } else {
                try types.encodeString(writer, self.principal_type);
            }
        }

        // Field: PrincipalName
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.principal_name);
            } else {
                try types.encodeString(writer, self.principal_name);
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

        // Field: PrincipalType
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.principal_type) else types.computeSizeString(self.principal_type);
        }

        // Field: PrincipalName
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.principal_name) else types.computeSizeString(self.principal_name);
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
        // Field: PrincipalType
        if (version >= 0 and version <= 32767) {
            self.principal_type = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: PrincipalName
        if (version >= 0 and version <= 32767) {
            self.principal_name = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }


        if (is_flexible) {
            const tagged_fields_data = try types.decodeTaggedFields(reader, allocator);
            self._tagged_fields = tagged_fields_data;
        }
        return self;
    }

    fn isFlexibleVersion(version: i16) bool {
        const range = types.VersionRange.parse("2+") catch return false;
        return range.contains(version);
    }
};

/// DescribeDelegationTokenResponse
pub const DescribeDelegationTokenResponse = struct {
    const Self = @This();

    /// The error code, or 0 if there was no error.
    error_code: i16 = 0,
    /// The tokens.
    tokens: ?[]DescribedDelegationToken = null,
    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    throttle_time_ms: i32 = 0,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 1, .max = 3 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 41;
    }

    /// Create a default instance of DescribeDelegationTokenResponse
    pub fn default() Self {
        return .{
            .error_code = 0,
            .tokens = null,
            .throttle_time_ms = 0,
            ._tagged_fields = null,
        };
    }

    /// Sets `error_code` to the passed value.
    /// The error code, or 0 if there was no error.
    pub fn withErrorCode(self: Self, value: i16) Self {
        var result = self;
        result.error_code = value;
        return result;
    }

    /// Sets `tokens` to the passed value.
    /// The tokens.
    pub fn withTokens(self: Self, value: ?[]DescribedDelegationToken) Self {
        var result = self;
        result.tokens = value;
        return result;
    }

    /// Sets `throttle_time_ms` to the passed value.
    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    pub fn withThrottleTimeMs(self: Self, value: i32) Self {
        var result = self;
        result.throttle_time_ms = value;
        return result;
    }

    /// Encode DescribeDelegationTokenResponse
    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: ErrorCode
        if (version >= 0 and version <= 32767) {
            try types.encodeInt16(writer, self.error_code);
        }

        // Field: Tokens
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.tokens);
                if (self.tokens) |arr| {
                    for (arr) |*item| {
                        try DescribedDelegationToken.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.tokens);
                if (self.tokens) |arr| {
                    for (arr) |*item| {
                        try DescribedDelegationToken.encode(item, writer, version);
                    }
                }
            }
        }

        // Field: ThrottleTimeMs
        if (version >= 0 and version <= 32767) {
            try types.encodeInt32(writer, self.throttle_time_ms);
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

    /// Compute the size of DescribeDelegationTokenResponse for the given version
    pub fn computeSize(self: *const Self, version: i16) !usize {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        var total_size: usize = 0;

        // Field: ErrorCode
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt16(self.error_code);
        }

        // Field: Tokens
        if (version >= 0 and version <= 32767) {
            if (self.tokens) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try DescribedDelegationToken.computeSize(item, version);
                }
            } else {
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(1) else 4;
            }
        }

        // Field: ThrottleTimeMs
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt32(self.throttle_time_ms);
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

    /// Decode DescribeDelegationTokenResponse
    pub fn decode(reader: anytype, version: i16, allocator: std.mem.Allocator) !Self {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        var self: Self = .{};

        // Field: ErrorCode
        if (version >= 0 and version <= 32767) {
            self.error_code = try types.decodeInt16(reader);
        }

        // Field: Tokens
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(DescribedDelegationToken, array_len);
            for (array) |*item| {
                item.* = try DescribedDelegationToken.decode(reader, version, allocator);
            }
            self.tokens = array;
        }

        // Field: ThrottleTimeMs
        if (version >= 0 and version <= 32767) {
            self.throttle_time_ms = try types.decodeInt32(reader);
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
        const range = types.VersionRange.parse("1-3") catch return false;
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
