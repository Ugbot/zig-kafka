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

        // 0.16 port: `std.net` (Address, tcpConnectToAddress) is absent from
        // this stripped std, so resolve + connect via `std.c.getaddrinfo` and
        // a raw blocking socket. Address resolution and connection are fused
        // (getaddrinfo hands us connect-ready sockaddrs directly); we still
        // apply the existing TCP_NODELAY + timeout setsockopt logic and keep
        // the fd, matching the original connect() contract.
        std.debug.print("[CONN] Resolving {s}:{d}\n", .{ self.host, self.port });
        const sock = self.dialBlocking() catch |err| {
            self.state = .disconnected;
            return err;
        };
        std.debug.print("[CONN] Successfully connected!\n", .{});

        self.socket = sock;
        self.state = .connected;
    }

    /// Resolve `self.host`:`self.port` and open a blocking TCP socket, trying
    /// each address getaddrinfo returns until one connects. Applies
    /// TCP_NODELAY and SO_RCVTIMEO/SNDTIMEO to the chosen fd.
    fn dialBlocking(self: *Self) !posix.socket_t {
        // NUL-terminate host (getaddrinfo wants a C string).
        var host_z: [256]u8 = undefined;
        if (self.host.len >= host_z.len) return error.ConnectionFailed;
        @memcpy(host_z[0..self.host.len], self.host);
        host_z[self.host.len] = 0;

        var port_buf: [8]u8 = undefined;
        const port_str = std.fmt.bufPrint(&port_buf, "{d}", .{self.port}) catch return error.ConnectionFailed;
        port_buf[port_str.len] = 0;

        var hints: std.c.addrinfo = std.mem.zeroes(std.c.addrinfo);
        hints.family = std.c.AF.UNSPEC;
        hints.socktype = std.c.SOCK.STREAM;

        const host_ptr: [*:0]const u8 = @ptrCast(&host_z);
        const port_ptr: [*:0]const u8 = @ptrCast(&port_buf);
        var res: ?*std.c.addrinfo = null;
        const rc = std.c.getaddrinfo(host_ptr, port_ptr, &hints, &res);
        if (@intFromEnum(rc) != 0) {
            std.debug.print("[RESOLVE] getaddrinfo failed: {d}\n", .{@intFromEnum(rc)});
            return error.DnsResolutionFailed;
        }
        const head = res orelse return error.DnsResolutionFailed;
        defer std.c.freeaddrinfo(head);

        var ai: ?*std.c.addrinfo = head;
        while (ai) |a| : (ai = a.next) {
            const addr = a.addr orelse continue;
            const sock = std.c.socket(@intCast(a.family), @intCast(a.socktype), @intCast(a.protocol));
            if (sock < 0) continue;

            // Low latency + bounded blocking I/O.
            setTcpNoDelay(sock) catch {};
            setSocketTimeout(sock, posix.SO.RCVTIMEO, self.request_timeout_ms) catch {};
            setSocketTimeout(sock, posix.SO.SNDTIMEO, self.request_timeout_ms) catch {};

            if (std.c.connect(sock, addr, a.addrlen) == 0) return sock;
            std.debug.print("[CONN] Connect attempt failed, trying next addr\n", .{});
            _ = std.c.close(sock);
        }
        return error.ConnectionFailed;
    }

    /// Close the connection and release the socket.
    pub fn close(self: *Self) void {
        if (self.socket != invalid_socket) {
            _ = std.c.close(self.socket);
            self.socket = invalid_socket;
        }
        self.state = .closed;
    }

    /// Disconnect without transitioning to .closed (allows reconnection).
    pub fn disconnect(self: *Self) void {
        if (self.socket != invalid_socket) {
            _ = std.c.close(self.socket);
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
        var header_stream = @import("ztime").fixedBufferStream(self.recv_buf[4..total]);
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

    // 0.16 port: `std.posix.send`/`std.posix.recv` are absent here, so go
    // through the libc syscalls directly (`std.c.send`/`std.c.recv`). These
    // return `isize` with -1 + errno on failure (rather than a Zig error
    // union), so we map errno to the same connection errors the original code
    // produced.
    pub fn sendAll(self: *Self, data: []const u8) !void {
        var sent: usize = 0;
        while (sent < data.len) {
            const chunk = data[sent..];
            const rc = std.c.send(self.socket, chunk.ptr, chunk.len, 0);
            if (rc < 0) {
                const e = std.c.errno(rc);
                self.disconnect();
                return switch (e) {
                    .CONNRESET, .PIPE => error.ConnectionClosed,
                    else => error.ConnectionFailed,
                };
            }
            const n: usize = @intCast(rc);
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
            const dst = buf[received..];
            const rc = std.c.recv(self.socket, dst.ptr, dst.len, 0);
            if (rc < 0) {
                const e = std.c.errno(rc);
                self.disconnect();
                return switch (e) {
                    .CONNRESET => error.ConnectionClosed,
                    // EAGAIN == EWOULDBLOCK on this target; a blocking socket
                    // returns it when SO_RCVTIMEO fires.
                    .AGAIN => error.OperationTimeout,
                    else => error.ConnectionFailed,
                };
            }
            const n: usize = @intCast(rc);
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

    /// Minimal resolved-address handle. `std.net.Address` is absent from this
    /// stripped 0.16 std, so resolution returns just the bits the rest of the
    /// SDK needs: the requested port (the live connect path in `dialBlocking`
    /// uses getaddrinfo's sockaddrs directly and never materializes this).
    pub const ResolvedAddress = struct {
        port: u16,
        family: i32,

        pub fn getPort(self: ResolvedAddress) u16 {
            return self.port;
        }
    };

    /// Resolve `host` (IP literal or DNS name) for `port` using
    /// `std.c.getaddrinfo`. Returns the requested port and the address family
    /// of the first resolved record.
    fn resolveAddress(host: []const u8, port: u16) !ResolvedAddress {
        var host_z: [256]u8 = undefined;
        if (host.len >= host_z.len) return error.DnsResolutionFailed;
        @memcpy(host_z[0..host.len], host);
        host_z[host.len] = 0;

        var port_buf: [8]u8 = undefined;
        const port_str = std.fmt.bufPrint(&port_buf, "{d}", .{port}) catch return error.DnsResolutionFailed;
        port_buf[port_str.len] = 0;

        var hints: std.c.addrinfo = std.mem.zeroes(std.c.addrinfo);
        hints.family = std.c.AF.UNSPEC;
        hints.socktype = std.c.SOCK.STREAM;

        const host_ptr: [*:0]const u8 = @ptrCast(&host_z);
        const port_ptr: [*:0]const u8 = @ptrCast(&port_buf);
        var res: ?*std.c.addrinfo = null;
        const rc = std.c.getaddrinfo(host_ptr, port_ptr, &hints, &res);
        if (@intFromEnum(rc) != 0) return error.DnsResolutionFailed;
        const head = res orelse return error.DnsResolutionFailed;
        defer std.c.freeaddrinfo(head);

        return .{ .port = port, .family = head.family };
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
