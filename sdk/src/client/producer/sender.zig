const std = @import("std");
const RecordAccumulator = @import("accumulator.zig").RecordAccumulator;
const BatchSlot = @import("accumulator.zig").BatchSlot;
const BrokerPool = @import("../../wire/broker_pool.zig").BrokerPool;
const MetadataCache = @import("../metadata/cache.zig").MetadataCache;
const DeliveryReport = @import("delivery_report.zig").DeliveryReport;
const CompressionType = @import("../config.zig").CompressionType;
const compression = @import("compression.zig");
const types = @import("kafka_generated").types;
const ProduceRequest = @import("kafka_generated").produce_request.ProduceRequest;
const TopicProduceData = @import("kafka_generated").produce_request.TopicProduceData;
const PartitionProduceData = @import("kafka_generated").produce_request.PartitionProduceData;
const ProduceResponse = @import("kafka_generated").produce_response.ProduceResponse;
const request_mod = @import("../../wire/request.zig");
const ProducerMetrics = @import("../metrics.zig").ProducerMetrics;
const ProducerIdManager = @import("producer_id_manager.zig").ProducerIdManager;
const SequenceManager = @import("sequence_manager.zig").SequenceManager;
const TransactionCoordinator = @import("transaction_coordinator.zig").TransactionCoordinator;

/// Sender runs in a background thread, draining ready batches from the
/// accumulator, grouping them by leader broker, sending ProduceRequests,
/// and enqueuing DeliveryReports back to the application.
pub const Sender = struct {
    const Self = @This();

    /// Reference to the shared accumulator.
    accumulator: *RecordAccumulator,

    /// Reference to the broker pool.
    broker_pool: *BrokerPool,

    /// Reference to the metadata cache.
    metadata: *MetadataCache,

    /// Reference to producer metrics.
    metrics: *ProducerMetrics,

    /// Delivery report ring buffer (SPSC: sender → app thread).
    delivery_reports: [DR_RING_SIZE]DeliveryReport = [_]DeliveryReport{DeliveryReport{}} ** DR_RING_SIZE,
    dr_head: std.atomic.Value(u32) = std.atomic.Value(u32).init(0),
    dr_tail: std.atomic.Value(u32) = std.atomic.Value(u32).init(0),

    /// Required acks.
    acks: i16 = -1,

    /// Produce request timeout (ms).
    timeout_ms: i32 = 30_000,

    /// API version to use for Produce requests.
    produce_version: i16 = 3,

    /// Compression type for record batches.
    compression_type: CompressionType = .none,

    /// Producer ID manager (null if idempotence disabled).
    producer_id_manager: ?*ProducerIdManager = null,

    /// Sequence number manager (null if idempotence disabled).
    sequence_manager: ?*SequenceManager = null,

    /// Transaction coordinator (null if not transactional).
    transaction_coordinator: ?*TransactionCoordinator = null,

    /// Whether the sender should keep running.
    running: std.atomic.Value(bool) = std.atomic.Value(bool).init(false),

    /// Background thread handle.
    thread: ?std.Thread = null,

    pub const DR_RING_SIZE = 1024;

    pub fn init(
        accumulator: *RecordAccumulator,
        broker_pool: *BrokerPool,
        metadata: *MetadataCache,
        metrics: *ProducerMetrics,
    ) Self {
        return .{
            .accumulator = accumulator,
            .broker_pool = broker_pool,
            .metadata = metadata,
            .metrics = metrics,
        };
    }

    /// Start the sender background thread.
    pub fn start(self: *Self) !void {
        self.running.store(true, .release);
        self.thread = try std.Thread.spawn(.{}, senderLoop, .{self});
    }

    /// Stop the sender background thread.
    pub fn stop(self: *Self) void {
        self.running.store(false, .release);
        if (self.thread) |t| {
            t.join();
            self.thread = null;
        }
    }

    /// Run one iteration of the send loop (exposed for testing).
    pub fn runOnce(self: *Self, allocator: std.mem.Allocator) void {
        const now: i64 = @intCast(@import("ztime").milliTimestamp());
        const expired_count = self.accumulator.markExpired(now);

        if (expired_count > 0) {
            std.debug.print("[SENDER] Marked {d} batches as ready to send\n", .{expired_count});
        }

        // Drain all ready slots
        var slot_idx: u16 = 0;
        var sent_count: u16 = 0;
        while (slot_idx < RecordAccumulator.MAX_SLOTS) : (slot_idx += 1) {
            const slot = &self.accumulator.slots[slot_idx];
            if (slot.state != .ready) continue;

            std.debug.print("[SENDER] Sending batch for {s} partition {d}\n", .{ slot.topicName(), slot.partition });
            self.sendBatch(slot_idx, slot, allocator);
            sent_count += 1;
        }

        if (sent_count > 0) {
            std.debug.print("[SENDER] Sent {d} batches\n", .{sent_count});
        }
    }

    /// Poll for delivery reports. Returns count of reports consumed.
    pub fn pollDeliveryReports(self: *Self, callback: *const fn (*const DeliveryReport) void, max: u32) u32 {
        var count: u32 = 0;
        while (count < max) {
            const head = self.dr_head.load(.acquire);
            const tail = self.dr_tail.load(.acquire);
            if (head == tail) break; // Empty

            const report = &self.delivery_reports[head % DR_RING_SIZE];
            callback(report);

            self.dr_head.store((head + 1) % DR_RING_SIZE, .release);
            count += 1;
        }
        return count;
    }

    // ========================================================================
    // Internal
    // ========================================================================

    fn senderLoop(self: *Self) void {
        std.debug.print("[SENDER] Background thread started\n", .{});
        var iterations: u32 = 0;
        while (self.running.load(.acquire)) {
            iterations += 1;
            if (iterations % 1000 == 0) {
                std.debug.print("[SENDER] Still running, iteration {d}\n", .{iterations});
            }
            self.runOnce(std.heap.page_allocator);
            @import("ztime").sleepNs(1_000_000); // 1ms sleep between iterations
        }
        std.debug.print("[SENDER] Background thread stopped after {d} iterations\n", .{iterations});
    }

    fn sendBatch(self: *Self, slot_idx: u16, slot: *BatchSlot, allocator: std.mem.Allocator) void {
        const topic_name = slot.topicName();
        const partition = slot.partition;
        const start_ms = @import("ztime").milliTimestamp();

        // Assign sequence number if idempotence enabled
        if (self.sequence_manager) |seq_mgr| {
            const seq = seq_mgr.getNextSequence(topic_name, partition) catch |err| {
                std.debug.print("[SENDER] ERROR: Failed to get sequence: {any}\n", .{err});
                self.accumulator.completeSlot(slot_idx);
                return;
            };
            slot.base_sequence = seq;
        }

        // Set producer ID and epoch in batch builder before finalizing
        if (self.producer_id_manager) |pid_mgr| {
            var builder = slot.builder();
            builder.producer_id = pid_mgr.getProducerId();
            builder.producer_epoch = pid_mgr.getProducerEpoch();
            builder.base_sequence = slot.base_sequence;

            // Set transactional flag if in transaction
            if (self.transaction_coordinator) |txn| {
                if (txn.isInTransaction()) {
                    builder.attributes.is_transactional = 1;
                }
            }

            slot.saveBuilderState(&builder);
        }

        // Finalize the batch
        const batch_bytes = self.accumulator.drainSlot(slot_idx) orelse {
            self.accumulator.completeSlot(slot_idx);
            return;
        };

        // Find the leader for this partition
        const conn = self.broker_pool.getLeader(topic_name, partition) catch {
            // No leader available — report error
            self.metrics.recordConnectionError();
            self.metrics.recordBatchFailed();
            self.enqueueDR(topic_name, partition, -1, 5, 0); // LEADER_NOT_AVAILABLE
            self.accumulator.completeSlot(slot_idx);
            return;
        };

        // Build ProduceRequest with this single batch
        // For simplicity, we send one topic-partition per request.
        // A production sender would group by leader.
        var partition_data = [_]PartitionProduceData{
            .{
                .index = partition,
                .records = batch_bytes,
            },
        };

        var topic_data = [_]TopicProduceData{
            .{
                .name = topic_name,
                .partition_data = &partition_data,
            },
        };

        var req = ProduceRequest{
            .acks = self.acks,
            .timeout_ms = self.timeout_ms,
            .topic_data = &topic_data,
        };

        const resp_size = conn.sendRequest(0, self.produce_version, &req) catch |err| {
            std.debug.print("[SENDER] ERROR: sendRequest failed for {s}-{d}: {any}\n", .{ topic_name, partition, err });
            self.metrics.recordTimeoutError();
            self.metrics.recordBatchFailed();
            self.enqueueDR(topic_name, partition, -1, 7, 0); // REQUEST_TIMED_OUT
            self.accumulator.completeSlot(slot_idx);
            return;
        };
        std.debug.print("[SENDER] ProduceRequest sent, got response size={d}\n", .{resp_size});

        // Record latency before parsing
        const latency_ms: u64 = @intCast(@import("ztime").milliTimestamp() - start_ms);

        // Parse ProduceResponse and record metrics
        const success = self.parseProduceResponse(
            conn.recv_buf[0..resp_size],
            topic_name,
            partition,
            allocator,
        );

        if (success) {
            self.metrics.recordBatchSent(latency_ms);

            // Update sequence counter after successful send
            if (self.sequence_manager) |seq_mgr| {
                const count: i32 = @intCast(slot.record_count);
                seq_mgr.updateSequence(topic_name, partition, count) catch |err| {
                    std.debug.print("[SENDER] WARNING: Failed to update sequence: {any}\n", .{err});
                };
            }
        } else {
            self.metrics.recordBatchFailed();
        }

        self.accumulator.completeSlot(slot_idx);
    }

    fn parseProduceResponse(
        self: *Self,
        data: []const u8,
        topic_name: []const u8,
        partition: i32,
        allocator: std.mem.Allocator,
    ) bool {
        // Use arena allocator for response decoding (zero-leak principle)
        var arena = std.heap.ArenaAllocator.init(allocator);
        defer arena.deinit();

        // Skip 4-byte size prefix + response header
        const resp_header_ver = request_mod.responseHeaderVersion(0, self.produce_version);
        var stream = @import("ztime").fixedBufferStream(data[4..]);
        const reader = stream.reader();

        // Skip response header
        _ = types.decodeInt32(reader) catch {
            self.enqueueDR(topic_name, partition, -1, -1, 0);
            return false;
        };
        if (resp_header_ver >= 1) {
            // Skip tagged fields
            _ = types.decodeUnsignedVarInt(reader) catch {};
        }

        // Decode response body using arena (automatically freed)
        const resp = ProduceResponse.decode(reader, self.produce_version, arena.allocator()) catch {
            self.enqueueDR(topic_name, partition, -1, -1, 0);
            return false;
        };

        // Find our topic-partition in the response
        if (resp.responses) |responses| {
            for (responses) |topic_resp| {
                if (topic_resp.partition_responses) |part_resps| {
                    for (part_resps) |part_resp| {
                        if (part_resp.index == partition) {
                            self.enqueueDR(
                                topic_name,
                                partition,
                                part_resp.base_offset,
                                part_resp.error_code,
                                0,
                            );
                            return part_resp.error_code == 0;
                        }
                    }
                }
            }
        }

        // Partition not found in response
        self.enqueueDR(topic_name, partition, -1, -1, 0);
        return false;
    }

    fn enqueueDR(
        self: *Self,
        topic_name: []const u8,
        partition: i32,
        offset: i64,
        error_code: i16,
        latency_us: u64,
    ) void {
        const tail = self.dr_tail.load(.acquire);
        const next_tail = (tail + 1) % DR_RING_SIZE;
        const head = self.dr_head.load(.acquire);

        if (next_tail == head) return; // Ring full, drop report

        var dr = &self.delivery_reports[tail];
        dr.setTopic(topic_name);
        dr.partition = partition;
        dr.offset = offset;
        dr.error_code = error_code;
        dr.latency_us = latency_us;

        self.dr_tail.store(next_tail, .release);
    }
};

// ============================================================================
// Tests
// ============================================================================

test "Sender delivery report ring" {
    var acc = RecordAccumulator{};
    var cache = MetadataCache{};
    var pool = BrokerPool.init(std.testing.allocator);
    var metrics = ProducerMetrics{};
    var sender = Sender.init(&acc, &pool, &cache, &metrics);

    // Enqueue a DR manually
    sender.enqueueDR("test-topic", 0, 42, 0, 1500);

    const count = sender.pollDeliveryReports(&struct {
        fn cb(dr: *const DeliveryReport) void {
            _ = dr;
        }
    }.cb, 10);

    try std.testing.expectEqual(@as(u32, 1), count);
}

test "Sender init" {
    var acc = RecordAccumulator{};
    var cache = MetadataCache{};
    var pool = BrokerPool.init(std.testing.allocator);
    var metrics = ProducerMetrics{};
    var sender = Sender.init(&acc, &pool, &cache, &metrics);

    try std.testing.expectEqual(@as(i16, -1), sender.acks);
    try std.testing.expectEqual(false, sender.running.load(.acquire));
}

test "Sender delivery report ring overflow" {
    var acc = RecordAccumulator{};
    var cache = MetadataCache{};
    var pool = BrokerPool.init(std.testing.allocator);
    var metrics = ProducerMetrics{};
    var sender = Sender.init(&acc, &pool, &cache, &metrics);

    // Fill the ring completely
    var i: u32 = 0;
    while (i < Sender.DR_RING_SIZE - 1) : (i += 1) {
        sender.enqueueDR("topic", 0, @intCast(i), 0, 100);
    }

    // Ring is now full (tail + 1 == head)
    // Next enqueue should be silently dropped
    sender.enqueueDR("topic", 0, 9999, 0, 100);

    // Drain all
    var count: u32 = 0;
    count = sender.pollDeliveryReports(&struct {
        fn cb(dr: *const DeliveryReport) void {
            _ = dr;
        }
    }.cb, Sender.DR_RING_SIZE);

    try std.testing.expectEqual(@as(u32, Sender.DR_RING_SIZE - 1), count);
}

test "Sender delivery report FIFO ordering" {
    var acc = RecordAccumulator{};
    var cache = MetadataCache{};
    var pool = BrokerPool.init(std.testing.allocator);
    var metrics = ProducerMetrics{};
    var sender = Sender.init(&acc, &pool, &cache, &metrics);

    // Enqueue 5 DRs with distinct offsets
    sender.enqueueDR("t", 0, 100, 0, 0);
    sender.enqueueDR("t", 0, 200, 0, 0);
    sender.enqueueDR("t", 0, 300, 0, 0);
    sender.enqueueDR("t", 0, 400, 0, 0);
    sender.enqueueDR("t", 0, 500, 0, 0);

    const count = sender.pollDeliveryReports(&struct {
        var next_expected: i64 = 100;
        fn cb(dr: *const DeliveryReport) void {
            // Verify FIFO order via offsets
            std.testing.expectEqual(next_expected, dr.offset) catch unreachable;
            next_expected += 100;
        }
    }.cb, 10);

    try std.testing.expectEqual(@as(u32, 5), count);
}

test "Sender delivery report empty poll" {
    var acc = RecordAccumulator{};
    var cache = MetadataCache{};
    var pool = BrokerPool.init(std.testing.allocator);
    var metrics = ProducerMetrics{};
    var sender = Sender.init(&acc, &pool, &cache, &metrics);

    const count = sender.pollDeliveryReports(&struct {
        fn cb(dr: *const DeliveryReport) void {
            _ = dr;
        }
    }.cb, 100);

    try std.testing.expectEqual(@as(u32, 0), count);
}

test "Sender delivery report max limit" {
    var acc = RecordAccumulator{};
    var cache = MetadataCache{};
    var pool = BrokerPool.init(std.testing.allocator);
    var metrics = ProducerMetrics{};
    var sender = Sender.init(&acc, &pool, &cache, &metrics);

    // Enqueue 10
    var i: u32 = 0;
    while (i < 10) : (i += 1) {
        sender.enqueueDR("t", 0, @intCast(i), 0, 0);
    }

    // Poll with max=3
    var polled: u32 = 0;
    polled = sender.pollDeliveryReports(&struct {
        fn cb(dr: *const DeliveryReport) void {
            _ = dr;
        }
    }.cb, 3);
    try std.testing.expectEqual(@as(u32, 3), polled);

    // 7 should remain
    polled = sender.pollDeliveryReports(&struct {
        fn cb(dr: *const DeliveryReport) void {
            _ = dr;
        }
    }.cb, 100);
    try std.testing.expectEqual(@as(u32, 7), polled);
}

test "Sender runOnce with no ready batches" {
    var acc = RecordAccumulator{};
    var cache = MetadataCache{};
    var pool = BrokerPool.init(std.testing.allocator);
    var metrics = ProducerMetrics{};
    var sender = Sender.init(&acc, &pool, &cache, &metrics);

    // Should not crash with empty accumulator
    sender.runOnce(std.testing.allocator);
    try std.testing.expectEqual(@as(u16, 0), acc.pendingCount());
}

test "Sender delivery report topic preservation" {
    var acc = RecordAccumulator{};
    var cache = MetadataCache{};
    var pool = BrokerPool.init(std.testing.allocator);
    var metrics = ProducerMetrics{};
    var sender = Sender.init(&acc, &pool, &cache, &metrics);

    sender.enqueueDR("my-important-topic", 7, 42, 0, 5000);

    _ = sender.pollDeliveryReports(&struct {
        fn cb(dr: *const DeliveryReport) void {
            std.testing.expectEqualStrings("my-important-topic", dr.topic()) catch unreachable;
            std.testing.expectEqual(@as(i32, 7), dr.partition) catch unreachable;
            std.testing.expectEqual(@as(i64, 42), dr.offset) catch unreachable;
            std.testing.expectEqual(@as(u64, 5000), dr.latency_us) catch unreachable;
        }
    }.cb, 1);
}
