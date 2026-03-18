const std = @import("std");
const config = @import("../config.zig");
const RecordAccumulator = @import("accumulator.zig").RecordAccumulator;
const Sender = @import("sender.zig").Sender;
const Partitioner = @import("partitioner.zig").Partitioner;
const DeliveryReport = @import("delivery_report.zig").DeliveryReport;
const BrokerPool = @import("../../wire/broker_pool.zig").BrokerPool;
const MetadataCache = @import("../metadata/cache.zig").MetadataCache;
const ProducerMetrics = @import("../metrics.zig").ProducerMetrics;
const ProducerMetricsSnapshot = @import("../metrics.zig").ProducerMetricsSnapshot;
const ProducerIdManager = @import("producer_id_manager.zig").ProducerIdManager;
const SequenceManager = @import("sequence_manager.zig").SequenceManager;
const TransactionCoordinator = @import("transaction_coordinator.zig").TransactionCoordinator;

/// Kafka producer public API.
///
/// Thread-safe: produce() can be called from the application thread
/// while the sender runs in its background thread.
///
/// Large internal structures (accumulator, sender) are heap-allocated
/// because they exceed typical stack sizes.
pub const KafkaProducer = struct {
    const Self = @This();

    /// Record accumulator (batches records per partition). Heap-allocated.
    accumulator: *RecordAccumulator,

    /// Sender (background thread draining batches). Heap-allocated.
    sender: *Sender,

    /// Partitioner.
    partitioner: Partitioner,

    /// Metadata cache reference.
    metadata: *MetadataCache,

    /// Broker pool reference.
    broker_pool: *BrokerPool,

    /// Producer configuration.
    cfg: config.ProducerConfig,

    /// Allocator used for internal heap allocations.
    allocator: std.mem.Allocator,

    /// Producer metrics (heap-allocated to ensure stable address).
    metrics: *ProducerMetrics,

    /// Producer ID manager (null if idempotence disabled).
    producer_id_manager: ?*ProducerIdManager,

    /// Sequence number manager (null if idempotence disabled).
    sequence_manager: ?*SequenceManager,

    /// Transaction coordinator (null if not transactional).
    transaction_coordinator: ?*TransactionCoordinator,

    /// Whether the producer has been started.
    started: bool = false,

    /// Whether the producer has been closed.
    closed: bool = false,

    pub fn init(
        metadata: *MetadataCache,
        broker_pool: *BrokerPool,
        producer_config: config.ProducerConfig,
        allocator: std.mem.Allocator,
    ) !Self {
        // Validate idempotence configuration
        if (producer_config.enable_idempotence or producer_config.transactional_id != null) {
            if (producer_config.acks != -1) {
                std.debug.print("[PRODUCER] ERROR: Idempotent/transactional producers require acks=-1\n", .{});
                return error.InvalidConfiguration;
            }
        }

        const acc = try allocator.create(RecordAccumulator);
        acc.* = .{};
        acc.max_batch_bytes = producer_config.batch_size;
        acc.linger_ms = producer_config.linger_ms;

        const metrics = try allocator.create(ProducerMetrics);
        metrics.* = .{};

        // Initialize producer ID manager if idempotence/transactions enabled
        var pid_manager: ?*ProducerIdManager = null;
        var seq_manager: ?*SequenceManager = null;
        var txn_coordinator: ?*TransactionCoordinator = null;

        if (producer_config.enable_idempotence or producer_config.transactional_id != null) {
            const pid_mgr = try allocator.create(ProducerIdManager);
            pid_mgr.* = ProducerIdManager.init(
                producer_config.transactional_id,
                producer_config.transaction_timeout_ms,
                broker_pool,
            );
            pid_manager = pid_mgr;

            const seq_mgr = try allocator.create(SequenceManager);
            seq_mgr.* = SequenceManager.init(allocator);
            seq_manager = seq_mgr;

            // Create transaction coordinator if transactional
            if (producer_config.transactional_id) |txn_id| {
                const txn_coord = try allocator.create(TransactionCoordinator);
                txn_coord.* = TransactionCoordinator.init(txn_id, pid_mgr, broker_pool, allocator);
                txn_coordinator = txn_coord;
            }
        }

        const sender = try allocator.create(Sender);
        sender.* = Sender.init(acc, broker_pool, metadata, metrics);
        sender.acks = producer_config.acks;
        sender.timeout_ms = @intCast(producer_config.request_timeout_ms);
        sender.compression_type = producer_config.compression_type;
        sender.producer_id_manager = pid_manager;
        sender.sequence_manager = seq_manager;
        sender.transaction_coordinator = txn_coordinator;

        return Self{
            .accumulator = acc,
            .sender = sender,
            .partitioner = Partitioner.init(producer_config.partitioner),
            .metadata = metadata,
            .broker_pool = broker_pool,
            .cfg = producer_config,
            .metrics = metrics,
            .producer_id_manager = pid_manager,
            .sequence_manager = seq_manager,
            .transaction_coordinator = txn_coordinator,
            .allocator = allocator,
        };
    }

    /// Start the background sender thread.
    pub fn start(self: *Self) !void {
        if (self.closed) return error.ClientClosed;
        if (self.started) return;

        // Initialize producer ID if idempotence/transactions enabled
        if (self.producer_id_manager) |pid_mgr| {
            try pid_mgr.initializeProducerId();
        }

        // Find transaction coordinator if transactional
        if (self.transaction_coordinator) |txn| {
            try txn.findCoordinator();
        }

        try self.sender.start();
        self.started = true;
    }

    /// Produce a record to the given topic.
    ///
    /// The record is buffered in the accumulator and will be sent
    /// by the background sender thread when the batch is full or
    /// the linger time expires.
    ///
    /// Returns immediately (non-blocking).
    pub fn produce(
        self: *Self,
        topic: []const u8,
        key: ?[]const u8,
        value: []const u8,
    ) !void {
        if (self.closed) return error.ClientClosed;

        const num_partitions = self.metadata.getPartitionCount(topic);
        if (num_partitions == 0) {
            std.debug.print("[PRODUCER] ERROR: Unknown topic {s}\n", .{topic});
            return error.UnknownTopic;
        }

        const partition: i32 = @intCast(self.partitioner.partition(key, num_partitions));
        std.debug.print("[PRODUCER] Producing to {s} partition {d}/{d}\n", .{ topic, partition, num_partitions });

        // Add partition to transaction if transactional and in transaction
        if (self.transaction_coordinator) |txn| {
            if (txn.isInTransaction()) {
                try txn.maybeAddPartitionToTxn(topic, partition);
            }
        }

        const now: i64 = @intCast(std.time.milliTimestamp());
        _ = try self.accumulator.append(topic, partition, key, value, now);

        // Record metrics
        self.metrics.*.recordMessageSent(value.len);
    }

    /// Produce a record to a specific partition (manual partition assignment).
    pub fn produceToPartition(
        self: *Self,
        topic: []const u8,
        partition: i32,
        key: ?[]const u8,
        value: []const u8,
    ) !void {
        if (self.closed) return error.ClientClosed;

        const num_partitions = self.metadata.getPartitionCount(topic);
        if (num_partitions == 0) return error.UnknownTopic;
        if (partition < 0 or partition >= num_partitions) return error.InvalidPartition;

        // Add partition to transaction if transactional and in transaction
        if (self.transaction_coordinator) |txn| {
            if (txn.isInTransaction()) {
                try txn.maybeAddPartitionToTxn(topic, partition);
            }
        }

        const now: i64 = @intCast(std.time.milliTimestamp());
        _ = try self.accumulator.append(topic, partition, key, value, now);

        // Record metrics
        self.metrics.*.recordMessageSent(value.len);
    }

    /// Flush all buffered records, blocking until all have been sent
    /// or the timeout expires.
    pub fn flush(self: *Self, timeout_ms: u32) !void {
        if (self.closed) return error.ClientClosed;

        const deadline = std.time.milliTimestamp() + @as(i64, timeout_ms);
        const initial_pending = self.accumulator.pendingCount();
        std.debug.print("[PRODUCER] Flushing {d} pending batches, timeout={d}ms\n", .{ initial_pending, timeout_ms });

        while (self.accumulator.pendingCount() > 0) {
            if (std.time.milliTimestamp() >= deadline) {
                return error.FlushTimeout;
            }
            // If sender is not running, do a manual drain
            if (!self.started) {
                self.sender.runOnce(std.heap.page_allocator);
            }
            std.Thread.sleep(1_000_000); // 1ms
        }
    }

    /// Poll for delivery reports from the sender thread.
    /// Returns the number of reports consumed.
    pub fn pollDeliveryReports(
        self: *Self,
        callback: *const fn (*const DeliveryReport) void,
        max: u32,
    ) u32 {
        return self.sender.pollDeliveryReports(callback, max);
    }

    /// Close the producer. Stops the sender thread.
    /// Does NOT flush pending records — call flush() first if needed.
    pub fn close(self: *Self) void {
        if (self.closed) return;
        self.sender.stop();
        self.allocator.destroy(self.sender);
        self.allocator.destroy(self.accumulator);
        self.allocator.destroy(self.metrics);

        // Cleanup idempotence managers
        if (self.producer_id_manager) |pid_mgr| {
            self.allocator.destroy(pid_mgr);
        }
        if (self.sequence_manager) |seq_mgr| {
            seq_mgr.deinit();
            self.allocator.destroy(seq_mgr);
        }
        if (self.transaction_coordinator) |txn| {
            txn.deinit();
            self.allocator.destroy(txn);
        }

        self.closed = true;
        self.started = false;
    }

    /// Number of records currently buffered across all partitions.
    pub fn pendingCount(self: *const Self) u16 {
        return self.accumulator.pendingCount();
    }

    /// Get a snapshot of producer metrics.
    pub fn getMetrics(self: *const Self) ProducerMetricsSnapshot {
        return self.metrics.getSnapshot();
    }

    // ========================================================================
    // Transaction API
    // ========================================================================

    /// Begin a new transaction.
    ///
    /// Only available for transactional producers (transactional_id set).
    /// All subsequent produce() calls will be part of this transaction until
    /// commitTransaction() or abortTransaction() is called.
    ///
    /// Transactions provide:
    /// - Atomic writes across multiple partitions
    /// - Exactly-once semantics (no duplicates, even on retry)
    /// - Read isolation (consumers can read only committed data)
    pub fn beginTransaction(self: *Self) !void {
        if (self.closed) return error.ClientClosed;

        const txn = self.transaction_coordinator orelse {
            return error.NotTransactionalProducer;
        };

        try txn.beginTransaction();
    }

    /// Commit the current transaction.
    ///
    /// All messages produced in this transaction become visible atomically.
    /// Blocks until the transaction coordinator confirms the commit.
    pub fn commitTransaction(self: *Self) !void {
        if (self.closed) return error.ClientClosed;

        const txn = self.transaction_coordinator orelse {
            return error.NotTransactionalProducer;
        };

        // Flush all pending batches before committing
        try self.flush(self.cfg.flush_timeout_ms);

        try txn.commitTransaction();
    }

    /// Abort the current transaction.
    ///
    /// All messages produced in this transaction are discarded.
    /// Blocks until the transaction coordinator confirms the abort.
    pub fn abortTransaction(self: *Self) !void {
        if (self.closed) return error.ClientClosed;

        const txn = self.transaction_coordinator orelse {
            return error.NotTransactionalProducer;
        };

        try txn.abortTransaction();
    }

    /// Check if currently in a transaction.
    pub fn isInTransaction(self: *const Self) bool {
        if (self.transaction_coordinator) |txn| {
            return txn.isInTransaction();
        }
        return false;
    }
};

// ============================================================================
// Tests
// ============================================================================

test "KafkaProducer init" {
    var cache = MetadataCache{};
    var pool = BrokerPool.init(std.testing.allocator);

    var producer = try KafkaProducer.init(&cache, &pool, .{}, std.testing.allocator);
    defer producer.close();
    try std.testing.expectEqual(false, producer.started);
    try std.testing.expectEqual(false, producer.closed);
    try std.testing.expectEqual(@as(u16, 0), producer.pendingCount());
}

test "KafkaProducer produce requires topic in metadata" {
    var cache = MetadataCache{};
    var pool = BrokerPool.init(std.testing.allocator);

    var producer = try KafkaProducer.init(&cache, &pool, .{}, std.testing.allocator);
    defer producer.close();
    const result = producer.produce("unknown-topic", "key", "value");
    try std.testing.expectError(error.UnknownTopic, result);
}

test "KafkaProducer produce with known topic" {
    var cache = MetadataCache{};

    // Register a topic with 3 partitions
    const parts = [_]@import("../metadata/cache.zig").PartitionEntry{
        .{ .partition_id = 0, .leader_id = 0 },
        .{ .partition_id = 1, .leader_id = 1 },
        .{ .partition_id = 2, .leader_id = 0 },
    };
    cache.updateTopic("test-topic", &parts);

    var pool = BrokerPool.init(std.testing.allocator);

    var producer = try KafkaProducer.init(&cache, &pool, .{}, std.testing.allocator);
    defer producer.close();
    try producer.produce("test-topic", "key-1", "value-1");
    try std.testing.expectEqual(@as(u16, 1), producer.pendingCount());
}

test "KafkaProducer close" {
    var cache = MetadataCache{};
    var pool = BrokerPool.init(std.testing.allocator);

    var producer = try KafkaProducer.init(&cache, &pool, .{}, std.testing.allocator);
    producer.close();
    try std.testing.expect(producer.closed);

    const result = producer.produce("topic", "k", "v");
    try std.testing.expectError(error.ClientClosed, result);
}

test "KafkaProducer double close" {
    var cache = MetadataCache{};
    var pool = BrokerPool.init(std.testing.allocator);

    var producer = try KafkaProducer.init(&cache, &pool, .{}, std.testing.allocator);
    producer.close();
    // Second close should be a no-op, not crash
    producer.close();
    try std.testing.expect(producer.closed);
}

test "KafkaProducer produceToPartition" {
    var cache = MetadataCache{};

    const parts = [_]@import("../metadata/cache.zig").PartitionEntry{
        .{ .partition_id = 0, .leader_id = 0 },
        .{ .partition_id = 1, .leader_id = 1 },
        .{ .partition_id = 2, .leader_id = 0 },
    };
    cache.updateTopic("test-topic", &parts);

    var pool = BrokerPool.init(std.testing.allocator);

    var producer = try KafkaProducer.init(&cache, &pool, .{}, std.testing.allocator);
    defer producer.close();

    // Valid partition
    try producer.produceToPartition("test-topic", 1, "key", "value");
    try std.testing.expectEqual(@as(u16, 1), producer.pendingCount());
}

test "KafkaProducer produceToPartition out of range" {
    var cache = MetadataCache{};

    const parts = [_]@import("../metadata/cache.zig").PartitionEntry{
        .{ .partition_id = 0, .leader_id = 0 },
    };
    cache.updateTopic("test-topic", &parts);

    var pool = BrokerPool.init(std.testing.allocator);

    var producer = try KafkaProducer.init(&cache, &pool, .{}, std.testing.allocator);
    defer producer.close();

    // Out of range partitions
    try std.testing.expectError(error.InvalidPartition, producer.produceToPartition("test-topic", 1, "k", "v"));
    try std.testing.expectError(error.InvalidPartition, producer.produceToPartition("test-topic", -1, "k", "v"));
}

test "KafkaProducer produce null key" {
    var cache = MetadataCache{};

    const parts = [_]@import("../metadata/cache.zig").PartitionEntry{
        .{ .partition_id = 0, .leader_id = 0 },
        .{ .partition_id = 1, .leader_id = 1 },
    };
    cache.updateTopic("test-topic", &parts);

    var pool = BrokerPool.init(std.testing.allocator);

    var producer = try KafkaProducer.init(&cache, &pool, .{}, std.testing.allocator);
    defer producer.close();

    // Null key should use round-robin/sticky partitioner
    try producer.produce("test-topic", null, "value-1");
    try producer.produce("test-topic", null, "value-2");
    try std.testing.expect(producer.pendingCount() >= 1);
}

test "KafkaProducer custom config" {
    var cache = MetadataCache{};
    var pool = BrokerPool.init(std.testing.allocator);

    const pcfg = config.ProducerConfig{
        .acks = 1,
        .linger_ms = 100,
        .batch_size = 32_768,
        .partitioner = .round_robin,
    };

    var producer = try KafkaProducer.init(&cache, &pool, pcfg, std.testing.allocator);
    defer producer.close();

    try std.testing.expectEqual(@as(i16, 1), producer.sender.acks);
}

test "KafkaProducer multiple topics" {
    var cache = MetadataCache{};

    const parts = [_]@import("../metadata/cache.zig").PartitionEntry{
        .{ .partition_id = 0, .leader_id = 0 },
    };
    cache.updateTopic("topic-a", &parts);
    cache.updateTopic("topic-b", &parts);

    var pool = BrokerPool.init(std.testing.allocator);

    var producer = try KafkaProducer.init(&cache, &pool, .{}, std.testing.allocator);
    defer producer.close();

    try producer.produce("topic-a", "k1", "v1");
    try producer.produce("topic-b", "k2", "v2");
    try std.testing.expectEqual(@as(u16, 2), producer.pendingCount());
}

test "KafkaProducer flush empty" {
    var cache = MetadataCache{};
    var pool = BrokerPool.init(std.testing.allocator);

    var producer = try KafkaProducer.init(&cache, &pool, .{}, std.testing.allocator);
    defer producer.close();

    // Flush with nothing pending should return immediately
    try producer.flush(100);
}
