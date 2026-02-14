//! Auto-generated Kafka protocol message
//! Message: DeleteAclsResponse
//! API Key: 31
//! Type: response
//! Valid Versions: 1-3
//! Flexible Versions: 2+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// Nested struct: DeleteAclsFilterResult
pub const DeleteAclsFilterResult = struct {
    const Self = @This();

    /// The error code, or 0 if the filter succeeded.
    /// Versions: 0+
    error_code: i16 = 0,
    /// The error message, or null if the filter succeeded.
    /// Versions: 0+
    error_message: ?[]const u8 = null,
    /// The ACLs which matched this filter.
    /// Versions: 0+
    matching_acls: ?[]DeleteAclsMatchingAcl = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: ErrorCode
        if (version >= 0 and version <= 32767) {
            try types.encodeInt16(writer, self.error_code);
        }

        // Field: ErrorMessage
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.error_message);
            } else {
                try types.encodeString(writer, self.error_message);
            }
        }

        // Field: MatchingAcls
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.matching_acls);
                if (self.matching_acls) |arr| {
                    for (arr) |*item| {
                        try DeleteAclsMatchingAcl.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.matching_acls);
                if (self.matching_acls) |arr| {
                    for (arr) |*item| {
                        try DeleteAclsMatchingAcl.encode(item, writer, version);
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

        // Field: ErrorMessage
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.error_message) else types.computeSizeString(self.error_message);
        }

        // Field: MatchingAcls
        if (version >= 0 and version <= 32767) {
            if (self.matching_acls) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try DeleteAclsMatchingAcl.computeSize(item, version);
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

        // Field: ErrorMessage
        if (version >= 0 and version <= 32767) {
            self.error_message = if (is_flexible)
                try types.decodeCompactString(reader, allocator)
            else
                try types.decodeString(reader, allocator);
        }

        // Field: MatchingAcls
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(DeleteAclsMatchingAcl, array_len);
            for (array) |*item| {
                item.* = try DeleteAclsMatchingAcl.decode(reader, version, allocator);
            }
            self.matching_acls = array;
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

/// Nested struct: DeleteAclsMatchingAcl
pub const DeleteAclsMatchingAcl = struct {
    const Self = @This();

    /// The deletion error code, or 0 if the deletion succeeded.
    /// Versions: 0+
    error_code: i16 = 0,
    /// The deletion error message, or null if the deletion succeeded.
    /// Versions: 0+
    error_message: ?[]const u8 = null,
    /// The ACL resource type.
    /// Versions: 0+
    resource_type: i8 = 0,
    /// The ACL resource name.
    /// Versions: 0+
    resource_name: []const u8 = "",
    /// The ACL resource pattern type.
    /// Versions: 1+
    pattern_type: i8 = 3,
    /// The ACL principal.
    /// Versions: 0+
    principal: []const u8 = "",
    /// The ACL host.
    /// Versions: 0+
    host: []const u8 = "",
    /// The ACL operation.
    /// Versions: 0+
    operation: i8 = 0,
    /// The ACL permission type.
    /// Versions: 0+
    permission_type: i8 = 0,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: ErrorCode
        if (version >= 0 and version <= 32767) {
            try types.encodeInt16(writer, self.error_code);
        }

        // Field: ErrorMessage
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.error_message);
            } else {
                try types.encodeString(writer, self.error_message);
            }
        }

        // Field: ResourceType
        if (version >= 0 and version <= 32767) {
            try types.encodeInt8(writer, self.resource_type);
        }

        // Field: ResourceName
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.resource_name);
            } else {
                try types.encodeString(writer, self.resource_name);
            }
        }

        // Field: PatternType
        if (version >= 1 and version <= 32767) {
            try types.encodeInt8(writer, self.pattern_type);
        }

        // Field: Principal
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.principal);
            } else {
                try types.encodeString(writer, self.principal);
            }
        }

        // Field: Host
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactString(writer, self.host);
            } else {
                try types.encodeString(writer, self.host);
            }
        }

        // Field: Operation
        if (version >= 0 and version <= 32767) {
            try types.encodeInt8(writer, self.operation);
        }

        // Field: PermissionType
        if (version >= 0 and version <= 32767) {
            try types.encodeInt8(writer, self.permission_type);
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

        // Field: ErrorMessage
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.error_message) else types.computeSizeString(self.error_message);
        }

        // Field: ResourceType
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt8(self.resource_type);
        }

        // Field: ResourceName
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.resource_name) else types.computeSizeString(self.resource_name);
        }

        // Field: PatternType
        if (version >= 1 and version <= 32767) {
            total_size += types.computeSizeInt8(self.pattern_type);
        }

        // Field: Principal
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.principal) else types.computeSizeString(self.principal);
        }

        // Field: Host
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactString(self.host) else types.computeSizeString(self.host);
        }

        // Field: Operation
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt8(self.operation);
        }

        // Field: PermissionType
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeInt8(self.permission_type);
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

        // Field: ErrorMessage
        if (version >= 0 and version <= 32767) {
            self.error_message = if (is_flexible)
                try types.decodeCompactString(reader, allocator)
            else
                try types.decodeString(reader, allocator);
        }

        // Field: ResourceType
        if (version >= 0 and version <= 32767) {
            self.resource_type = try types.decodeInt8(reader);
        }

        // Field: ResourceName
        if (version >= 0 and version <= 32767) {
            self.resource_name = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: PatternType
        if (version >= 1 and version <= 32767) {
            self.pattern_type = try types.decodeInt8(reader);
        }

        // Field: Principal
        if (version >= 0 and version <= 32767) {
            self.principal = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: Host
        if (version >= 0 and version <= 32767) {
            self.host = if (is_flexible)
                try types.decodeCompactString(reader, allocator) orelse ""
            else
                try types.decodeString(reader, allocator) orelse "";
        }

        // Field: Operation
        if (version >= 0 and version <= 32767) {
            self.operation = try types.decodeInt8(reader);
        }

        // Field: PermissionType
        if (version >= 0 and version <= 32767) {
            self.permission_type = try types.decodeInt8(reader);
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

/// DeleteAclsResponse
pub const DeleteAclsResponse = struct {
    const Self = @This();

    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    throttle_time_ms: i32 = 0,
    /// The results for each filter.
    filter_results: ?[]DeleteAclsFilterResult = null,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 1, .max = 3 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 31;
    }

    /// Create a default instance of DeleteAclsResponse
    pub fn default() Self {
        return .{
            .throttle_time_ms = 0,
            .filter_results = null,
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

    /// Sets `filter_results` to the passed value.
    /// The results for each filter.
    pub fn withFilterResults(self: Self, value: ?[]DeleteAclsFilterResult) Self {
        var result = self;
        result.filter_results = value;
        return result;
    }

    /// Encode DeleteAclsResponse
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

        // Field: FilterResults
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactArrayLenNonNull(writer, self.filter_results);
                if (self.filter_results) |arr| {
                    for (arr) |*item| {
                        try DeleteAclsFilterResult.encode(item, writer, version);
                    }
                }
            } else {
                try types.encodeArrayLenNonNull(writer, self.filter_results);
                if (self.filter_results) |arr| {
                    for (arr) |*item| {
                        try DeleteAclsFilterResult.encode(item, writer, version);
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

    /// Compute the size of DeleteAclsResponse for the given version
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

        // Field: FilterResults
        if (version >= 0 and version <= 32767) {
            if (self.filter_results) |arr| {
                const len: u32 = @intCast(arr.len + 1);
                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                for (arr) |*item| {
                    total_size += try DeleteAclsFilterResult.computeSize(item, version);
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

    /// Decode DeleteAclsResponse
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

        // Field: FilterResults
        if (version >= 0 and version <= 32767) {
            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
            const array = try allocator.alloc(DeleteAclsFilterResult, array_len);
            for (array) |*item| {
                item.* = try DeleteAclsFilterResult.decode(reader, version, allocator);
            }
            self.filter_results = array;
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
