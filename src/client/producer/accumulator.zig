const std = @import("std");
const RecordBatchBuilder = @import("kafka_generated").record_batch.RecordBatchBuilder;

/// Per-partition record accumulator.
///
/// Fixed array of batch slots, each wrapping a RecordBatchBuilder.
/// Records are appended to the appropriate slot based on topic+partition.
/// When a slot is full or reaches linger time, it becomes "ready" for sending.
pub const RecordAccumulator = struct {
    const Self = @This();

    /// Batch slots (fixed capacity, no HashMap).
    slots: [MAX_SLOTS]BatchSlot = [_]BatchSlot{BatchSlot{}} ** MAX_SLOTS,

    /// Configured max batch size (bytes).
    max_batch_bytes: u32 = 16_384,

    /// Configured linger time (ms).
    linger_ms: u32 = 5,

    pub const MAX_SLOTS = 32;

    /// Append a record to the appropriate batch slot.
    /// Returns the slot index, or error if no slot is available.
    pub fn append(
        self: *Self,
        topic: []const u8,
        partition: i32,
        key: ?[]const u8,
        value: []const u8,
        timestamp_ms: i64,
    ) !u16 {
        // Find existing slot for this topic+partition
        for (&self.slots, 0..) |*slot, i| {
            if (slot.state == .active and
                slot.partition == partition and
                std.mem.eql(u8, slot.topicName(), topic))
            {
                // Check if batch has space
                const record_overhead = estimateRecordSize(key, value);
                if (slot.bytes_written + record_overhead > self.max_batch_bytes) {
                    // Mark as ready (full) and try to find a new slot
                    slot.state = .ready;
                } else {
                    // Append to existing batch
                    var builder = slot.builder();
                    builder.addRecord(key, value, timestamp_ms) catch {
                        slot.state = .ready;
                        // Fall through to allocate new slot
                        continue;
                    };
                    slot.saveBuilderState(&builder);
                    slot.record_count += 1;
                    return @intCast(i);
                }
            }
        }

        // Allocate a new slot
        for (&self.slots, 0..) |*slot, i| {
            if (slot.state == .empty) {
                slot.reset(topic, partition, timestamp_ms);
                var builder = slot.builder();
                builder.addRecord(key, value, timestamp_ms) catch return error.RecordTooLarge;
                slot.saveBuilderState(&builder);
                slot.record_count = 1;
                slot.state = .active;
                return @intCast(i);
            }
        }

        return error.AccumulatorFull;
    }

    /// Get all slots that are ready to send (either full or lingered).
    /// Returns count of ready slots found. Caller should iterate slots
    /// and check state == .ready.
    pub fn markExpired(self: *Self, now_ms: i64) u16 {
        var count: u16 = 0;
        for (&self.slots) |*slot| {
            if (slot.state == .active) {
                if (now_ms - slot.create_time_ms >= self.linger_ms) {
                    slot.state = .ready;
                    count += 1;
                }
            } else if (slot.state == .ready) {
                count += 1;
            }
        }
        return count;
    }

    /// Get a slot's finalized batch bytes and mark it as sending.
    /// Returns null if the slot is not ready.
    pub fn drainSlot(self: *Self, slot_idx: u16) ?[]const u8 {
        if (slot_idx >= MAX_SLOTS) return null;
        var slot = &self.slots[slot_idx];
        if (slot.state != .ready) return null;

        var builder = slot.builder();
        const batch = builder.finalize() catch return null;
        slot.state = .sending;
        return batch;
    }

    /// Mark a slot as complete (acked or failed). Reclaims the slot.
    pub fn completeSlot(self: *Self, slot_idx: u16) void {
        if (slot_idx >= MAX_SLOTS) return;
        self.slots[slot_idx].state = .empty;
    }

    /// Count of active + ready slots.
    pub fn pendingCount(self: *const Self) u16 {
        var count: u16 = 0;
        for (&self.slots) |*slot| {
            if (slot.state == .active or slot.state == .ready or slot.state == .sending) {
                count += 1;
            }
        }
        return count;
    }

    fn estimateRecordSize(key: ?[]const u8, value: []const u8) u32 {
        var size: u32 = 20; // overhead (varint sizes, attributes, headers count, etc.)
        if (key) |k| size += @intCast(k.len);
        size += @intCast(value.len);
        return size;
    }
};

/// A single batch slot in the accumulator.
pub const BatchSlot = struct {
    /// Topic name storage.
    topic_buf: [MAX_TOPIC_LEN]u8 = [_]u8{0} ** MAX_TOPIC_LEN,
    topic_len: u16 = 0,

    /// Partition this batch targets.
    partition: i32 = -1,

    /// Batch buffer (pre-allocated).
    batch_buf: [BATCH_BUFFER_SIZE]u8 = undefined,

    /// RecordBatchBuilder state (reconstructible from batch_buf).
    batch_pos: usize = 61, // Default to records_start
    batch_record_count: i32 = 0,
    batch_last_offset_delta: i32 = 0,
    batch_base_timestamp: i64 = 0,
    batch_max_timestamp: i64 = 0,

    /// Bytes written so far.
    bytes_written: u32 = 0,

    /// Number of records in this batch.
    record_count: u32 = 0,

    /// Timestamp when this batch was created.
    create_time_ms: i64 = 0,

    /// Base sequence number for this batch (for idempotent/transactional producers).
    /// Set by sender before draining. -1 = not assigned yet.
    base_sequence: i32 = -1,

    /// Slot state.
    state: State = .empty,

    pub const MAX_TOPIC_LEN = 249;
    pub const BATCH_BUFFER_SIZE = 65_536; // 64KB per batch slot

    pub const State = enum {
        /// Slot is free.
        empty,
        /// Actively accumulating records.
        active,
        /// Ready to be sent (full or lingered).
        ready,
        /// Currently being sent to broker.
        sending,
    };

    pub fn topicName(self: *const BatchSlot) []const u8 {
        return self.topic_buf[0..self.topic_len];
    }

    pub fn reset(self: *BatchSlot, topic: []const u8, partition: i32, timestamp_ms: i64) void {
        const len = @min(topic.len, MAX_TOPIC_LEN);
        @memcpy(self.topic_buf[0..len], topic[0..len]);
        self.topic_len = @intCast(len);
        self.partition = partition;
        self.bytes_written = 61; // Header size
        self.record_count = 0;
        self.create_time_ms = timestamp_ms;
        self.base_sequence = -1; // Assigned by sender
        self.state = .empty;

        // Initialize the builder state
        self.batch_pos = 61;
        self.batch_record_count = 0;
        self.batch_last_offset_delta = 0;
        self.batch_base_timestamp = timestamp_ms;
        self.batch_max_timestamp = timestamp_ms;
    }

    /// Save builder state back to this slot after addRecord.
    pub fn saveBuilderState(self: *BatchSlot, b: *const RecordBatchBuilder) void {
        self.batch_pos = b.pos;
        self.batch_record_count = b.record_count;
        self.batch_last_offset_delta = b.last_offset_delta;
        self.batch_max_timestamp = b.max_timestamp;
        self.bytes_written = @intCast(b.pos);
    }

    /// Reconstruct a RecordBatchBuilder pointing at this slot's buffer.
    pub fn builder(self: *BatchSlot) RecordBatchBuilder {
        return .{
            .buffer = &self.batch_buf,
            .batch_start = 0,
            .records_start = 61,
            .pos = self.batch_pos,
            .base_offset = 0, // Broker assigns offset
            .partition_leader_epoch = 0,
            .base_timestamp = self.batch_base_timestamp,
            .attributes = .{
                .compression = .none,
                .timestamp_type = 0,
                .is_transactional = 0,
                .is_control_batch = 0,
                .has_delete_horizon_ms = 0,
            },
            .record_count = self.batch_record_count,
            .last_offset_delta = self.batch_last_offset_delta,
            .max_timestamp = self.batch_max_timestamp,
            .producer_id = -1, // Set by sender
            .producer_epoch = -1, // Set by sender
            .base_sequence = self.base_sequence, // From slot
        };
    }
};

// ============================================================================
// Tests
// ============================================================================

test "RecordAccumulator basic append" {
    var acc = RecordAccumulator{};
    acc.max_batch_bytes = 64_000;

    const now: i64 = @intCast(std.time.milliTimestamp());
    const slot_idx = try acc.append("test-topic", 0, "key1", "value1", now);
    try std.testing.expect(slot_idx < RecordAccumulator.MAX_SLOTS);
    try std.testing.expectEqual(@as(u16, 1), acc.pendingCount());
}

test "RecordAccumulator same partition reuses slot" {
    var acc = RecordAccumulator{};
    acc.max_batch_bytes = 64_000;

    const now: i64 = @intCast(std.time.milliTimestamp());
    const idx1 = try acc.append("topic", 0, "k1", "v1", now);
    const idx2 = try acc.append("topic", 0, "k2", "v2", now);

    try std.testing.expectEqual(idx1, idx2);
    try std.testing.expectEqual(@as(u16, 1), acc.pendingCount());
}

test "RecordAccumulator different partitions use different slots" {
    var acc = RecordAccumulator{};
    acc.max_batch_bytes = 64_000;

    const now: i64 = @intCast(std.time.milliTimestamp());
    const idx1 = try acc.append("topic", 0, "k1", "v1", now);
    const idx2 = try acc.append("topic", 1, "k2", "v2", now);

    try std.testing.expect(idx1 != idx2);
    try std.testing.expectEqual(@as(u16, 2), acc.pendingCount());
}

test "RecordAccumulator markExpired" {
    var acc = RecordAccumulator{};
    acc.max_batch_bytes = 64_000;
    acc.linger_ms = 10;

    const past: i64 = @intCast(std.time.milliTimestamp() - 100);
    _ = try acc.append("topic", 0, "k", "v", past);

    const now: i64 = @intCast(std.time.milliTimestamp());
    const ready = acc.markExpired(now);
    try std.testing.expectEqual(@as(u16, 1), ready);
    try std.testing.expectEqual(BatchSlot.State.ready, acc.slots[0].state);
}

test "RecordAccumulator complete slot" {
    var acc = RecordAccumulator{};
    acc.max_batch_bytes = 64_000;

    const now: i64 = @intCast(std.time.milliTimestamp());
    const idx = try acc.append("topic", 0, "k", "v", now);
    try std.testing.expectEqual(@as(u16, 1), acc.pendingCount());

    acc.completeSlot(idx);
    try std.testing.expectEqual(@as(u16, 0), acc.pendingCount());
}

test "RecordAccumulator slot exhaustion" {
    var acc = RecordAccumulator{};
    acc.max_batch_bytes = 64_000;

    const now: i64 = @intCast(std.time.milliTimestamp());

    // Fill all slots with different partitions
    var i: i32 = 0;
    while (i < RecordAccumulator.MAX_SLOTS) : (i += 1) {
        _ = try acc.append("topic", i, "k", "v", now);
    }
    try std.testing.expectEqual(@as(u16, RecordAccumulator.MAX_SLOTS), acc.pendingCount());

    // Next append should fail — no free slots
    const result = acc.append("topic", @intCast(RecordAccumulator.MAX_SLOTS), "k", "v", now);
    try std.testing.expectError(error.AccumulatorFull, result);
}

test "RecordAccumulator drain and complete cycle" {
    var acc = RecordAccumulator{};
    acc.max_batch_bytes = 64_000;

    const now: i64 = @intCast(std.time.milliTimestamp());
    const idx = try acc.append("topic", 0, "k", "value-data", now);

    // Not ready yet
    try std.testing.expectEqual(@as(?[]const u8, null), acc.drainSlot(idx));

    // Mark as ready
    acc.slots[idx].state = .ready;

    // Drain should return batch bytes
    const batch = acc.drainSlot(idx);
    try std.testing.expect(batch != null);
    try std.testing.expect(batch.?.len > 0);

    // Slot should now be in sending state
    try std.testing.expect(acc.slots[idx].state == .sending);

    // Complete returns it to empty
    acc.completeSlot(idx);
    try std.testing.expect(acc.slots[idx].state == .empty);
    try std.testing.expectEqual(@as(u16, 0), acc.pendingCount());
}

test "RecordAccumulator multiple records same batch" {
    var acc = RecordAccumulator{};
    acc.max_batch_bytes = 64_000;

    const now: i64 = @intCast(std.time.milliTimestamp());
    _ = try acc.append("topic", 0, "k1", "v1", now);
    _ = try acc.append("topic", 0, "k2", "v2", now);
    _ = try acc.append("topic", 0, "k3", "v3", now);

    // Should all be in one slot
    try std.testing.expectEqual(@as(u16, 1), acc.pendingCount());
    try std.testing.expectEqual(@as(u32, 3), acc.slots[0].record_count);
}

test "RecordAccumulator batch full triggers new slot" {
    var acc = RecordAccumulator{};
    acc.max_batch_bytes = 100; // Very small batch to force overflow

    const now: i64 = @intCast(std.time.milliTimestamp());

    // First record fits
    const idx1 = try acc.append("topic", 0, "k1", "value-that-is-large-enough", now);

    // Second record should overflow, causing first slot to become ready
    // and a new slot to be allocated
    const idx2 = try acc.append("topic", 0, "k2", "another-large-value-here", now);

    // Should have 2 slots now (first is ready, second is active)
    try std.testing.expect(idx1 != idx2 or acc.slots[idx1].state == .ready);
    try std.testing.expect(acc.pendingCount() >= 1);
}

test "RecordAccumulator null key" {
    var acc = RecordAccumulator{};
    acc.max_batch_bytes = 64_000;

    const now: i64 = @intCast(std.time.milliTimestamp());
    const idx = try acc.append("topic", 0, null, "value-only", now);
    try std.testing.expect(idx < RecordAccumulator.MAX_SLOTS);
    try std.testing.expectEqual(@as(u32, 1), acc.slots[idx].record_count);
}

test "RecordAccumulator markExpired does not touch empty slots" {
    var acc = RecordAccumulator{};
    acc.linger_ms = 0; // Expire immediately

    const now: i64 = @intCast(std.time.milliTimestamp());
    const ready = acc.markExpired(now);
    try std.testing.expectEqual(@as(u16, 0), ready);
}

test "RecordAccumulator drainSlot out of range" {
    var acc = RecordAccumulator{};
    try std.testing.expectEqual(@as(?[]const u8, null), acc.drainSlot(RecordAccumulator.MAX_SLOTS));
    try std.testing.expectEqual(@as(?[]const u8, null), acc.drainSlot(RecordAccumulator.MAX_SLOTS + 1));
}

test "RecordAccumulator completeSlot out of range" {
    var acc = RecordAccumulator{};
    // Should not crash
    acc.completeSlot(RecordAccumulator.MAX_SLOTS);
    acc.completeSlot(RecordAccumulator.MAX_SLOTS + 1);
}

test "RecordAccumulator topic name stored correctly" {
    var acc = RecordAccumulator{};
    acc.max_batch_bytes = 64_000;

    const now: i64 = @intCast(std.time.milliTimestamp());
    const idx = try acc.append("my-test-topic", 0, "k", "v", now);
    try std.testing.expectEqualStrings("my-test-topic", acc.slots[idx].topicName());
}

test "RecordAccumulator different topics different slots" {
    var acc = RecordAccumulator{};
    acc.max_batch_bytes = 64_000;

    const now: i64 = @intCast(std.time.milliTimestamp());
    const idx1 = try acc.append("topic-a", 0, "k", "v", now);
    const idx2 = try acc.append("topic-b", 0, "k", "v", now);

    try std.testing.expect(idx1 != idx2);
    try std.testing.expectEqual(@as(u16, 2), acc.pendingCount());
}

test "RecordAccumulator drain produces valid RecordBatch" {
    var acc = RecordAccumulator{};
    acc.max_batch_bytes = 64_000;

    const now: i64 = @intCast(std.time.milliTimestamp());
    const idx = try acc.append("topic", 0, "key", "value", now);
    _ = try acc.append("topic", 0, "key2", "value2", now);

    // Mark ready and drain
    acc.slots[idx].state = .ready;
    const batch = acc.drainSlot(idx).?;

    // Verify it's a valid RecordBatch
    // Magic byte = 2
    try std.testing.expectEqual(@as(u8, 2), batch[16]);
    // Record count = 2
    const count = std.mem.readInt(i32, batch[57..61], .big);
    try std.testing.expectEqual(@as(i32, 2), count);
    // CRC integrity
    const stored_crc = std.mem.readInt(u32, batch[17..21], .big);
    const crc32c = @import("kafka_generated").record_batch.crc32c;
    const computed_crc = crc32c(batch[21..]);
    try std.testing.expectEqual(stored_crc, computed_crc);
}

test "RecordAccumulator slot reuse after complete" {
    var acc = RecordAccumulator{};
    acc.max_batch_bytes = 64_000;

    const now: i64 = @intCast(std.time.milliTimestamp());

    // Fill a slot
    const idx1 = try acc.append("topic", 0, "k", "v", now);
    acc.slots[idx1].state = .ready;
    _ = acc.drainSlot(idx1);
    acc.completeSlot(idx1);

    // Same slot should be reusable
    const idx2 = try acc.append("topic", 0, "k2", "v2", now);
    try std.testing.expectEqual(idx1, idx2);
}

test "RecordAccumulator state transitions" {
    var acc = RecordAccumulator{};
    acc.max_batch_bytes = 64_000;

    const now: i64 = @intCast(std.time.milliTimestamp());
    const idx = try acc.append("topic", 0, "k", "v", now);

    // Verify state: active
    try std.testing.expect(acc.slots[idx].state == .active);

    // Transition to ready (via markExpired or explicit)
    acc.slots[idx].state = .ready;
    try std.testing.expect(acc.slots[idx].state == .ready);

    // Drain transitions to sending
    _ = acc.drainSlot(idx);
    try std.testing.expect(acc.slots[idx].state == .sending);

    // Complete transitions to empty
    acc.completeSlot(idx);
    try std.testing.expect(acc.slots[idx].state == .empty);
}

test "RecordAccumulator markExpired counts ready slots" {
    var acc = RecordAccumulator{};
    acc.max_batch_bytes = 64_000;
    acc.linger_ms = 0; // Expire immediately

    const past: i64 = 1000; // Far in the past
    _ = try acc.append("t1", 0, "k", "v", past);
    _ = try acc.append("t2", 0, "k", "v", past);
    _ = try acc.append("t3", 0, "k", "v", past);

    const now: i64 = @intCast(std.time.milliTimestamp());
    const ready = acc.markExpired(now);
    try std.testing.expectEqual(@as(u16, 3), ready);
}

test "RecordAccumulator long topic name truncation" {
    var acc = RecordAccumulator{};
    acc.max_batch_bytes = 64_000;

    // Topic name exactly at limit (249 chars)
    var long_name: [249]u8 = undefined;
    @memset(&long_name, 'x');

    const now: i64 = @intCast(std.time.milliTimestamp());
    const idx = try acc.append(&long_name, 0, "k", "v", now);
    try std.testing.expectEqual(@as(u16, 249), acc.slots[idx].topic_len);
    try std.testing.expectEqualSlices(u8, &long_name, acc.slots[idx].topicName());
}

test "RecordAccumulator pendingCount reflects all non-empty states" {
    var acc = RecordAccumulator{};
    acc.max_batch_bytes = 64_000;

    const now: i64 = @intCast(std.time.milliTimestamp());
    _ = try acc.append("t1", 0, "k", "v", now);
    _ = try acc.append("t2", 0, "k", "v", now);

    // One active, one ready
    acc.slots[1].state = .ready;
    try std.testing.expectEqual(@as(u16, 2), acc.pendingCount());

    // Mark one as sending
    _ = acc.drainSlot(1);
    try std.testing.expectEqual(@as(u16, 2), acc.pendingCount()); // sending still counts
}

test "RecordAccumulator batch slot reset clears state" {
    var slot = BatchSlot{};
    slot.reset("test-topic", 5, 12345);

    try std.testing.expectEqualStrings("test-topic", slot.topicName());
    try std.testing.expectEqual(@as(i32, 5), slot.partition);
    try std.testing.expectEqual(@as(i64, 12345), slot.create_time_ms);
    try std.testing.expectEqual(@as(u32, 0), slot.record_count);
    try std.testing.expect(slot.state == .empty);
}
