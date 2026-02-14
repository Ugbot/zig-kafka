//! Auto-generated Kafka protocol message
//! Message: CreateDelegationTokenResponse
//! API Key: 38
//! Type: response
//! Valid Versions: 1-3
//! Flexible Versions: 2+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// CreateDelegationTokenResponse
pub const CreateDelegationTokenResponse = struct {
    const Self = @This();

    /// The top-level error, or zero if there was no error.
    error_code: i16 = 0,
    /// The principal type of the token owner.
    principal_type: []const u8 = "",
    /// The name of the token owner.
    principal_name: []const u8 = "",
    /// The principal type of the requester of the token.
    /// Versions: 3+
    token_requester_principal_type: []const u8 = "",
    /// The principal type of the requester of the token.
    /// Versions: 3+
    token_requester_principal_name: []const u8 = "",
    /// When this token was generated.
    issue_timestamp_ms: i64 = 0,
    /// When this token expires.
    expiry_timestamp_ms: i64 = 0,
    /// The maximum lifetime of this token.
    max_timestamp_ms: i64 = 0,
    /// The token UUID.
    token_id: []const u8 = "",
    /// HMAC of the delegation token.
    hmac: []const u8 = &[_]u8{},
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
        return 38;
    }

    /// Create a default instance of CreateDelegationTokenResponse
    pub fn default() Self {
        return .{
            .error_code = 0,
            .principal_type = "",
            .principal_name = "",
            .token_requester_principal_type = "",
            .token_requester_principal_name = "",
            .issue_timestamp_ms = 0,
            .expiry_timestamp_ms = 0,
            .max_timestamp_ms = 0,
            .token_id = "",
            .hmac = &[_]u8{},
            .throttle_time_ms = 0,
            ._tagged_fields = null,
        };
    }

    /// Sets `error_code` to the passed value.
    /// The top-level error, or zero if there was no error.
    pub fn withErrorCode(self: Self, value: i16) Self {
        var result = self;
        result.error_code = value;
        return result;
    }

    /// Sets `principal_type` to the passed value.
    /// The principal type of the token owner.
    pub fn withPrincipalType(self: Self, value: []const u8) Self {
        var result = self;
        result.principal_type = value;
        return result;
    }

    /// Sets `principal_name` to the passed value.
    /// The name of the token owner.
    pub fn withPrincipalName(self: Self, value: []const u8) Self {
        var result = self;
        result.principal_name = value;
        return result;
    }

    /// Sets `token_requester_principal_type` to the passed value.
    /// The principal type of the requester of the token.
    /// Versions: 3+
    pub fn withTokenRequesterPrincipalType(self: Self, value: []const u8) Self {
        var result = self;
        result.token_requester_principal_type = value;
        return result;
    }

    /// Sets `token_requester_principal_name` to the passed value.
    /// The principal type of the requester of the token.
    /// Versions: 3+
    pub fn withTokenRequesterPrincipalName(self: Self, value: []const u8) Self {
        var result = self;
        result.token_requester_principal_name = value;
        return result;
    }

    /// Sets `issue_timestamp_ms` to the passed value.
    /// When this token was generated.
    pub fn withIssueTimestampMs(self: Self, value: i64) Self {
        var result = self;
        result.issue_timestamp_ms = value;
        return result;
    }

    /// Sets `expiry_timestamp_ms` to the passed value.
    /// When this token expires.
    pub fn withExpiryTimestampMs(self: Self, value: i64) Self {
        var result = self;
        result.expiry_timestamp_ms = value;
        return result;
    }

    /// Sets `max_timestamp_ms` to the passed value.
    /// The maximum lifetime of this token.
    pub fn withMaxTimestampMs(self: Self, value: i64) Self {
        var result = self;
        result.max_timestamp_ms = value;
        return result;
    }

    /// Sets `token_id` to the passed value.
    /// The token UUID.
    pub fn withTokenId(self: Self, value: []const u8) Self {
        var result = self;
        result.token_id = value;
        return result;
    }

    /// Sets `hmac` to the passed value.
    /// HMAC of the delegation token.
    pub fn withHmac(self: Self, value: []const u8) Self {
        var result = self;
        result.hmac = value;
        return result;
    }

    /// Sets `throttle_time_ms` to the passed value.
    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    pub fn withThrottleTimeMs(self: Self, value: i32) Self {
        var result = self;
        result.throttle_time_ms = value;
        return result;
    }

    /// Encode CreateDelegationTokenResponse
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

        // Field: IssueTimestampMs
        if (version >= 0 and version <= 32767) {
            try types.encodeInt64(writer, self.issue_timestamp_ms);
        }

        // Field: ExpiryTimestampMs
        if (version >= 0 and version <= 32767) {
            try types.encodeInt64(writer, self.expiry_timestamp_ms);
        }

        // Field: MaxTimestampMs
        if (version >= 0 and version <= 32767) {
            try types.encodeInt64(writer, self.max_timestamp_ms);
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

    /// Compute the size of CreateDelegationTokenResponse for the given version
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

        // Field: IssueTimestampMs
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt64(self.issue_timestamp_ms);
        }

        // Field: ExpiryTimestampMs
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt64(self.expiry_timestamp_ms);
        }

        // Field: MaxTimestampMs
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt64(self.max_timestamp_ms);
        }

        // Field: TokenId
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.token_id) else types.computeSizeString(self.token_id);
        }

        // Field: Hmac
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactBytes(self.hmac) else types.computeSizeBytes(self.hmac);
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

    /// Decode CreateDelegationTokenResponse
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

        // Field: IssueTimestampMs
        if (version >= 0 and version <= 32767) {
            self.issue_timestamp_ms = try types.decodeInt64(reader);
        }

        // Field: ExpiryTimestampMs
        if (version >= 0 and version <= 32767) {
            self.expiry_timestamp_ms = try types.decodeInt64(reader);
        }

        // Field: MaxTimestampMs
        if (version >= 0 and version <= 32767) {
            self.max_timestamp_ms = try types.decodeInt64(reader);
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

        // Field: ThrottleTimeMs
        if (version >= 0 and version <= 32767) {
            self.throttle_time_ms = try types.decodeInt32(reader);
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
