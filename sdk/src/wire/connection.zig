const std = @import("std");
const posix = std.posix;
const types = @import("kafka_generated").types;
const request_mod = @import("request.zig");
const response_mod = @import("response.zig");
const ResponseHeader = @import("kafka_generated").response_header.ResponseHeader;

/// A blocking TCP connection to a single Kafka broker.
///
/// Each BrokerConnection owns pre-allocated send and receive buffers.
/// All I/O is synchronous (blocking POSIX sockets), intended to be
/// driven from a dedicated I/O thread per broker.
pub const BrokerConnection = struct {
    const Self = @This();

    /// Broker node ID from cluster metadata (-1 if not yet known).
    node_id: i32 = -1,

    /// Remote host (not owned; must outlive the connection).
    host: []const u8,

    /// Remote port.
    port: u16,

    /// Underlying socket file descriptor.
    socket: posix.socket_t = invalid_socket,

    /// Pre-allocated send buffer.
    send_buf: []u8,

    /// Pre-allocated receive buffer.
    recv_buf: []u8,

    /// Next correlation ID to assign.
    next_correlation_id: i32 = 1,

    /// Connection state.
    state: State = .disconnected,

    /// Client ID sent in request headers.
    client_id: []const u8 = "tickstream-zig-client",

    /// Connection timeout in milliseconds.
    connect_timeout_ms: u32 = 30_000,

    /// Request timeout in milliseconds.
    request_timeout_ms: u32 = 30_000,

    /// Negotiated API version ranges (indexed by API key, max 80 APIs).
    /// Values are {min, max} version pairs. null = not supported by broker.
    api_versions: [MAX_API_KEYS]?VersionRange = [_]?VersionRange{null} ** MAX_API_KEYS,

    /// Whether API version negotiation has completed.
    versions_negotiated: bool = false,

    pub const MAX_API_KEYS = 80;
    pub const VersionRange = struct { min: i16, max: i16 };
    pub const State = enum { disconnected, connecting, connected, closed };

    const invalid_socket: posix.socket_t = switch (@import("builtin").os.tag) {
        .windows => @as(posix.socket_t, @bitCast(@as(usize, ~@as(usize, 0)))),
        else => -1,
    };

    /// Initialize a BrokerConnection. Buffers must be pre-allocated by the caller.
    pub fn init(
        host: []const u8,
        port: u16,
        send_buf: []u8,
        recv_buf: []u8,
    ) Self {
        return .{
            .host = host,
            .port = port,
            .send_buf = send_buf,
            .recv_buf = recv_buf,
        };
    }

    /// Establish a TCP connection to the broker.
    pub fn connect(self: *Self) !void {
        if (self.state == .connected) return;
        if (self.state == .closed) return error.ClientClosed;

        self.state = .connecting;

        // Resolve address
        std.debug.print("[CONN] Resolving {s}:{d}\n", .{ self.host, self.port });
        const addr = try resolveAddress(self.host, self.port);

        // Create socket
        const sock = try posix.socket(
            addr.any.family,
            posix.SOCK.STREAM | posix.SOCK.CLOEXEC,
            posix.IPPROTO.TCP,
        );
        std.debug.print("[CONN] Created socket, attempting connect...\n", .{});

        // Set TCP_NODELAY for low latency
        setTcpNoDelay(sock) catch {};

        // Set send/recv timeouts
        setSocketTimeout(sock, posix.SO.RCVTIMEO, self.request_timeout_ms) catch {};
        setSocketTimeout(sock, posix.SO.SNDTIMEO, self.request_timeout_ms) catch {};

        // Connect (blocking)
        posix.connect(sock, &addr.any, addr.getOsSockLen()) catch |err| {
            std.debug.print("[CONN] Connect failed: {any}\n", .{err});
            posix.close(sock);
            self.state = .disconnected;
            return switch (err) {
                error.ConnectionRefused => error.ConnectionFailed,
                error.ConnectionTimedOut => error.ConnectionTimeout,
                else => error.ConnectionFailed,
            };
        };
        std.debug.print("[CONN] Successfully connected!\n", .{});

        self.socket = sock;
        self.state = .connected;
    }

    /// Close the connection and release the socket.
    pub fn close(self: *Self) void {
        if (self.socket != invalid_socket) {
            posix.close(self.socket);
            self.socket = invalid_socket;
        }
        self.state = .closed;
    }

    /// Disconnect without transitioning to .closed (allows reconnection).
    pub fn disconnect(self: *Self) void {
        if (self.socket != invalid_socket) {
            posix.close(self.socket);
            self.socket = invalid_socket;
        }
        self.state = .disconnected;
    }

    /// Send a request and receive the response synchronously.
    ///
    /// `body` must be a generated request type with encode() and computeSize().
    /// Returns the total bytes in recv_buf containing the response frame.
    pub fn sendRequest(self: *Self, api_key: i16, api_version: i16, body: anytype) !usize {
        if (self.state != .connected) return error.ConnectionFailed;

        const correlation_id = self.next_correlation_id;
        self.next_correlation_id +%= 1;

        // Encode request into send buffer
        const req_size = request_mod.encodeRequest(
            self.send_buf,
            api_key,
            api_version,
            correlation_id,
            self.client_id,
            body,
        ) catch |err| switch (err) {
            error.BufferExhausted => return error.BufferExhausted,
            else => return error.ProtocolError,
        };

        // Send all bytes
        try self.sendAll(self.send_buf[0..req_size]);

        // Receive response: first read 4-byte size prefix
        try self.recvExact(self.recv_buf[0..4]);

        const message_size = std.mem.readInt(i32, self.recv_buf[0..4], .big);
        if (message_size < 0 or message_size > 100 * 1024 * 1024) {
            self.disconnect();
            return error.ProtocolError;
        }

        const msg_size: usize = @intCast(message_size);
        const total = 4 + msg_size;
        if (total > self.recv_buf.len) {
            self.disconnect();
            return error.BufferExhausted;
        }

        // Read remaining bytes
        try self.recvExact(self.recv_buf[4..total]);

        // Validate correlation ID
        const resp_header_version = request_mod.responseHeaderVersion(api_key, api_version);
        var header_stream = std.io.fixedBufferStream(self.recv_buf[4..total]);
        const resp_header = ResponseHeader.decode(header_stream.reader(), resp_header_version, std.heap.page_allocator) catch {
            self.disconnect();
            return error.ProtocolError;
        };

        if (resp_header.correlation_id != correlation_id) {
            self.disconnect();
            return error.CorrelationMismatch;
        }

        return total;
    }

    /// Get the negotiated version for an API, or null if not supported.
    pub fn negotiatedVersion(self: *const Self, api_key: i16) ?i16 {
        if (api_key < 0 or api_key >= MAX_API_KEYS) return null;
        const idx: usize = @intCast(api_key);
        const range = self.api_versions[idx] orelse return null;
        return range.max; // Use the highest mutually supported version
    }

    // ========================================================================
    // Internal I/O helpers
    // ========================================================================

    pub fn sendAll(self: *Self, data: []const u8) !void {
        var sent: usize = 0;
        while (sent < data.len) {
            const n = posix.send(self.socket, data[sent..], 0) catch |err| {
                self.disconnect();
                return switch (err) {
                    error.ConnectionResetByPeer, error.BrokenPipe => error.ConnectionClosed,
                    else => error.ConnectionFailed,
                };
            };
            if (n == 0) {
                self.disconnect();
                return error.ConnectionClosed;
            }
            sent += n;
        }
    }

    pub fn recvExact(self: *Self, buf: []u8) !void {
        var received: usize = 0;
        while (received < buf.len) {
            const n = posix.recv(self.socket, buf[received..], 0) catch |err| {
                self.disconnect();
                return switch (err) {
                    error.ConnectionResetByPeer => error.ConnectionClosed,
                    error.WouldBlock => error.OperationTimeout,
                    else => error.ConnectionFailed,
                };
            };
            if (n == 0) {
                self.disconnect();
                return error.ConnectionClosed;
            }
            received += n;
        }
    }

    // ========================================================================
    // Socket setup helpers
    // ========================================================================

    fn resolveAddress(host: []const u8, port: u16) !std.net.Address {
        // Try parsing as IP first
        return std.net.Address.parseIp4(host, port) catch {
            std.debug.print("[RESOLVE] Not IPv4, trying IPv6...\n", .{});
            return std.net.Address.parseIp6(host, port) catch {
                std.debug.print("[RESOLVE] Not IPv6, trying DNS resolution for {s}...\n", .{host});
                // DNS resolution
                return std.net.Address.resolveIp(host, port) catch |err| {
                    std.debug.print("[RESOLVE] DNS resolution failed: {any}\n", .{err});
                    return error.DnsResolutionFailed;
                };
            };
        };
    }

    fn setTcpNoDelay(sock: posix.socket_t) !void {
        const one: [4]u8 = .{ 1, 0, 0, 0 };
        try posix.setsockopt(sock, posix.IPPROTO.TCP, 1, &one); // TCP_NODELAY = 1
    }

    fn setSocketTimeout(sock: posix.socket_t, option: u32, timeout_ms: u32) !void {
        const secs = timeout_ms / 1000;
        const usecs = (timeout_ms % 1000) * 1000;
        const tv = posix.timeval{
            .sec = @intCast(secs),
            .usec = @intCast(usecs),
        };
        try posix.setsockopt(sock, posix.SOL.SOCKET, option, std.mem.asBytes(&tv));
    }
};

// ============================================================================
// Tests
// ============================================================================

test "BrokerConnection init" {
    var send_buf: [1024]u8 = undefined;
    var recv_buf: [1024]u8 = undefined;

    const conn = BrokerConnection.init("localhost", 9092, &send_buf, &recv_buf);
    try std.testing.expectEqual(BrokerConnection.State.disconnected, conn.state);
    try std.testing.expectEqual(@as(i32, -1), conn.node_id);
    try std.testing.expectEqual(@as(i32, 1), conn.next_correlation_id);
    try std.testing.expectEqual(false, conn.versions_negotiated);
    try std.testing.expectEqualStrings("localhost", conn.host);
    try std.testing.expectEqual(@as(u16, 9092), conn.port);
}

test "BrokerConnection negotiatedVersion" {
    var send_buf: [1024]u8 = undefined;
    var recv_buf: [1024]u8 = undefined;

    var conn = BrokerConnection.init("localhost", 9092, &send_buf, &recv_buf);

    // No versions negotiated yet
    try std.testing.expectEqual(@as(?i16, null), conn.negotiatedVersion(0));
    try std.testing.expectEqual(@as(?i16, null), conn.negotiatedVersion(1));

    // Set some version ranges
    conn.api_versions[0] = .{ .min = 3, .max = 9 }; // Produce
    conn.api_versions[1] = .{ .min = 0, .max = 12 }; // Fetch
    conn.api_versions[18] = .{ .min = 0, .max = 4 }; // ApiVersions

    try std.testing.expectEqual(@as(?i16, 9), conn.negotiatedVersion(0));
    try std.testing.expectEqual(@as(?i16, 12), conn.negotiatedVersion(1));
    try std.testing.expectEqual(@as(?i16, 4), conn.negotiatedVersion(18));

    // Out of range
    try std.testing.expectEqual(@as(?i16, null), conn.negotiatedVersion(-1));
    try std.testing.expectEqual(@as(?i16, null), conn.negotiatedVersion(80));
}

test "BrokerConnection address resolution" {
    const addr = try BrokerConnection.resolveAddress("127.0.0.1", 9092);
    try std.testing.expectEqual(@as(u16, 9092), addr.getPort());
}

test "BrokerConnection address resolution IPv6" {
    const addr = try BrokerConnection.resolveAddress("::1", 9092);
    try std.testing.expectEqual(@as(u16, 9092), addr.getPort());
}

test "BrokerConnection sendRequest requires connected state" {
    var send_buf: [1024]u8 = undefined;
    var recv_buf: [1024]u8 = undefined;

    var conn = BrokerConnection.init("localhost", 9092, &send_buf, &recv_buf);
    // conn is disconnected

    const ApiVersionsRequest = @import("kafka_generated").api_versions_request.ApiVersionsRequest;
    var req = ApiVersionsRequest{};
    const result = conn.sendRequest(18, 3, &req);
    try std.testing.expectError(error.ConnectionFailed, result);
}

test "BrokerConnection close transitions state" {
    var send_buf: [1024]u8 = undefined;
    var recv_buf: [1024]u8 = undefined;

    var conn = BrokerConnection.init("localhost", 9092, &send_buf, &recv_buf);
    try std.testing.expect(conn.state == .disconnected);

    conn.close();
    try std.testing.expect(conn.state == .closed);
}

test "BrokerConnection disconnect allows reconnect" {
    var send_buf: [1024]u8 = undefined;
    var recv_buf: [1024]u8 = undefined;

    var conn = BrokerConnection.init("localhost", 9092, &send_buf, &recv_buf);
    conn.disconnect();
    try std.testing.expect(conn.state == .disconnected);
    // disconnected state allows reconnect attempts (unlike closed)
}

test "BrokerConnection correlation ID increments" {
    var send_buf: [1024]u8 = undefined;
    var recv_buf: [1024]u8 = undefined;

    var conn = BrokerConnection.init("localhost", 9092, &send_buf, &recv_buf);
    try std.testing.expectEqual(@as(i32, 1), conn.next_correlation_id);

    // Manually simulate correlation ID advancement
    conn.next_correlation_id +%= 1;
    try std.testing.expectEqual(@as(i32, 2), conn.next_correlation_id);
}

test "BrokerConnection connect to closed returns error" {
    var send_buf: [1024]u8 = undefined;
    var recv_buf: [1024]u8 = undefined;

    var conn = BrokerConnection.init("localhost", 9092, &send_buf, &recv_buf);
    conn.state = .closed;

    const result = conn.connect();
    try std.testing.expectError(error.ClientClosed, result);
}

test "BrokerConnection negotiatedVersion out of range" {
    var send_buf: [1024]u8 = undefined;
    var recv_buf: [1024]u8 = undefined;

    var conn = BrokerConnection.init("localhost", 9092, &send_buf, &recv_buf);

    // Negative and over-max API keys
    try std.testing.expectEqual(@as(?i16, null), conn.negotiatedVersion(-5));
    try std.testing.expectEqual(@as(?i16, null), conn.negotiatedVersion(100));
}

test "BrokerConnection configurable timeouts" {
    var send_buf: [1024]u8 = undefined;
    var recv_buf: [1024]u8 = undefined;

    var conn = BrokerConnection.init("localhost", 9092, &send_buf, &recv_buf);
    conn.connect_timeout_ms = 5000;
    conn.request_timeout_ms = 10000;
    conn.client_id = "my-custom-client";

    try std.testing.expectEqual(@as(u32, 5000), conn.connect_timeout_ms);
    try std.testing.expectEqual(@as(u32, 10000), conn.request_timeout_ms);
    try std.testing.expectEqualStrings("my-custom-client", conn.client_id);
}

test "BrokerConnection state machine: disconnected is initial state" {
    var send_buf: [1024]u8 = undefined;
    var recv_buf: [1024]u8 = undefined;
    const conn = BrokerConnection.init("localhost", 9092, &send_buf, &recv_buf);
    try std.testing.expect(conn.state == .disconnected);
}

test "BrokerConnection state machine: close from disconnected" {
    var send_buf: [1024]u8 = undefined;
    var recv_buf: [1024]u8 = undefined;
    var conn = BrokerConnection.init("localhost", 9092, &send_buf, &recv_buf);

    // Close from disconnected should work and set state to closed
    conn.close();
    try std.testing.expect(conn.state == .closed);

    // Close again should be a no-op (socket is already invalid)
    conn.close();
    try std.testing.expect(conn.state == .closed);
}

test "BrokerConnection state machine: disconnect from disconnected" {
    var send_buf: [1024]u8 = undefined;
    var recv_buf: [1024]u8 = undefined;
    var conn = BrokerConnection.init("localhost", 9092, &send_buf, &recv_buf);

    // Disconnect from disconnected is fine (stays disconnected)
    conn.disconnect();
    try std.testing.expect(conn.state == .disconnected);
}

test "BrokerConnection state machine: connect already connected is no-op" {
    var send_buf: [1024]u8 = undefined;
    var recv_buf: [1024]u8 = undefined;
    var conn = BrokerConnection.init("localhost", 9092, &send_buf, &recv_buf);

    // Manually set to connected to test the early return
    conn.state = .connected;
    try conn.connect(); // Should return immediately
    try std.testing.expect(conn.state == .connected);
}

test "BrokerConnection api_versions default null" {
    var send_buf: [1024]u8 = undefined;
    var recv_buf: [1024]u8 = undefined;
    const conn = BrokerConnection.init("localhost", 9092, &send_buf, &recv_buf);

    // All versions should be null initially
    for (conn.api_versions) |v| {
        try std.testing.expectEqual(@as(?BrokerConnection.VersionRange, null), v);
    }
}

test "BrokerConnection MAX_API_KEYS boundary" {
    var send_buf: [1024]u8 = undefined;
    var recv_buf: [1024]u8 = undefined;
    var conn = BrokerConnection.init("localhost", 9092, &send_buf, &recv_buf);

    // Set first and last
    conn.api_versions[0] = .{ .min = 0, .max = 10 };
    conn.api_versions[BrokerConnection.MAX_API_KEYS - 1] = .{ .min = 0, .max = 5 };

    try std.testing.expectEqual(@as(?i16, 10), conn.negotiatedVersion(0));
    try std.testing.expectEqual(@as(?i16, 5), conn.negotiatedVersion(@as(i16, BrokerConnection.MAX_API_KEYS - 1)));
    try std.testing.expectEqual(@as(?i16, null), conn.negotiatedVersion(@as(i16, BrokerConnection.MAX_API_KEYS)));
}

test "BrokerConnection correlation ID wraps on overflow" {
    var send_buf: [1024]u8 = undefined;
    var recv_buf: [1024]u8 = undefined;
    var conn = BrokerConnection.init("localhost", 9092, &send_buf, &recv_buf);

    conn.next_correlation_id = std.math.maxInt(i32);
    conn.next_correlation_id +%= 1;
    try std.testing.expectEqual(std.math.minInt(i32), conn.next_correlation_id);
}

test "BrokerConnection address resolution various formats" {
    // Loopback IPv4
    const addr1 = try BrokerConnection.resolveAddress("127.0.0.1", 9092);
    try std.testing.expectEqual(@as(u16, 9092), addr1.getPort());

    // Different port
    const addr2 = try BrokerConnection.resolveAddress("127.0.0.1", 19092);
    try std.testing.expectEqual(@as(u16, 19092), addr2.getPort());

    // IPv6 loopback
    const addr3 = try BrokerConnection.resolveAddress("::1", 9092);
    try std.testing.expectEqual(@as(u16, 9092), addr3.getPort());
}

test "BrokerConnection sendRequest from closed state" {
    var send_buf: [1024]u8 = undefined;
    var recv_buf: [1024]u8 = undefined;
    var conn = BrokerConnection.init("localhost", 9092, &send_buf, &recv_buf);
    conn.state = .closed;

    const ApiVersionsRequest = @import("kafka_generated").api_versions_request.ApiVersionsRequest;
    var req = ApiVersionsRequest{};
    const result = conn.sendRequest(18, 3, &req);
    try std.testing.expectError(error.ConnectionFailed, result);
}

test "BrokerConnection sendRequest from connecting state" {
    var send_buf: [1024]u8 = undefined;
    var recv_buf: [1024]u8 = undefined;
    var conn = BrokerConnection.init("localhost", 9092, &send_buf, &recv_buf);
    conn.state = .connecting;

    const ApiVersionsRequest = @import("kafka_generated").api_versions_request.ApiVersionsRequest;
    var req = ApiVersionsRequest{};
    const result = conn.sendRequest(18, 3, &req);
    try std.testing.expectError(error.ConnectionFailed, result);
}

test "BrokerConnection buffer sizes preserved" {
    var send_buf: [2048]u8 = undefined;
    var recv_buf: [4096]u8 = undefined;
    const conn = BrokerConnection.init("broker", 9093, &send_buf, &recv_buf);

    try std.testing.expectEqual(@as(usize, 2048), conn.send_buf.len);
    try std.testing.expectEqual(@as(usize, 4096), conn.recv_buf.len);
}
