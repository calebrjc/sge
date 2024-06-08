const std = @import("std");
const testing = std.testing;

const raylib = @cImport({
    @cInclude("raylib.h");
    @cInclude("raymath.h");
});

pub fn run_example_app(comptime str: []const u8) void {
    const title = std.fmt.comptimePrint("Example App: {s}", .{str});
    raylib.InitWindow(800, 450, title);
    defer raylib.CloseWindow();

    raylib.SetTargetFPS(60);

    while (!raylib.WindowShouldClose()) {
        raylib.BeginDrawing();
        defer raylib.EndDrawing();

        raylib.ClearBackground(raylib.RAYWHITE);
        raylib.DrawText("Congrats! You created your first window!", 190, 200, 20, raylib.DARKGRAY);
    }
}
