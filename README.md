# zig-kafka

A native Kafka client library for Zig, providing full protocol support and a high-level SDK.

## Features

- **Full Protocol Support**: Complete implementation of Kafka wire protocol with 140+ message types
- **Producer API**: High-throughput producer with batching, compression, and idempotence
- **Consumer API**: Consumer with group coordination, offset management, and rebalancing
- **Admin API**: Topic and configuration management
- **Zero Dependencies**: Pure Zig implementation
- **High Performance**: Designed for 100k+ msgs/sec throughput
- **Protocol Generator**: Included code generator for Kafka protocol specifications

## Quick Start

### Installation

Add to your `build.zig.zon`:

```zig
.dependencies = .{
    .@"zig-kafka" = .{
        .url = "https://github.com/Ugbot/zig-kafka/archive/<commit-hash>.tar.gz",
        .hash = "<hash>",
    },
},
```

Or for local development:

```zig
.dependencies = .{
    .@"zig-kafka" = .{
        .path = "../zig-kafka",
    },
},
```

Add to your `build.zig`:

```zig
const zig_kafka = b.dependency("zig-kafka", .{
    .target = target,
    .optimize = optimize,
});

exe.root_module.addImport("zig-kafka", zig_kafka.module("zig-kafka"));
```

### Usage Example

```zig
const std = @import("std");
const kafka = @import("zig-kafka");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Create client
    var client = try kafka.KafkaClient.init(allocator, .{
        .bootstrap_servers = &[_][]const u8{"localhost:9092"},
    });
    defer client.deinit();

    // Create producer
    var producer = try client.createProducer(.{
        .client_id = "my-producer",
    });
    defer producer.close();

    // Send message
    try producer.send(.{
        .topic = "test-topic",
        .key = "key1",
        .value = "Hello, Kafka!",
    });

    // Create consumer
    var consumer = try client.createConsumer(.{
        .group_id = "my-group",
        .topics = &[_][]const u8{"test-topic"},
    });
    defer consumer.close();

    // Poll messages
    while (true) {
        const records = try consumer.poll(1000);
        for (records) |record| {
            std.debug.print("Received: {s}\n", .{record.value});
        }
    }
}
```

## Building

```bash
# Build library
zig build

# Run tests
zig build test

# Run integration tests (requires Kafka broker on localhost:9092)
zig build test-integration

# Build protocol generator
zig build
```

## Protocol Generator

The library includes a protocol generator that converts Kafka's JSON protocol specifications into Zig code:

```bash
# Generate a protocol file
zig build generate -- generator/specs/ProduceRequest.json src/generated/produce_request.zig

# Or use the generator directly
cd generator
zig build
./zig-out/bin/kafka-protocol-generator specs/ProduceRequest.json ../src/generated/produce_request.zig
```

## Architecture

- **`src/protocol/`**: Low-level wire protocol (framing, encoding, compression)
- **`src/generated/`**: Auto-generated protocol message types
- **`src/wire/`**: Connection management and broker pool
- **`src/client/`**: High-level Producer, Consumer, and Admin APIs
- **`generator/`**: Protocol code generator

## Compatibility

- **Zig Version**: 0.14.1 or later
- **Kafka Version**: Compatible with Kafka 0.10+ (tested with Kafka 3.8 and Redpanda 25.3.7)
- **Protocol Support**: API versions 0-16 with dynamic version negotiation

## Performance

Designed for high-throughput workloads:
- Zero-allocation hot paths with buffer pooling
- Lock-free concurrent data structures
- Batch processing and compression support
- Target: 100k+ messages/second per node

## Status

**Current State**: Alpha - Core functionality working, API may change

- ✅ Producer: Working with idempotence support
- ✅ Consumer: Working with group coordination
- ✅ Admin: Basic topic management
- 🚧 Transactions: In progress
- 🚧 Exactly-once semantics: In progress

## Contributing

Contributions welcome! This library follows strict guidelines:
- Zero runtime allocations in hot paths
- Lock-free concurrency patterns
- Complete implementations (no TODOs or placeholders)
- Benchmarked performance

## License

Apache 2.0 / MIT dual license (pending)

## Acknowledgments

Built as part of the [TickStream](https://github.com/Ugbot/tickstream) project.
