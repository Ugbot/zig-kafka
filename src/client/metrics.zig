const std = @import("std");

/// Producer metrics tracking.
pub const ProducerMetrics = struct {
    // Message counts
    messages_sent: std.atomic.Value(u64) = std.atomic.Value(u64).init(0),
    messages_failed: std.atomic.Value(u64) = std.atomic.Value(u64).init(0),

    // Byte counts
    bytes_sent: std.atomic.Value(u64) = std.atomic.Value(u64).init(0),

    // Batch metrics
    batches_sent: std.atomic.Value(u64) = std.atomic.Value(u64).init(0),
    batches_failed: std.atomic.Value(u64) = std.atomic.Value(u64).init(0),

    // Timing (in milliseconds)
    total_request_latency_ms: std.atomic.Value(u64) = std.atomic.Value(u64).init(0),
    max_request_latency_ms: std.atomic.Value(u64) = std.atomic.Value(u64).init(0),

    // Error counts
    connection_errors: std.atomic.Value(u64) = std.atomic.Value(u64).init(0),
    timeout_errors: std.atomic.Value(u64) = std.atomic.Value(u64).init(0),

    pub fn recordMessageSent(self: *ProducerMetrics, bytes: usize) void {
        _ = self.messages_sent.fetchAdd(1, .monotonic);
        _ = self.bytes_sent.fetchAdd(bytes, .monotonic);
    }

    pub fn recordMessageFailed(self: *ProducerMetrics) void {
        _ = self.messages_failed.fetchAdd(1, .monotonic);
    }

    pub fn recordBatchSent(self: *ProducerMetrics, latency_ms: u64) void {
        _ = self.batches_sent.fetchAdd(1, .monotonic);
        _ = self.total_request_latency_ms.fetchAdd(latency_ms, .monotonic);

        // Update max latency
        var current_max = self.max_request_latency_ms.load(.monotonic);
        while (latency_ms > current_max) {
            const prev = self.max_request_latency_ms.cmpxchgWeak(
                current_max,
                latency_ms,
                .monotonic,
                .monotonic,
            );
            if (prev == null) break;
            current_max = prev.?;
        }
    }

    pub fn recordBatchFailed(self: *ProducerMetrics) void {
        _ = self.batches_failed.fetchAdd(1, .monotonic);
    }

    pub fn recordConnectionError(self: *ProducerMetrics) void {
        _ = self.connection_errors.fetchAdd(1, .monotonic);
    }

    pub fn recordTimeoutError(self: *ProducerMetrics) void {
        _ = self.timeout_errors.fetchAdd(1, .monotonic);
    }

    pub fn getSnapshot(self: *const ProducerMetrics) ProducerMetricsSnapshot {
        const messages_sent = self.messages_sent.load(.monotonic);
        const batches_sent = self.batches_sent.load(.monotonic);
        const total_latency = self.total_request_latency_ms.load(.monotonic);

        return .{
            .messages_sent = messages_sent,
            .messages_failed = self.messages_failed.load(.monotonic),
            .bytes_sent = self.bytes_sent.load(.monotonic),
            .batches_sent = batches_sent,
            .batches_failed = self.batches_failed.load(.monotonic),
            .avg_request_latency_ms = if (batches_sent > 0) total_latency / batches_sent else 0,
            .max_request_latency_ms = self.max_request_latency_ms.load(.monotonic),
            .connection_errors = self.connection_errors.load(.monotonic),
            .timeout_errors = self.timeout_errors.load(.monotonic),
        };
    }

    pub fn reset(self: *ProducerMetrics) void {
        self.messages_sent.store(0, .monotonic);
        self.messages_failed.store(0, .monotonic);
        self.bytes_sent.store(0, .monotonic);
        self.batches_sent.store(0, .monotonic);
        self.batches_failed.store(0, .monotonic);
        self.total_request_latency_ms.store(0, .monotonic);
        self.max_request_latency_ms.store(0, .monotonic);
        self.connection_errors.store(0, .monotonic);
        self.timeout_errors.store(0, .monotonic);
    }
};

pub const ProducerMetricsSnapshot = struct {
    messages_sent: u64,
    messages_failed: u64,
    bytes_sent: u64,
    batches_sent: u64,
    batches_failed: u64,
    avg_request_latency_ms: u64,
    max_request_latency_ms: u64,
    connection_errors: u64,
    timeout_errors: u64,
};

/// Consumer metrics tracking.
pub const ConsumerMetrics = struct {
    // Message counts
    messages_consumed: std.atomic.Value(u64) = std.atomic.Value(u64).init(0),
    bytes_consumed: std.atomic.Value(u64) = std.atomic.Value(u64).init(0),

    // Fetch metrics
    fetch_requests: std.atomic.Value(u64) = std.atomic.Value(u64).init(0),
    fetch_errors: std.atomic.Value(u64) = std.atomic.Value(u64).init(0),

    // Timing
    total_fetch_latency_ms: std.atomic.Value(u64) = std.atomic.Value(u64).init(0),
    max_fetch_latency_ms: std.atomic.Value(u64) = std.atomic.Value(u64).init(0),

    // Offset management
    commits_total: std.atomic.Value(u64) = std.atomic.Value(u64).init(0),
    commits_failed: std.atomic.Value(u64) = std.atomic.Value(u64).init(0),

    // Consumer group coordination
    rebalances_total: std.atomic.Value(u64) = std.atomic.Value(u64).init(0),
    heartbeat_failures: std.atomic.Value(u64) = std.atomic.Value(u64).init(0),

    // Auto-seek events
    auto_seeks_earliest: std.atomic.Value(u64) = std.atomic.Value(u64).init(0),
    auto_seeks_latest: std.atomic.Value(u64) = std.atomic.Value(u64).init(0),

    pub fn recordMessagesConsumed(self: *ConsumerMetrics, count: usize, bytes: usize) void {
        _ = self.messages_consumed.fetchAdd(count, .monotonic);
        _ = self.bytes_consumed.fetchAdd(bytes, .monotonic);
    }

    pub fn recordFetchRequest(self: *ConsumerMetrics, latency_ms: u64) void {
        _ = self.fetch_requests.fetchAdd(1, .monotonic);
        _ = self.total_fetch_latency_ms.fetchAdd(latency_ms, .monotonic);

        // Update max latency
        var current_max = self.max_fetch_latency_ms.load(.monotonic);
        while (latency_ms > current_max) {
            const prev = self.max_fetch_latency_ms.cmpxchgWeak(
                current_max,
                latency_ms,
                .monotonic,
                .monotonic,
            );
            if (prev == null) break;
            current_max = prev.?;
        }
    }

    pub fn recordFetchError(self: *ConsumerMetrics) void {
        _ = self.fetch_errors.fetchAdd(1, .monotonic);
    }

    pub fn recordCommit(self: *ConsumerMetrics, success: bool) void {
        _ = self.commits_total.fetchAdd(1, .monotonic);
        if (!success) {
            _ = self.commits_failed.fetchAdd(1, .monotonic);
        }
    }

    pub fn recordRebalance(self: *ConsumerMetrics) void {
        _ = self.rebalances_total.fetchAdd(1, .monotonic);
    }

    pub fn recordHeartbeatFailure(self: *ConsumerMetrics) void {
        _ = self.heartbeat_failures.fetchAdd(1, .monotonic);
    }

    pub fn recordAutoSeek(self: *ConsumerMetrics, reset_policy: enum { earliest, latest }) void {
        switch (reset_policy) {
            .earliest => _ = self.auto_seeks_earliest.fetchAdd(1, .monotonic),
            .latest => _ = self.auto_seeks_latest.fetchAdd(1, .monotonic),
        }
    }

    pub fn getSnapshot(self: *const ConsumerMetrics) ConsumerMetricsSnapshot {
        const fetch_requests = self.fetch_requests.load(.monotonic);
        const total_latency = self.total_fetch_latency_ms.load(.monotonic);

        return .{
            .messages_consumed = self.messages_consumed.load(.monotonic),
            .bytes_consumed = self.bytes_consumed.load(.monotonic),
            .fetch_requests = fetch_requests,
            .fetch_errors = self.fetch_errors.load(.monotonic),
            .avg_fetch_latency_ms = if (fetch_requests > 0) total_latency / fetch_requests else 0,
            .max_fetch_latency_ms = self.max_fetch_latency_ms.load(.monotonic),
            .commits_total = self.commits_total.load(.monotonic),
            .commits_failed = self.commits_failed.load(.monotonic),
            .rebalances_total = self.rebalances_total.load(.monotonic),
            .heartbeat_failures = self.heartbeat_failures.load(.monotonic),
            .auto_seeks_earliest = self.auto_seeks_earliest.load(.monotonic),
            .auto_seeks_latest = self.auto_seeks_latest.load(.monotonic),
        };
    }

    pub fn reset(self: *ConsumerMetrics) void {
        self.messages_consumed.store(0, .monotonic);
        self.bytes_consumed.store(0, .monotonic);
        self.fetch_requests.store(0, .monotonic);
        self.fetch_errors.store(0, .monotonic);
        self.total_fetch_latency_ms.store(0, .monotonic);
        self.max_fetch_latency_ms.store(0, .monotonic);
        self.commits_total.store(0, .monotonic);
        self.commits_failed.store(0, .monotonic);
        self.rebalances_total.store(0, .monotonic);
        self.heartbeat_failures.store(0, .monotonic);
        self.auto_seeks_earliest.store(0, .monotonic);
        self.auto_seeks_latest.store(0, .monotonic);
    }
};

pub const ConsumerMetricsSnapshot = struct {
    messages_consumed: u64,
    bytes_consumed: u64,
    fetch_requests: u64,
    fetch_errors: u64,
    avg_fetch_latency_ms: u64,
    max_fetch_latency_ms: u64,
    commits_total: u64,
    commits_failed: u64,
    rebalances_total: u64,
    heartbeat_failures: u64,
    auto_seeks_earliest: u64,
    auto_seeks_latest: u64,
};

// ============================================================================
// Tests
// ============================================================================

test "ProducerMetrics basic operations" {
    var metrics = ProducerMetrics{};

    // Record some operations
    metrics.recordMessageSent(100);
    metrics.recordMessageSent(200);
    metrics.recordMessageFailed();

    metrics.recordBatchSent(50);
    metrics.recordBatchSent(100);

    const snapshot = metrics.getSnapshot();

    try std.testing.expectEqual(@as(u64, 2), snapshot.messages_sent);
    try std.testing.expectEqual(@as(u64, 1), snapshot.messages_failed);
    try std.testing.expectEqual(@as(u64, 300), snapshot.bytes_sent);
    try std.testing.expectEqual(@as(u64, 2), snapshot.batches_sent);
    try std.testing.expectEqual(@as(u64, 75), snapshot.avg_request_latency_ms);
    try std.testing.expectEqual(@as(u64, 100), snapshot.max_request_latency_ms);
}

test "ConsumerMetrics basic operations" {
    var metrics = ConsumerMetrics{};

    // Record some operations
    metrics.recordMessagesConsumed(10, 1000);
    metrics.recordMessagesConsumed(5, 500);

    metrics.recordFetchRequest(25);
    metrics.recordFetchRequest(75);
    metrics.recordFetchError();

    metrics.recordCommit(true);
    metrics.recordCommit(false);

    metrics.recordRebalance();
    metrics.recordAutoSeek(.earliest);
    metrics.recordAutoSeek(.latest);

    const snapshot = metrics.getSnapshot();

    try std.testing.expectEqual(@as(u64, 15), snapshot.messages_consumed);
    try std.testing.expectEqual(@as(u64, 1500), snapshot.bytes_consumed);
    try std.testing.expectEqual(@as(u64, 2), snapshot.fetch_requests);
    try std.testing.expectEqual(@as(u64, 1), snapshot.fetch_errors);
    try std.testing.expectEqual(@as(u64, 50), snapshot.avg_fetch_latency_ms);
    try std.testing.expectEqual(@as(u64, 75), snapshot.max_fetch_latency_ms);
    try std.testing.expectEqual(@as(u64, 2), snapshot.commits_total);
    try std.testing.expectEqual(@as(u64, 1), snapshot.commits_failed);
    try std.testing.expectEqual(@as(u64, 1), snapshot.rebalances_total);
    try std.testing.expectEqual(@as(u64, 1), snapshot.auto_seeks_earliest);
    try std.testing.expectEqual(@as(u64, 1), snapshot.auto_seeks_latest);
}

test "Metrics reset" {
    var metrics = ProducerMetrics{};

    metrics.recordMessageSent(100);
    metrics.recordBatchSent(50);

    var snapshot = metrics.getSnapshot();
    try std.testing.expectEqual(@as(u64, 1), snapshot.messages_sent);

    metrics.reset();

    snapshot = metrics.getSnapshot();
    try std.testing.expectEqual(@as(u64, 0), snapshot.messages_sent);
    try std.testing.expectEqual(@as(u64, 0), snapshot.bytes_sent);
    try std.testing.expectEqual(@as(u64, 0), snapshot.batches_sent);
}
