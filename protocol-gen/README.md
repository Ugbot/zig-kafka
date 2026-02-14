# Kafka Protocol Generator

Generates type-safe Zig code from Kafka JSON protocol specifications.

## Features

- ✅ **199 protocol specifications** included
- ✅ **All Kafka versions** (v0-v16) supported
- ✅ **Flexible encoding** (v4+) with compact types
- ✅ **Tagged fields** support
- ✅ **Comptime validation** - catches errors at compile time

## Usage

### Basic Generation

```bash
# Build the generator
zig build

# Generate code from a specification
./zig-out/bin/kafka-protocol-generator specs/ProduceRequest.json output/produce_request.zig
```

### Batch Generation

```bash
# Generate all protocols
cd protocol-gen
./scripts/generate_all.sh
```

This processes all 199 protocol specs in `specs/` and generates corresponding Zig files.

## Input Format

The generator accepts Kafka protocol JSON specifications. Example:

```json
{
  "apiKey": 0,
  "type": "request",
  "name": "ProduceRequest",
  "validVersions": "0-10",
  "flexibleVersions": "9+",
  "fields": [
    {
      "name": "transactionalId",
      "type": "string",
      "versions": "3+",
      "nullableVersions": "3+",
      "default": "null"
    }
  ]
}
```

## Output Format

Generated Zig code includes:

- **Type definitions** - Structs matching protocol structure
- **Encoding functions** - `encode(writer, version, allocator)`
- **Decoding functions** - `decode(reader, version, allocator)`
- **Version checks** - `isFlexibleVersion(version)`, `supportedVersions()`
- **Default constructors** - `default()` with builder methods

Example generated code:

```zig
pub const ProduceRequest = struct {
    transactional_id: ?[]const u8 = null,
    topics: []ProduceTopic,

    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        // Version-specific encoding logic
    }

    pub fn decode(reader: anytype, version: i16, allocator: Allocator) !Self {
        // Version-specific decoding logic
    }

    pub fn isFlexibleVersion(version: i16) bool {
        return version >= 9;
    }
};
```

## Scripts

### `clean_json.py`
Preprocesses JSON specs to fix formatting issues.

```bash
python3 scripts/clean_json.py specs/input.json specs/output.json
```

### `generate_all.sh`
Generates code for all protocols in bulk.

```bash
./scripts/generate_all.sh
```

### `post_generate_fix.sh`
Post-processes generated files to fix common issues.

```bash
./scripts/post_generate_fix.sh generated/
```

## Documentation

Detailed documentation in `docs/`:

- [COMPLETION_SUMMARY.md](docs/COMPLETION_SUMMARY.md) - Generator features
- [FEATURE_PARITY_PLAN.md](docs/FEATURE_PARITY_PLAN.md) - Roadmap
- [IMPLEMENTATION_COMPLETE.md](docs/IMPLEMENTATION_COMPLETE.md) - Implementation status
- [VALIDATION_REPORT.md](docs/VALIDATION_REPORT.md) - Testing results

## Examples

See `examples/` directory:

- `example.zig` - Complete usage example
- `simple_example.zig` - Minimal example

## Protocol Specifications

The `specs/` directory contains 199 Kafka protocol JSON files:

- Request/Response pairs for all APIs
- All versions from Kafka 0.8 through 3.8
- Official Apache Kafka protocol definitions

## Building

```bash
cd protocol-gen
zig build
```

The generator executable will be at `zig-out/bin/kafka-protocol-generator`.

## Testing

```bash
# Run generator tests
zig build test
```

## Contributing

When adding new protocol support:

1. Add JSON spec to `specs/`
2. Run `clean_json.py` if needed
3. Generate with `generate_all.sh`
4. Verify output compiles
5. Add tests

## License

Dual-licensed under Apache 2.0 / MIT
