// Kafka wire protocol frame handling
// Response framing: size prefix + ResponseHeader + body + size backpatch
// Request parsing: size prefix + RequestHeader fields
//
// New handlers use writeResponseFrameHeader/finishResponseFrame with generated types.
// Legacy Frame/Body/Header types kept for backward compatibility during migration.

const std = @import("std");
const kafka_gen = @import("kafka_generated");
const types = kafka_gen.types;
const GeneratedResponseHeader = kafka_gen.response_header.ResponseHeader;

// ============================================================================
// Response Framing (used by handlers with generated types)
// ============================================================================

/// Determine the response header version for a given API.
/// Returns 0 (non-flexible: correlation_id only) or 1 (flexible: correlation_id + tagged fields).
///
/// ApiVersions (key 18) always returns 0 per KIP-511 — the response must be
/// parseable by any client regardless of flexible encoding support.
///
/// The `is_flexible` parameter should come from the generated type's isFlexibleVersion().
pub fn responseHeaderVersion(api_key: i16, is_flexible: bool) i16 {
    if (api_key == 18) return 0;
    return if (is_flexible) @as(i16, 1) else 0;
}

/// Write a response frame header: 4-byte size placeholder + ResponseHeader.
/// The caller then encodes the response body using the same writer, then calls
/// finishResponseFrame() to backpatch the size prefix.
///
/// response_header_version: 0 or 1 (from responseHeaderVersion())
pub fn writeResponseFrameHeader(writer: anytype, correlation_id: i32, response_header_ver: i16) !void {
    // 4-byte size placeholder (backpatched by finishResponseFrame)
    try writer.writeInt(i32, 0, .big);

    // Encode response header using generated type
    var hdr = GeneratedResponseHeader.default().withCorrelationId(correlation_id);
    try hdr.encode(writer, response_header_ver);
}

/// Backpatch the 4-byte size prefix and return the complete response frame.
/// `written` is the total bytes written to the buffer (including the 4-byte prefix).
pub fn finishResponseFrame(buffer: []u8, written: usize) []const u8 {
    const message_size: i32 = @intCast(written - 4);
    std.mem.writeInt(i32, buffer[0..4], message_size, .big);
    return buffer[0..written];
}

// ============================================================================
// Legacy types (used by fetch.zig during migration — remove in Phase 4)
// ============================================================================

/// Kafka wire protocol frame containing size, header, and body
pub const Frame = struct {
    size: i32,
    header: Header,
    body: Body,

    /// Decode complete request from wire bytes (including 4-byte size prefix)
    pub fn requestFromBytes(data: []const u8, allocator: std.mem.Allocator) !Frame {
        var stream = std.io.fixedBufferStream(data);
        const reader = stream.reader();

        const size = try types.decodeInt32(reader);
        const header = try Header.decodeRequest(reader, allocator);
        const body = try Body.decodeRequest(
            reader,
            header.request.api_key,
            header.request.api_version,
            allocator,
        );

        return Frame{
            .size = size,
            .header = header,
            .body = body,
        };
    }

    /// Encode complete response to wire bytes (including 4-byte size prefix)
    pub fn response(
        header: Header,
        body: Body,
        api_key: i16,
        api_version: i16,
        allocator: std.mem.Allocator,
    ) ![]const u8 {
        _ = api_key;
        var buffer = std.array_list.Managed(u8).init(allocator);
        const writer = buffer.writer();

        try types.encodeInt32(writer, 0);
        try header.encodeResponse(writer, api_version);
        try body.encodeResponse(writer, api_version);

        const actual_size: i32 = @intCast(buffer.items.len - 4);
        std.mem.writeInt(i32, buffer.items[0..4], actual_size, .big);

        return buffer.toOwnedSlice();
    }

    pub fn deinit(self: *Frame, allocator: std.mem.Allocator) void {
        self.body.deinit(allocator);
        self.header.deinit(allocator);
    }
};

/// Request or Response header (legacy)
pub const Header = union(enum) {
    request: RequestHeader,
    response: ResponseHeader,

    pub const RequestHeader = struct {
        api_key: i16,
        api_version: i16,
        correlation_id: i32,
        client_id: ?[]const u8,
    };

    pub const ResponseHeader = struct {
        correlation_id: i32,
    };

    pub fn decodeRequest(reader: anytype, allocator: std.mem.Allocator) !Header {
        const api_key = try types.decodeInt16(reader);
        const api_version = try types.decodeInt16(reader);
        const correlation_id = try types.decodeInt32(reader);

        // Client ID: nullable string (i16 length, -1 for null)
        const client_id_len = try types.decodeInt16(reader);
        var client_id: ?[]const u8 = null;
        if (client_id_len >= 0) {
            const buf = try allocator.alloc(u8, @intCast(client_id_len));
            _ = try reader.readAll(buf);
            client_id = buf;
        }

        // Handle flexible header tagged fields if needed
        const is_flexible = isFlexibleHeader(api_key, api_version);
        if (is_flexible) {
            _ = try types.decodeUnsignedVarInt(reader);
        }

        return Header{
            .request = .{
                .api_key = api_key,
                .api_version = api_version,
                .correlation_id = correlation_id,
                .client_id = client_id,
            },
        };
    }

    pub fn encodeResponse(self: Header, writer: anytype, api_version: i16) !void {
        const res = self.response;
        try types.encodeInt32(writer, res.correlation_id);

        const is_flexible = api_version >= 12;
        if (is_flexible) {
            try types.encodeUnsignedVarInt(writer, 0);
        }
    }

    fn isFlexibleHeader(api_key: i16, api_version: i16) bool {
        return switch (api_key) {
            0 => api_version >= 9, // Produce
            1 => api_version >= 12, // Fetch
            2 => api_version >= 6, // ListOffsets
            3 => api_version >= 9, // Metadata
            8 => api_version >= 8, // OffsetCommit
            9 => api_version >= 6, // OffsetFetch
            10 => api_version >= 3, // FindCoordinator
            11 => api_version >= 6, // JoinGroup
            12 => api_version >= 4, // Heartbeat
            13 => api_version >= 4, // LeaveGroup
            14 => api_version >= 4, // SyncGroup
            18 => false, // ApiVersions: flexible body but classic header
            19 => api_version >= 5, // CreateTopics
            20 => api_version >= 4, // DeleteTopics
            else => false,
        };
    }

    pub fn deinit(self: *Header, allocator: std.mem.Allocator) void {
        switch (self.*) {
            .request => |req| {
                if (req.client_id) |client_id| {
                    allocator.free(client_id);
                }
            },
            .response => {},
        }
    }
};

/// Message body union (legacy — used by fetch.zig)
pub const Body = union(enum) {
    fetch_request: kafka_gen.fetch_request.FetchRequest,
    produce_request: kafka_gen.produce_request.ProduceRequest,
    metadata_request: @import("../generated/metadata_request.zig").MetadataRequest,
    api_versions_request: @import("../generated/api_versions_request.zig").ApiVersionsRequest,

    fetch_response: kafka_gen.fetch_response.FetchResponse,
    produce_response: @import("../generated/produce_response.zig").ProduceResponse,
    metadata_response: @import("../generated/metadata_response.zig").MetadataResponse,
    api_versions_response: @import("../generated/api_versions_response.zig").ApiVersionsResponse,

    pub fn decodeRequest(reader: anytype, api_key: i16, api_version: i16, allocator: std.mem.Allocator) !Body {
        return switch (api_key) {
            1 => .{ .fetch_request = try kafka_gen.fetch_request.FetchRequest.decode(reader, api_version, allocator) },
            0 => .{ .produce_request = try kafka_gen.produce_request.ProduceRequest.decode(reader, api_version, allocator) },
            3 => .{ .metadata_request = try @import("../generated/metadata_request.zig").MetadataRequest.decode(reader, api_version, allocator) },
            18 => .{ .api_versions_request = try @import("../generated/api_versions_request.zig").ApiVersionsRequest.decode(reader, api_version, allocator) },
            else => return error.UnknownApiKey,
        };
    }

    pub fn encodeResponse(self: Body, writer: anytype, api_version: i16) !void {
        switch (self) {
            .fetch_response => |*msg| try msg.encode(writer, api_version),
            .produce_response => |*msg| try msg.encode(writer, api_version),
            .metadata_response => |*msg| try msg.encode(writer, api_version),
            .api_versions_response => |*msg| try msg.encode(writer, api_version),
            else => return error.InvalidBodyForResponse,
        }
    }

    pub fn deinit(self: *Body, allocator: std.mem.Allocator) void {
        _ = self;
        _ = allocator;
    }
};
