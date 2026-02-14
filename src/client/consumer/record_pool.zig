const std = @import("std");

/// Pre-allocated buffer pool for consumer records.
/// Follows TickStream's zero-allocation principle - all memory pre-allocated at init.
pub const RecordPool = struct {
    const Self = @This();

    /// Maximum number of records that can be in flight at once
    pub const MAX_RECORDS = 1024;

    /// Maximum size for a single key
    pub const MAX_KEY_SIZE = 1024;

    /// Maximum size for a single value
    pub const MAX_VALUE_SIZE = 1024 * 1024; // 1MB

    /// Storage for keys (heap-allocated to avoid stack overflow)
    key_buffers: *[MAX_RECORDS][MAX_KEY_SIZE]u8,

    /// Storage for values (heap-allocated to avoid stack overflow)
    value_buffers: *[MAX_RECORDS][MAX_VALUE_SIZE]u8,

    /// Actual key lengths (0 = null key)
    key_lengths: [MAX_RECORDS]u32 = [_]u32{0} ** MAX_RECORDS,

    /// Actual value lengths
    value_lengths: [MAX_RECORDS]u32 = [_]u32{0} ** MAX_RECORDS,

    /// Ring buffer head (next slot to allocate)
    head: std.atomic.Value(u32) = std.atomic.Value(u32).init(0),

    /// Ring buffer tail (next slot to free)
    tail: std.atomic.Value(u32) = std.atomic.Value(u32).init(0),

    /// Allocator for the buffer arrays (stored for deinit)
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) !Self {
        const keys = try allocator.create([MAX_RECORDS][MAX_KEY_SIZE]u8);
        errdefer allocator.destroy(keys);
        const values = try allocator.create([MAX_RECORDS][MAX_VALUE_SIZE]u8);

        return .{
            .key_buffers = keys,
            .value_buffers = values,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Self) void {
        self.allocator.destroy(self.key_buffers);
        self.allocator.destroy(self.value_buffers);
    }

    /// Allocate a record slot. Returns index or error if pool exhausted.
    pub fn alloc(self: *Self) !u32 {
        const h = self.head.load(.acquire);
        const next_head = (h + 1) % MAX_RECORDS;
        const t = self.tail.load(.acquire);

        if (next_head == t) {
            return error.RecordPoolExhausted;
        }

        self.head.store(next_head, .release);
        return h;
    }

    /// Store key in the allocated slot. Returns slice pointing to pool buffer.
    pub fn setKey(self: *Self, index: u32, key: ?[]const u8) ![]const u8 {
        if (index >= MAX_RECORDS) return error.InvalidIndex;

        if (key) |k| {
            if (k.len > MAX_KEY_SIZE) return error.KeyTooLarge;
            @memcpy(self.key_buffers[index][0..k.len], k);
            self.key_lengths[index] = @intCast(k.len);
            return self.key_buffers[index][0..k.len];
        } else {
            self.key_lengths[index] = 0;
            return &[_]u8{};
        }
    }

    /// Store value in the allocated slot. Returns slice pointing to pool buffer.
    pub fn setValue(self: *Self, index: u32, value: []const u8) ![]const u8 {
        if (index >= MAX_RECORDS) return error.InvalidIndex;
        if (value.len > MAX_VALUE_SIZE) return error.ValueTooLarge;

        @memcpy(self.value_buffers[index][0..value.len], value);
        self.value_lengths[index] = @intCast(value.len);
        return self.value_buffers[index][0..value.len];
    }

    /// Get key from slot (returns null if key_length == 0)
    pub fn getKey(self: *const Self, index: u32) ?[]const u8 {
        if (index >= MAX_RECORDS) return null;
        const len = self.key_lengths[index];
        if (len == 0) return null;
        return self.key_buffers[index][0..len];
    }

    /// Get value from slot
    pub fn getValue(self: *const Self, index: u32) ?[]const u8 {
        if (index >= MAX_RECORDS) return null;
        const len = self.value_lengths[index];
        if (len == 0) return null;
        return self.value_buffers[index][0..len];
    }

    /// Release all records up to count. Called when consumer is done with a batch.
    pub fn releaseAll(self: *Self, count: u32) void {
        const t = self.tail.load(.acquire);
        const new_tail = (t + count) % MAX_RECORDS;
        self.tail.store(new_tail, .release);
    }

    /// Get current pool usage (for debugging/monitoring)
    pub fn usage(self: *const Self) u32 {
        const h = self.head.load(.acquire);
        const t = self.tail.load(.acquire);
        if (h >= t) {
            return h - t;
        } else {
            return MAX_RECORDS - t + h;
        }
    }
};

// ============================================================================
// Tests
// ============================================================================

test "RecordPool basic allocation" {
    var pool = try RecordPool.init(std.testing.allocator);
    defer pool.deinit();

    const idx = try pool.alloc();
    try std.testing.expect(idx == 0);

    const key = try pool.setKey(idx, "test-key");
    try std.testing.expectEqualStrings("test-key", key);

    const value = try pool.setValue(idx, "test-value");
    try std.testing.expectEqualStrings("test-value", value);

    const retrieved_key = pool.getKey(idx).?;
    try std.testing.expectEqualStrings("test-key", retrieved_key);

    const retrieved_value = pool.getValue(idx).?;
    try std.testing.expectEqualStrings("test-value", retrieved_value);
}

test "RecordPool null key" {
    var pool = try RecordPool.init(std.testing.allocator);
    defer pool.deinit();

    const idx = try pool.alloc();
    _ = try pool.setKey(idx, null);
    _ = try pool.setValue(idx, "value");

    try std.testing.expect(pool.getKey(idx) == null);
    try std.testing.expectEqualStrings("value", pool.getValue(idx).?);
}

test "RecordPool release" {
    var pool = try RecordPool.init(std.testing.allocator);
    defer pool.deinit();

    // Allocate 3 records
    _ = try pool.alloc();
    _ = try pool.alloc();
    _ = try pool.alloc();

    try std.testing.expectEqual(@as(u32, 3), pool.usage());

    // Release 2 records
    pool.releaseAll(2);

    try std.testing.expectEqual(@as(u32, 1), pool.usage());
}

test "RecordPool exhaustion" {
    var pool = try RecordPool.init(std.testing.allocator);
    defer pool.deinit();

    // Fill the pool (leave one slot to distinguish full from empty)
    var i: u32 = 0;
    while (i < RecordPool.MAX_RECORDS - 1) : (i += 1) {
        _ = try pool.alloc();
    }

    // Next allocation should fail
    const result = pool.alloc();
    try std.testing.expectError(error.RecordPoolExhausted, result);
}

test "RecordPool key too large" {
    var pool = try RecordPool.init(std.testing.allocator);
    defer pool.deinit();
    const idx = try pool.alloc();

    const large_key = try std.testing.allocator.alloc(u8, RecordPool.MAX_KEY_SIZE + 1);
    defer std.testing.allocator.free(large_key);

    const result = pool.setKey(idx, large_key);
    try std.testing.expectError(error.KeyTooLarge, result);
}

test "RecordPool value too large" {
    var pool = try RecordPool.init(std.testing.allocator);
    defer pool.deinit();
    const idx = try pool.alloc();

    const large_value = try std.testing.allocator.alloc(u8, RecordPool.MAX_VALUE_SIZE + 1);
    defer std.testing.allocator.free(large_value);

    const result = pool.setValue(idx, large_value);
    try std.testing.expectError(error.ValueTooLarge, result);
}
