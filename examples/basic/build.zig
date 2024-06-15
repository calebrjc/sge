const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const zge = b.dependency("zge", .{ .target = target, .optimize = optimize });

    const basic_example = b.addExecutable(.{
        .name = "basic_example",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    basic_example.root_module.addImport("zge", zge.module("zge"));
    b.installArtifact(basic_example);

    // "zig build run" -----------------------------------------------------------------------------

    const run_cmd = b.addRunArtifact(basic_example);
    run_cmd.step.dependOn(b.getInstallStep());

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
