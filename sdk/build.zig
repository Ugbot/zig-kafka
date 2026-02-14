const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Create kafka_generated module for generated protocol types
    const kafka_generated = b.addModule("kafka_generated", .{
        .root_source_file = b.path("src/generated_index.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Create main kafka SDK module
    const kafka = b.addModule("kafka", .{
        .root_source_file = b.path("src/lib.zig"),
        .target = target,
        .optimize = optimize,
    });
    kafka.addImport("kafka_generated", kafka_generated);

    // Unit tests
    const unit_tests = b.addTest(.{
        .name = "sdk-unit-tests",
        .root_source_file = b.path("src/lib.zig"),
        .target = target,
        .optimize = optimize,
    });
    unit_tests.root_module.addImport("kafka_generated", kafka_generated);

    const run_unit_tests = b.addRunArtifact(unit_tests);

    // Protocol tests
    const protocol_tests = b.addTest(.{
        .name = "protocol-tests",
        .root_source_file = b.path("tests/protocol_tests.zig"),
        .target = target,
        .optimize = optimize,
    });
    protocol_tests.root_module.addImport("kafka", kafka);
    protocol_tests.root_module.addImport("kafka_generated", kafka_generated);

    const run_protocol_tests = b.addRunArtifact(protocol_tests);

    // Integration tests
    const integration_tests = b.addTest(.{
        .name = "integration-tests",
        .root_source_file = b.path("tests/integration_tests.zig"),
        .target = target,
        .optimize = optimize,
    });
    integration_tests.root_module.addImport("kafka", kafka);
    integration_tests.root_module.addImport("kafka_generated", kafka_generated);

    const run_integration_tests = b.addRunArtifact(integration_tests);

    // Test step
    const test_step = b.step("test", "Run all tests");
    test_step.dependOn(&run_unit_tests.step);
    test_step.dependOn(&run_protocol_tests.step);

    // Integration test step (separate, requires running Kafka)
    const integration_test_step = b.step("test-integration", "Run integration tests (requires Kafka)");
    integration_test_step.dependOn(&run_integration_tests.step);
}
