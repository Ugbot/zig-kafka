//! Auto-generated Kafka protocol message
//! Message: DescribeClusterRequest
//! API Key: 60
//! Type: request
//! Valid Versions: 0-2
//! Flexible Versions: 0+
//!
//! DO NOT EDIT - Generated from protocol JSON

const std = @import("std");
const types = @import("../protocol/types.zig");

/// DescribeClusterRequest
pub const DescribeClusterRequest = struct {
    const Self = @This();

    /// Whether to include cluster authorized operations.
    include_cluster_authorized_operations: bool = false,
    /// The endpoint type to describe. 1=brokers, 2=controllers.
    /// Versions: 1+
    endpoint_type: i8 = 1,
    /// Whether to include fenced brokers when listing brokers.
    /// Versions: 2+
    include_fenced_brokers: bool = false,

    /// Tagged fields for forward compatibility
    _tagged_fields: ?[]types.TaggedField = null,

    // ============================================================================
    // METHODS
    // ============================================================================

    /// Version range for this message
    pub const VERSIONS = types.VersionRange{ .min = 0, .max = 2 };

    /// API Key for this message
    pub fn apiKey() i16 {
        return 60;
    }

    /// Create a default instance of DescribeClusterRequest
    pub fn default() Self {
        return .{
            .include_cluster_authorized_operations = false,
            .endpoint_type = 1,
            .include_fenced_brokers = false,
            ._tagged_fields = null,
        };
    }

    /// Sets `include_cluster_authorized_operations` to the passed value.
    /// Whether to include cluster authorized operations.
    pub fn withIncludeClusterAuthorizedOperations(self: Self, value: bool) Self {
        var result = self;
        result.include_cluster_authorized_operations = value;
        return result;
    }

    /// Sets `endpoint_type` to the passed value.
    /// The endpoint type to describe. 1=brokers, 2=controllers.
    /// Versions: 1+
    pub fn withEndpointType(self: Self, value: i8) Self {
        var result = self;
        result.endpoint_type = value;
        return result;
    }

    /// Sets `include_fenced_brokers` to the passed value.
    /// Whether to include fenced brokers when listing brokers.
    /// Versions: 2+
    pub fn withIncludeFencedBrokers(self: Self, value: bool) Self {
        var result = self;
        result.include_fenced_brokers = value;
        return result;
    }

    /// Encode DescribeClusterRequest
    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        // Field: IncludeClusterAuthorizedOperations
        if (version >= 0 and version <= 32767) {
            try types.encodeBoolean(writer, self.include_cluster_authorized_operations);
        }

        // Field: EndpointType
        if (version >= 1 and version <= 32767) {
            try types.encodeInt8(writer, self.endpoint_type);
        }

        // Field: IncludeFencedBrokers
        if (version >= 2 and version <= 32767) {
            try types.encodeBoolean(writer, self.include_fenced_brokers);
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

    /// Compute the size of DescribeClusterRequest for the given version
    pub fn computeSize(self: *const Self, version: i16) !usize {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        _ = &is_flexible;

        var total_size: usize = 0;

        // Field: IncludeClusterAuthorizedOperations
        if (version >= 0 and version <= 32767) {
            total_size += types.computeSizeBoolean(self.include_cluster_authorized_operations);
        }

        // Field: EndpointType
        if (version >= 1 and version <= 32767) {
            total_size += types.computeSizeInt8(self.endpoint_type);
        }

        // Field: IncludeFencedBrokers
        if (version >= 2 and version <= 32767) {
            total_size += types.computeSizeBoolean(self.include_fenced_brokers);
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

    /// Decode DescribeClusterRequest
    pub fn decode(reader: anytype, version: i16, allocator: std.mem.Allocator) !Self {
        if (!isValidVersion(version)) {
            return types.Error.UnsupportedVersion;
        }
        const is_flexible = isFlexibleVersion(version);
        var self: Self = .{};

        // Field: IncludeClusterAuthorizedOperations
        if (version >= 0 and version <= 32767) {
            self.include_cluster_authorized_operations = try types.decodeBoolean(reader);
        }

        // Field: EndpointType
        if (version >= 1 and version <= 32767) {
            self.endpoint_type = try types.decodeInt8(reader);
        }

        // Field: IncludeFencedBrokers
        if (version >= 2 and version <= 32767) {
            self.include_fenced_brokers = try types.decodeBoolean(reader);
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
        const range = types.VersionRange.parse("0-2") catch return false;
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
