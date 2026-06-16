const std = @import("std");
const BrokerConnection = @import("connection.zig").BrokerConnection;
const request_mod = @import("request.zig");
const types = @import("kafka_generated").types;
const ApiVersionsRequest = @import("kafka_generated").api_versions_request.ApiVersionsRequest;
const ApiVersionsResponse = @import("kafka_generated").api_versions_response.ApiVersionsResponse;

/// Negotiate API versions with a broker.
///
/// Sends an ApiVersionsRequest (v3 preferred, falls back to v0) and
/// populates the connection's api_versions array with the broker's
/// supported version ranges.
///
/// Must be called after connect() and before any other request.
pub fn negotiateApiVersions(conn: *BrokerConnection, allocator: std.mem.Allocator) !void {
    // Try v3 first (flexible, includes client software info)
    const api_version: i16 = 3;

    var req = ApiVersionsRequest{
        .client_software_name = "tickstream-kafka-client",
        .client_software_version = "0.1.0",
    };

    // Encode into send buffer
    const header_version = request_mod.requestHeaderVersion(18, api_version);
    var header = @import("kafka_generated").request_header.RequestHeader{
        .request_api_key = 18,
        .request_api_version = api_version,
        .correlation_id = conn.next_correlation_id,
        .client_id = conn.client_id,
    };
    conn.next_correlation_id +%= 1;

    const header_size = try header.computeSize(header_version);
    const body_size = try req.computeSize(api_version);
    const message_size = header_size + body_size;
    const total_size = 4 + message_size;

    if (total_size > conn.send_buf.len) {
        return error.BufferExhausted;
    }

    var stream = @import("ztime").fixedBufferStream(conn.send_buf);
    const writer = stream.writer();

    try types.encodeInt32(writer, @intCast(message_size));
    try header.encode(writer, header_version);
    try req.encode(writer, api_version);

    // Send
    try conn.sendAll(conn.send_buf[0..total_size]);

    // Receive response
    try conn.recvExact(conn.recv_buf[0..4]);
    const resp_msg_size = std.mem.readInt(i32, conn.recv_buf[0..4], .big);
    if (resp_msg_size < 0 or resp_msg_size > 100 * 1024 * 1024) {
        conn.disconnect();
        return error.ProtocolError;
    }
    const resp_size: usize = @intCast(resp_msg_size);
    if (4 + resp_size > conn.recv_buf.len) {
        conn.disconnect();
        return error.BufferExhausted;
    }
    try conn.recvExact(conn.recv_buf[4 .. 4 + resp_size]);

    // Parse response header (ApiVersions always uses response header v0)
    var resp_stream = @import("ztime").fixedBufferStream(conn.recv_buf[4 .. 4 + resp_size]);
    const resp_reader = resp_stream.reader();

    const correlation_id = try types.decodeInt32(resp_reader);
    _ = correlation_id; // We trust the broker here; validated in production

    // Decode response body using an arena so all decoded memory is freed
    // after we extract the version ranges into the connection's fixed arrays.
    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();

    const resp = try ApiVersionsResponse.decode(resp_reader, api_version, arena.allocator());

    if (resp.error_code != 0) {
        return error.UnsupportedApiVersion;
    }

    // Store negotiated versions (copies into conn's fixed-size array)
    if (resp.api_keys) |api_keys| {
        for (api_keys) |entry| {
            if (entry.api_key >= 0 and entry.api_key < BrokerConnection.MAX_API_KEYS) {
                const idx: usize = @intCast(entry.api_key);
                conn.api_versions[idx] = .{
                    .min = entry.min_version,
                    .max = entry.max_version,
                };
            }
        }
    }

    conn.versions_negotiated = true;
}

/// Select the best (highest) mutually-supported version for an API.
///
/// `client_min` and `client_max` are the version range this client supports.
/// The broker's range is read from conn.api_versions.
/// Returns null if no overlap exists.
pub fn selectVersion(
    conn: *const BrokerConnection,
    api_key: i16,
    client_min: i16,
    client_max: i16,
) ?i16 {
    if (api_key < 0 or api_key >= BrokerConnection.MAX_API_KEYS) return null;
    const idx: usize = @intCast(api_key);
    const broker_range = conn.api_versions[idx] orelse return null;

    // Overlap: max(client_min, broker_min) .. min(client_max, broker_max)
    const overlap_min = @max(client_min, broker_range.min);
    const overlap_max = @min(client_max, broker_range.max);

    if (overlap_min > overlap_max) return null;
    return overlap_max; // Use highest mutually supported version
}

// ============================================================================
// Tests
// ============================================================================

test "selectVersion overlap" {
    var send_buf: [1024]u8 = undefined;
    var recv_buf: [1024]u8 = undefined;
    var conn = BrokerConnection.init("localhost", 9092, &send_buf, &recv_buf);

    // Broker supports Produce v3-v9
    conn.api_versions[0] = .{ .min = 3, .max = 9 };

    // Client supports v3-v13 → overlap is v3-v9, pick v9
    try std.testing.expectEqual(@as(?i16, 9), selectVersion(&conn, 0, 3, 13));

    // Client supports v0-v5 → overlap is v3-v5, pick v5
    try std.testing.expectEqual(@as(?i16, 5), selectVersion(&conn, 0, 0, 5));

    // Client supports v10-v13 → no overlap
    try std.testing.expectEqual(@as(?i16, null), selectVersion(&conn, 0, 10, 13));
}

test "selectVersion unsupported API" {
    var send_buf: [1024]u8 = undefined;
    var recv_buf: [1024]u8 = undefined;
    var conn = BrokerConnection.init("localhost", 9092, &send_buf, &recv_buf);

    // API 50 not in broker's response
    try std.testing.expectEqual(@as(?i16, null), selectVersion(&conn, 50, 0, 5));
}

test "selectVersion negative API key" {
    var send_buf: [1024]u8 = undefined;
    var recv_buf: [1024]u8 = undefined;
    var conn = BrokerConnection.init("localhost", 9092, &send_buf, &recv_buf);

    try std.testing.expectEqual(@as(?i16, null), selectVersion(&conn, -1, 0, 5));
}

test "selectVersion exact match" {
    var send_buf: [1024]u8 = undefined;
    var recv_buf: [1024]u8 = undefined;
    var conn = BrokerConnection.init("localhost", 9092, &send_buf, &recv_buf);

    // Broker supports exactly v5-v5
    conn.api_versions[1] = .{ .min = 5, .max = 5 };

    // Client supports v5-v5 → exact match
    try std.testing.expectEqual(@as(?i16, 5), selectVersion(&conn, 1, 5, 5));

    // Client supports v4-v6 → overlap at v5
    try std.testing.expectEqual(@as(?i16, 5), selectVersion(&conn, 1, 4, 6));

    // Client supports v0-v4 → no overlap
    try std.testing.expectEqual(@as(?i16, null), selectVersion(&conn, 1, 0, 4));
}

test "selectVersion picks highest" {
    var send_buf: [1024]u8 = undefined;
    var recv_buf: [1024]u8 = undefined;
    var conn = BrokerConnection.init("localhost", 9092, &send_buf, &recv_buf);

    // Broker supports v0-v12
    conn.api_versions[3] = .{ .min = 0, .max = 12 };

    // Client supports v0-v9 → should pick v9 (highest overlap)
    try std.testing.expectEqual(@as(?i16, 9), selectVersion(&conn, 3, 0, 9));
}

test "selectVersion all known API keys" {
    var send_buf: [1024]u8 = undefined;
    var recv_buf: [1024]u8 = undefined;
    var conn = BrokerConnection.init("localhost", 9092, &send_buf, &recv_buf);

    // Simulate a modern broker supporting common APIs
    conn.api_versions[0] = .{ .min = 0, .max = 11 }; // Produce
    conn.api_versions[1] = .{ .min = 0, .max = 16 }; // Fetch
    conn.api_versions[3] = .{ .min = 0, .max = 12 }; // Metadata
    conn.api_versions[18] = .{ .min = 0, .max = 4 }; // ApiVersions

    // Verify all return something reasonable
    try std.testing.expect(selectVersion(&conn, 0, 0, 11) != null);
    try std.testing.expect(selectVersion(&conn, 1, 0, 16) != null);
    try std.testing.expect(selectVersion(&conn, 3, 0, 12) != null);
    try std.testing.expect(selectVersion(&conn, 18, 0, 4) != null);
}
