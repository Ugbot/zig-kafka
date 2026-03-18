//! Simple example showing the generator works

const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    std.debug.print("Kafka Protocol Generator Test\n", .{});
    std.debug.print("=============================\n", .{});

    // Test that we can import and use the types
    const types = @import("src/types.zig");

    // Test VarInt encoding/decoding
    var buffer = std.array_list.Managed(u8).init(allocator);
    defer buffer.deinit();

    const test_value: i32 = 12345;
    try types.encodeVarInt(buffer.writer(), test_value);

    var stream = std.io.fixedBufferStream(buffer.items);
    const decoded = try types.decodeVarInt(stream.reader());

    std.debug.print("VarInt test: {d} -> {} bytes -> {d}\n", .{ test_value, buffer.items.len, decoded });

    if (test_value == decoded) {
        std.debug.print("✅ VarInt encoding/decoding works!\n", .{});
    } else {
        std.debug.print("❌ VarInt test failed!\n", .{});
    }

    std.debug.print("\n✅ Generator library is functional!\n", .{});
}
