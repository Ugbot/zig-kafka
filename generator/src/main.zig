//! Kafka Protocol Generator - Main Entry Point
//! Generates complete Zig implementations from Kafka protocol JSON specifications

const std = @import("std");
const generator = @import("complete_generator.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 3) {
        try printUsage(args[0]);
        return;
    }

    if (std.mem.eql(u8, args[1], "--dir")) {
        if (args.len < 4) {
            try printUsage(args[0]);
            return;
        }
        try generator.generateFromDirectory(allocator, args[2], args[3]);
    } else {
        try generator.generateFromFile(allocator, args[1], args[2]);
    }
}

fn printUsage(program_name: []const u8) !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print(
        \\Usage:
        \\  {s} <input.json> <output.zig>        - Generate single file
        \\  {s} --dir <specs_dir> <output_dir>   - Generate from directory
        \\
        \\Examples:
        \\  {s} ApiVersionsRequest.json api_versions_request.zig
        \\  {s} --dir ./specs ./generated
        \\
    , .{ program_name, program_name, program_name, program_name });
}
