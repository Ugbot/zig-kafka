# Kafka Protocol Generator

A high-performance, zero-allocation Kafka protocol code generator for Zig.

## Overview

This library generates complete Zig implementations of the Kafka protocol from the official Apache Kafka JSON specifications. Unlike other implementations that rely on runtime reflection or complex serialization frameworks, this generator produces explicit, optimized code designed for high-performance systems.

## Features

- **Complete Protocol Support**: Generates all Kafka message types from JSON specs
- **Zero Allocation**: Generated code designed for allocation-free operation
- **Version Aware**: Handles multiple protocol versions and flexible encoding
- **Type Safe**: Full Zig type safety with compile-time guarantees
- **High Performance**: Explicit encoding/decoding for maximum speed
- **Standards Compliant**: Based on official Apache Kafka protocol specifications

## Architecture

The generator consists of three main components:

1. **Generator** (`src/generator.zig`): Parses JSON specs and generates Zig code
2. **Type System** (`src/types.zig`): Complete Kafka type implementations
3. **Runtime** (`src/runtime.zig`): Runtime support for generated code

## Usage

### Building the Generator

```bash
zig build
```

### Generating Protocol Code

```bash
# Generate a single message
./zig-out/bin/kafka-protocol-generator spec.json output.zig

# Generate all messages from a directory
./zig-out/bin/kafka-protocol-generator --dir specs/ --output generated/
```

### Using Generated Code

```zig
const kafka = @import("kafka-protocol");
const ApiVersionsRequest = @import("generated/api_versions_request.zig");

// Create request
var request = ApiVersionsRequest{
    .client_software_name = "my-client",
    .client_software_version = "1.0.0",
};

// Encode to bytes
var buffer: [1024]u8 = undefined;
var stream = std.io.fixedBufferStream(&buffer);
try ApiVersionsRequest.encode(&request, stream.writer(), 3);

// Decode from bytes
var read_stream = std.io.fixedBufferStream(buffer[0..stream.pos]);
const decoded = try ApiVersionsRequest.decode(read_stream.reader(), 3, allocator);
```

## Design Principles

- **Explicit over Magic**: No hidden allocations or runtime surprises
- **Performance First**: Optimized for high-throughput, low-latency systems
- **Type Safety**: Leverage Zig's compile-time guarantees
- **Standards Compliance**: Bit-perfect compatibility with Apache Kafka

## Comparison with Other Implementations

Unlike serde-based implementations (like Tansu), this generator produces explicit code that:

- Has predictable performance characteristics
- Requires no runtime reflection
- Generates minimal machine code
- Supports zero-allocation operation
- Provides compile-time protocol validation

## License

Licensed under the Apache License, Version 2.0.
