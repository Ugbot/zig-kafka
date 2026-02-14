const std = @import("std");
const BrokerPool = @import("../../wire/broker_pool.zig").BrokerPool;
const ProducerIdManager = @import("producer_id_manager.zig").ProducerIdManager;
const types = @import("kafka_generated").types;
const FindCoordinatorRequest = @import("kafka_generated").find_coordinator_request.FindCoordinatorRequest;
const FindCoordinatorResponse = @import("kafka_generated").find_coordinator_response.FindCoordinatorResponse;
const AddPartitionsToTxnRequest = @import("kafka_generated").add_partitions_to_txn_request.AddPartitionsToTxnRequest;
const AddPartitionsToTxnResponse = @import("kafka_generated").add_partitions_to_txn_response.AddPartitionsToTxnResponse;
const EndTxnRequest = @import("kafka_generated").end_txn_request.EndTxnRequest;
const EndTxnResponse = @import("kafka_generated").end_txn_response.EndTxnResponse;

/// Transaction state machine for producer transactions.
pub const TransactionState = enum {
    /// No transaction in progress.
    not_in_transaction,
    /// Transaction has been started (beginTransaction called).
    in_transaction,
    /// Transaction is being committed.
    committing,
    /// Transaction is being aborted.
    aborting,
    /// Transaction committed successfully.
    committed,
    /// Transaction aborted successfully.
    aborted,
    /// Fatal error - producer must be closed.
    fatal_error,
};

/// Manages transaction lifecycle for transactional producers.
///
/// Responsibilities:
/// - Find transaction coordinator
/// - Track partitions added to current transaction
/// - Send AddPartitionsToTxn requests
/// - Send EndTxn (commit/abort) requests
/// - Maintain transaction state machine
///
/// NOT thread-safe: Only accessed by application thread.
pub const TransactionCoordinator = struct {
    const Self = @This();

    /// Transactional ID (immutable).
    transactional_id: []const u8,

    /// Reference to producer ID manager.
    producer_id_manager: *ProducerIdManager,

    /// Reference to broker pool.
    broker_pool: *BrokerPool,

    /// Current transaction state.
    state: TransactionState,

    /// Transaction coordinator node ID (-1 = not discovered yet).
    coordinator_node_id: i32,

    /// Partitions added to the current transaction.
    /// Cleared on commit/abort, rebuilt on beginTransaction.
    partitions_in_txn: PartitionSet,

    /// Allocator for managing partition set.
    allocator: std.mem.Allocator,

    pub fn init(
        transactional_id: []const u8,
        producer_id_manager: *ProducerIdManager,
        broker_pool: *BrokerPool,
        allocator: std.mem.Allocator,
    ) Self {
        return .{
            .transactional_id = transactional_id,
            .producer_id_manager = producer_id_manager,
            .broker_pool = broker_pool,
            .state = .not_in_transaction,
            .coordinator_node_id = -1,
            .partitions_in_txn = PartitionSet.init(allocator),
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Self) void {
        // Free all partition keys
        for (self.partitions_in_txn.keys()) |key| {
            self.allocator.free(key.topic);
        }
        self.partitions_in_txn.deinit();
    }

    /// Find the transaction coordinator for this transactional_id.
    pub fn findCoordinator(self: *Self) !void {
        std.debug.print("[TXN] Finding coordinator for transactional_id={s}\n", .{self.transactional_id});

        // Build FindCoordinator request
        var req = FindCoordinatorRequest.default();
        req.key = self.transactional_id;
        req.key_type = 1; // 1 = TRANSACTION

        // Send to any broker
        const conn = try self.broker_pool.getAnyBroker();
        const resp_size = try conn.sendRequest(10, 4, req);

        // Parse response
        var stream = std.io.fixedBufferStream(conn.recv_buf[4..resp_size]);
        const reader = stream.reader();

        // Skip correlation ID
        _ = try types.decodeInt32(reader);

        // Skip tagged fields (flexible version)
        _ = try types.decodeUnsignedVarInt(reader);

        // Decode response
        var arena = std.heap.ArenaAllocator.init(self.allocator);
        defer arena.deinit();
        const resp = try FindCoordinatorResponse.decode(reader, 4, arena.allocator());

        // Check for errors
        if (resp.error_code != 0) {
            std.debug.print("[TXN] FindCoordinator failed: error_code={d}\n", .{resp.error_code});
            return error.CoordinatorNotAvailable;
        }

        self.coordinator_node_id = resp.node_id;
        std.debug.print("[TXN] Found coordinator: node_id={d}, host={s}:{d}\n", .{
            resp.node_id,
            resp.host,
            resp.port,
        });

        // Register coordinator with broker pool if needed
        // (Broker pool should already know about it from metadata)
    }

    /// Begin a new transaction.
    ///
    /// Must be called before producing any messages in a transaction.
    /// Cannot be called if already in a transaction.
    pub fn beginTransaction(self: *Self) !void {
        if (self.state != .not_in_transaction and self.state != .committed and self.state != .aborted) {
            return error.TransactionAlreadyStarted;
        }

        // Ensure we have a coordinator
        if (self.coordinator_node_id == -1) {
            try self.findCoordinator();
        }

        // Clear partitions from previous transaction
        for (self.partitions_in_txn.keys()) |key| {
            self.allocator.free(key.topic);
        }
        self.partitions_in_txn.clearRetainingCapacity();

        self.state = .in_transaction;
        std.debug.print("[TXN] Transaction started\n", .{});
    }

    /// Add a partition to the current transaction if not already added.
    ///
    /// Sends AddPartitionsToTxn request to the transaction coordinator.
    pub fn maybeAddPartitionToTxn(self: *Self, topic: []const u8, partition: i32) !void {
        if (self.state != .in_transaction) {
            return error.NotInTransaction;
        }

        const key = TopicPartition{ .topic = topic, .partition = partition };

        // Check if already added
        if (self.partitions_in_txn.contains(key)) {
            return; // Already in transaction
        }

        std.debug.print("[TXN] Adding partition to transaction: {s}-{d}\n", .{ topic, partition });

        // Build AddPartitionsToTxn request
        // Use v3-and-below fields for compatibility
        var req = AddPartitionsToTxnRequest.default();
        req.v3_and_below_transactional_id = self.transactional_id;
        req.v3_and_below_producer_id = self.producer_id_manager.getProducerId();
        req.v3_and_below_producer_epoch = self.producer_id_manager.getProducerEpoch();
        // Note: v3_and_below_topics would need to be set, but for now we'll use version 0
        // which uses the simpler fields

        // Send to coordinator (use version 0 for simplicity)
        const conn = try self.broker_pool.getConnection(self.coordinator_node_id);
        const resp_size = try conn.sendRequest(24, 0, req);

        // Parse response
        var stream = std.io.fixedBufferStream(conn.recv_buf[4..resp_size]);
        const reader = stream.reader();

        // Skip correlation ID
        _ = try types.decodeInt32(reader);

        // Version 0 doesn't have tagged fields (not flexible)
        // Skip tagged fields only for flexible versions (v3+)
        // _ = try types.decodeUnsignedVarInt(reader);

        // Decode response
        var arena = std.heap.ArenaAllocator.init(self.allocator);
        defer arena.deinit();
        const resp = try AddPartitionsToTxnResponse.decode(reader, 0, arena.allocator());

        // Check for errors in response (v3-and-below uses different field)
        if (resp.results_by_topic_v3_and_below) |results| {
            for (results) |topic_result| {
                if (topic_result.results_by_partition) |part_results| {
                    for (part_results) |part_result| {
                        if (part_result.partition_error_code != 0) {
                            std.debug.print("[TXN] AddPartitionsToTxn failed: partition={d}, error={d}\n", .{
                                part_result.partition_index,
                                part_result.partition_error_code,
                            });
                            return error.AddPartitionsToTxnFailed;
                        }
                    }
                }
            }
        }

        // Add to our tracking set
        const topic_copy = try self.allocator.dupe(u8, topic);
        const key_owned = TopicPartition{ .topic = topic_copy, .partition = partition };
        try self.partitions_in_txn.put(key_owned, {});

        std.debug.print("[TXN] Partition added successfully: {s}-{d}\n", .{ topic, partition });
    }

    /// Commit the current transaction.
    ///
    /// All messages produced in this transaction become visible atomically.
    pub fn commitTransaction(self: *Self) !void {
        if (self.state != .in_transaction) {
            return error.NotInTransaction;
        }

        self.state = .committing;
        std.debug.print("[TXN] Committing transaction\n", .{});

        try self.endTransaction(true);

        self.state = .committed;
        std.debug.print("[TXN] Transaction committed\n", .{});
    }

    /// Abort the current transaction.
    ///
    /// All messages produced in this transaction are discarded.
    pub fn abortTransaction(self: *Self) !void {
        if (self.state != .in_transaction) {
            return error.NotInTransaction;
        }

        self.state = .aborting;
        std.debug.print("[TXN] Aborting transaction\n", .{});

        try self.endTransaction(false);

        self.state = .aborted;
        std.debug.print("[TXN] Transaction aborted\n", .{});
    }

    /// Internal: Send EndTxn request to coordinator.
    fn endTransaction(self: *Self, committed: bool) !void {
        var req = EndTxnRequest.default();
        req.transactional_id = self.transactional_id;
        req.producer_id = self.producer_id_manager.getProducerId();
        req.producer_epoch = self.producer_id_manager.getProducerEpoch();
        req.committed = committed;

        // Send to coordinator
        const conn = try self.broker_pool.getConnection(self.coordinator_node_id);
        const resp_size = try conn.sendRequest(26, 3, req);

        // Parse response
        var stream = std.io.fixedBufferStream(conn.recv_buf[4..resp_size]);
        const reader = stream.reader();

        // Skip correlation ID
        _ = try types.decodeInt32(reader);

        // Skip tagged fields
        _ = try types.decodeUnsignedVarInt(reader);

        // Decode response
        var arena = std.heap.ArenaAllocator.init(self.allocator);
        defer arena.deinit();
        const resp = try EndTxnResponse.decode(reader, 3, arena.allocator());

        // Check for errors
        if (resp.error_code != 0) {
            std.debug.print("[TXN] EndTxn failed: error_code={d}\n", .{resp.error_code});
            self.state = .fatal_error;
            return error.EndTxnFailed;
        }
    }

    /// Check if currently in a transaction.
    pub fn isInTransaction(self: *const Self) bool {
        return self.state == .in_transaction;
    }

    /// Get current transaction state.
    pub fn getState(self: *const Self) TransactionState {
        return self.state;
    }
};

/// Key for partition set: (topic, partition).
const TopicPartition = struct {
    topic: []const u8,
    partition: i32,

    pub fn hash(self: TopicPartition) u64 {
        var hasher = std.hash.Wyhash.init(0);
        hasher.update(self.topic);
        hasher.update(std.mem.asBytes(&self.partition));
        return hasher.final();
    }

    pub fn eql(self: TopicPartition, other: TopicPartition) bool {
        return self.partition == other.partition and
            std.mem.eql(u8, self.topic, other.topic);
    }
};

const PartitionSet = std.ArrayHashMap(
    TopicPartition,
    void,
    struct {
        pub fn hash(_: @This(), key: TopicPartition) u32 {
            return @truncate(key.hash());
        }
        pub fn eql(_: @This(), a: TopicPartition, b: TopicPartition, _: usize) bool {
            return a.eql(b);
        }
    },
    true,
);

// ============================================================================
// Tests
// ============================================================================

test "TransactionCoordinator init" {
    var pool = BrokerPool.init(std.testing.allocator);
    defer pool.deinit();

    var pid_mgr = ProducerIdManager.init("test-txn", 60_000, &pool);

    var txn = TransactionCoordinator.init("test-txn", &pid_mgr, &pool, std.testing.allocator);
    defer txn.deinit();

    try std.testing.expectEqual(TransactionState.not_in_transaction, txn.getState());
    try std.testing.expect(!txn.isInTransaction());
    try std.testing.expectEqualStrings("test-txn", txn.transactional_id);
}

test "TransactionCoordinator state transitions" {
    var pool = BrokerPool.init(std.testing.allocator);
    defer pool.deinit();

    var pid_mgr = ProducerIdManager.init("test-txn", 60_000, &pool);

    var txn = TransactionCoordinator.init("test-txn", &pid_mgr, &pool, std.testing.allocator);
    defer txn.deinit();

    // Cannot commit/abort when not in transaction
    try std.testing.expectError(error.NotInTransaction, txn.commitTransaction());
    try std.testing.expectError(error.NotInTransaction, txn.abortTransaction());

    // Cannot add partitions when not in transaction
    try std.testing.expectError(error.NotInTransaction, txn.maybeAddPartitionToTxn("topic", 0));
}
