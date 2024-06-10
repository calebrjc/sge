const std = @import("std");
const testing = std.testing;

const raylib = @cImport({
    @cInclude("raylib.h");
    @cInclude("raymath.h");
});

// TODO:
// - GFX system
// - Text class
// - Logging system

// Types -------------------------------------------------------------------------------------------

pub fn Vec2(T: type) type {
    return struct {
        x: T,
        y: T,
    };
}

pub const Vec2i = Vec2(i32);
pub const Vec2f = Vec2(f32);

pub const WindowProperties = struct {
    size: Vec2i,
    title: [:0]const u8,
    target_fps: u16,

    pub fn init(size: Vec2i, comptime title: [:0]const u8, target_fps: u16) WindowProperties {
        return .{
            .size = size,
            .title = title,
            .target_fps = target_fps,
        };
    }
};

// Variables and State -----------------------------------------------------------------------------

pub var allocator: std.mem.Allocator = undefined;
var window_properties: WindowProperties = undefined;
var current_scene: ?Scene = null;
var new_scene: ?Scene = null;

// CORE --------------------------------------------------------------------------------------------

pub fn init(alloc: std.mem.Allocator, win_props: WindowProperties) void {
    allocator = alloc;
    window_properties = win_props;
    textures = std.ArrayList(TextureData).init(alloc); // GFX
    scenes = std.ArrayList(Scene).init(alloc); // SCENE
}

pub fn deinit() void {
    textures.deinit();
    scenes.deinit();
}

pub fn run() !void {
    raylib.InitWindow(window_properties.size.x, window_properties.size.y, window_properties.title);
    defer raylib.CloseWindow();

    raylib.SetTargetFPS(window_properties.target_fps);

    const placeholder_text = Text.init("SGE", 120);
    const placeholder_text_pos = Vec2i{
        .x = @divTrunc(raylib.GetScreenWidth() - placeholder_text.size.x, 2),
        .y = @divTrunc(raylib.GetScreenHeight() - placeholder_text.size.y, 2),
    };

    while (!raylib.WindowShouldClose()) {
        // Update -------------------------------------------------------------
        if (new_scene) |new| {
            if (current_scene) |old| {
                old.deinit();
            }

            current_scene = new;
            new_scene = null;

            current_scene.?.init();
        }

        if (current_scene) |scene| {
            scene.update();
        }

        // Draw ---------------------------------------------------------------

        raylib.BeginDrawing();
        defer raylib.EndDrawing();

        if (current_scene) |scene| {
            scene.draw();
        } else {
            clearBackground(Color.black);

            drawText(placeholder_text, placeholder_text_pos, Color.ray_white);
        }
    }

    if (current_scene) |scene| {
        scene.deinit();
    } else {
        // TODO(Caleb): Log that no scene was set
    }
}

pub fn getWindowProperties() WindowProperties {
    return window_properties;
}

// GFX ---------------------------------------------------------------------------------------------

// Types -----------------------------------------------------------------------

const GFXError = error{
    InvalidTextureID,
    TextureNotLoaded,
};

pub const Texture = struct {
    id: u64,
    size: Vec2i,
};

const TextureData = struct {
    id: u64,
    loaded: bool,
    data: raylib.Texture2D,
    size: Vec2i,

    pub fn init(id: u64, data: raylib.Texture2D) TextureData {
        return .{
            .id = id,
            .loaded = true,
            .data = data,
            .size = .{ .x = data.width, .y = data.height },
        };
    }
};

pub const Text = struct {
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

pub const Color = struct {
    r: u8,
    g: u8,
    b: u8,
    a: u8,

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

    pub fn init(r: u8, g: u8, b: u8, a: u8) Color {
        return .{
            .r = r,
            .g = g,
            .b = b,
            .a = a,
        };
    }

    fn toRaylibColor(self: Color) raylib.Color {
        return .{
            .r = self.r,
            .g = self.g,
            .b = self.b,
            .a = self.a,
        };
    }
};

// Variables -------------------------------------------------------------------

var textures: std.ArrayList(TextureData) = undefined;

// Functions -------------------------------------------------------------------

pub fn clearBackground(color: Color) void {
    raylib.ClearBackground(color.toRaylibColor());
}

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

    raylib.DrawTexture(texture_data.data, pos.x, pos.y, tint.toRaylibColor());
}

pub fn drawText(text: Text, pos: Vec2i, color: Color) void {
    raylib.DrawText(text.text, pos.x, pos.y, text.font_size, color.toRaylibColor());
}

// SCENE -------------------------------------------------------------------------------------------

const SceneInitFunction = *const fn () void;
const SceneDeinitFunction = *const fn () void;
const SceneUpdateFunction = *const fn () void;
const SceneDrawFunction = *const fn () void;

const Scene = struct {
    init: SceneInitFunction,
    deinit: SceneDeinitFunction,
    update: SceneUpdateFunction,
    draw: SceneDrawFunction,
};

const SceneID = u64;

var scenes: std.ArrayList(Scene) = undefined;

pub fn registerScene(comptime scene: Scene) ?SceneID {
    scenes.append(scene) catch return null;
    return scenes.items.len - 1;
}

pub fn setScene(id: SceneID) void {
    if (id >= scenes.items.len) return;

    new_scene = scenes.items[id];
}
