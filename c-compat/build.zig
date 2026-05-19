const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Pull the sibling SDK module so we can link against it.
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

    // librdkafka-shaped shared library. Zig 0.16: addSharedLibrary is gone;
    // use addLibrary with linkage=.dynamic and a per-target root_module that
    // carries target/optimize + link.libc.
    const c_lib_module = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    c_lib_module.addImport("kafka", kafka);

    const c_lib = b.addLibrary(.{
        .name = "rdkafka",
        .root_module = c_lib_module,
        .linkage = .dynamic,
        .version = .{ .major = 2, .minor = 13, .patch = 0 },
    });

    b.installArtifact(c_lib);

    // Header bundle.
    const install_header = b.addInstallFile(
        b.path("include/rdkafka.h"),
        "include/rdkafka.h",
    );
    b.getInstallStep().dependOn(&install_header.step);

    // C-side smoke test using the C API.
    const c_test_module = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    c_test_module.addCSourceFile(.{
        .file = b.path("tests/c_api_test.c"),
        .flags = &.{"-std=c11"},
    });
    c_test_module.addIncludePath(b.path("include"));

    // 0.16: linkLibrary lives on the Module, not on the Compile step.
    c_test_module.linkLibrary(c_lib);

    const c_test = b.addExecutable(.{
        .name = "c-api-test",
        .root_module = c_test_module,
    });

    const install_test = b.addInstallArtifact(c_test, .{});

    const test_step = b.step("test", "Run C API tests");
    test_step.dependOn(&install_test.step);

    const run_test = b.addRunArtifact(c_test);
    run_test.step.dependOn(&install_test.step);

    const run_test_step = b.step("run-test", "Run the C API test");
    run_test_step.dependOn(&run_test.step);
}
