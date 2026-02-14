const std = @import("std");

/// Client-level configuration for connecting to a Kafka cluster.
pub const ClientConfig = struct {
    /// Bootstrap broker addresses (host:port pairs).
    /// At least one must be provided. Max 64 brokers.
    bootstrap_servers: []const BrokerAddress = &.{},

    /// Client identifier sent in every request header.
    client_id: []const u8 = "tickstream-zig-client",

    /// Timeout for establishing a TCP connection to a broker (ms).
    connection_timeout_ms: u32 = 30_000,

    /// Timeout for individual request/response round-trips (ms).
    request_timeout_ms: u32 = 30_000,

    /// Interval between metadata refresh requests (ms).
    metadata_max_age_ms: u32 = 300_000,

    /// Size of send buffer per broker connection (bytes).
    send_buffer_bytes: u32 = 1_048_576, // 1MB

    /// Size of receive buffer per broker connection (bytes).
    recv_buffer_bytes: u32 = 1_048_576, // 1MB

    /// Maximum number of in-flight requests per broker connection.
    max_in_flight_requests: u32 = 5,

    /// Retry backoff base (ms). Actual backoff is base * 2^attempt with jitter.
    retry_backoff_ms: u32 = 100,

    /// Maximum retry backoff (ms).
    retry_backoff_max_ms: u32 = 10_000,

    /// Maximum number of retries for retriable errors.
    retries: u32 = 2_147_483_647, // INT32_MAX (effectively infinite)

    /// SASL mechanism (null = no auth).
    sasl_mechanism: ?SaslMechanism = null,

    /// SASL username (PLAIN/SCRAM).
    sasl_username: ?[]const u8 = null,

    /// SASL password (PLAIN/SCRAM).
    sasl_password: ?[]const u8 = null,

    /// SASL OAUTHBEARER token (static; for dynamic tokens use a callback in the future).
    sasl_oauth_token: ?[]const u8 = null,

    /// Enable TLS for broker connections.
    tls_enabled: bool = false,
};

/// Producer-specific configuration.
pub const ProducerConfig = struct {
    /// Number of acknowledgments required.
    /// 0 = fire-and-forget, 1 = leader only, -1 = full ISR.
    acks: i16 = -1,

    /// Maximum time to wait for acks from the broker (ms).
    request_timeout_ms: u32 = 30_000,

    /// Maximum time to buffer records before sending a batch (ms).
    linger_ms: u32 = 5,

    /// Maximum size of a single request (bytes).
    max_request_size: u32 = 1_048_576, // 1MB

    /// Maximum size of a single record batch per partition (bytes).
    batch_size: u32 = 16_384, // 16KB

    /// Compression codec for record batches.
    compression_type: CompressionType = .none,

    /// Enable idempotent producer (requires acks=-1).
    enable_idempotence: bool = false,

    /// Transactional ID (null = non-transactional).
    transactional_id: ?[]const u8 = null,

    /// Transaction timeout (ms). Only used when transactional_id is set.
    transaction_timeout_ms: u32 = 60_000,

    /// Maximum number of batch slots in the accumulator.
    /// Each topic-partition pair uses one slot.
    max_batch_slots: u16 = 256,

    /// Maximum time to wait for delivery reports during flush (ms).
    flush_timeout_ms: u32 = 60_000,

    /// Partitioner strategy.
    partitioner: PartitionerType = .murmur2,
};

/// Consumer-specific configuration.
pub const ConsumerConfig = struct {
    /// Consumer group ID (null = no group coordination).
    group_id: ?[]const u8 = null,

    /// Group instance ID for static membership (null = dynamic).
    group_instance_id: ?[]const u8 = null,

    /// Session timeout for group membership (ms).
    session_timeout_ms: u32 = 45_000,

    /// Heartbeat interval within a consumer group (ms).
    heartbeat_interval_ms: u32 = 3_000,

    /// Maximum time between poll() calls before the consumer is considered dead (ms).
    max_poll_interval_ms: u32 = 300_000,

    /// Maximum number of records returned per poll().
    max_poll_records: u32 = 500,

    /// Maximum bytes to fetch per partition per request.
    max_partition_fetch_bytes: u32 = 1_048_576, // 1MB

    /// Minimum bytes the broker should return (can wait until this much data is available).
    fetch_min_bytes: u32 = 1,

    /// Maximum bytes the broker should return per fetch.
    fetch_max_bytes: u32 = 52_428_800, // 50MB

    /// Maximum time the broker waits for fetch_min_bytes (ms).
    fetch_max_wait_ms: u32 = 500,

    /// What to do when there is no initial offset or the offset is out of range.
    auto_offset_reset: AutoOffsetReset = .latest,

    /// Enable automatic periodic offset commits.
    enable_auto_commit: bool = true,

    /// Frequency of automatic offset commits (ms).
    auto_commit_interval_ms: u32 = 5_000,

    /// Partition assignment strategy.
    assignment_strategy: AssignmentStrategy = .range,
};

/// Broker network address.
pub const BrokerAddress = struct {
    host: []const u8,
    port: u16 = 9092,
};

/// SASL authentication mechanisms.
pub const SaslMechanism = enum {
    plain,
    scram_sha_256,
    scram_sha_512,
    oauthbearer,
};

/// Record batch compression codecs.
pub const CompressionType = enum(u3) {
    none = 0,
    gzip = 1,
    snappy = 2,
    lz4 = 3,
    zstd = 4,
};

/// Partitioner strategies.
pub const PartitionerType = enum {
    /// Kafka-compatible Murmur2 hash (matches Java client).
    murmur2,
    /// Round-robin across partitions.
    round_robin,
    /// Sticky partitioner (batch to same partition until full).
    sticky,
};

/// Consumer auto-offset-reset policy.
pub const AutoOffsetReset = enum {
    earliest,
    latest,
    none,
};

/// Consumer group partition assignment strategy.
pub const AssignmentStrategy = enum {
    range,
    round_robin,
    sticky,
};

// ============================================================================
// Tests
// ============================================================================

test "ClientConfig defaults" {
    const cfg = ClientConfig{};
    try std.testing.expectEqual(@as(u32, 30_000), cfg.connection_timeout_ms);
    try std.testing.expectEqual(@as(u32, 1_048_576), cfg.send_buffer_bytes);
    try std.testing.expectEqual(false, cfg.tls_enabled);
    try std.testing.expectEqual(@as(?SaslMechanism, null), cfg.sasl_mechanism);
    try std.testing.expectEqualStrings("tickstream-zig-client", cfg.client_id);
}

test "ProducerConfig defaults" {
    const cfg = ProducerConfig{};
    try std.testing.expectEqual(@as(i16, -1), cfg.acks);
    try std.testing.expectEqual(@as(u32, 5), cfg.linger_ms);
    try std.testing.expectEqual(@as(u32, 16_384), cfg.batch_size);
    try std.testing.expectEqual(CompressionType.none, cfg.compression_type);
    try std.testing.expectEqual(false, cfg.enable_idempotence);
    try std.testing.expectEqual(PartitionerType.murmur2, cfg.partitioner);
}

test "ConsumerConfig defaults" {
    const cfg = ConsumerConfig{};
    try std.testing.expectEqual(@as(u32, 45_000), cfg.session_timeout_ms);
    try std.testing.expectEqual(@as(u32, 3_000), cfg.heartbeat_interval_ms);
    try std.testing.expectEqual(AutoOffsetReset.latest, cfg.auto_offset_reset);
    try std.testing.expectEqual(true, cfg.enable_auto_commit);
    try std.testing.expectEqual(AssignmentStrategy.range, cfg.assignment_strategy);
}

test "ClientConfig with bootstrap servers" {
    const servers = [_]BrokerAddress{
        .{ .host = "broker-1", .port = 9092 },
        .{ .host = "broker-2", .port = 9093 },
        .{ .host = "broker-3", .port = 9094 },
    };
    const cfg = ClientConfig{
        .bootstrap_servers = &servers,
        .client_id = "my-app",
    };
    try std.testing.expectEqual(@as(usize, 3), cfg.bootstrap_servers.len);
    try std.testing.expectEqualStrings("broker-1", cfg.bootstrap_servers[0].host);
    try std.testing.expectEqual(@as(u16, 9093), cfg.bootstrap_servers[1].port);
}

test "ProducerConfig acks validation" {
    // acks=0 (fire-and-forget)
    const cfg0 = ProducerConfig{ .acks = 0 };
    try std.testing.expectEqual(@as(i16, 0), cfg0.acks);

    // acks=1 (leader only)
    const cfg1 = ProducerConfig{ .acks = 1 };
    try std.testing.expectEqual(@as(i16, 1), cfg1.acks);

    // acks=-1 (full ISR, default)
    const cfg_all = ProducerConfig{};
    try std.testing.expectEqual(@as(i16, -1), cfg_all.acks);
}

test "ProducerConfig idempotence" {
    const cfg = ProducerConfig{
        .enable_idempotence = true,
        .acks = -1,
    };
    try std.testing.expect(cfg.enable_idempotence);
    try std.testing.expectEqual(@as(i16, -1), cfg.acks);
}

test "ProducerConfig transactional" {
    const cfg = ProducerConfig{
        .transactional_id = "my-txn-id",
        .enable_idempotence = true,
        .acks = -1,
        .transaction_timeout_ms = 120_000,
    };
    try std.testing.expectEqualStrings("my-txn-id", cfg.transactional_id.?);
    try std.testing.expectEqual(@as(u32, 120_000), cfg.transaction_timeout_ms);
}

test "ConsumerConfig with group" {
    const cfg = ConsumerConfig{
        .group_id = "my-consumer-group",
        .session_timeout_ms = 30_000,
        .auto_offset_reset = .earliest,
        .enable_auto_commit = false,
    };
    try std.testing.expectEqualStrings("my-consumer-group", cfg.group_id.?);
    try std.testing.expectEqual(AutoOffsetReset.earliest, cfg.auto_offset_reset);
    try std.testing.expect(!cfg.enable_auto_commit);
}

test "ConsumerConfig static membership" {
    const cfg = ConsumerConfig{
        .group_id = "group",
        .group_instance_id = "instance-1",
    };
    try std.testing.expectEqualStrings("instance-1", cfg.group_instance_id.?);
}

test "ClientConfig SASL configuration" {
    const cfg = ClientConfig{
        .sasl_mechanism = .scram_sha_256,
        .sasl_username = "user",
        .sasl_password = "pass",
    };
    try std.testing.expectEqual(SaslMechanism.scram_sha_256, cfg.sasl_mechanism.?);
    try std.testing.expectEqualStrings("user", cfg.sasl_username.?);
}

test "ClientConfig TLS" {
    const cfg = ClientConfig{
        .tls_enabled = true,
    };
    try std.testing.expect(cfg.tls_enabled);
}

test "CompressionType values match Kafka" {
    // Verify enum values match Kafka protocol compression type codes
    try std.testing.expectEqual(@as(u3, 0), @intFromEnum(CompressionType.none));
    try std.testing.expectEqual(@as(u3, 1), @intFromEnum(CompressionType.gzip));
    try std.testing.expectEqual(@as(u3, 2), @intFromEnum(CompressionType.snappy));
    try std.testing.expectEqual(@as(u3, 3), @intFromEnum(CompressionType.lz4));
    try std.testing.expectEqual(@as(u3, 4), @intFromEnum(CompressionType.zstd));
}

test "BrokerAddress default port" {
    const addr = BrokerAddress{ .host = "localhost" };
    try std.testing.expectEqual(@as(u16, 9092), addr.port);
}
