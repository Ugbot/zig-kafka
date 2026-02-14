const std = @import("std");
const BrokerConnection = @import("connection.zig").BrokerConnection;
const MetadataCache = @import("../client/metadata/cache.zig").MetadataCache;

/// Fixed-size pool of broker connections.
///
/// Broker ID maps directly to array index. Maximum 64 brokers.
/// Send/recv buffers are allocated on demand when a connection is created.
pub const BrokerPool = struct {
    const Self = @This();

    /// Connections indexed by broker node ID.
    connections: [MAX_BROKERS]?BrokerConnection = [_]?BrokerConnection{null} ** MAX_BROKERS,

    /// Heap-allocated send buffers (one per connected broker, allocated on demand).
    send_bufs: [MAX_BROKERS]?[]u8 = [_]?[]u8{null} ** MAX_BROKERS,

    /// Heap-allocated receive buffers (one per connected broker, allocated on demand).
    recv_bufs: [MAX_BROKERS]?[]u8 = [_]?[]u8{null} ** MAX_BROKERS,

    /// Reference to the metadata cache for leader lookups.
    metadata: ?*MetadataCache = null,

    /// Allocator for buffer allocation.
    allocator: std.mem.Allocator,

    /// Default client ID for new connections.
    client_id: []const u8 = "tickstream-zig-client",

    /// Connection timeout (ms) for new connections.
    connect_timeout_ms: u32 = 30_000,

    /// Request timeout (ms) for new connections.
    request_timeout_ms: u32 = 30_000,

    pub const MAX_BROKERS = 64;
    pub const BUFFER_SIZE = 1_048_576; // 1MB per buffer

    /// Initialize the pool with an allocator.
    pub fn init(allocator: std.mem.Allocator) Self {
        return .{
            .allocator = allocator,
        };
    }

    /// Get or create a connection to a specific broker by node ID.
    pub fn getConnection(self: *Self, node_id: i32) !*BrokerConnection {
        if (node_id < 0 or node_id >= MAX_BROKERS) return error.UnknownBroker;
        const idx: usize = @intCast(node_id);

        // Return existing connection if available and connected
        if (self.connections[idx]) |*conn| {
            if (conn.state == .connected) return conn;
            if (conn.state == .disconnected) {
                // Try to reconnect
                conn.connect() catch return error.ConnectionFailed;
                return conn;
            }
        }

        // Need to create a new connection — look up broker in metadata
        const md = self.metadata orelse return error.NoBrokersAvailable;
        const broker = md.getBroker(node_id) orelse return error.UnknownBroker;

        // Allocate buffers on demand
        if (self.send_bufs[idx] == null) {
            self.send_bufs[idx] = try self.allocator.alloc(u8, BUFFER_SIZE);
        }
        if (self.recv_bufs[idx] == null) {
            self.recv_bufs[idx] = try self.allocator.alloc(u8, BUFFER_SIZE);
        }

        var conn = BrokerConnection.init(
            broker.host(),
            broker.port,
            self.send_bufs[idx].?,
            self.recv_bufs[idx].?,
        );
        conn.node_id = node_id;
        conn.client_id = self.client_id;
        conn.connect_timeout_ms = self.connect_timeout_ms;
        conn.request_timeout_ms = self.request_timeout_ms;

        conn.connect() catch return error.ConnectionFailed;

        self.connections[idx] = conn;
        return &(self.connections[idx].?);
    }

    /// Get the connection to the leader of a topic-partition.
    pub fn getLeader(self: *Self, topic: []const u8, partition_id: i32) !*BrokerConnection {
        const md = self.metadata orelse return error.NoBrokersAvailable;
        const leader_id = md.getLeader(topic, partition_id);
        if (leader_id < 0) return error.LeaderNotKnown;
        return self.getConnection(leader_id);
    }

    /// Get any available connected broker (for metadata requests, etc.).
    pub fn getAnyBroker(self: *Self) !*BrokerConnection {
        // First try: return any already-connected broker
        for (&self.connections) |*slot| {
            if (slot.*) |*conn| {
                if (conn.state == .connected) return conn;
            }
        }

        // Second try: reconnect any known broker
        for (&self.connections) |*slot| {
            if (slot.*) |*conn| {
                if (conn.state == .disconnected) {
                    conn.connect() catch continue;
                    return conn;
                }
            }
        }

        return error.NoBrokersAvailable;
    }

    /// Close a specific broker connection and free its buffers.
    pub fn closeConnection(self: *Self, node_id: i32) void {
        if (node_id < 0 or node_id >= MAX_BROKERS) return;
        const idx: usize = @intCast(node_id);
        if (self.connections[idx]) |*conn| {
            conn.close();
            self.connections[idx] = null;
        }
        if (self.send_bufs[idx]) |buf| {
            self.allocator.free(buf);
            self.send_bufs[idx] = null;
        }
        if (self.recv_bufs[idx]) |buf| {
            self.allocator.free(buf);
            self.recv_bufs[idx] = null;
        }
    }

    /// Close all connections and free all buffers.
    pub fn closeAll(self: *Self) void {
        for (&self.connections, 0..) |*slot, idx| {
            if (slot.*) |*conn| {
                conn.close();
            }
            slot.* = null;
            if (self.send_bufs[idx]) |buf| {
                self.allocator.free(buf);
                self.send_bufs[idx] = null;
            }
            if (self.recv_bufs[idx]) |buf| {
                self.allocator.free(buf);
                self.recv_bufs[idx] = null;
            }
        }
    }

    /// Count of currently connected brokers.
    pub fn connectedCount(self: *const Self) u16 {
        var count: u16 = 0;
        for (&self.connections) |*slot| {
            if (slot.*) |*conn| {
                if (conn.state == .connected) count += 1;
            }
        }
        return count;
    }
};

// ============================================================================
// Tests
// ============================================================================

test "BrokerPool init" {
    var pool = BrokerPool.init(std.testing.allocator);
    try std.testing.expectEqual(@as(u16, 0), pool.connectedCount());
}

test "BrokerPool getAnyBroker empty" {
    var pool = BrokerPool.init(std.testing.allocator);
    const result = pool.getAnyBroker();
    try std.testing.expectError(error.NoBrokersAvailable, result);
}

test "BrokerPool getConnection unknown broker" {
    var cache = MetadataCache{};
    var pool = BrokerPool.init(std.testing.allocator);
    pool.metadata = &cache;

    // Node ID 5 not in metadata
    const result = pool.getConnection(5);
    try std.testing.expectError(error.UnknownBroker, result);
}

test "BrokerPool getConnection out of range" {
    var pool = BrokerPool.init(std.testing.allocator);

    const result = pool.getConnection(-1);
    try std.testing.expectError(error.UnknownBroker, result);

    const result2 = pool.getConnection(64);
    try std.testing.expectError(error.UnknownBroker, result2);
}

test "BrokerPool getLeader unknown" {
    var cache = MetadataCache{};
    var pool = BrokerPool.init(std.testing.allocator);
    pool.metadata = &cache;

    const result = pool.getLeader("nonexistent", 0);
    try std.testing.expectError(error.LeaderNotKnown, result);
}

test "BrokerPool closeAll on empty pool" {
    var pool = BrokerPool.init(std.testing.allocator);
    // Should not crash
    pool.closeAll();
    try std.testing.expectEqual(@as(u16, 0), pool.connectedCount());
}

test "BrokerPool closeConnection out of range" {
    var pool = BrokerPool.init(std.testing.allocator);
    // Should not crash
    pool.closeConnection(-1);
    pool.closeConnection(64);
    pool.closeConnection(100);
}

test "BrokerPool getLeader no metadata" {
    var pool = BrokerPool.init(std.testing.allocator);
    // No metadata set
    const result = pool.getLeader("topic", 0);
    try std.testing.expectError(error.NoBrokersAvailable, result);
}

test "BrokerPool getConnection no metadata" {
    var pool = BrokerPool.init(std.testing.allocator);
    // No metadata set, no existing connection
    const result = pool.getConnection(0);
    try std.testing.expectError(error.NoBrokersAvailable, result);
}

test "BrokerPool configurable settings" {
    var pool = BrokerPool.init(std.testing.allocator);
    pool.client_id = "custom-client";
    pool.connect_timeout_ms = 5000;
    pool.request_timeout_ms = 10000;

    try std.testing.expectEqualStrings("custom-client", pool.client_id);
    try std.testing.expectEqual(@as(u32, 5000), pool.connect_timeout_ms);
    try std.testing.expectEqual(@as(u32, 10000), pool.request_timeout_ms);
}
