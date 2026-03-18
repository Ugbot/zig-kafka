//! Complete Kafka Protocol Generator - Feature Parity with Rust/Tanzu
//! Generates Zig code with ALL features: encode, decode, computeSize, builder pattern, defaults

const std = @import("std");
const json = std.json;
const fs = std.fs;
const ArrayList = std.array_list.Managed;
const Allocator = std.mem.Allocator;

/// Field specification from JSON
const FieldSpec = struct {
    name: []const u8,
    type: []const u8,
    versions: []const u8,
    about: ?[]const u8 = null,
    default: ?json.Value = null,
    nullableVersions: ?[]const u8 = null,
    flexibleVersions: ?[]const u8 = null,
    fields: ?[]const FieldSpec = null,
    taggedVersions: ?[]const u8 = null,
    tag: ?i32 = null,
};

/// Nested struct definition
const NestedStruct = struct {
    name: []const u8,
    fields: []const FieldSpec,
    versions: []const u8,
};

/// Message specification from JSON
const MessageSpec = struct {
    apiKey: ?i16 = null,
    type: []const u8,
    name: []const u8,
    validVersions: []const u8,
    flexibleVersions: ?[]const u8 = null,
    fields: []const FieldSpec,
};

/// Generate from a single JSON file
pub fn generateFromFile(allocator: Allocator, json_path: []const u8, output_path: []const u8) !void {
    const json_content = try fs.cwd().readFileAlloc(allocator, json_path, 1024 * 1024);
    defer allocator.free(json_content);

    const parsed = try json.parseFromSlice(MessageSpec, allocator, json_content, .{
        .ignore_unknown_fields = true,
        .allocate = .alloc_always,
    });
    defer parsed.deinit();

    const spec = parsed.value;

    var output = ArrayList(u8).init(allocator);
    defer output.deinit();

    try generateMessage(&output, spec, allocator);

    try fs.cwd().writeFile(.{
        .sub_path = output_path,
        .data = output.items,
    });

    std.debug.print("✅ Generated {s} from {s}\n", .{ output_path, json_path });
}

/// Generate from directory
pub fn generateFromDirectory(allocator: Allocator, specs_dir: []const u8, output_dir: []const u8) !void {
    var dir = try fs.cwd().openDir(specs_dir, .{ .iterate = true });
    defer dir.close();

    var iterator = dir.iterate();
    var generated_count: u32 = 0;
    var failed_count: u32 = 0;

    try fs.cwd().makePath(output_dir);

    while (try iterator.next()) |entry| {
        if (entry.kind != .file) continue;
        if (!std.mem.endsWith(u8, entry.name, ".json")) continue;

        const json_path = try std.fmt.allocPrint(allocator, "{s}/{s}", .{ specs_dir, entry.name });
        defer allocator.free(json_path);

        const base_name = entry.name[0 .. entry.name.len - 5];
        const zig_name = try toSnakeCase(allocator, base_name);
        defer allocator.free(zig_name);

        const output_path = try std.fmt.allocPrint(allocator, "{s}/{s}.zig", .{ output_dir, zig_name });
        defer allocator.free(output_path);

        std.debug.print("Generating {s}... ", .{base_name});

        generateFromFile(allocator, json_path, output_path) catch |err| {
            std.debug.print("❌ ({any})\n", .{err});
            failed_count += 1;
            continue;
        };

        generated_count += 1;
    }

    std.debug.print("\n✅ Generated {d} files, {d} failed\n", .{ generated_count, failed_count });
}

/// Generate complete message implementation
fn generateMessage(output: *ArrayList(u8), spec: MessageSpec, allocator: Allocator) !void {
    try generateFileHeader(output, spec);
    try generateImports(output);

    // Collect nested structs
    var nested_structs = ArrayList(NestedStruct).init(allocator);
    defer nested_structs.deinit();
    try collectNestedStructs(spec.fields, &nested_structs, allocator);

    // Generate nested structs (innermost first)
    var i = nested_structs.items.len;
    while (i > 0) {
        i -= 1;
        try generateNestedStruct(output, nested_structs.items[i], spec, allocator);
    }

    // Generate main struct
    try generateStruct(output, spec, allocator);

    // NEW: Generate version metadata constants
    try generateVersionMetadata(output, spec);

    // NEW: Generate default() function
    try generateDefaultFunction(output, spec, allocator);

    // NEW: Generate builder pattern methods
    try generateBuilderMethods(output, spec, allocator);

    // Generate encode/decode/computeSize
    try generateEncodeFunction(output, spec, allocator);
    try generateComputeSizeFunction(output, spec, allocator);  // NEW!
    try generateDecodeFunction(output, spec, allocator);

    // Generate utility functions
    try generateUtilityFunctions(output, spec);
}

fn generateFileHeader(output: *ArrayList(u8), spec: MessageSpec) !void {
    const writer = output.writer();

    try writer.print(
        \\//! Auto-generated Kafka protocol message
        \\//! Message: {s}
        \\
    , .{spec.name});

    if (spec.apiKey) |api_key| {
        try writer.print("//! API Key: {d}\n", .{api_key});
    }

    try writer.print(
        \\//! Type: {s}
        \\//! Valid Versions: {s}
        \\
    , .{ spec.type, spec.validVersions });

    if (spec.flexibleVersions) |flexible| {
        try writer.print("//! Flexible Versions: {s}\n", .{flexible});
    }
    try writer.writeAll("//!\n//! DO NOT EDIT - Generated from protocol JSON\n\n");
}

fn generateImports(output: *ArrayList(u8)) !void {
    const writer = output.writer();
    try writer.writeAll(
        \\const std = @import("std");
        \\const types = @import("../src/types.zig");
        \\
        \\
    );
}

fn generateStruct(output: *ArrayList(u8), spec: MessageSpec, allocator: Allocator) !void {
    const writer = output.writer();

    try writer.print("/// {s}\n", .{spec.name});
    try writer.print("pub const {s} = struct {{\n", .{spec.name});
    try writer.writeAll("    const Self = @This();\n\n");

    // Generate fields
    for (spec.fields) |field| {
        if (field.about) |about| {
            try writer.print("    /// {s}\n", .{about});
        }
        if (!std.mem.eql(u8, field.versions, "0+")) {
            try writer.print("    /// Versions: {s}\n", .{field.versions});
        }

        const field_name = try toSnakeCase(allocator, field.name);
        defer allocator.free(field_name);

        const zig_type = try getZigType(allocator, field);
        defer allocator.free(zig_type);

        const default_value = try getDefaultValue(allocator, field);
        defer allocator.free(default_value);

        try writer.print("    {s}: {s}", .{ field_name, zig_type });
        if (default_value.len > 0) {
            try writer.print(" = {s}", .{default_value});
        }
        try writer.writeAll(",\n");
    }

    try writer.writeAll("\n    /// Tagged fields for forward compatibility\n");
    try writer.writeAll("    _tagged_fields: ?[]types.TaggedField = null,\n");

    try writer.writeAll("\n    // ============================================================================\n");
    try writer.writeAll("    // METHODS\n");
    try writer.writeAll("    // ============================================================================\n\n");
}

// NEW: Generate version metadata constants
fn generateVersionMetadata(output: *ArrayList(u8), spec: MessageSpec) !void {
    const writer = output.writer();

    const version_range = try parseVersionRange(spec.validVersions);

    try writer.print(
        \\    /// Version range for this message
        \\    pub const VERSIONS = types.VersionRange{{ .min = {d}, .max = {d} }};
        \\
        \\
    , .{ version_range.min, version_range.max });

    if (spec.apiKey) |api_key| {
        try writer.print(
            \\    /// API Key for this message
            \\    pub fn apiKey() i16 {{
            \\        return {d};
            \\    }}
            \\
            \\
        , .{api_key});
    }
}

// NEW: Generate default() function
fn generateDefaultFunction(output: *ArrayList(u8), spec: MessageSpec, allocator: Allocator) !void {
    const writer = output.writer();

    try writer.print(
        \\    /// Create a default instance of {s}
        \\    pub fn default() Self {{
        \\        return .{{
        \\
    , .{spec.name});

    for (spec.fields) |field| {
        const field_name = try toSnakeCase(allocator, field.name);
        defer allocator.free(field_name);

        const default_value = try getDefaultValue(allocator, field);
        defer allocator.free(default_value);

        if (default_value.len > 0) {
            try writer.print("            .{s} = {s},\n", .{ field_name, default_value });
        }
    }

    try writer.writeAll(
        \\            ._tagged_fields = null,
        \\        };
        \\    }
        \\
        \\
    );
}

// NEW: Generate builder pattern methods (with_* functions)
fn generateBuilderMethods(output: *ArrayList(u8), spec: MessageSpec, allocator: Allocator) !void {
    const writer = output.writer();

    for (spec.fields) |field| {
        const field_name = try toSnakeCase(allocator, field.name);
        defer allocator.free(field_name);

        const zig_type = try getZigType(allocator, field);
        defer allocator.free(zig_type);

        // Generate with_* method
        const method_name = try std.fmt.allocPrint(allocator, "with{s}", .{field.name});
        defer allocator.free(method_name);

        if (field.about) |about| {
            try writer.print("    /// Sets `{s}` to the passed value.\n", .{field_name});
            try writer.print("    /// {s}\n", .{about});
        }
        if (!std.mem.eql(u8, field.versions, "0+")) {
            try writer.print("    /// Versions: {s}\n", .{field.versions});
        }

        try writer.print(
            \\    pub fn {s}(self: Self, value: {s}) Self {{
            \\        var result = self;
            \\        result.{s} = value;
            \\        return result;
            \\    }}
            \\
            \\
        , .{ method_name, zig_type, field_name });
    }
}

// NEW: Generate computeSize() function
fn generateComputeSizeFunction(output: *ArrayList(u8), spec: MessageSpec, allocator: Allocator) !void {
    const writer = output.writer();

    try writer.print(
        \\    /// Compute the size of {s} for the given version
        \\    pub fn computeSize(self: *const Self, version: i16) !usize {{
        \\        if (!isValidVersion(version)) {{
        \\            return types.Error.UnsupportedVersion;
        \\        }}
        \\        const is_flexible = isFlexibleVersion(version);
        \\        _ = &is_flexible;
        \\
        \\        var total_size: usize = 0;
        \\
        \\
    , .{spec.name});

    // Compute size for regular (non-tagged) fields
    for (spec.fields) |field| {
        if (field.taggedVersions != null) continue;
        try generateFieldComputeSize(writer, field, allocator);
    }

    // Compute size for tagged fields section
    try writer.writeAll(
        \\        if (is_flexible) {
        \\            var num_tagged_fields: u32 = 0;
        \\
    );

    // Count tagged fields
    for (spec.fields) |field| {
        if (field.taggedVersions == null) continue;

        const field_name = try toSnakeCase(allocator, field.name);
        defer allocator.free(field_name);

        const version_range = try parseVersionRange(field.taggedVersions.?);
        const zig_type = try getZigType(allocator, field);
        defer allocator.free(zig_type);

        try writer.print(
            \\            if (version >= {d} and version <= {d}) {{
            \\
        , .{ version_range.min, version_range.max });

        if (std.mem.startsWith(u8, zig_type, "?")) {
            try writer.print("                if (self.{s} != null) num_tagged_fields += 1;\n", .{field_name});
        } else if (field.fields != null) {
            try writer.print("                if (!std.mem.eql(u8, std.mem.asBytes(&self.{s}), std.mem.asBytes(&@as({s}, .{{}})))) num_tagged_fields += 1;\n", .{ field_name, field.name });
        } else {
            const default_value = try getDefaultValue(allocator, field);
            defer allocator.free(default_value);
            if (default_value.len > 0) {
                try writer.print("                if (self.{s} != {s}) num_tagged_fields += 1;\n", .{ field_name, default_value });
            } else {
                try writer.print("                num_tagged_fields += 1;\n", .{});
            }
        }

        try writer.writeAll("            }\n");
    }

    try writer.writeAll(
        \\
        \\            if (self._tagged_fields) |fields| {
        \\                num_tagged_fields += @intCast(fields.len);
        \\            }
        \\
        \\            total_size += types.computeSizeUnsignedVarInt(num_tagged_fields);
        \\
    );

    // Compute size for each tagged field
    for (spec.fields) |field| {
        if (field.taggedVersions == null) continue;
        if (field.tag == null) continue;

        const field_name = try toSnakeCase(allocator, field.name);
        defer allocator.free(field_name);

        const version_range = try parseVersionRange(field.taggedVersions.?);
        const tag = field.tag.?;

        try writer.print(
            \\
            \\            // Tagged field: {s} (tag {d})
            \\            if (version >= {d} and version <= {d}) {{
            \\
        , .{ field.name, tag, version_range.min, version_range.max });

        const zig_type = try getZigType(allocator, field);
        defer allocator.free(zig_type);

        if (std.mem.startsWith(u8, zig_type, "?")) {
            try writer.print("                if (self.{s}) |val| {{\n", .{field_name});
            try writer.print("                    total_size += types.computeSizeUnsignedVarInt({d});\n", .{tag});

            if (std.mem.indexOf(u8, field.type, "string") != null or std.mem.indexOf(u8, field.type, "String") != null) {
                try writer.writeAll("                    const size = types.computeSizeCompactString(val);\n");
                try writer.writeAll("                    total_size += types.computeSizeUnsignedVarInt(@intCast(size));\n");
                try writer.writeAll("                    total_size += size;\n");
            } else if (std.mem.startsWith(u8, field.type, "[]")) {
                // Array type
                const element_type = field.type[2..];
                if (field.fields != null) {
                    // Array of structs
                    try writer.writeAll("                    var array_size: usize = types.computeSizeUnsignedVarInt(@intCast(val.len + 1));\n");
                    try writer.writeAll("                    for (val) |*item| {\n");
                    try writer.print("                        array_size += try {s}.computeSize(item, version);\n", .{element_type});
                    try writer.writeAll("                    }\n");
                    try writer.writeAll("                    total_size += types.computeSizeUnsignedVarInt(@intCast(array_size));\n");
                    try writer.writeAll("                    total_size += array_size;\n");
                } else {
                    // Array of primitives - TODO
                    try writer.writeAll("                    // TODO: Array of primitives\n");
                }
            } else if (field.fields != null) {
                try writer.print("                    const size = try {s}.computeSize(&val, version);\n", .{field.name});
                try writer.writeAll("                    total_size += types.computeSizeUnsignedVarInt(@intCast(size));\n");
                try writer.writeAll("                    total_size += size;\n");
            } else {
                const compute_fn = try getComputeSizeFunctionName(allocator, field.type);
                defer allocator.free(compute_fn);
                try writer.print("                    const size = {s}(val);\n", .{compute_fn});
                try writer.writeAll("                    total_size += types.computeSizeUnsignedVarInt(@intCast(size));\n");
                try writer.writeAll("                    total_size += size;\n");
            }

            try writer.writeAll("                }\n");
        } else if (field.fields != null) {
            try writer.print("                if (!std.mem.eql(u8, std.mem.asBytes(&self.{s}), std.mem.asBytes(&@as({s}, .{{}})))) {{\n", .{ field_name, field.name });
            try writer.print("                    total_size += types.computeSizeUnsignedVarInt({d});\n", .{tag});
            try writer.print("                    const size = try {s}.computeSize(&self.{s}, version);\n", .{ field.name, field_name });
            try writer.writeAll("                    total_size += types.computeSizeUnsignedVarInt(@intCast(size));\n");
            try writer.writeAll("                    total_size += size;\n");
            try writer.writeAll("                }\n");
        } else {
            const default_value = try getDefaultValue(allocator, field);
            defer allocator.free(default_value);
            if (default_value.len > 0) {
                try writer.print("                if (self.{s} != {s}) {{\n", .{ field_name, default_value });
            } else {
                try writer.writeAll("                {\n");
            }
            try writer.print("                    total_size += types.computeSizeUnsignedVarInt({d});\n", .{tag});

            const compute_fn = try getComputeSizeFunctionName(allocator, field.type);
            defer allocator.free(compute_fn);
            try writer.print("                    const size = {s}(self.{s});\n", .{ compute_fn, field_name });
            try writer.writeAll("                    total_size += types.computeSizeUnsignedVarInt(@intCast(size));\n");
            try writer.writeAll("                    total_size += size;\n");
            try writer.writeAll("                }\n");
        }

        try writer.writeAll("            }\n");
    }

    try writer.writeAll(
        \\
        \\            if (self._tagged_fields) |fields| {
        \\                total_size += types.computeSizeTaggedFields(fields);
        \\            }
        \\        }
        \\
        \\        return total_size;
        \\    }
        \\
        \\
    );
}

fn generateFieldComputeSize(writer: anytype, field: FieldSpec, allocator: Allocator) !void {
    const field_name = try toSnakeCase(allocator, field.name);
    defer allocator.free(field_name);

    const version_range = try parseVersionRange(field.versions);

    try writer.print("        // Field: {s}\n", .{field.name});
    try writer.print("        if (version >= {d} and version <= {d}) {{\n", .{ version_range.min, version_range.max });

    if (std.mem.startsWith(u8, field.type, "[]")) {
        const element_type = field.type[2..];
        const is_struct = field.fields != null;

        // Non-nullable arrays: null means empty (varint 1 / i32 0), nullable: null means null (varint 0 / i32 -1)
        const null_compact_size = if (isNullable(field)) "types.computeSizeUnsignedVarInt(0)" else "types.computeSizeUnsignedVarInt(1)";

        if (is_struct) {
            // Array of structs
            try writer.print(
                \\            if (self.{s}) |arr| {{
                \\                const len: u32 = @intCast(arr.len + 1);
                \\                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                \\                for (arr) |*item| {{
                \\                    total_size += try {s}.computeSize(item, version);
                \\                }}
                \\            }} else {{
                \\                total_size += if (is_flexible) {s} else 4;
                \\            }}
                \\
            , .{ field_name, element_type, null_compact_size });
        } else {
            // Array of primitives
            const compute_fn = try getComputeSizeFunctionName(allocator, element_type);
            defer allocator.free(compute_fn);

            try writer.print(
                \\            if (self.{s}) |arr| {{
                \\                const len: u32 = @intCast(arr.len + 1);
                \\                total_size += if (is_flexible) types.computeSizeUnsignedVarInt(len) else 4;
                \\                for (arr) |item| {{
                \\                    total_size += {s}(item);
                \\                }}
                \\            }} else {{
                \\                total_size += if (is_flexible) {s} else 4;
                \\            }}
                \\
            , .{ field_name, compute_fn, null_compact_size });
        }
    } else {
        // Primitive or custom struct type
        const compute_fn = try getComputeSizeFunctionName(allocator, field.type);
        defer allocator.free(compute_fn);

        // Check if it's a custom struct (needs version parameter)
        if (isPrimitiveType(field.type) or std.mem.eql(u8, field.type, "uuid")) {
            // Primitive (int/bool/uuid) - no version needed, no flexibility
            try writer.print("            total_size += {s}(self.{s});\n", .{ compute_fn, field_name });
        } else if (std.mem.eql(u8, field.type, "string") or std.mem.eql(u8, field.type, "bytes")) {
            // String/bytes - needs flexible vs non-flexible handling
            const non_compact_fn = if (std.mem.eql(u8, field.type, "string"))
                "types.computeSizeString"
            else
                "types.computeSizeBytes";
            if (isFieldNeverFlexible(field)) {
                // Per-field flexibleVersions: "none" — always use non-compact size
                try writer.print(
                    \\            total_size += {s}(self.{s});
                    \\
                , .{ non_compact_fn, field_name });
            } else {
                try writer.print(
                    \\            total_size += if (is_flexible) {s}(self.{s}) else {s}(self.{s});
                    \\
                , .{ compute_fn, field_name, non_compact_fn, field_name });
            }
        } else if (std.mem.eql(u8, field.type, "records")) {
            // Records type ALWAYS uses i32 length prefix (NULLABLE_BYTES),
            // even in flexible versions.
            try writer.print(
                \\            total_size += types.computeSizeBytes(self.{s});
                \\
            , .{field_name});
        } else {
            // Custom struct - needs version parameter
            try writer.print("            total_size += try {s}(&self.{s}, version);\n", .{ compute_fn, field_name });
        }
    }

    try writer.writeAll("        }\n\n");
}

fn generateEncodeFunction(output: *ArrayList(u8), spec: MessageSpec, allocator: Allocator) !void {
    const writer = output.writer();

    try writer.print(
        \\    /// Encode {s}
        \\    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {{
        \\        if (!isValidVersion(version)) {{
        \\            return types.Error.UnsupportedVersion;
        \\        }}
        \\        const is_flexible = isFlexibleVersion(version);
        \\        _ = &is_flexible;
        \\
        \\
    , .{spec.name});

    // Encode regular (non-tagged) fields only
    for (spec.fields) |field| {
        if (field.taggedVersions != null) continue;
        try generateFieldEncode(writer, field, allocator);
    }

    // Generate tagged fields encoding
    try writer.writeAll(
        \\
        \\        if (is_flexible) {
        \\            var num_tagged_fields: u32 = 0;
        \\
    );

    // Count and encode tagged fields
    for (spec.fields) |field| {
        if (field.taggedVersions == null) continue;

        const field_name = try toSnakeCase(allocator, field.name);
        defer allocator.free(field_name);

        const version_range = try parseVersionRange(field.taggedVersions.?);

        // Check if field should be encoded for this version
        try writer.print(
            \\            if (version >= {d} and version <= {d}) {{
            \\
        , .{ version_range.min, version_range.max });

        // Check if field is non-default (for optional fields)
        const zig_type = try getZigType(allocator, field);
        defer allocator.free(zig_type);

        if (std.mem.startsWith(u8, zig_type, "?")) {
            try writer.print("                if (self.{s} != null) num_tagged_fields += 1;\n", .{field_name});
        } else if (field.fields != null) {
            // Struct type - check if it's non-default
            try writer.print("                if (!std.mem.eql(u8, std.mem.asBytes(&self.{s}), std.mem.asBytes(&@as({s}, .{{}})))) num_tagged_fields += 1;\n", .{ field_name, field.name });
        } else {
            // Primitive type with explicit default check
            const default_value = try getDefaultValue(allocator, field);
            defer allocator.free(default_value);
            if (default_value.len > 0) {
                try writer.print("                if (self.{s} != {s}) num_tagged_fields += 1;\n", .{ field_name, default_value });
            } else {
                try writer.print("                num_tagged_fields += 1;\n", .{});
            }
        }

        try writer.writeAll("            }\n");
    }

    try writer.writeAll(
        \\
        \\            // Count unknown tagged fields
        \\            if (self._tagged_fields) |fields| {
        \\                num_tagged_fields += @intCast(fields.len);
        \\            }
        \\
        \\            try types.encodeUnsignedVarInt(writer, num_tagged_fields);
        \\
    );

    // Now encode each tagged field with its tag number
    for (spec.fields) |field| {
        if (field.taggedVersions == null) continue;
        if (field.tag == null) continue;

        const field_name = try toSnakeCase(allocator, field.name);
        defer allocator.free(field_name);

        const version_range = try parseVersionRange(field.taggedVersions.?);
        const tag = field.tag.?;

        try writer.print(
            \\
            \\            // Tagged field: {s} (tag {d})
            \\            if (version >= {d} and version <= {d}) {{
            \\
        , .{ field.name, tag, version_range.min, version_range.max });

        const zig_type = try getZigType(allocator, field);
        defer allocator.free(zig_type);

        // Check if field should be written (non-default)
        if (std.mem.startsWith(u8, zig_type, "?")) {
            try writer.print("                if (self.{s}) |val| {{\n", .{field_name});
            try writer.print("                    try types.encodeUnsignedVarInt(writer, {d});\n", .{tag});

            // Encode the value
            if (std.mem.indexOf(u8, field.type, "string") != null or std.mem.indexOf(u8, field.type, "String") != null) {
                try writer.writeAll("                    const size = types.computeSizeCompactString(val);\n");
                try writer.writeAll("                    try types.encodeUnsignedVarInt(writer, @intCast(size));\n");
                try writer.writeAll("                    try types.encodeCompactString(writer, val);\n");
            } else if (std.mem.startsWith(u8, field.type, "[]")) {
                // Array type - need to encode array elements
                const element_type = field.type[2..];
                if (field.fields != null) {
                    // Array of structs
                    try writer.writeAll("                    // Compute size of array\n");
                    try writer.writeAll("                    var array_size: usize = types.computeSizeUnsignedVarInt(@intCast(val.len + 1));\n");
                    try writer.writeAll("                    for (val) |*item| {\n");
                    try writer.print("                        array_size += try {s}.computeSize(item, version);\n", .{element_type});
                    try writer.writeAll("                    }\n");
                    try writer.writeAll("                    try types.encodeUnsignedVarInt(writer, @intCast(array_size));\n");
                    try writer.writeAll("                    try types.encodeUnsignedVarInt(writer, @intCast(val.len + 1));\n");
                    try writer.writeAll("                    for (val) |*item| {\n");
                    try writer.print("                        try {s}.encode(item, writer, version);\n", .{element_type});
                    try writer.writeAll("                    }\n");
                } else {
                    // Array of primitives
                    const encode_fn = try getEncodeFunctionName(allocator, element_type);
                    defer allocator.free(encode_fn);
                    try writer.writeAll("                    // TODO: Handle array of primitives in tagged fields\n");
                }
            } else if (field.fields != null) {
                // Nested struct
                try writer.print("                    const size = try {s}.computeSize(&val, version);\n", .{field.name});
                try writer.writeAll("                    try types.encodeUnsignedVarInt(writer, @intCast(size));\n");
                try writer.print("                    try {s}.encode(&val, writer, version);\n", .{field.name});
            } else {
                // Primitive type
                const encode_fn = try getEncodeFunctionName(allocator, field.type);
                defer allocator.free(encode_fn);
                const compute_fn = try getComputeSizeFunctionName(allocator, field.type);
                defer allocator.free(compute_fn);
                try writer.print("                    const size = {s}(val);\n", .{compute_fn});
                try writer.writeAll("                    try types.encodeUnsignedVarInt(writer, @intCast(size));\n");
                try writer.print("                    try {s}(writer, val);\n", .{encode_fn});
            }

            try writer.writeAll("                }\n");
        } else if (field.fields != null) {
            // Non-optional struct - check if non-default
            try writer.print("                if (!std.mem.eql(u8, std.mem.asBytes(&self.{s}), std.mem.asBytes(&@as({s}, .{{}})))) {{\n", .{ field_name, field.name });
            try writer.print("                    try types.encodeUnsignedVarInt(writer, {d});\n", .{tag});
            try writer.print("                    const size = try {s}.computeSize(&self.{s}, version);\n", .{ field.name, field_name });
            try writer.writeAll("                    try types.encodeUnsignedVarInt(writer, @intCast(size));\n");
            try writer.print("                    try {s}.encode(&self.{s}, writer, version);\n", .{ field.name, field_name });
            try writer.writeAll("                }\n");
        } else {
            // Non-optional primitive with default check
            const default_value = try getDefaultValue(allocator, field);
            defer allocator.free(default_value);
            if (default_value.len > 0) {
                try writer.print("                if (self.{s} != {s}) {{\n", .{ field_name, default_value });
            } else {
                try writer.writeAll("                {\n");
            }
            try writer.print("                    try types.encodeUnsignedVarInt(writer, {d});\n", .{tag});
            const encode_fn = try getEncodeFunctionName(allocator, field.type);
            defer allocator.free(encode_fn);

            const compute_fn = try getComputeSizeFunctionName(allocator, field.type);
            defer allocator.free(compute_fn);
            try writer.print("                    const size = {s}(self.{s});\n", .{ compute_fn, field_name });
            try writer.writeAll("                    try types.encodeUnsignedVarInt(writer, @intCast(size));\n");
            try writer.print("                    try {s}(writer, self.{s});\n", .{ encode_fn, field_name });
            try writer.writeAll("                }\n");
        }

        try writer.writeAll("            }\n");
    }

    try writer.writeAll(
        \\
        \\            // Encode unknown tagged fields
        \\            if (self._tagged_fields) |fields| {
        \\                try types.encodeTaggedFields(writer, fields);
        \\            }
        \\        }
        \\    }
        \\
        \\
    );
}

fn generateFieldEncode(writer: anytype, field: FieldSpec, allocator: Allocator) !void {
    const field_name = try toSnakeCase(allocator, field.name);
    defer allocator.free(field_name);

    const version_range = try parseVersionRange(field.versions);

    try writer.print("        // Field: {s}\n", .{field.name});
    try writer.print("        if (version >= {d} and version <= {d}) {{\n", .{ version_range.min, version_range.max });

    if (std.mem.startsWith(u8, field.type, "[]")) {
        const element_type = field.type[2..];
        const is_struct = field.fields != null;

        if (is_struct) {
            const compact_fn = if (isNullable(field)) "encodeCompactArrayLen" else "encodeCompactArrayLenNonNull";
            const classic_fn = if (isNullable(field)) "encodeArrayLen" else "encodeArrayLenNonNull";
            try writer.print(
                \\            if (is_flexible) {{
                \\                try types.{s}(writer, self.{s});
                \\                if (self.{s}) |arr| {{
                \\                    for (arr) |*item| {{
                \\                        try {s}.encode(item, writer, version);
                \\                    }}
                \\                }}
                \\            }} else {{
                \\                try types.{s}(writer, self.{s});
                \\                if (self.{s}) |arr| {{
                \\                    for (arr) |*item| {{
                \\                        try {s}.encode(item, writer, version);
                \\                    }}
                \\                }}
                \\            }}
                \\
            , .{ compact_fn, field_name, field_name, element_type, classic_fn, field_name, field_name, element_type });
        } else {
            const encode_fn = try getEncodeFunctionName(allocator, element_type);
            defer allocator.free(encode_fn);

            // Convert element_type to Zig type (int32 -> i32, etc.)
            const zig_element_type = try getZigPrimitiveType(allocator, element_type);
            defer allocator.free(zig_element_type);

            const compact_array_fn = if (isNullable(field)) "encodeCompactArray" else "encodeCompactArrayNonNull";
            const classic_array_fn = if (isNullable(field)) "encodeArray" else "encodeArrayNonNull";

            try writer.print(
                \\            if (is_flexible) {{
                \\                try types.{s}({s}, writer, self.{s}, {s});
                \\            }} else {{
                \\                try types.{s}({s}, writer, self.{s}, {s});
                \\            }}
                \\
            , .{ compact_array_fn, zig_element_type, field_name, encode_fn, classic_array_fn, zig_element_type, field_name, encode_fn });
        }
    } else {
        const encode_fn = try getEncodeFunctionName(allocator, field.type);
        defer allocator.free(encode_fn);

        // Check if it's a custom struct (needs version parameter)
        if (isPrimitiveType(field.type) or std.mem.eql(u8, field.type, "uuid")) {
            // Primitive (int/bool/uuid) - no version needed, no flexibility
            try writer.print("            try {s}(writer, self.{s});\n", .{ encode_fn, field_name });
        } else if (std.mem.eql(u8, field.type, "string") or std.mem.eql(u8, field.type, "bytes")) {
            // String/bytes - needs flexible vs non-flexible handling
            const non_compact_fn = if (std.mem.eql(u8, field.type, "string"))
                "types.encodeString"
            else
                "types.encodeBytes";
            if (isFieldNeverFlexible(field)) {
                // Per-field flexibleVersions: "none" — always use non-compact encoding
                try writer.print(
                    \\            try {s}(writer, self.{s});
                    \\
                , .{ non_compact_fn, field_name });
            } else {
                try writer.print(
                    \\            if (is_flexible) {{
                    \\                try {s}(writer, self.{s});
                    \\            }} else {{
                    \\                try {s}(writer, self.{s});
                    \\            }}
                    \\
                , .{ encode_fn, field_name, non_compact_fn, field_name });
            }
        } else if (std.mem.eql(u8, field.type, "records")) {
            // Records type ALWAYS uses i32 length prefix (NULLABLE_BYTES),
            // even in flexible versions. Per Kafka protocol spec, the
            // "records" type never uses compact encoding.
            try writer.print(
                \\            try types.encodeBytes(writer, self.{s});
                \\
            , .{field_name});
        } else {
            // Custom struct - needs version parameter
            try writer.print("            try {s}(&self.{s}, writer, version);\n", .{ encode_fn, field_name });
        }
    }

    try writer.writeAll("        }\n\n");
}

fn generateDecodeFunction(output: *ArrayList(u8), spec: MessageSpec, allocator: Allocator) !void {
    const writer = output.writer();

    try writer.print(
        \\    /// Decode {s}
        \\    pub fn decode(reader: anytype, version: i16, allocator: std.mem.Allocator) !Self {{
        \\        if (!isValidVersion(version)) {{
        \\            return types.Error.UnsupportedVersion;
        \\        }}
        \\        const is_flexible = isFlexibleVersion(version);
        \\        var self: Self = .{{}};
        \\
        \\
    , .{spec.name});

    // Decode regular (non-tagged) fields
    for (spec.fields) |field| {
        if (field.taggedVersions != null) continue;
        try generateFieldDecode(writer, field, allocator);
    }

    // Generate tagged fields decoding
    try writer.writeAll(
        \\
        \\        if (is_flexible) {
        \\            const num_tagged_fields = try types.decodeUnsignedVarInt(reader);
        \\            var unknown_tagged_fields = std.array_list.Managed(types.TaggedField).init(allocator);
        \\
        \\            var i: u32 = 0;
        \\            while (i < num_tagged_fields) : (i += 1) {
        \\                const tag = try types.decodeUnsignedVarInt(reader);
        \\                const size = try types.decodeUnsignedVarInt(reader);
        \\
    );

    // Generate switch cases for known tagged fields
    const has_tagged_fields = blk: {
        for (spec.fields) |field| {
            if (field.taggedVersions != null and field.tag != null) break :blk true;
        }
        break :blk false;
    };

    if (has_tagged_fields) {
        try writer.writeAll(
            \\                switch (tag) {
            \\
        );

        for (spec.fields) |field| {
            if (field.taggedVersions == null or field.tag == null) continue;

            const field_name = try toSnakeCase(allocator, field.name);
            defer allocator.free(field_name);

            const tag = field.tag.?;
            const version_range = try parseVersionRange(field.taggedVersions.?);

            try writer.print(
                \\                    {d} => {{ // {s}
                \\                        if (version >= {d} and version <= {d}) {{
                \\
            , .{ tag, field.name, version_range.min, version_range.max });

            // Decode the tagged field value
            if (std.mem.indexOf(u8, field.type, "string") != null or std.mem.indexOf(u8, field.type, "String") != null) {
                try writer.print("                            self.{s} = try types.decodeCompactString(reader, allocator);\n", .{field_name});
            } else if (std.mem.startsWith(u8, field.type, "[]")) {
                // Array type
                const element_type = field.type[2..];
                if (field.fields != null) {
                    // Array of structs
                    try writer.writeAll("                            const array_len = try types.decodeCompactArrayLen(reader);\n");
                    try writer.print("                            const array = try allocator.alloc({s}, array_len);\n", .{element_type});
                    try writer.writeAll("                            for (array) |*item| {\n");
                    try writer.print("                                item.* = try {s}.decode(reader, version, allocator);\n", .{element_type});
                    try writer.writeAll("                            }\n");
                    try writer.print("                            self.{s} = array;\n", .{field_name});
                } else {
                    // Array of primitives - TODO
                    try writer.writeAll("                            // TODO: Decode array of primitives\n");
                }
            } else if (field.fields != null) {
                // Nested struct
                try writer.print("                            self.{s} = try {s}.decode(reader, version, allocator);\n", .{ field_name, field.name });
            } else {
                // Primitive type
                const decode_fn = try getDecodeFunctionName(allocator, field.type);
                defer allocator.free(decode_fn);

                const zig_type = try getZigType(allocator, field);
                defer allocator.free(zig_type);

                if (std.mem.startsWith(u8, zig_type, "?")) {
                    try writer.print("                            self.{s} = try {s}(reader);\n", .{ field_name, decode_fn });
                } else {
                    try writer.print("                            self.{s} = try {s}(reader);\n", .{ field_name, decode_fn });
                }
            }

            try writer.writeAll(
                \\                        } else {
                \\                            try reader.skipBytes(size, .{});
                \\                        }
                \\                    },
                \\
            );
        }

        try writer.writeAll(
            \\                    else => {
            \\                        const field_data = try allocator.alloc(u8, size);
            \\                        _ = try reader.readAll(field_data);
            \\                        try unknown_tagged_fields.append(.{ .tag = tag, .data = field_data });
            \\                    },
            \\                }
            \\
        );
    } else {
        try writer.writeAll(
            \\                const field_data = try allocator.alloc(u8, size);
            \\                _ = try reader.readAll(field_data);
            \\                try unknown_tagged_fields.append(.{ .tag = tag, .data = field_data });
            \\
        );
    }

    try writer.writeAll(
        \\            }
        \\
        \\            if (unknown_tagged_fields.items.len > 0) {
        \\                self._tagged_fields = try unknown_tagged_fields.toOwnedSlice();
        \\            }
        \\        }
        \\
        \\        return self;
        \\    }
        \\
        \\
    );
}

fn generateFieldDecode(writer: anytype, field: FieldSpec, allocator: Allocator) !void {
    const field_name = try toSnakeCase(allocator, field.name);
    defer allocator.free(field_name);

    const version_range = try parseVersionRange(field.versions);

    try writer.print("        // Field: {s}\n", .{field.name});
    try writer.print("        if (version >= {d} and version <= {d}) {{\n", .{ version_range.min, version_range.max });

    if (std.mem.startsWith(u8, field.type, "[]")) {
        const element_type = field.type[2..];
        const is_struct = field.fields != null;

        if (is_struct) {
            if (isNullable(field)) {
                // Nullable struct array: check for null length marker
                try writer.print(
                    \\            const raw_len: i32 = if (is_flexible) blk: {{
                    \\                const v = try types.decodeUnsignedVarInt(reader);
                    \\                break :blk if (v == 0) @as(i32, -1) else @as(i32, @intCast(v - 1));
                    \\            }} else try types.decodeInt32(reader);
                    \\            if (raw_len < 0) {{
                    \\                self.{s} = null;
                    \\            }} else {{
                    \\                const array_len: usize = @intCast(raw_len);
                    \\                const array = try allocator.alloc({s}, array_len);
                    \\                for (array) |*item| {{
                    \\                    item.* = try {s}.decode(reader, version, allocator);
                    \\                }}
                    \\                self.{s} = array;
                    \\            }}
                    \\
                , .{ field_name, element_type, element_type, field_name });
            } else {
                try writer.print(
                    \\            const array_len = if (is_flexible) try types.decodeCompactArrayLen(reader) else try types.decodeArrayLen(reader);
                    \\            const array = try allocator.alloc({s}, array_len);
                    \\            for (array) |*item| {{
                    \\                item.* = try {s}.decode(reader, version, allocator);
                    \\            }}
                    \\            self.{s} = array;
                    \\
                , .{ element_type, element_type, field_name });
            }
        } else {
            const decode_fn = try getDecodeFunctionName(allocator, element_type);
            defer allocator.free(decode_fn);
            const zig_type = try getZigPrimitiveType(allocator, element_type);
            defer allocator.free(zig_type);
            const is_primitive = isPrimitiveType(element_type);

            if (is_primitive) {
                try writer.print(
                    \\            self.{s} = if (is_flexible)
                    \\                try types.decodeCompactPrimitiveArray({s}, reader, allocator, {s})
                    \\            else
                    \\                try types.decodePrimitiveArray({s}, reader, allocator, {s});
                    \\
                , .{ field_name, zig_type, decode_fn, zig_type, decode_fn });
            } else if (std.mem.eql(u8, element_type, "string")) {
                // String arrays: elements are non-nullable, use NonNullable wrappers
                try writer.print(
                    \\            self.{s} = if (is_flexible)
                    \\                try types.decodeCompactArray({s}, reader, allocator, types.decodeNonNullableCompactString)
                    \\            else
                    \\                try types.decodeArray({s}, reader, allocator, types.decodeNonNullableString);
                    \\
                , .{ field_name, zig_type, zig_type });
            } else if (std.mem.eql(u8, element_type, "bytes")) {
                // Bytes arrays: elements are non-nullable, use NonNullable wrappers
                try writer.print(
                    \\            self.{s} = if (is_flexible)
                    \\                try types.decodeCompactArray({s}, reader, allocator, types.decodeNonNullableCompactBytes)
                    \\            else
                    \\                try types.decodeArray({s}, reader, allocator, types.decodeNonNullableBytes);
                    \\
                , .{ field_name, zig_type, zig_type });
            } else {
                try writer.print(
                    \\            self.{s} = if (is_flexible)
                    \\                try types.decodeCompactArray({s}, reader, allocator, {s})
                    \\            else
                    \\                try types.decodeArray({s}, reader, allocator, {s});
                    \\
                , .{ field_name, zig_type, decode_fn, zig_type, decode_fn });
            }
        }
    } else {
        const decode_fn = try getDecodeFunctionName(allocator, field.type);
        defer allocator.free(decode_fn);

        // Check if it's a custom struct (needs version parameter)
        if (isPrimitiveType(field.type) or std.mem.eql(u8, field.type, "uuid")) {
            // Primitive - no version, no allocator
            try writer.print("            self.{s} = try {s}(reader);\n", .{ field_name, decode_fn });
        } else if (std.mem.eql(u8, field.type, "string") or std.mem.eql(u8, field.type, "bytes")) {
            // String/bytes - needs flexible vs non-flexible handling
            const non_compact_fn = if (std.mem.eql(u8, field.type, "string"))
                "types.decodeString"
            else
                "types.decodeBytes";
            if (isFieldNeverFlexible(field)) {
                // Per-field flexibleVersions: "none" — always use non-compact decoding
                if (isNullable(field)) {
                    try writer.print(
                        \\            self.{s} = try {s}(reader, allocator);
                        \\
                    , .{ field_name, non_compact_fn });
                } else {
                    try writer.print(
                        \\            self.{s} = try {s}(reader, allocator) orelse "";
                        \\
                    , .{ field_name, non_compact_fn });
                }
            } else if (isNullable(field)) {
                // Nullable: preserve null from wire
                try writer.print(
                    \\            self.{s} = if (is_flexible)
                    \\                try {s}(reader, allocator)
                    \\            else
                    \\                try {s}(reader, allocator);
                    \\
                , .{ field_name, decode_fn, non_compact_fn });
            } else {
                // Non-nullable: coerce wire null to empty
                try writer.print(
                    \\            self.{s} = if (is_flexible)
                    \\                try {s}(reader, allocator) orelse ""
                    \\            else
                    \\                try {s}(reader, allocator) orelse "";
                    \\
                , .{ field_name, decode_fn, non_compact_fn });
            }
        } else if (std.mem.eql(u8, field.type, "records")) {
            // Records type ALWAYS uses i32 length prefix (NULLABLE_BYTES),
            // even in flexible versions. Per Kafka protocol spec, the
            // "records" type never uses compact encoding.
            if (isNullable(field)) {
                try writer.print(
                    \\            self.{s} = try types.decodeBytes(reader, allocator);
                    \\
                , .{field_name});
            } else {
                try writer.print(
                    \\            self.{s} = try types.decodeBytes(reader, allocator) orelse "";
                    \\
                , .{field_name});
            }
        } else {
            // Custom struct - needs reader, version, allocator
            try writer.print("            self.{s} = try {s}(reader, version, allocator);\n", .{ field_name, decode_fn });
        }
    }

    try writer.writeAll("        }\n\n");
}

fn generateUtilityFunctions(output: *ArrayList(u8), spec: MessageSpec) !void {
    const writer = output.writer();

    try writer.print(
        \\    /// Check if version is valid
        \\    pub fn isValidVersion(version: i16) bool {{
        \\        const range = types.VersionRange.parse("{s}") catch return false;
        \\        return range.contains(version);
        \\    }}
        \\
    , .{spec.validVersions});

    if (spec.flexibleVersions) |flexible| {
        try writer.print(
            \\    /// Check if version uses flexible encoding
            \\    pub fn isFlexibleVersion(version: i16) bool {{
            \\        const range = types.VersionRange.parse("{s}") catch return false;
            \\        return range.contains(version);
            \\    }}
        , .{flexible});
    } else {
        try writer.writeAll(
            \\    /// Check if version uses flexible encoding
            \\    pub fn isFlexibleVersion(version: i16) bool {
            \\        _ = version;
            \\        return false;
            \\    }
        );
    }

    // NEW: Generate headerVersion() function
    try writer.writeAll(
        \\
        \\    /// Get the header version for this API version
        \\    /// Returns 2 for flexible versions, 1 for classic versions
        \\    pub fn headerVersion(api_version: i16) i16 {
        \\        if (isFlexibleVersion(api_version)) return 2;
        \\        return 1;
        \\    }
        \\
    );

    try writer.writeAll(
        \\
        \\};
        \\
    );
}

// ============================================================================
// NESTED STRUCT GENERATION
// ============================================================================

fn collectNestedStructs(fields: []const FieldSpec, nested_structs: *ArrayList(NestedStruct), allocator: Allocator) !void {
    for (fields) |field| {
        // Handle arrays of structs: []FetchPartition
        if (std.mem.startsWith(u8, field.type, "[]") and field.fields != null) {
            const struct_name = try extractTypeName(allocator, field.type);
            defer allocator.free(struct_name);

            if (field.fields) |nested_fields| {
                try collectNestedStructs(nested_fields, nested_structs, allocator);

                const owned_name = try allocator.dupe(u8, struct_name);
                try nested_structs.append(.{
                    .name = owned_name,
                    .fields = nested_fields,
                    .versions = field.versions,
                });
            }
        }
        // Handle inline nested structs with custom type names: EpochEndOffset, ReplicaState, etc.
        else if (field.fields != null and !isPrimitiveType(field.type) and !std.mem.eql(u8, field.type, "string") and !std.mem.eql(u8, field.type, "bytes")) {
            if (field.fields) |nested_fields| {
                try collectNestedStructs(nested_fields, nested_structs, allocator);

                const owned_name = try allocator.dupe(u8, field.type);
                try nested_structs.append(.{
                    .name = owned_name,
                    .fields = nested_fields,
                    .versions = field.versions,
                });
            }
        }
    }
}

fn extractTypeName(allocator: Allocator, type_str: []const u8) ![]u8 {
    if (std.mem.startsWith(u8, type_str, "[]")) {
        return try allocator.dupe(u8, type_str[2..]);
    }
    return try allocator.dupe(u8, type_str);
}

fn generateNestedStruct(output: *ArrayList(u8), nested: NestedStruct, parent_spec: MessageSpec, allocator: Allocator) !void {
    const writer = output.writer();

    try writer.print("/// Nested struct: {s}\n", .{nested.name});
    try writer.print("pub const {s} = struct {{\n", .{nested.name});
    try writer.writeAll("    const Self = @This();\n\n");

    // Generate fields (skip tagged fields - they go in _tagged_fields)
    for (nested.fields) |field| {
        // Skip fields with taggedVersions - they are encoded as tagged fields
        if (field.taggedVersions != null) continue;

        if (field.about) |about| {
            try writer.print("    /// {s}\n", .{about});
        }
        try writer.print("    /// Versions: {s}\n", .{field.versions});

        const field_name = try toSnakeCase(allocator, field.name);
        defer allocator.free(field_name);

        const zig_type = try getZigType(allocator, field);
        defer allocator.free(zig_type);

        const default_value = try getDefaultValue(allocator, field);
        defer allocator.free(default_value);

        try writer.print("    {s}: {s}", .{ field_name, zig_type });
        if (default_value.len > 0) {
            try writer.print(" = {s}", .{default_value});
        }
        try writer.writeAll(",\n");
    }

    // Add tagged fields for forward compatibility (flexible versions only)
    try writer.writeAll("\n    /// Tagged fields for forward compatibility\n");
    try writer.writeAll("    _tagged_fields: ?[]types.TaggedField = null,\n");

    try writer.writeAll("\n");

    // Add encode method
    try writer.print("    pub fn encode(self: *const Self, writer: anytype, version: i16) !void {{\n", .{});
    try writer.writeAll("        const is_flexible = isFlexibleVersion(version);\n");
    try writer.writeAll("        _ = &is_flexible;\n");
    try writer.writeAll("\n");

    // Encode regular (non-tagged) fields only
    for (nested.fields) |field| {
        if (field.taggedVersions != null) continue;
        try generateFieldEncode(writer, field, allocator);
    }

    // Add tagged fields encoding for flexible versions
    try writer.writeAll(
        \\
        \\        if (is_flexible) {
        \\            if (self._tagged_fields) |fields| {
        \\                try types.encodeTaggedFields(writer, fields);
        \\            } else {
        \\                try types.encodeUnsignedVarInt(writer, 0);
        \\            }
        \\        }
    );

    try writer.writeAll("\n    }\n\n");

    // NEW: Add computeSize method
    try writer.print("    pub fn computeSize(self: *const Self, version: i16) !usize {{\n", .{});
    try writer.writeAll("        const is_flexible = isFlexibleVersion(version);\n");
    try writer.writeAll("        _ = &is_flexible;\n");
    try writer.writeAll("        var total_size: usize = 0;\n\n");

    // Compute size for regular (non-tagged) fields only
    for (nested.fields) |field| {
        if (field.taggedVersions != null) continue;
        try generateFieldComputeSize(writer, field, allocator);
    }

    // Add tagged fields size for flexible versions
    try writer.writeAll(
        \\
        \\        if (is_flexible) {
        \\            if (self._tagged_fields) |fields| {
        \\                total_size += types.computeSizeTaggedFields(fields);
        \\            } else {
        \\                total_size += 1; // Empty tagged fields marker
        \\            }
        \\        }
        \\
    );

    try writer.writeAll("        return total_size;\n");
    try writer.writeAll("    }\n\n");

    // Add decode method
    try writer.print("    pub fn decode(reader: anytype, version: i16, allocator: std.mem.Allocator) !Self {{\n", .{});
    try writer.writeAll("        const is_flexible = isFlexibleVersion(version);\n");
    try writer.writeAll("        _ = &is_flexible;\n");
    try writer.writeAll("        _ = &allocator;\n");
    try writer.print("        var self: Self = .{{}};\n", .{});

    // Decode regular (non-tagged) fields only
    for (nested.fields) |field| {
        if (field.taggedVersions != null) continue;
        try generateFieldDecode(writer, field, allocator);
    }

    // Add tagged fields decoding for flexible versions
    try writer.writeAll(
        \\
        \\        if (is_flexible) {
        \\            const tagged_fields_data = try types.decodeTaggedFields(reader, allocator);
        \\            self._tagged_fields = tagged_fields_data;
        \\        }
        \\
    );

    try writer.writeAll("        return self;\n");
    try writer.writeAll("    }\n");

    // Use parent's flexible versions for nested struct
    if (parent_spec.flexibleVersions) |flexible| {
        try writer.print(
            \\
            \\    fn isFlexibleVersion(version: i16) bool {{
            \\        const range = types.VersionRange.parse("{s}") catch return false;
            \\        return range.contains(version);
            \\    }}
        , .{flexible});
    } else {
        try writer.writeAll(
            \\
            \\    fn isFlexibleVersion(version: i16) bool {
            \\        _ = version;
            \\        return false;
            \\    }
        );
    }

    try writer.writeAll("\n};\n\n");
}

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

fn getZigType(allocator: Allocator, field: FieldSpec) ![]u8 {
    if (std.mem.startsWith(u8, field.type, "[]")) {
        const element_type = field.type[2..];
        const zig_element_type = try getZigPrimitiveType(allocator, element_type);
        defer allocator.free(zig_element_type);
        return try std.fmt.allocPrint(allocator, "?[]{s}", .{zig_element_type});
    } else {
        const base_type = try getZigPrimitiveType(allocator, field.type);
        defer allocator.free(base_type);

        if (isNullable(field)) {
            return try std.fmt.allocPrint(allocator, "?{s}", .{base_type});
        } else {
            return try allocator.dupe(u8, base_type);
        }
    }
}

fn getZigPrimitiveType(allocator: Allocator, kafka_type: []const u8) ![]u8 {
    if (std.mem.eql(u8, kafka_type, "bool")) return try allocator.dupe(u8, "bool");
    if (std.mem.eql(u8, kafka_type, "int8")) return try allocator.dupe(u8, "i8");
    if (std.mem.eql(u8, kafka_type, "int16")) return try allocator.dupe(u8, "i16");
    if (std.mem.eql(u8, kafka_type, "int32")) return try allocator.dupe(u8, "i32");
    if (std.mem.eql(u8, kafka_type, "int64")) return try allocator.dupe(u8, "i64");
    if (std.mem.eql(u8, kafka_type, "uint16")) return try allocator.dupe(u8, "u16");
    if (std.mem.eql(u8, kafka_type, "uint32")) return try allocator.dupe(u8, "u32");
    if (std.mem.eql(u8, kafka_type, "float64")) return try allocator.dupe(u8, "f64");
    if (std.mem.eql(u8, kafka_type, "string")) return try allocator.dupe(u8, "[]const u8");
    if (std.mem.eql(u8, kafka_type, "bytes")) return try allocator.dupe(u8, "[]const u8");
    if (std.mem.eql(u8, kafka_type, "uuid")) return try allocator.dupe(u8, "[16]u8");
    if (std.mem.eql(u8, kafka_type, "records")) return try allocator.dupe(u8, "[]const u8");

    // Custom type (nested struct)
    return try allocator.dupe(u8, kafka_type);
}

fn getDefaultValue(allocator: Allocator, field: FieldSpec) ![]u8 {
    if (field.default) |default| {
        switch (default) {
            .null => return try allocator.dupe(u8, "null"),
            .bool => |b| return try allocator.dupe(u8, if (b) "true" else "false"),
            .integer => |i| return try std.fmt.allocPrint(allocator, "{d}", .{i}),
            .string => |s| {
                if (std.mem.eql(u8, s, "null")) {
                    if (isNullable(field)) {
                        return try allocator.dupe(u8, "null");
                    }
                }

                // Handle bool fields with string defaults "true"/"false"
                if (std.mem.eql(u8, field.type, "bool")) {
                    if (std.mem.eql(u8, s, "true")) {
                        return try allocator.dupe(u8, "true");
                    } else if (std.mem.eql(u8, s, "false")) {
                        return try allocator.dupe(u8, "false");
                    }
                }

                if (std.mem.startsWith(u8, field.type, "int") or std.mem.startsWith(u8, field.type, "uint")) {
                    if (std.mem.startsWith(u8, s, "0x")) {
                        return try allocator.dupe(u8, s);
                    } else if (std.fmt.parseInt(i64, s, 10)) |_| {
                        return try allocator.dupe(u8, s);
                    } else |_| {
                        return try std.fmt.allocPrint(allocator, "\"{s}\"", .{s});
                    }
                } else {
                    return try std.fmt.allocPrint(allocator, "\"{s}\"", .{s});
                }
            },
            .float => |f| return try std.fmt.allocPrint(allocator, "{d}", .{f}),
            else => return try allocator.dupe(u8, ""),
        }
    }

    if (isNullable(field)) {
        return try allocator.dupe(u8, "null");
    }

    if (std.mem.eql(u8, field.type, "bool")) return try allocator.dupe(u8, "false");
    if (std.mem.startsWith(u8, field.type, "int") or std.mem.startsWith(u8, field.type, "uint")) {
        return try allocator.dupe(u8, "0");
    }
    if (std.mem.eql(u8, field.type, "float64")) return try allocator.dupe(u8, "0.0");
    if (std.mem.eql(u8, field.type, "string")) return try allocator.dupe(u8, "\"\"");
    if (std.mem.eql(u8, field.type, "bytes")) return try allocator.dupe(u8, "&[_]u8{}");
    if (std.mem.eql(u8, field.type, "uuid")) return try allocator.dupe(u8, "[_]u8{0} ** 16");
    if (std.mem.startsWith(u8, field.type, "[]")) {
        return try allocator.dupe(u8, "null");
    }

    return try allocator.dupe(u8, ".{}");
}

fn isPrimitiveType(kafka_type: []const u8) bool {
    return std.mem.eql(u8, kafka_type, "bool") or
        std.mem.eql(u8, kafka_type, "int8") or
        std.mem.eql(u8, kafka_type, "int16") or
        std.mem.eql(u8, kafka_type, "int32") or
        std.mem.eql(u8, kafka_type, "int64") or
        std.mem.eql(u8, kafka_type, "uint16") or
        std.mem.eql(u8, kafka_type, "uint32") or
        std.mem.eql(u8, kafka_type, "float64") or
        std.mem.eql(u8, kafka_type, "uuid");
}

fn getEncodeFunctionName(allocator: Allocator, kafka_type: []const u8) ![]u8 {
    if (std.mem.eql(u8, kafka_type, "bool")) return try allocator.dupe(u8, "types.encodeBoolean");
    if (std.mem.eql(u8, kafka_type, "int8")) return try allocator.dupe(u8, "types.encodeInt8");
    if (std.mem.eql(u8, kafka_type, "int16")) return try allocator.dupe(u8, "types.encodeInt16");
    if (std.mem.eql(u8, kafka_type, "int32")) return try allocator.dupe(u8, "types.encodeInt32");
    if (std.mem.eql(u8, kafka_type, "int64")) return try allocator.dupe(u8, "types.encodeInt64");
    if (std.mem.eql(u8, kafka_type, "uint16")) return try allocator.dupe(u8, "types.encodeUint16");
    if (std.mem.eql(u8, kafka_type, "uint32")) return try allocator.dupe(u8, "types.encodeUint32");
    if (std.mem.eql(u8, kafka_type, "float64")) return try allocator.dupe(u8, "types.encodeFloat64");
    if (std.mem.eql(u8, kafka_type, "string")) return try allocator.dupe(u8, "types.encodeCompactString");
    if (std.mem.eql(u8, kafka_type, "bytes")) return try allocator.dupe(u8, "types.encodeCompactBytes");
    if (std.mem.eql(u8, kafka_type, "uuid")) return try allocator.dupe(u8, "types.encodeUuid");
    if (std.mem.eql(u8, kafka_type, "records")) return try allocator.dupe(u8, "types.encodeCompactBytes");

    // Custom nested struct - use StructName.encode method
    return try std.fmt.allocPrint(allocator, "{s}.encode", .{kafka_type});
}

fn getDecodeFunctionName(allocator: Allocator, kafka_type: []const u8) ![]u8 {
    if (std.mem.eql(u8, kafka_type, "bool")) return try allocator.dupe(u8, "types.decodeBoolean");
    if (std.mem.eql(u8, kafka_type, "int8")) return try allocator.dupe(u8, "types.decodeInt8");
    if (std.mem.eql(u8, kafka_type, "int16")) return try allocator.dupe(u8, "types.decodeInt16");
    if (std.mem.eql(u8, kafka_type, "int32")) return try allocator.dupe(u8, "types.decodeInt32");
    if (std.mem.eql(u8, kafka_type, "int64")) return try allocator.dupe(u8, "types.decodeInt64");
    if (std.mem.eql(u8, kafka_type, "uint16")) return try allocator.dupe(u8, "types.decodeUint16");
    if (std.mem.eql(u8, kafka_type, "uint32")) return try allocator.dupe(u8, "types.decodeUint32");
    if (std.mem.eql(u8, kafka_type, "float64")) return try allocator.dupe(u8, "types.decodeFloat64");
    if (std.mem.eql(u8, kafka_type, "string")) return try allocator.dupe(u8, "types.decodeCompactString");
    if (std.mem.eql(u8, kafka_type, "bytes")) return try allocator.dupe(u8, "types.decodeCompactBytes");
    if (std.mem.eql(u8, kafka_type, "uuid")) return try allocator.dupe(u8, "types.decodeUuid");
    if (std.mem.eql(u8, kafka_type, "records")) return try allocator.dupe(u8, "types.decodeCompactBytes");

    // Custom nested struct - use StructName.decode method
    return try std.fmt.allocPrint(allocator, "{s}.decode", .{kafka_type});
}

// NEW: Get compute size function name
fn getComputeSizeFunctionName(allocator: Allocator, kafka_type: []const u8) ![]u8 {
    if (std.mem.eql(u8, kafka_type, "bool")) return try allocator.dupe(u8, "types.computeSizeBoolean");
    if (std.mem.eql(u8, kafka_type, "int8")) return try allocator.dupe(u8, "types.computeSizeInt8");
    if (std.mem.eql(u8, kafka_type, "int16")) return try allocator.dupe(u8, "types.computeSizeInt16");
    if (std.mem.eql(u8, kafka_type, "int32")) return try allocator.dupe(u8, "types.computeSizeInt32");
    if (std.mem.eql(u8, kafka_type, "int64")) return try allocator.dupe(u8, "types.computeSizeInt64");
    if (std.mem.eql(u8, kafka_type, "uint16")) return try allocator.dupe(u8, "types.computeSizeUint16");
    if (std.mem.eql(u8, kafka_type, "uint32")) return try allocator.dupe(u8, "types.computeSizeUint32");
    if (std.mem.eql(u8, kafka_type, "float64")) return try allocator.dupe(u8, "types.computeSizeFloat64");
    if (std.mem.eql(u8, kafka_type, "string")) return try allocator.dupe(u8, "types.computeSizeCompactString");
    if (std.mem.eql(u8, kafka_type, "bytes")) return try allocator.dupe(u8, "types.computeSizeCompactBytes");
    if (std.mem.eql(u8, kafka_type, "uuid")) return try allocator.dupe(u8, "types.computeSizeUuid");
    if (std.mem.eql(u8, kafka_type, "records")) return try allocator.dupe(u8, "types.computeSizeCompactBytes");

    // Custom nested struct - use StructName.computeSize method
    return try std.fmt.allocPrint(allocator, "{s}.computeSize", .{kafka_type});
}

fn needsAllocator(kafka_type: []const u8) bool {
    return std.mem.eql(u8, kafka_type, "string") or
        std.mem.eql(u8, kafka_type, "bytes") or
        std.mem.startsWith(u8, kafka_type, "[]");
}

fn isNullable(field: FieldSpec) bool {
    return field.nullableVersions != null;
}

/// Check if a field has a per-field flexibleVersions override of "none",
/// meaning it must always use non-compact encoding regardless of message-level flexibility.
fn isFieldNeverFlexible(field: FieldSpec) bool {
    if (field.flexibleVersions) |fv| {
        return std.mem.eql(u8, fv, "none");
    }
    return false;
}

fn toSnakeCase(allocator: Allocator, input: []const u8) ![]u8 {
    var result = ArrayList(u8).init(allocator);
    defer result.deinit();

    var i: usize = 0;
    while (i < input.len) : (i += 1) {
        const c = input[i];
        if (std.ascii.isUpper(c)) {
            if (i > 0) {
                try result.append('_');
            }
            try result.append(std.ascii.toLower(c));
        } else {
            try result.append(c);
        }
    }

    return result.toOwnedSlice();
}

fn capitalize(allocator: Allocator, input: []const u8) ![]u8 {
    if (input.len == 0) return try allocator.dupe(u8, input);

    var result = try allocator.alloc(u8, input.len);
    result[0] = std.ascii.toUpper(input[0]);
    if (input.len > 1) {
        @memcpy(result[1..], input[1..]);
    }
    return result;
}

const VersionRange = struct {
    min: i16,
    max: i16,
};

fn parseVersionRange(str: []const u8) !VersionRange {
    if (str.len == 0) return error.InvalidVersion;

    if (str[str.len - 1] == '+') {
        const min = try std.fmt.parseInt(i16, str[0 .. str.len - 1], 10);
        return VersionRange{ .min = min, .max = std.math.maxInt(i16) };
    }

    if (std.mem.indexOf(u8, str, "-")) |dash_pos| {
        const min = try std.fmt.parseInt(i16, str[0..dash_pos], 10);
        const max = try std.fmt.parseInt(i16, str[dash_pos + 1 ..], 10);
        return VersionRange{ .min = min, .max = max };
    }

    const version = try std.fmt.parseInt(i16, str, 10);
    return VersionRange{ .min = version, .max = version };
}
