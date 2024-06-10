const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});


    const sge = b.addStaticLibrary(.{
        .name = "sge",
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(sge);

    const sge_module = b.addModule("sge", .{
        .root_source_file = b.path("src/root.zig"),
    });
    const raylib = b.dependency("raylib", .{ .target = target, .optimize = optimize });

    sge_module.addIncludePath(raylib.path("src"));
    sge_module.linkLibrary(raylib.artifact("raylib"));

    const example = b.addExecutable(.{
        .name = "sge_example",
        .root_source_file = b.path("src/example/example.zig"),
        .target = target,
        .optimize = optimize,
    });
    example.root_module.addImport("sge", sge_module);
    b.installArtifact(example);

    // "zig build run" -----------------------------------------------------------------------------

    const run_cmd = b.addRunArtifact(example);
    run_cmd.step.dependOn(b.getInstallStep());

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // "zig test" ----------------------------------------------------------------------------------

    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}
