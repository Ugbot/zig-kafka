const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Generated protocol types module (auto-generated from JSON specs).
    const kafka_generated = b.addModule("kafka_generated", .{
        .root_source_file = b.path("src/generated_index.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Main SDK module — depends on the generated types.
    const kafka = b.addModule("kafka", .{
        .root_source_file = b.path("src/lib.zig"),
        .target = target,
        .optimize = optimize,
    });
    kafka.addImport("kafka_generated", kafka_generated);

    // Test executables.
    //
    // Zig 0.16: `addTest` (and friends) take a `root_module: *Module` instead
    // of the previous flat `.root_source_file/.target/.optimize` triple. Each
    // test gets its own scratch module so the imports above can be wired
    // through cleanly.
    const unit_test_module = b.createModule(.{
        .root_source_file = b.path("src/lib.zig"),
        .target = target,
        .optimize = optimize,
    });
    unit_test_module.addImport("kafka_generated", kafka_generated);
    const unit_tests = b.addTest(.{
        .name = "sdk-unit-tests",
        .root_module = unit_test_module,
    });
    const run_unit_tests = b.addRunArtifact(unit_tests);

    const protocol_test_module = b.createModule(.{
        .root_source_file = b.path("tests/protocol_tests.zig"),
        .target = target,
        .optimize = optimize,
    });
    protocol_test_module.addImport("kafka", kafka);
    protocol_test_module.addImport("kafka_generated", kafka_generated);
    const protocol_tests = b.addTest(.{
        .name = "protocol-tests",
        .root_module = protocol_test_module,
    });
    const run_protocol_tests = b.addRunArtifact(protocol_tests);

    const integration_test_module = b.createModule(.{
        .root_source_file = b.path("tests/integration_tests.zig"),
        .target = target,
        .optimize = optimize,
    });
    integration_test_module.addImport("kafka", kafka);
    integration_test_module.addImport("kafka_generated", kafka_generated);
    const integration_tests = b.addTest(.{
        .name = "integration-tests",
        .root_module = integration_test_module,
    });
    const run_integration_tests = b.addRunArtifact(integration_tests);

    const test_step = b.step("test", "Run all tests");
    test_step.dependOn(&run_unit_tests.step);
    test_step.dependOn(&run_protocol_tests.step);

    const integration_test_step = b.step("test-integration", "Run integration tests (requires Kafka)");
    integration_test_step.dependOn(&run_integration_tests.step);
}
