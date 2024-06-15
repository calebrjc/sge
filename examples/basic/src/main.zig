const std = @import("std");
const zge = @import("zge");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) @panic("We leaked memory!");
    }

    zge.init(.{
        .allocator = allocator,
        .win_props = .{
            .size = .{ .x = 1920, .y = 1080 },
            .title = "Example Application",
            .target_fps = 60,
        },
    });
    defer zge.deinit();

    const splash_scene_id = zge.registerScene(.{
        .init = splashScreenInit,
        .deinit = splashScreenDeinit,
        .update = splashScreenUpdate,
        .draw = splashScreenDraw,
    }).?;
    zge.setScene(splash_scene_id);

    try zge.run();
}

// Example Scene -----------------------------------------------------------------------------------

// TODO(Caleb): Make this a struct

var splash_raylib_logo: zge.Texture = undefined;
var splash_title: zge.Text = undefined;
var splash_subtitle: zge.Text = undefined;
var splash_made_with: zge.Text = undefined;
var splash_version: zge.Text = undefined;
var splash_title_pos: zge.Vec2i = undefined;

fn splashScreenInit() void {
    splash_raylib_logo = zge.loadTexture("assets/raylib_96x96.png");

    splash_title = zge.Text.init("ASTEROIDS", 100);
    splash_subtitle = zge.Text.init("by calebrjc", 30);
    splash_made_with = zge.Text.init("made with", 30);
    splash_version = zge.Text.init("v0.0.1", 30);

    const win_props = zge.getWindowProperties();
    splash_title_pos = zge.Vec2i{
        .x = @divTrunc(win_props.size.x - splash_title.size.x, 2),
        .y = @divTrunc(win_props.size.y - splash_title.size.y, 2),
    };
}

fn splashScreenDeinit() void {
    zge.unloadTexture(splash_raylib_logo) catch unreachable;
}

fn splashScreenUpdate() void {}

fn splashScreenDraw() void {
    const win_props = zge.getWindowProperties();

    zge.clearBackground(zge.Color.dark_gray);

    zge.drawText(splash_title, splash_title_pos, zge.Color.ray_white);

    zge.drawText(
        splash_subtitle,
        .{
            .x = @divTrunc(win_props.size.x - splash_subtitle.size.x, 2),
            .y = splash_title_pos.y + splash_title.size.y,
        },
        zge.Color.gray,
    );

    zge.drawText(
        splash_made_with,
        .{
            .x = win_props.size.x - splash_made_with.size.x - splash_raylib_logo.size.x - 20,
            .y = win_props.size.y - splash_made_with.size.y - 10,
        },
        zge.Color.gray,
    );

    zge.drawTexture(
        splash_raylib_logo,
        .{
            .x = -splash_raylib_logo.size.x - 10,
            .y = win_props.size.y - splash_raylib_logo.size.y - 10,
        },
        zge.Color.ray_white,
    );

    zge.drawText(
        splash_version,
        .{
            .x = 10,
            .y = win_props.size.y - splash_version.size.y - 10,
        },
        zge.Color.gray,
    );
}
