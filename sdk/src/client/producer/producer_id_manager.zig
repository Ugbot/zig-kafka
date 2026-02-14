const std = @import("std");
const BrokerPool = @import("../../wire/broker_pool.zig").BrokerPool;
const types = @import("kafka_generated").types;
const InitProducerIdRequest = @import("kafka_generated").init_producer_id_request.InitProducerIdRequest;
const InitProducerIdResponse = @import("kafka_generated").init_producer_id_response.InitProducerIdResponse;

/// Manages producer ID (PID) and epoch for idempotent/transactional producers.
///
/// Thread-safe: Uses atomics for concurrent access from sender thread.
pub const ProducerIdManager = struct {
    const Self = @This();

    /// Current producer ID (-1 = not initialized).
    producer_id: std.atomic.Value(i64),

    /// Current producer epoch.
    producer_epoch: std.atomic.Value(i16),

    /// Transactional ID (null = idempotent-only, non-null = transactional).
    transactional_id: ?[]const u8,

    /// Transaction timeout in milliseconds.
    transaction_timeout_ms: i32,

    /// Whether producer ID has been initialized.
    initialized: std.atomic.Value(bool),

    /// Broker pool for making InitProducerId requests.
    broker_pool: *BrokerPool,

    pub fn init(
        transactional_id: ?[]const u8,
        transaction_timeout_ms: u32,
        broker_pool: *BrokerPool,
    ) Self {
        return .{
            .producer_id = std.atomic.Value(i64).init(-1),
            .producer_epoch = std.atomic.Value(i16).init(0),
            .transactional_id = transactional_id,
            .transaction_timeout_ms = @intCast(transaction_timeout_ms),
            .initialized = std.atomic.Value(bool).init(false),
            .broker_pool = broker_pool,
        };
    }

    /// Initialize the producer ID by sending InitProducerId request to any broker.
    ///
    /// For transactional producers (transactional_id != null):
    ///   - Registers the transactional ID with the transaction coordinator
    ///   - Returns a unique PID + epoch for this producer instance
    ///   - Automatically recovers from fenced epochs
    ///
    /// For idempotent producers (transactional_id == null):
    ///   - Generates a fresh PID for deduplication
    ///   - No coordination with transaction coordinator needed
    pub fn initializeProducerId(self: *Self) !void {
        if (self.initialized.load(.acquire)) {
            return; // Already initialized
        }

        // Build InitProducerId request
        const request = InitProducerIdRequest.default()
            .withTransactionalId(self.transactional_id)
            .withTransactionTimeoutMs(self.transaction_timeout_ms)
            .withProducerId(self.producer_id.load(.monotonic))
            .withProducerEpoch(self.producer_epoch.load(.monotonic));

        // Send to any broker (coordinator will be found automatically)
        const conn = try self.broker_pool.getAnyBroker();
        const resp_size = try conn.sendRequest(22, 4, request);

        // Parse response (skip 4-byte size prefix)
        var stream = std.io.fixedBufferStream(conn.recv_buf[4..resp_size]);
        const reader = stream.reader();

        // Skip correlation ID
        _ = try types.decodeInt32(reader);

        // Skip tagged fields if flexible version
        _ = try types.decodeUnsignedVarInt(reader);

        // Decode response body
        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer arena.deinit();
        const response = try InitProducerIdResponse.decode(reader, 4, arena.allocator());

        // Check for errors
        if (response.error_code != 0) {
            std.debug.print("[PID_MANAGER] InitProducerId failed: error_code={d}\n", .{response.error_code});
            return error.InitProducerIdFailed;
        }

        // Store the producer ID and epoch
        self.producer_id.store(response.producer_id, .release);
        self.producer_epoch.store(response.producer_epoch, .release);
        self.initialized.store(true, .release);

        std.debug.print("[PID_MANAGER] Initialized: PID={d}, epoch={d}, transactional={}\n", .{
            response.producer_id,
            response.producer_epoch,
            self.transactional_id != null,
        });
    }

    /// Get the current producer ID.
    /// Returns -1 if not initialized.
    pub fn getProducerId(self: *const Self) i64 {
        return self.producer_id.load(.acquire);
    }

    /// Get the current producer epoch.
    pub fn getProducerEpoch(self: *const Self) i16 {
        return self.producer_epoch.load(.acquire);
    }

    /// Check if the producer ID has been initialized.
    pub fn isInitialized(self: *const Self) bool {
        return self.initialized.load(.acquire);
    }

    /// Bump the epoch (used when recovering from errors).
    ///
    /// This requires re-initializing with the transaction coordinator.
    /// Call initializeProducerId() after bumping the epoch.
    pub fn bumpEpoch(self: *Self) void {
        const current_epoch = self.producer_epoch.load(.acquire);
        self.producer_epoch.store(current_epoch + 1, .release);
        self.initialized.store(false, .release);
    }
};

// ============================================================================
// Tests
// ============================================================================

test "ProducerIdManager init" {
    var pool = BrokerPool.init(std.testing.allocator);
    defer pool.deinit();

    var manager = ProducerIdManager.init(null, 60_000, &pool);
    try std.testing.expectEqual(@as(i64, -1), manager.getProducerId());
    try std.testing.expectEqual(@as(i16, 0), manager.getProducerEpoch());
    try std.testing.expect(!manager.isInitialized());
}

test "ProducerIdManager transactional init" {
    var pool = BrokerPool.init(std.testing.allocator);
    defer pool.deinit();

    var manager = ProducerIdManager.init("my-txn-id", 120_000, &pool);
    try std.testing.expectEqualStrings("my-txn-id", manager.transactional_id.?);
    try std.testing.expectEqual(@as(i32, 120_000), manager.transaction_timeout_ms);
    try std.testing.expect(!manager.isInitialized());
}

test "ProducerIdManager epoch bump" {
    var pool = BrokerPool.init(std.testing.allocator);
    defer pool.deinit();

    var manager = ProducerIdManager.init(null, 60_000, &pool);

    // Manually set initialized state
    manager.initialized.store(true, .release);
    manager.producer_epoch.store(5, .release);

    try std.testing.expect(manager.isInitialized());
    try std.testing.expectEqual(@as(i16, 5), manager.getProducerEpoch());

    // Bump epoch resets initialization
    manager.bumpEpoch();
    try std.testing.expectEqual(@as(i16, 6), manager.getProducerEpoch());
    try std.testing.expect(!manager.isInitialized());
}
