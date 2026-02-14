# C Compatibility Layer

Drop-in replacement for librdkafka v2.13.0 built in Zig.

## Features

- ✅ **Binary compatible** with librdkafka v2.13.0
- ✅ **Shared library** - `librdkafka.so/.dylib/.dll`
- ✅ **Same API** - No code changes needed
- ✅ **Zero dependencies** - Pure Zig implementation
- 🚧 **Subset implementation** - Core features working, advanced features in progress

## Installation

### Build from Source

```bash
cd c-compat
zig build
```

**Outputs:**
- `zig-out/lib/librdkafka.dylib` (or `.so` on Linux, `.dll` on Windows)
- `zig-out/include/rdkafka.h`

### Link Against Your Application

```bash
# Compile
gcc -o myapp myapp.c -I/path/to/zig-kafka/zig-out/include

# Link
gcc myapp.c -L/path/to/zig-kafka/zig-out/lib -lrdkafka -o myapp

# Run
LD_LIBRARY_PATH=/path/to/zig-kafka/zig-out/lib ./myapp
```

## C API Examples

### Producer

```c
#include <rdkafka.h>
#include <stdio.h>
#include <string.h>

int main(void) {
    // Create configuration
    rd_kafka_conf_t *conf = rd_kafka_conf_new();
    char errstr[512];

    if (rd_kafka_conf_set(conf, "bootstrap.servers", "localhost:9092",
                          errstr, sizeof(errstr)) != RD_KAFKA_CONF_OK) {
        fprintf(stderr, "Config error: %s\n", errstr);
        return 1;
    }

    rd_kafka_conf_set(conf, "client.id", "my-producer", NULL, 0);

    // Create producer
    rd_kafka_t *rk = rd_kafka_new(RD_KAFKA_PRODUCER, conf,
                                   errstr, sizeof(errstr));
    if (!rk) {
        fprintf(stderr, "Failed to create producer: %s\n", errstr);
        return 1;
    }

    // Create topic
    rd_kafka_topic_t *rkt = rd_kafka_topic_new(rk, "test-topic", NULL);

    // Produce message
    const char *msg = "Hello, Kafka!";
    if (rd_kafka_produce(rkt, RD_KAFKA_PARTITION_UA, 0,
                         (void*)msg, strlen(msg),
                         NULL, 0, NULL) == -1) {
        fprintf(stderr, "Failed to produce message\n");
    }

    // Wait for message delivery
    rd_kafka_flush(rk, 5000); // 5 second timeout

    // Cleanup
    rd_kafka_topic_destroy(rkt);
    rd_kafka_destroy(rk);

    return 0;
}
```

### Consumer

```c
#include <rdkafka.h>
#include <stdio.h>

int main(void) {
    // Create configuration
    rd_kafka_conf_t *conf = rd_kafka_conf_new();
    char errstr[512];

    rd_kafka_conf_set(conf, "bootstrap.servers", "localhost:9092", NULL, 0);
    rd_kafka_conf_set(conf, "group.id", "my-group", NULL, 0);
    rd_kafka_conf_set(conf, "auto.offset.reset", "earliest", NULL, 0);

    // Create consumer
    rd_kafka_t *rk = rd_kafka_new(RD_KAFKA_CONSUMER, conf,
                                   errstr, sizeof(errstr));
    if (!rk) {
        fprintf(stderr, "Failed to create consumer: %s\n", errstr);
        return 1;
    }

    // Subscribe to topics
    rd_kafka_topic_partition_list_t *topics = rd_kafka_topic_partition_list_new(1);
    rd_kafka_topic_partition_list_add(topics, "test-topic", RD_KAFKA_PARTITION_UA);

    if (rd_kafka_subscribe(rk, topics) != 0) {
        fprintf(stderr, "Failed to subscribe\n");
        return 1;
    }

    rd_kafka_topic_partition_list_destroy(topics);

    // Poll for messages
    while (1) {
        rd_kafka_message_t *msg = rd_kafka_consumer_poll(rk, 1000);

        if (msg) {
            if (msg->err == RD_KAFKA_RESP_ERR_NO_ERROR) {
                printf("Received: %.*s\n", (int)msg->len, (char*)msg->payload);
            }
            rd_kafka_message_destroy(msg);
        }
    }

    // Cleanup
    rd_kafka_consumer_close(rk);
    rd_kafka_destroy(rk);

    return 0;
}
```

## API Coverage

### Implemented

- ✅ Configuration (`rd_kafka_conf_*`)
- ✅ Client lifecycle (`rd_kafka_new`, `rd_kafka_destroy`)
- ✅ Topics (`rd_kafka_topic_*`)
- ✅ Producer (`rd_kafka_produce`, `rd_kafka_flush`)
- ✅ Consumer (`rd_kafka_subscribe`, `rd_kafka_consumer_poll`)
- ✅ Topic partition lists
- ✅ Error handling (`rd_kafka_err2str`, `rd_kafka_err2name`)
- ✅ Version info (`rd_kafka_version`, `rd_kafka_version_str`)

### In Progress / Stubbed

- 🚧 Message headers
- 🚧 Offset commit/fetch (auto-commit works)
- 🚧 Admin API
- 🚧 Callbacks (delivery reports, rebalance)
- 🚧 Events and queues
- 🚧 Metadata queries
- 🚧 Statistics

### Not Yet Implemented

- ❌ Transactions
- ❌ Idempotent producer (via C API)
- ❌ SASL/SSL configuration
- ❌ Schema registry integration

## Differences from librdkafka

While the API is compatible, there are some behavioral differences:

1. **Simplified Configuration** - Not all librdkafka config parameters are supported yet
2. **No Statistics** - Statistics callback not yet implemented
3. **Limited Callbacks** - Delivery reports and rebalance callbacks in progress
4. **No Admin API** - Admin operations stubbed

## Linking

### Dynamic Linking (Recommended)

```bash
gcc myapp.c -L/path/to/lib -lrdkafka -o myapp
```

### Static Linking

Not currently supported. The library is built as a shared library only.

## Building

```bash
cd c-compat
zig build
```

**Output:**
- `zig-out/lib/librdkafka.2.13.0.dylib` - Versioned library
- `zig-out/lib/librdkafka.2.dylib` - Major version symlink
- `zig-out/lib/librdkafka.dylib` - Unversioned symlink
- `zig-out/include/rdkafka.h` - C header file

## Testing

```bash
# Build and run C API test
zig build test

# Run test executable
./zig-out/bin/c-api-test
```

## Compatibility Notes

### Version String

The library identifies itself as:

```c
rd_kafka_version_str() → "2.13.0-zig-kafka"
rd_kafka_version()     → 0x020d00ff
```

### Error Codes

All librdkafka v2.13.0 error codes are supported:

- Internal errors: -200 to -100
- Broker errors: 0 to 100+

### Thread Safety

The library is thread-safe for most operations. However:

- Don't call `rd_kafka_destroy()` while other threads are using the handle
- Consumer poll operations should be from a single thread

## Migration from librdkafka

To migrate existing librdkafka code:

1. **No code changes required** - API is binary compatible
2. **Recompile against new headers** (optional, but recommended)
3. **Link against zig-kafka** instead of librdkafka
4. **Test thoroughly** - Some advanced features may not be implemented yet

## Performance

Similar performance to native Zig SDK:

- Zero allocations in hot paths
- Lock-free concurrency
- Efficient batching and compression

## Examples

See `examples/` directory:

- `producer.c` - Basic producer
- `consumer.c` - Basic consumer

## Support

For issues specific to the C compatibility layer:

- Check if the feature is implemented (see API Coverage above)
- File an issue on GitHub
- Consider using the native Zig SDK if full feature set is needed

## License

Dual-licensed under Apache 2.0 / MIT

## Acknowledgments

- librdkafka project for the API design
- Apache Kafka project for the protocol specification
