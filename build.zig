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
    const sdk_lib = b.addLibrary(.{
        .name = "kafka",
        .root_module = b.createModule(.{
            .root_source_file = b.path("sdk/src/lib.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    sdk_lib.root_module.addImport("kafka_generated", kafka_generated);
    b.installArtifact(sdk_lib);

    //
    // C Compatibility Library
    //

    const c_lib_module = b.createModule(.{
        .root_source_file = b.path("c-compat/src/root.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    c_lib_module.addImport("kafka", kafka);

    const c_lib = b.addLibrary(.{
        .name = "rdkafka",
        .linkage = .dynamic,
        .root_module = c_lib_module,
        .version = .{ .major = 2, .minor = 13, .patch = 0 },
    });
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
    const sdk_tests = b.addTest(.{
        .name = "sdk-tests",
        .root_module = b.createModule(.{
            .root_source_file = b.path("sdk/src/lib.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    sdk_tests.root_module.addImport("kafka_generated", kafka_generated);

    const run_sdk_tests = b.addRunArtifact(sdk_tests);

    // SDK protocol tests
    const protocol_tests = b.addTest(.{
        .name = "protocol-tests",
        .root_module = b.createModule(.{
            .root_source_file = b.path("sdk/tests/protocol_tests.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    protocol_tests.root_module.addImport("kafka", kafka);
    protocol_tests.root_module.addImport("kafka_generated", kafka_generated);

    const run_protocol_tests = b.addRunArtifact(protocol_tests);

    // SDK integration tests (requires running Kafka broker)
    const integration_tests = b.addTest(.{
        .name = "integration-tests",
        .root_module = b.createModule(.{
            .root_source_file = b.path("sdk/tests/integration_tests.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    integration_tests.root_module.addImport("kafka", kafka);
    integration_tests.root_module.addImport("kafka_generated", kafka_generated);

    const run_integration_tests = b.addRunArtifact(integration_tests);

    // C API test executable. 0.16: C source files, libc linkage, include
    // paths, and library linkage all live on the Module now, not the Compile.
    const c_test_module = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    c_test_module.addCSourceFile(.{
        .file = b.path("c-compat/tests/c_api_test.c"),
        .flags = &.{"-std=c11"},
    });
    c_test_module.addIncludePath(b.path("c-compat/include"));
    c_test_module.linkLibrary(c_lib);

    const c_test = b.addExecutable(.{
        .name = "c-api-test",
        .root_module = c_test_module,
    });
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
