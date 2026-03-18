# Zig Kafka Toolkit

A comprehensive Apache Kafka toolkit for Zig with three main components:

## 🎯 Components

### 1. Protocol Generator (`protocol-gen/`)
Auto-generates type-safe Zig code from Kafka JSON protocol specifications.

### 2. SDK (`sdk/`)
Native Zig Kafka client library with Producer, Consumer, and Admin APIs.

### 3. C Compatibility (`c-compat/`)
librdkafka v2.13.0 compatible shared library for C/C++ applications.

## ✨ Features

- ✅ **Full Protocol Support** - Kafka v0-v16 with flexible encoding
- ✅ **Zero-Copy Design** - Pre-allocated buffers, no runtime allocations
- ✅ **Producer API** - High-throughput with idempotence support
- ✅ **Consumer API** - Groups with automatic rebalancing
- ✅ **Admin API** - Topic and group management
- ✅ **C Compatible** - Drop-in librdkafka replacement
- ✅ **Tested** - Kafka 3.8+ and Redpanda 25.3.7

## 🚀 Quick Start

### Zig SDK

```zig
const kafka = @import("kafka");

var client = try kafka.KafkaClient.init(allocator, .{
    .bootstrap_servers = &[_][]const u8{"localhost:9092"},
});
defer client.deinit();

var producer = try client.createProducer(.{});
try producer.send(.{
    .topic = "test",
    .value = "Hello, Kafka!",
});
try producer.flush(5000);
```

### C API

```c
#include <rdkafka.h>

rd_kafka_conf_t *conf = rd_kafka_conf_new();
rd_kafka_conf_set(conf, "bootstrap.servers", "localhost:9092", NULL, 0);

rd_kafka_t *rk = rd_kafka_new(RD_KAFKA_PRODUCER, conf, NULL, 0);
rd_kafka_topic_t *rkt = rd_kafka_topic_new(rk, "test", NULL);

rd_kafka_produce(rkt, -1, 0, "Hello!", 6, NULL, 0, NULL);
rd_kafka_flush(rk, 5000);
```

## 📦 Installation

```bash
git clone https://github.com/yourusername/zig-kafka.git
cd zig-kafka
zig build
```

**Outputs:**
- `zig-out/bin/kafka-protocol-generator` - Code generator
- `zig-out/lib/libkafka.a` - Zig static library
- `zig-out/lib/librdkafka.dylib` - C shared library
- `zig-out/include/rdkafka.h` - C header

## 📚 Documentation

- [Protocol Generator](protocol-gen/README.md) - Code generation
- [SDK Guide](sdk/README.md) - Native Zig API
- [C Compatibility](c-compat/README.md) - librdkafka API
- [Architecture](docs/ARCHITECTURE.md) - System design

## 🧪 Testing

```bash
zig build test              # SDK unit tests
zig build test-integration  # Integration (needs Kafka)
zig build test-c            # C API tests
```

## 📊 Performance

- **Zero-allocation** hot paths
- **Lock-free** concurrency
- **100k+ msgs/sec** producer throughput
- Tested against Kafka 3.8 and Redpanda 25.3.7

## 🛠 Development

### Build All Components

```bash
zig build                   # Build everything
zig build gen -- <spec>     # Run protocol generator
```

### Run Protocol Generator

```bash
zig build gen -- protocol-gen/specs/ProduceRequest.json output.zig
```

## 🌟 Status

| Feature | Status |
|---------|--------|
| Producer | ✅ Complete |
| Idempotent Producer | ✅ Complete |
| Consumer | ✅ Complete |
| Consumer Groups | ✅ Complete |
| Admin API | ✅ Complete |
| Transactions | 🚧 In Progress |
| SASL/SSL | 📋 Planned |

✅ Complete | 🚧 In Progress | 📋 Planned

## 📋 Requirements

- Zig 0.15.2+
- Kafka 2.0+ or Redpanda 22.3+ (for testing)

## 🤝 Contributing

Contributions welcome! See [CONTRIBUTING.md](CONTRIBUTING.md).

## 📄 License

Dual-licensed: Apache 2.0 / MIT

## 🙏 Acknowledgments

- Apache Kafka Protocol specification
- librdkafka, kafka-go, franz-go projects
- TickStream production Kafka codec

---

**Maintained by**: Ben Gamble
**Status**: Active Development - Producer/Consumer APIs production-ready
