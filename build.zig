const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const raylib = b.dependency("raylib", .{ .target = target, .optimize = optimize });
    const zge_module = b.addModule("zge", .{
        .root_source_file = b.path("src/core.zig"),
    });
    zge_module.addIncludePath(raylib.path("src"));
    zge_module.linkLibrary(raylib.artifact("raylib"));

    // "zig test" ----------------------------------------------------------------------------------

    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/core.zig"),
        .target = target,
        .optimize = optimize,
    });
    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}
