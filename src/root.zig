const std = @import("std");
const testing = std.testing;

const raylib = @cImport({
    @cInclude("raylib.h");
    @cInclude("raymath.h");
});

// TODO:
// - GFX system
// - Text class
// - Scene system
// - Logging system

// Submodules --------------------------------------------------------------------------------------

// Types -------------------------------------------------------------------------------------------

pub fn Vec2(T: type) type {
    return struct {
        x: T,
        y: T,
    };
}

const Vec2i = Vec2(i32);
const Vec2f = Vec2(f32);

// Variables and State -----------------------------------------------------------------------------

pub var allocator: std.mem.Allocator = undefined;

// CORE --------------------------------------------------------------------------------------------

pub fn init(alloc: std.mem.Allocator) void {
    allocator = alloc;
    textures = std.ArrayList(TextureData).init(alloc); // GFX
    scenes = std.ArrayList(Scene).init(alloc); // SCENE
}

pub fn deinit() void {
    textures.deinit();
}

pub fn run() !void {
    raylib.InitWindow(1280, 720, "ASTEROIDS - Client");
    defer raylib.CloseWindow();

    const raylib_logo = loadTexture("assets/raylib_96x96.png");
    defer unloadTexture(raylib_logo) catch unreachable;

    const title = Text.init("ASTEROIDS", 100);
    const subtitle = Text.init("by calebrjc", 30);
    const made_with = Text.init("made with", 30);
    const version = Text.init("v0.0.1", 30);

    const title_pos = Vec2i{
        .x = @divTrunc(raylib.GetScreenWidth() - title.size.x, 2),
        .y = @divTrunc(raylib.GetScreenHeight() - title.size.y, 2) - 25,
    };

    while (!raylib.WindowShouldClose()) {
        // Update -------------------------------------------------------------

        // ...

        // Draw ---------------------------------------------------------------

        raylib.BeginDrawing();
        defer raylib.EndDrawing();

        raylib.ClearBackground(raylib.DARKGRAY);

        drawText(title, title_pos, Color.ray_white);

        drawText(
            subtitle,
            .{
                .x = @divTrunc(raylib.GetScreenWidth() - subtitle.size.x, 2),
                .y = title_pos.y + title.size.y,
            },
            Color.gray,
        );

        drawText(
            made_with,
            .{
                .x = raylib.GetScreenWidth() - made_with.size.x - raylib_logo.size.x - 20,
                .y = raylib.GetScreenHeight() - made_with.size.y - 10,
            },
            Color.gray,
        );

        drawTexture(
            raylib_logo,
            .{
                .x = raylib.GetScreenWidth() - raylib_logo.size.x - 10,
                .y = raylib.GetScreenHeight() - raylib_logo.size.y - 10,
            },
            Color.lime,
        );

        drawText(
            version,
            .{
                .x = 10,
                .y = raylib.GetScreenHeight() - version.size.y - 10,
            },
            Color.gray,
        );
    }
}

fn update() void {
    // ...
}

fn draw() void {
    raylib.BeginDrawing();
    defer raylib.EndDrawing();

    raylib.ClearBackground(raylib.RAYWHITE);
    raylib.DrawText("Congrats! You created your first window!", 190, 200, 20, raylib.DARKGRAY);
}

// GFX ---------------------------------------------------------------------------------------------

const TextureID = u64;

const Texture = struct {
    id: TextureID,
    size: Vec2i,
};

const TextureData = struct {
    id: TextureID,
    loaded: bool,
    data: raylib.Texture2D,
    size: Vec2i,

    pub fn init(id: TextureID, data: raylib.Texture2D) TextureData {
        return .{
            .id = id,
            .loaded = true,
            .data = data,
            .size = .{ .x = data.width, .y = data.height },
        };
    }
};

const Text = struct {
    text: [:0]const u8,
    font_size: u16,
    size: Vec2i,

    pub fn init(text: [:0]const u8, font_size: u16) Text {
        const size = raylib.MeasureTextEx(
            raylib.GetFontDefault(),
            text,
            @floatFromInt(font_size),
            @as(f32, @floatFromInt(font_size)) / 10, // Raylib's default spacing between characters
        );

        return .{
            .text = text,
            .font_size = font_size,
            .size = .{ .x = @intFromFloat(size.x), .y = @intFromFloat(size.y) },
        };
    }
};

const Color = struct {
    r: u8,
    g: u8,
    b: u8,
    a: u8,

    pub fn init(r: u8, g: u8, b: u8, a: u8) Color {
        return .{
            .r = r,
            .g = g,
            .b = b,
            .a = a,
        };
    }

    fn asRaylibColor(self: Color) raylib.Color {
        return .{
            .r = self.r,
            .g = self.g,
            .b = self.b,
            .a = self.a,
        };
    }

    pub const light_gray = Color.init(200, 200, 200, 255);
    pub const gray = Color.init(130, 130, 130, 255);
    pub const dark_gray = Color.init(80, 80, 80, 255);
    pub const yellow = Color.init(253, 249, 0, 255);
    pub const gold = Color.init(255, 203, 0, 255);
    pub const orange = Color.init(255, 161, 0, 255);
    pub const pink = Color.init(255, 109, 194, 255);
    pub const red = Color.init(230, 41, 55, 255);
    pub const maroon = Color.init(190, 33, 55, 255);
    pub const green = Color.init(0, 228, 48, 255);
    pub const lime = Color.init(0, 158, 47, 255);
    pub const dark_green = Color.init(0, 117, 44, 255);
    pub const sky_blue = Color.init(102, 191, 255, 255);
    pub const blue = Color.init(0, 121, 241, 255);
    pub const dark_blue = Color.init(0, 82, 172, 255);
    pub const purple = Color.init(200, 122, 255, 255);
    pub const violet = Color.init(135, 60, 190, 255);
    pub const dark_purple = Color.init(112, 31, 126, 255);
    pub const beige = Color.init(211, 176, 131, 255);
    pub const brown = Color.init(127, 106, 79, 255);
    pub const dark_brown = Color.init(76, 63, 47, 255);
    pub const white = Color.init(255, 255, 255, 255);
    pub const black = Color.init(0, 0, 0, 255);
    pub const blank = Color.init(0, 0, 0, 0);
    pub const magenta = Color.init(255, 0, 255, 255);
    pub const ray_white = Color.init(245, 245, 245, 255);
};

const GFXError = error{
    InvalidTextureID,
    TextureNotLoaded,
};

var textures: std.ArrayList(TextureData) = undefined;

pub fn loadTexture(comptime path: [:0]const u8) Texture {
    const raw_texture_data = raylib.LoadTexture(path);
    errdefer raylib.UnloadTexture(raw_texture_data);

    const texture_data = TextureData.init(textures.items.len, raw_texture_data);
    textures.append(texture_data) catch unreachable;

    return .{ .id = texture_data.id, .size = texture_data.size };
}

pub fn unloadTexture(texture: Texture) GFXError!void {
    if (texture.id >= textures.items.len) return GFXError.InvalidTextureID;

    var texture_data = &textures.items[texture.id];
    if (!texture_data.loaded) return GFXError.TextureNotLoaded;

    raylib.UnloadTexture(texture_data.data);
    texture_data.loaded = false;
}

pub fn drawTexture(texture: Texture, pos: Vec2i, tint: Color) void {
    if (texture.id >= textures.items.len) return;

    const texture_data = textures.items[texture.id];
    if (!texture_data.loaded) return;

    raylib.DrawTexture(texture_data.data, pos.x, pos.y, tint.asRaylibColor());
}

pub fn drawText(text: Text, pos: Vec2i, color: Color) void {
    raylib.DrawText(text.text, pos.x, pos.y, text.font_size, color.asRaylibColor());
}

// SCENE -------------------------------------------------------------------------------------------

const SceneInitFunction = *const fn () void;
const SceneDeinitFunction = *const fn () void;
const SceneUpdateFunction = *const fn () void;
const SceneDrawFunction = *const fn () void;

const Scene = struct {
    init: SceneInitFunction,
    deinit: ?SceneDeinitFunction = null,
    update: SceneUpdateFunction,
    draw: SceneDrawFunction,
};

var scenes: std.ArrayList(Scene) = undefined;

// LOGGING -----------------------------------------------------------------------------------------

// EXAMPLES ----------------------------------------------------------------------------------------

// pub fn run_example_app(comptime str: []const u8) void {
//     const title = std.fmt.comptimePrint("Example App: {s}", .{str});
//     raylib.InitWindow(800, 450, title);
//     defer raylib.CloseWindow();

//     raylib.SetTargetFPS(60);

//     while (!raylib.WindowShouldClose()) {
//         raylib.BeginDrawing();
//         defer raylib.EndDrawing();

//         raylib.ClearBackground(raylib.RAYWHITE);
//         raylib.DrawText("Congrats! You created your first window!", 190, 200, 20, raylib.DARKGRAY);
//     }
// }
