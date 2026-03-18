//! Tests for the Kafka Protocol Generator

const std = @import("std");
const testing = std.testing;
const generator = @import("simple_generator.zig");
const types = @import("types.zig");

test "generator functions" {
    std.testing.refAllDecls(generator);
}

test "types functions" {
    std.testing.refAllDecls(types);
}

test "version range functionality" {
    // Test that our types.zig version range parsing works
    {
        const range = try types.VersionRange.parse("0-4");
        try testing.expect(range.contains(0));
        try testing.expect(range.contains(2));
        try testing.expect(range.contains(4));
        try testing.expect(!range.contains(5));
    }

    {
        const range = try types.VersionRange.parse("3+");
        try testing.expect(!range.contains(2));
        try testing.expect(range.contains(3));
        try testing.expect(range.contains(100));
    }
}

test "type encoding/decoding" {
    const allocator = testing.allocator;

    // Test VarInt
    {
        var buffer = std.array_list.Managed(u8).init(allocator);
        defer buffer.deinit();

        try types.encodeVarInt(buffer.writer(), 300);

        var stream = std.io.fixedBufferStream(buffer.items);
        const decoded = try types.decodeVarInt(stream.reader());
        try testing.expectEqual(@as(i32, 300), decoded);
    }

    // Test CompactString
    {
        var buffer = std.array_list.Managed(u8).init(allocator);
        defer buffer.deinit();

        try types.encodeCompactString(buffer.writer(), "hello");

        var stream = std.io.fixedBufferStream(buffer.items);
        const decoded = try types.decodeCompactString(stream.reader(), allocator);
        defer if (decoded) |s| allocator.free(s);

        try testing.expectEqualStrings("hello", decoded.?);
    }
}
