const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Generated protocol types module (used internally by wire/client code)
    const kafka_generated = b.addModule("kafka_generated", .{
        .root_source_file = b.path("src/generated_index.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Main library module
    const lib_module = b.addModule("zig-kafka", .{
        .root_source_file = b.path("src/lib.zig"),
        .target = target,
        .optimize = optimize,
    });
    lib_module.addImport("kafka_generated", kafka_generated);

    // Static library artifact
    const lib = b.addStaticLibrary(.{
        .name = "zig-kafka",
        .root_source_file = b.path("src/lib.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(lib);

    // Generator executable
    const generator = b.addExecutable(.{
        .name = "kafka-protocol-generator",
        .root_source_file = b.path("generator/src/main.zig"),
        .target = target,
        .optimize = .ReleaseFast,
    });
    b.installArtifact(generator);

    // Run generator command
    const run_generator = b.addRunArtifact(generator);
    if (b.args) |args| {
        run_generator.addArgs(args);
    }
    const generator_step = b.step("generate", "Run protocol generator");
    generator_step.dependOn(&run_generator.step);

    // Tests
    const tests = b.addTest(.{
        .root_source_file = b.path("tests/protocol_tests.zig"),
        .target = target,
        .optimize = optimize,
    });
    tests.root_module.addImport("zig-kafka", lib_module);

    const run_tests = b.addRunArtifact(tests);
    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&run_tests.step);

    // Integration tests (requires running Kafka broker)
    const integration_tests = b.addTest(.{
        .root_source_file = b.path("tests/integration_tests.zig"),
        .target = target,
        .optimize = optimize,
    });
    integration_tests.root_module.addImport("zig-kafka", lib_module);

    const run_integration_tests = b.addRunArtifact(integration_tests);
    const integration_test_step = b.step("test-integration", "Run integration tests (requires Kafka broker)");
    integration_test_step.dependOn(&run_integration_tests.step);
}
