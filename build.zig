const std = @import("std");

/// Zig Kafka Toolkit - Unified Build System
///
/// This builds three main components:
/// 1. Protocol Generator - kafka-protocol-generator executable
/// 2. SDK - Native Zig Kafka client library
/// 3. C Compatibility - librdkafka-compatible shared library

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    //
    // Protocol Generator
    //

    const generator = b.addExecutable(.{
        .name = "kafka-protocol-generator",
        .root_module = b.createModule(.{
            .root_source_file = b.path("protocol-gen/src/main.zig"),
            .target = target,
            .optimize = .ReleaseFast, // Generator should be fast
        }),
    });
    b.installArtifact(generator);

    const run_generator = b.addRunArtifact(generator);
    run_generator.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_generator.addArgs(args);
    }

    const gen_step = b.step("gen", "Run the protocol generator");
    gen_step.dependOn(&run_generator.step);

    //
    // SDK Module
    //

    const kafka_generated = b.addModule("kafka_generated", .{
        .root_source_file = b.path("sdk/src/generated_index.zig"),
        .target = target,
        .optimize = optimize,
    });

    const kafka = b.addModule("kafka", .{
        .root_source_file = b.path("sdk/src/lib.zig"),
        .target = target,
        .optimize = optimize,
    });
    kafka.addImport("kafka_generated", kafka_generated);

    // SDK static library (optional, for linking)
    const sdk_lib = b.addStaticLibrary(.{
        .name = "kafka",
        .root_module = b.createModule(.{
            .root_source_file = b.path("sdk/src/lib.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "kafka_generated", .module = kafka_generated },
            },
        }),
    });
    b.installArtifact(sdk_lib);

    //
    // C Compatibility Library
    //

    const c_module = b.createModule(.{
        .root_source_file = b.path("c-compat/src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    c_module.addImport("kafka", kafka);

    const c_lib = b.addSharedLibrary(.{
        .name = "rdkafka",
        .root_module = c_module,
        .version = .{ .major = 2, .minor = 13, .patch = 0 },
    });
    c_lib.linkLibC();
    b.installArtifact(c_lib);

    // Install C headers
    const install_header = b.addInstallFile(
        b.path("c-compat/include/rdkafka.h"),
        "include/rdkafka.h",
    );
    b.getInstallStep().dependOn(&install_header.step);

    //
    // Tests
    //

    // SDK unit tests
    const sdk_test_module = b.createModule(.{
        .root_source_file = b.path("sdk/src/lib.zig"),
        .target = target,
        .optimize = optimize,
    });
    sdk_test_module.addImport("kafka_generated", kafka_generated);

    const sdk_tests = b.addTest(.{
        .name = "sdk-tests",
        .root_module = sdk_test_module,
    });

    const run_sdk_tests = b.addRunArtifact(sdk_tests);

    // SDK protocol tests
    const protocol_test_module = b.createModule(.{
        .root_source_file = b.path("sdk/tests/protocol_tests.zig"),
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

    // SDK integration tests (requires running Kafka broker)
    const integration_test_module = b.createModule(.{
        .root_source_file = b.path("sdk/tests/integration_tests.zig"),
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

    // C API test executable
    const c_test = b.addExecutable(.{
        .name = "c-api-test",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
        }),
    });
    c_test.addCSourceFile(.{
        .file = b.path("c-compat/tests/c_api_test.c"),
        .flags = &.{"-std=c11"},
    });
    c_test.linkLibrary(c_lib);
    c_test.linkLibC();
    c_test.addIncludePath(b.path("c-compat/include"));
    b.installArtifact(c_test);

    const run_c_test = b.addRunArtifact(c_test);
    run_c_test.step.dependOn(b.getInstallStep());

    // Test steps
    const test_step = b.step("test", "Run all SDK tests");
    test_step.dependOn(&run_sdk_tests.step);
    test_step.dependOn(&run_protocol_tests.step);

    const integration_test_step = b.step("test-integration", "Run integration tests (requires Kafka)");
    integration_test_step.dependOn(&run_integration_tests.step);

    const c_test_step = b.step("test-c", "Run C API test");
    c_test_step.dependOn(&run_c_test.step);

    const all_tests_step = b.step("test-all", "Run all tests");
    all_tests_step.dependOn(test_step);
    all_tests_step.dependOn(c_test_step);
}
