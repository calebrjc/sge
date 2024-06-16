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

    const splash_screen_id = zge.registerScene(SplashScreen.scene()).?;
    zge.setScene(splash_screen_id);

    try zge.run();
}

// Example Scene -----------------------------------------------------------------------------------

const SplashScreen = struct {
    // Save a function call or computation every frame by caching these variables
    // (at the cost of memory)
    var window_size: zge.Vec2i = undefined;
    var title_pos: zge.Vec2i = undefined;
    var subtitle_pos: zge.Vec2i = undefined;

    var title: zge.Text = undefined;
    var subtitle: zge.Text = undefined;
    var version: zge.Text = undefined;
    var made_with: zge.Text = undefined;
    var raylib_logo: zge.Texture = undefined;

    fn init() void {
        const win_props = zge.getWindowProperties();
        window_size = win_props.size;

        title = zge.Text.init("ZGE Example", 100);
        title_pos = .{
            .x = @divTrunc(window_size.x - title.size.x, 2),
            .y = @divTrunc(window_size.y - title.size.y, 2),
        };

        subtitle = zge.Text.init("by calebrjc", 30);
        subtitle_pos = .{
            .x = @divTrunc(window_size.x - subtitle.size.x, 2),
            .y = title_pos.y + title.size.y,
        };

        version = zge.Text.init("v0.0.1", 30);
        made_with = zge.Text.init("made with", 30);
        raylib_logo = zge.loadTexture("assets/raylib_128x128.png");
    }

    fn deinit() void {
        zge.unloadTexture(raylib_logo) catch unreachable;
    }

    fn update() void {}

    fn draw() void {
        zge.clearBackground(zge.Color.dark_gray);

        zge.drawText(title, title_pos, zge.Color.ray_white);
        zge.drawText(subtitle, subtitle_pos, zge.Color.gray);
        zge.drawText(
            version,
            .{
                .x = 10,
                .y = -version.size.y - 10,
            },
            zge.Color.gray,
        );
        zge.drawText(
            made_with,
            .{
                .x = -made_with.size.x - raylib_logo.size.x - 20,
                .y = -made_with.size.y - 10,
            },
            zge.Color.gray,
        );
        zge.drawTexture(
            raylib_logo,
            .{ .x = -raylib_logo.size.x - 10, .y = -raylib_logo.size.y - 10 },
            zge.Color.ray_white,
        );
    }

    pub fn scene() zge.Scene {
        return .{
            .init = SplashScreen.init,
            .deinit = SplashScreen.deinit,
            .update = SplashScreen.update,
            .draw = SplashScreen.draw,
        };
    }
};
