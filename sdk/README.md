# Zig Kafka SDK

Native Zig client library for Apache Kafka with Producer, Consumer, and Admin APIs.

## Features

- ✅ **Producer** - High-throughput message production
- ✅ **Idempotent Producer** - Exactly-once delivery semantics
- ✅ **Consumer** - Subscribe, poll, commit with consumer groups
- ✅ **Consumer Groups** - Automatic rebalancing (range & round-robin)
- ✅ **Admin** - Topic and consumer group management
- ✅ **Compression** - gzip, snappy, lz4, zstd support
- ✅ **Zero-Allocation** - Pre-allocated buffers, no runtime allocations

## Quick Start

### Producer

```zig
const kafka = @import("kafka");
const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Create client
    var client = try kafka.KafkaClient.init(allocator, .{
        .bootstrap_servers = &[_][]const u8{"localhost:9092"},
        .client_id = "my-producer",
    });
    defer client.deinit();

    // Create producer
    var producer = try client.createProducer(.{});
    defer producer.close();

    // Send messages
    try producer.send(.{
        .topic = "my-topic",
        .key = "user-123",
        .value = "Hello, Kafka!",
        .partition = null, // Auto-assign partition
    });

    // Wait for all messages to be sent
    try producer.flush(5000); // 5 second timeout
}
```

### Consumer

```zig
const kafka = @import("kafka");
const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Create client
    var client = try kafka.KafkaClient.init(allocator, .{
        .bootstrap_servers = &[_][]const u8{"localhost:9092"},
        .client_id = "my-consumer",
    });
    defer client.deinit();

    // Create consumer
    var consumer = try client.createConsumer(.{
        .group_id = "my-group",
        .auto_offset_reset = .earliest,
    });
    defer consumer.close();

    // Subscribe to topics
    try consumer.subscribe(&[_][]const u8{"my-topic"});

    // Poll for messages
    while (true) {
        const records = try consumer.poll(1000); // 1 second timeout
        for (records) |record| {
            std.debug.print("Topic: {s}, Partition: {d}, Offset: {d}\n", .{
                record.topic, record.partition, record.offset,
            });
            std.debug.print("Key: {?s}\n", .{record.key});
            std.debug.print("Value: {s}\n", .{record.value});
        }

        // Commit offsets
        try consumer.commit();
    }
}
```

### Admin Operations

```zig
const kafka = @import("kafka");

var client = try kafka.KafkaClient.init(allocator, .{
    .bootstrap_servers = &[_][]const u8{"localhost:9092"},
});
defer client.deinit();

var admin = try client.createAdmin();

// Create topic
try admin.createTopic(.{
    .name = "new-topic",
    .num_partitions = 3,
    .replication_factor = 2,
});

// List topics
const topics = try admin.listTopics(allocator);
defer allocator.free(topics);

// Delete topic
try admin.deleteTopic("old-topic");

// List consumer groups
const groups = try admin.listConsumerGroups(allocator);
defer allocator.free(groups);
```

## Architecture

The SDK has three layers:

### 1. Protocol Layer (`src/protocol/`)
- Wire types and primitives
- Message encoding/decoding
- Record batch handling
- Compression

### 2. Wire Layer (`src/wire/`)
- Connection management
- Broker pool
- Request/response framing
- API version negotiation

### 3. Client Layer (`src/client/`)
- **Producer** - Message accumulation, batching, sending
- **Consumer** - Fetching, group coordination, offset management
- **Admin** - Cluster operations

## Configuration

### Client Config

```zig
const config = kafka.ClientConfig{
    .bootstrap_servers = &[_][]const u8{"broker1:9092", "broker2:9092"},
    .client_id = "my-app",
    .request_timeout_ms = 30000,
    .metadata_max_age_ms = 300000,
};
```

### Producer Config

```zig
const config = kafka.ProducerConfig{
    .acks = .all, // -1, 0, 1
    .compression_type = .gzip,
    .batch_size = 16384,
    .linger_ms = 10,
    .max_in_flight_requests = 5,
    .enable_idempotence = true,
};
```

### Consumer Config

```zig
const config = kafka.ConsumerConfig{
    .group_id = "my-group",
    .auto_offset_reset = .latest, // or .earliest
    .enable_auto_commit = true,
    .auto_commit_interval_ms = 5000,
    .session_timeout_ms = 30000,
    .max_poll_records = 500,
};
```

## Advanced Features

### Transactional Producer (Coming Soon)

```zig
var producer = try client.createProducer(.{
    .transactional_id = "my-txn-id",
});

try producer.beginTransaction();
try producer.send(.{ .topic = "topic1", .value = "msg1" });
try producer.send(.{ .topic = "topic2", .value = "msg2" });
try producer.commitTransaction();
```

### Manual Offset Management

```zig
// Seek to specific offset
try consumer.seek("my-topic", 0, 1000);

// Seek to beginning/end
try consumer.seekToBeginning("my-topic", 0);
try consumer.seekToEnd("my-topic", 0);

// Get committed offsets
const offsets = try consumer.committed(allocator);
defer allocator.free(offsets);
```

### Custom Partitioner

```zig
const MyPartitioner = struct {
    pub fn partition(
        topic: []const u8,
        key: ?[]const u8,
        partition_count: u32,
    ) u32 {
        // Custom partitioning logic
        return 0;
    }
};

var producer = try client.createProducer(.{
    .partitioner = MyPartitioner.partition,
});
```

## Building

```bash
cd sdk
zig build
```

## Testing

```bash
# Unit tests
zig build test

# Integration tests (requires Kafka on :9092)
zig build test-integration
```

## Performance

- **Zero allocations** in message send/receive paths
- **Lock-free** producer accumulator
- **Pre-allocated** record pool for consumers
- **Batch compression** for efficiency
- **100k+ msgs/sec** tested throughput

## Memory Management

All buffers pre-allocated at startup:
- Producer accumulator uses ring buffers
- Consumer uses record pool (1024 slots)
- All protocol decoding uses arena allocators (auto-freed)

## Error Handling

All operations return error unions:

```zig
const SendError = error{
    QueueFull,
    MessageTooLarge,
    InvalidTopic,
    BrokerNotAvailable,
    Timeout,
};

producer.send(message) catch |err| switch (err) {
    error.QueueFull => {
        // Wait and retry
    },
    error.Timeout => {
        // Handle timeout
    },
    else => return err,
};
```

## Examples

See `examples/` directory:
- `producer_example.zig` - Basic producer
- `consumer_example.zig` - Basic consumer
- `admin_example.zig` - Admin operations

## License

Dual-licensed under Apache 2.0 / MIT
