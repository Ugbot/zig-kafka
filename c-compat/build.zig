const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Import SDK module from parent
    const sdk_path = b.pathResolve(&.{ b.pathFromRoot("../sdk"), "src/lib.zig" });
    const sdk_generated_path = b.pathResolve(&.{ b.pathFromRoot("../sdk"), "src/generated_index.zig" });

    const kafka_generated = b.createModule(.{
        .root_source_file = .{ .cwd_relative = sdk_generated_path },
        .target = target,
        .optimize = optimize,
    });

    const kafka = b.createModule(.{
        .root_source_file = .{ .cwd_relative = sdk_path },
        .target = target,
        .optimize = optimize,
    });
    kafka.addImport("kafka_generated", kafka_generated);

    // Create shared library (librdkafka.so / .dylib / .dll)
    const c_module = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
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

    // Install library
    b.installArtifact(c_lib);

    // Install headers
    const install_header = b.addInstallFile(
        b.path("include/rdkafka.h"),
        "include/rdkafka.h",
    );
    b.getInstallStep().dependOn(&install_header.step);

    // Create a test executable that uses the C API
    const c_test = b.addExecutable(.{
        .name = "c-api-test",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
        }),
    });
    c_test.addCSourceFile(.{
        .file = b.path("tests/c_api_test.c"),
        .flags = &.{"-std=c11"},
    });
    c_test.linkLibrary(c_lib);
    c_test.linkLibC();
    c_test.addIncludePath(b.path("include"));

    const install_test = b.addInstallArtifact(c_test, .{});

    // Test step
    const test_step = b.step("test", "Run C API tests");
    test_step.dependOn(&install_test.step);

    const run_test = b.addRunArtifact(c_test);
    run_test.step.dependOn(&install_test.step);

    const run_test_step = b.step("run-test", "Run the C API test");
    run_test_step.dependOn(&run_test.step);
}
