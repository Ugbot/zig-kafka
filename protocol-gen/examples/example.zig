//! Example usage of the Kafka Protocol Generator

const std = @import("std");
const kafka = @import("src/lib.zig");

// Import a generated message type
const ApiVersionsRequest = @import("generated/LApi_LVersions_LRequest.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    std.debug.print("🚀 Kafka Protocol Generator Example\n", .{});
    std.debug.print("===================================\n\n", .{});

    // Create an ApiVersionsRequest
    const request = ApiVersionsRequest.ApiVersionsRequest{
        .client_software_name = "kafka-protocol-generator-example",
        .client_software_version = "1.0.0",
    };

    std.debug.print("📦 Created ApiVersionsRequest:\n", .{});
    std.debug.print("   Client Name: {s}\n", .{request.client_software_name});
    std.debug.print("   Client Version: {s}\n", .{request.client_software_version});
    std.debug.print("   API Key: {d}\n", .{ApiVersionsRequest.apiKey()});

    // Test version checking
    const test_version: i16 = 3;
    std.debug.print("\n🔍 Version {d} validation:\n", .{test_version});
    std.debug.print("   Valid: {}\n", .{ApiVersionsRequest.isValidVersion(test_version)});
    std.debug.print("   Flexible: {}\n", .{ApiVersionsRequest.isFlexibleVersion(test_version)});

    // Test encoding
    std.debug.print("\n📤 Encoding test:\n", .{});
    var buffer = std.ArrayList(u8).init(allocator);
    defer buffer.deinit();

    try ApiVersionsRequest.encode(&request, buffer.writer(), test_version);
    std.debug.print("   Encoded {} bytes\n", .{buffer.items.len});

    // Test decoding
    std.debug.print("\n📥 Decoding test:\n", .{});
    var stream = std.io.fixedBufferStream(buffer.items);
    const decoded = try ApiVersionsRequest.decode(stream.reader(), test_version, allocator);

    std.debug.print("   Decoded client name: {s}\n", .{decoded.client_software_name});
    std.debug.print("   Decoded client version: {s}\n", .{decoded.client_software_version});

    // Clean up allocated strings
    if (decoded.client_software_name.len > 0) allocator.free(decoded.client_software_name);
    if (decoded.client_software_version.len > 0) allocator.free(decoded.client_software_version);

    std.debug.print("\n✅ Example completed successfully!\n", .{});
}
