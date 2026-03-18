//! Auto-generated Kafka protocol message
//! Message: EnvelopeRequest
//! API Key: 58
//! Type: request
//! Valid Versions: 0
//! Flexible Versions: 0+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// EnvelopeRequest
pub const EnvelopeRequest = struct {
    const Self = @This();

    /// The embedded request header and data.
    request_data: []const u8 = &[_]u8{},
    /// Value of the initial client principal when the request is redirected by a broker.
    request_principal: ?[]const u8 = null,
    /// The original client's address in bytes.
    client_host_address: []const u8 = &[_]u8{},

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 0, .max = 0 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 58;
    }

    /// Create a default instance of EnvelopeRequest
    pub fn default() Self {
        return .{
            .request_data = &[_]u8{},
            .request_principal = null,
            .client_host_address = &[_]u8{},
            ._tagged_fields = null,
        };
    }

    /// Sets `request_data` to the passed value.
    /// The embedded request header and data.
    pub fn withRequestData(self: Self, value: []const u8) Self {
        var result = self;
        result.request_data = value;
        return result;
    }

    /// Sets `request_principal` to the passed value.
    /// Value of the initial client principal when the request is redirected by a broker.
    pub fn withRequestPrincipal(self: Self, value: ?[]const u8) Self {
        var result = self;
        result.request_principal = value;
        return result;
    }

    /// Sets `client_host_address` to the passed value.
    /// The original client's address in bytes.
    pub fn withClientHostAddress(self: Self, value: []const u8) Self {
        var result = self;
        result.client_host_address = value;
        return result;
    }

    /// Encode EnvelopeRequest
    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: RequestData
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactBytes(writer, self.request_data);
            } else {
                try types.encodeBytes(writer, self.request_data);
            }
        }

        // Field: RequestPrincipal
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactBytes(writer, self.request_principal);
            } else {
                try types.encodeBytes(writer, self.request_principal);
            }
        }

        // Field: ClientHostAddress
        if (version >= 0 and version <= 32767) {
            if (is_flexible) {
                try types.encodeCompactBytes(writer, self.client_host_address);
            } else {
                try types.encodeBytes(writer, self.client_host_address);
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

    /// Compute the size of EnvelopeRequest for the given version
    pub fn computeSize(self: *const Self, version: i16) !usize {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        var total_size: usize = 0;

        // Field: RequestData
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactBytes(self.request_data) else types.computeSizeBytes(self.request_data);
        }

        // Field: RequestPrincipal
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactBytes(self.request_principal) else types.computeSizeBytes(self.request_principal);
        }

        // Field: ClientHostAddress
        if (version >= 0 and version <= 32767) {
            total_size += if (is_flexible) types.computeSizeCompactBytes(self.client_host_address) else types.computeSizeBytes(self.client_host_address);
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

    /// Decode EnvelopeRequest
    pub fn decode(reader: anytype, version: i16, allocator: std.mem.Allocator) !Self {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        var self: Self = .{};

        // Field: RequestData
        if (version >= 0 and version <= 32767) {
            self.request_data = if (is_flexible)
                try types.decodeCompactBytes(reader, allocator) orelse ""
            else
                try types.decodeBytes(reader, allocator) orelse "";
        }

        // Field: RequestPrincipal
        if (version >= 0 and version <= 32767) {
            self.request_principal = if (is_flexible)
                try types.decodeCompactBytes(reader, allocator)
            else
                try types.decodeBytes(reader, allocator);
        }

        // Field: ClientHostAddress
        if (version >= 0 and version <= 32767) {
            self.client_host_address = if (is_flexible)
                try types.decodeCompactBytes(reader, allocator) orelse ""
            else
                try types.decodeBytes(reader, allocator) orelse "";
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
