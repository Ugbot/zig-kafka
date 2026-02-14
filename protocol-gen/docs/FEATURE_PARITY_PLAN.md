# Kafka Protocol Generator - Feature Parity Plan

## Goal
Make the Zig generator feature-complete to match kafka-protocol-rs (Rust) and Tanzu implementations.

## Current State Analysis

### Rust Generator Features (kafka-protocol-rs)
1. ✅ **Bidirectional Protocol Support**
   - `Encodable` trait with `encode()` and `compute_size()`
   - `Decodable` trait with `decode()`

2. ✅ **Builder Pattern**
   - `with_*()` methods for all fields
   - Fluent API for constructing messages

3. ✅ **Default Trait**
   - Explicit default values for all fields
   - Handles nullable, optional, and required fields correctly

4. ✅ **Message Metadata**
   - `Message` trait with `VERSIONS` constant
   - `DEPRECATED_VERSIONS` tracking

5. ✅ **Header Version Support**
   - `HeaderVersion` trait implementation
   - Special cases for specific API keys (e.g., ApiVersions, ControlledShutdown)

6. ✅ **Conditional Compilation**
   - Client-side features (`#[cfg(feature = "client")]`)
   - Broker-side features (`#[cfg(feature = "broker")]`)

7. ✅ **Unknown Tagged Fields**
   - Proper tracking and encoding/decoding
   - Builder methods for unknown tagged fields

### Zig Generator Current Features
1. ✅ **Decode Support** - Has `decode()` function
2. ✅ **Encode Support** - Has `encode()` function
3. ✅ **Tagged Fields** - Handles `_tagged_fields`
4. ✅ **Flexible Versions** - Supports compact encoding
5. ✅ **Nested Structs** - Generates nested types correctly
6. ❌ **compute_size()** - MISSING
7. ❌ **Builder Pattern** - MISSING
8. ❌ **Default Function** - MISSING (uses struct init)
9. ❌ **Message Metadata** - MISSING
10. ❌ **Header Version** - MISSING

## Implementation Plan

### Phase 1: Core Protocol Features (CRITICAL)
**Status: In Progress**

#### 1.1 Add compute_size() Support
- [ ] Update `types.zig` to add `computeSize*()` functions for all primitives
- [ ] Generate `computeSize()` method for all structs
- [ ] Handle version conditionals in size computation
- [ ] Handle tagged fields size computation

#### 1.2 Add Builder Pattern
- [ ] Generate `with_*()` methods for all fields
- [ ] Return `Self` for method chaining
- [ ] Handle optional vs required fields correctly

#### 1.3 Add Default Support
- [ ] Generate explicit `default()` function
- [ ] Use correct default values from spec
- [ ] Handle nullable fields with `null`
- [ ] Handle primitive defaults (0, false, empty string, etc.)

### Phase 2: Metadata and Versioning
**Status: Pending**

#### 2.1 Message Metadata
- [ ] Add `VERSIONS` constant (min/max range)
- [ ] Add `DEPRECATED_VERSIONS` constant (optional)
- [ ] Generate helper functions for version validation

#### 2.2 Header Version Support
- [ ] Generate `headerVersion()` function
- [ ] Implement special cases for specific APIs
- [ ] Handle flexible vs non-flexible version headers

### Phase 3: Advanced Features
**Status: Pending**

#### 3.1 Conditional Compilation (Optional)
- [ ] Decide if we need client/broker separation in Zig
- [ ] Implement using `pub const client_only = true` flags if needed

#### 3.2 Unknown Tagged Fields
- [ ] Verify current implementation matches Rust behavior
- [ ] Add builder methods for unknown tagged fields

## Expected Generated Code Structure (Zig)

```zig
/// ApiVersionsRequest
pub const ApiVersionsRequest = struct {
    const Self = @This();

    // Fields
    client_software_name: []const u8 = "",
    client_software_version: []const u8 = "",
    _tagged_fields: ?[]TaggedField = null,

    // Metadata
    pub const VERSIONS = VersionRange{ .min = 0, .max = 4 };
    pub const DEPRECATED_VERSIONS: ?VersionRange = null;

    // Default constructor
    pub fn default() Self {
        return .{
            .client_software_name = "",
            .client_software_version = "",
            ._tagged_fields = null,
        };
    }

    // Builder methods
    pub fn withClientSoftwareName(self: Self, value: []const u8) Self {
        var result = self;
        result.client_software_name = value;
        return result;
    }

    pub fn withClientSoftwareVersion(self: Self, value: []const u8) Self {
        var result = self;
        result.client_software_version = value;
        return result;
    }

    // Encoding
    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {
        if (!isValidVersion(version)) return Error.UnsupportedVersion;
        // ... encode logic ...
    }

    // Size computation (NEW!)
    pub fn computeSize(self: *const Self, version: i16) !usize {
        if (!isValidVersion(version)) return Error.UnsupportedVersion;
        var total_size: usize = 0;
        // ... size computation logic ...
        return total_size;
    }

    // Decoding
    pub fn decode(reader: anytype, version: i16, allocator: std.mem.Allocator) !Self {
        // ... decode logic ...
    }

    // Version helpers
    pub fn isValidVersion(version: i16) bool {
        return version >= VERSIONS.min and version <= VERSIONS.max;
    }

    pub fn isFlexibleVersion(version: i16) bool {
        return version >= 3;
    }

    // Header version (NEW!)
    pub fn headerVersion(version: i16) i16 {
        if (version >= 3) return 2;
        return 1;
    }
};
```

## Success Criteria

1. ✅ Generated code can encode messages
2. ✅ Generated code can decode messages
3. ❌ Generated code can compute message size without encoding
4. ❌ Generated code supports builder pattern
5. ❌ Generated code has explicit defaults
6. ❌ Generated code includes version metadata
7. ❌ Generated code handles header versions correctly

## Testing Plan

1. **Unit Tests** - Test each feature in isolation
2. **Integration Tests** - Test with real Kafka broker
3. **Comparison Tests** - Compare with Rust implementation output
4. **FetchRequest/FetchResponse** - The most complex protocol to validate

## Timeline

- **Phase 1**: 2-3 hours (compute_size, builder, default)
- **Phase 2**: 1-2 hours (metadata, header version)
- **Phase 3**: 1 hour (cleanup, testing)

**Total Estimated Time**: 4-6 hours
