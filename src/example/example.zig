const std = @import("std");
const sge = @import("sge");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) @panic("We leaked memory!");
    }

    const win_props = sge.WindowProperties.init(
        .{ .x = 1920, .y = 1080 },
        "Example Application",
        60,
    );
    sge.init(allocator, win_props);
    defer sge.deinit();

    const splash_scene_id = sge.registerScene(.{
        .init = testSceneInit,
        .deinit = testSceneDeinit,
        .update = testSceneUpdate,
        .draw = testSceneDraw,
    }).?;
    sge.setScene(splash_scene_id);

    try sge.run();
}

// Splash Screen Scene -----------------------------------------------------------------------------

var splash_raylib_logo: sge.Texture = undefined;

var splash_title: sge.Text = undefined;
var splash_subtitle: sge.Text = undefined;
var splash_made_with: sge.Text = undefined;
var splash_version: sge.Text = undefined;

var splash_title_pos: sge.Vec2i = undefined;

fn testSceneInit() void {
    splash_raylib_logo = sge.loadTexture("assets/raylib_96x96.png");

    splash_title = sge.Text.init("ASTEROIDS", 100);
    splash_subtitle = sge.Text.init("by calebrjc", 30);
    splash_made_with = sge.Text.init("made with", 30);
    splash_version = sge.Text.init("v0.0.1", 30);

    const win_props = sge.getWindowProperties();
    splash_title_pos = sge.Vec2i{
        .x = @divTrunc(win_props.size.x - splash_title.size.x, 2),
        .y = @divTrunc(win_props.size.y - splash_title.size.y, 2) - 25,
    };
}

fn testSceneDeinit() void {
    sge.unloadTexture(splash_raylib_logo) catch unreachable;
}

fn testSceneUpdate() void {
    // ...
}

fn testSceneDraw() void {
    const win_props = sge.getWindowProperties();

    sge.clearBackground(sge.Color.dark_gray);

    sge.drawText(splash_title, splash_title_pos, sge.Color.ray_white);

    sge.drawText(
        splash_subtitle,
        .{
            .x = @divTrunc(win_props.size.x - splash_subtitle.size.x, 2),
            .y = splash_title_pos.y + splash_title.size.y,
        },
        sge.Color.gray,
    );

    sge.drawText(
        splash_made_with,
        .{
            .x = win_props.size.x - splash_made_with.size.x - splash_raylib_logo.size.x - 20,
            .y = win_props.size.y - splash_made_with.size.y - 10,
        },
        sge.Color.gray,
    );

    sge.drawTexture(
        splash_raylib_logo,
        .{
            .x = win_props.size.x - splash_raylib_logo.size.x - 10,
            .y = win_props.size.y - splash_raylib_logo.size.y - 10,
        },
        sge.Color.ray_white,
    );

    sge.drawText(
        splash_version,
        .{
            .x = 10,
            .y = win_props.size.y - splash_version.size.y - 10,
        },
        sge.Color.gray,
    );
}
