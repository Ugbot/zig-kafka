const std = @import("std");
const types = @import("kafka_generated").types;
const RequestHeader = @import("kafka_generated").request_header.RequestHeader;

/// Encode a Kafka request frame into a pre-allocated buffer.
///
/// Wire format:
///   [4 bytes] message_size (big-endian i32, does NOT include these 4 bytes)
///   [N bytes] RequestHeader (v1 or v2 depending on flexible version)
///   [M bytes] Request body (encoded by generated type)
///
/// Returns the total number of bytes written (including the 4-byte size prefix).
pub fn encodeRequest(
    buffer: []u8,
    api_key: i16,
    api_version: i16,
    correlation_id: i32,
    client_id: ?[]const u8,
    body: anytype,
) !usize {
    // Determine header version: v2 for flexible APIs, v1 for classic
    const header_version = requestHeaderVersion(api_key, api_version);

    // Build the header
    var header = RequestHeader{
        .request_api_key = api_key,
        .request_api_version = api_version,
        .correlation_id = correlation_id,
        .client_id = client_id,
    };

    // Compute sizes
    const header_size = try header.computeSize(header_version);
    const body_size = try body.computeSize(api_version);
    const message_size = header_size + body_size;
    const total_size = 4 + message_size; // 4-byte length prefix

    if (total_size > buffer.len) {
        return error.BufferExhausted;
    }

    // Write to buffer using a fixed buffer stream
    var stream = std.io.fixedBufferStream(buffer);
    const writer = stream.writer();

    // 4-byte message size prefix (big-endian)
    try types.encodeInt32(writer, @intCast(message_size));

    // Request header
    try header.encode(writer, header_version);

    // Request body
    try body.encode(writer, api_version);

    return total_size;
}

/// Determine the RequestHeader version for a given API key + version.
///
/// Per KIP-482: flexible versions use header v2 (with tagged fields),
/// classic versions use header v1.
/// Exception: ApiVersions (key 18) always uses header v2 per KIP-511,
/// even though the response header stays at v0.
pub fn requestHeaderVersion(api_key: i16, api_version: i16) i16 {
    // ApiVersions is special: always uses flexible request header v2 for v3+
    if (api_key == 18) {
        return if (api_version >= 3) 2 else 1;
    }

    // For all other APIs, check if this version is flexible
    const is_flexible = isFlexibleApiVersion(api_key, api_version);
    return if (is_flexible) 2 else 1;
}

/// Check if an API key + version combination uses flexible encoding.
/// This must match the per-message isFlexibleVersion() in generated types.
fn isFlexibleApiVersion(api_key: i16, api_version: i16) bool {
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
        18 => api_version >= 3, // ApiVersions
        19 => api_version >= 5, // CreateTopics
        20 => api_version >= 4, // DeleteTopics
        22 => api_version >= 4, // InitProducerId
        24 => api_version >= 4, // AddPartitionsToTxn
        25 => api_version >= 4, // AddOffsetsToTxn
        26 => api_version >= 4, // EndTxn
        28 => api_version >= 4, // TxnOffsetCommit
        32 => api_version >= 4, // DescribeConfigs
        33 => api_version >= 2, // AlterConfigs
        else => false,
    };
}

/// Response header version for a given API.
/// ApiVersions (key 18) always uses header v0 regardless of version.
pub fn responseHeaderVersion(api_key: i16, api_version: i16) i16 {
    if (api_key == 18) return 0;
    return if (isFlexibleApiVersion(api_key, api_version)) 1 else 0;
}

// ============================================================================
// Tests
// ============================================================================

test "requestHeaderVersion classic" {
    // Produce v3 is classic (flexible starts at v9)
    try std.testing.expectEqual(@as(i16, 1), requestHeaderVersion(0, 3));
    try std.testing.expectEqual(@as(i16, 1), requestHeaderVersion(0, 8));
}

test "requestHeaderVersion flexible" {
    // Produce v9+ is flexible
    try std.testing.expectEqual(@as(i16, 2), requestHeaderVersion(0, 9));
    try std.testing.expectEqual(@as(i16, 2), requestHeaderVersion(0, 13));
}

test "requestHeaderVersion ApiVersions special case" {
    // ApiVersions v0-v2 uses header v1
    try std.testing.expectEqual(@as(i16, 1), requestHeaderVersion(18, 0));
    try std.testing.expectEqual(@as(i16, 1), requestHeaderVersion(18, 2));
    // ApiVersions v3+ uses header v2
    try std.testing.expectEqual(@as(i16, 2), requestHeaderVersion(18, 3));
    try std.testing.expectEqual(@as(i16, 2), requestHeaderVersion(18, 4));
}

test "responseHeaderVersion ApiVersions always v0" {
    try std.testing.expectEqual(@as(i16, 0), responseHeaderVersion(18, 0));
    try std.testing.expectEqual(@as(i16, 0), responseHeaderVersion(18, 3));
    try std.testing.expectEqual(@as(i16, 0), responseHeaderVersion(18, 4));
}

test "responseHeaderVersion Produce" {
    // Produce v3 non-flexible → response header v0
    try std.testing.expectEqual(@as(i16, 0), responseHeaderVersion(0, 3));
    // Produce v9 flexible → response header v1
    try std.testing.expectEqual(@as(i16, 1), responseHeaderVersion(0, 9));
}

test "requestHeaderVersion all known APIs boundary" {
    // Verify flexible version boundaries for key APIs
    // Fetch: flexible at v12+
    try std.testing.expectEqual(@as(i16, 1), requestHeaderVersion(1, 11));
    try std.testing.expectEqual(@as(i16, 2), requestHeaderVersion(1, 12));

    // Metadata: flexible at v9+
    try std.testing.expectEqual(@as(i16, 1), requestHeaderVersion(3, 8));
    try std.testing.expectEqual(@as(i16, 2), requestHeaderVersion(3, 9));

    // FindCoordinator: flexible at v3+
    try std.testing.expectEqual(@as(i16, 1), requestHeaderVersion(10, 2));
    try std.testing.expectEqual(@as(i16, 2), requestHeaderVersion(10, 3));

    // CreateTopics: flexible at v5+
    try std.testing.expectEqual(@as(i16, 1), requestHeaderVersion(19, 4));
    try std.testing.expectEqual(@as(i16, 2), requestHeaderVersion(19, 5));
}

test "requestHeaderVersion unknown API" {
    // Unknown API key should default to classic header v1
    try std.testing.expectEqual(@as(i16, 1), requestHeaderVersion(999, 0));
    try std.testing.expectEqual(@as(i16, 1), requestHeaderVersion(255, 5));
}

test "responseHeaderVersion all flexible APIs" {
    // Fetch v12 flexible → v1
    try std.testing.expectEqual(@as(i16, 1), responseHeaderVersion(1, 12));
    // Metadata v9 flexible → v1
    try std.testing.expectEqual(@as(i16, 1), responseHeaderVersion(3, 9));
    // OffsetCommit v8 flexible → v1
    try std.testing.expectEqual(@as(i16, 1), responseHeaderVersion(8, 8));
}

test "encodeRequest buffer too small" {
    var small_buf: [4]u8 = undefined;
    const ApiVersionsRequest = @import("kafka_generated").api_versions_request.ApiVersionsRequest;
    var req = ApiVersionsRequest{};
    const result = encodeRequest(&small_buf, 18, 3, 1, "client", &req);
    try std.testing.expectError(error.BufferExhausted, result);
}

test "encodeRequest produces valid frame" {
    var buf: [1024]u8 = undefined;
    const ApiVersionsRequest = @import("kafka_generated").api_versions_request.ApiVersionsRequest;
    var req = ApiVersionsRequest{
        .client_software_name = "test",
        .client_software_version = "1.0",
    };

    const size = try encodeRequest(&buf, 18, 3, 42, "test-client", &req);
    try std.testing.expect(size > 4);

    // Verify 4-byte size prefix
    const msg_size = std.mem.readInt(i32, buf[0..4], .big);
    try std.testing.expectEqual(@as(usize, @intCast(msg_size)), size - 4);

    // Verify API key in header (bytes 4-5)
    const api_key = std.mem.readInt(i16, buf[4..6], .big);
    try std.testing.expectEqual(@as(i16, 18), api_key);

    // Verify API version (bytes 6-7)
    const api_ver = std.mem.readInt(i16, buf[6..8], .big);
    try std.testing.expectEqual(@as(i16, 3), api_ver);

    // Verify correlation ID (bytes 8-11)
    const corr_id = std.mem.readInt(i32, buf[8..12], .big);
    try std.testing.expectEqual(@as(i32, 42), corr_id);
}
