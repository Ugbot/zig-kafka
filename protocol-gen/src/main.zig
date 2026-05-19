//! Kafka Protocol Generator - Main Entry Point
//! Generates complete Zig implementations from Kafka protocol JSON specifications

const std = @import("std");
const generator = @import("complete_generator.zig");

pub fn main(init: std.process.Init.Minimal) !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Zig 0.16: command-line args come in via the process.Init.Minimal struct.
    // Collect them into an owned slice for backwards-compatible indexing.
    var arg_list: std.ArrayList([:0]const u8) = .empty;
    defer {
        for (arg_list.items) |a| allocator.free(@constCast(a));
        arg_list.deinit(allocator);
    }
    var it = init.args.iterate();
    while (it.next()) |raw| {
        const copy = try allocator.dupeZ(u8, raw);
        try arg_list.append(allocator, copy);
    }
    const args = arg_list.items;

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
    // Zig 0.16 reshuffled the file-IO surface; std.debug.print writes to
    // stderr and is API-stable across versions. Usage output isn't on a hot
    // path, so the stderr destination is acceptable.
    std.debug.print(
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
