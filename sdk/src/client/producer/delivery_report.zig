const std = @import("std");

/// Delivery report returned to the application after a produce request completes.
///
/// Flows from the sender thread back to the application via a lock-free queue.
pub const DeliveryReport = struct {
    /// Topic name (points into pre-allocated topic name storage).
    topic_buf: [MAX_TOPIC_LEN]u8 = [_]u8{0} ** MAX_TOPIC_LEN,
    topic_len: u16 = 0,

    /// Partition the record was produced to.
    partition: i32 = -1,

    /// Offset assigned by the broker (-1 if acks=0 or error).
    offset: i64 = -1,

    /// Timestamp assigned by the broker (ms since epoch, -1 if unavailable).
    timestamp: i64 = -1,

    /// Kafka error code from the ProduceResponse (0 = success).
    error_code: i16 = 0,

    /// Latency from produce() call to broker acknowledgment (microseconds).
    latency_us: u64 = 0,

    /// Opaque user context passed through from produce() call.
    user_context: u64 = 0,

    pub const MAX_TOPIC_LEN = 249;

    pub fn topic(self: *const DeliveryReport) []const u8 {
        return self.topic_buf[0..self.topic_len];
    }

    pub fn isSuccess(self: *const DeliveryReport) bool {
        return self.error_code == 0;
    }

    pub fn setTopic(self: *DeliveryReport, name: []const u8) void {
        const len = @min(name.len, MAX_TOPIC_LEN);
        @memcpy(self.topic_buf[0..len], name[0..len]);
        self.topic_len = @intCast(len);
    }
};

// ============================================================================
// Tests
// ============================================================================

test "DeliveryReport basic" {
    var dr = DeliveryReport{};
    dr.setTopic("orders");
    dr.partition = 3;
    dr.offset = 42;
    dr.error_code = 0;
    dr.latency_us = 1500;

    try std.testing.expectEqualStrings("orders", dr.topic());
    try std.testing.expect(dr.isSuccess());
    try std.testing.expectEqual(@as(i32, 3), dr.partition);
    try std.testing.expectEqual(@as(i64, 42), dr.offset);
}

test "DeliveryReport error" {
    var dr = DeliveryReport{};
    dr.setTopic("test");
    dr.error_code = 7; // REQUEST_TIMED_OUT

    try std.testing.expect(!dr.isSuccess());
}

test "DeliveryReport long topic name truncation" {
    var dr = DeliveryReport{};
    var long_name: [300]u8 = undefined;
    @memset(&long_name, 'z');

    dr.setTopic(&long_name);
    // Should truncate to DeliveryReport.MAX_TOPIC_LEN
    try std.testing.expectEqual(@as(u16, DeliveryReport.MAX_TOPIC_LEN), dr.topic_len);
    try std.testing.expectEqual(@as(usize, DeliveryReport.MAX_TOPIC_LEN), dr.topic().len);
}

test "DeliveryReport setTopic overwrites" {
    var dr = DeliveryReport{};
    dr.setTopic("first-topic");
    try std.testing.expectEqualStrings("first-topic", dr.topic());

    dr.setTopic("second");
    try std.testing.expectEqualStrings("second", dr.topic());
}

test "DeliveryReport default values" {
    const dr = DeliveryReport{};
    try std.testing.expectEqual(@as(i32, -1), dr.partition);
    try std.testing.expectEqual(@as(i64, -1), dr.offset);
    try std.testing.expectEqual(@as(i64, -1), dr.timestamp);
    try std.testing.expectEqual(@as(i16, 0), dr.error_code);
    try std.testing.expectEqual(@as(u64, 0), dr.latency_us);
    try std.testing.expectEqual(@as(u64, 0), dr.user_context);
    try std.testing.expect(dr.isSuccess());
}

test "DeliveryReport user context" {
    var dr = DeliveryReport{};
    dr.user_context = 0xDEADBEEF;
    try std.testing.expectEqual(@as(u64, 0xDEADBEEF), dr.user_context);
}
