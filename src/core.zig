const std = @import("std");
const testing = std.testing;

const c = @import("c.zig");

// TODO(Caleb): Document the public API

// NOTE(Caleb): Possible architecture plan:
// - core
// - log
// - gfx (window, frame timing, rendering)
// - scene (input, scene management)
// - math
// - ecs
// - audio
// - net

// core --------------------------------------------------------------------------------------------

var cfg: Config = undefined;
var current_scene: Scene = DefaultScene.scene();
var new_scene: ?Scene = null;

pub const Config = struct {
    allocator: std.mem.Allocator,
    win_props: WindowProperties,
};

pub fn init(config: Config) void {
    cfg = config;

    textures = std.ArrayList(TextureData).init(config.allocator);
    scenes = std.ArrayList(Scene).init(config.allocator);
}

pub fn deinit() void {
    textures.deinit();
    scenes.deinit();
}

pub fn getWindowProperties() WindowProperties {
    return cfg.win_props;
}

pub fn run() !void {
    // TODO(Caleb): Move to gfx
    c.InitWindow(cfg.win_props.size.x, cfg.win_props.size.y, cfg.win_props.title);
    defer c.CloseWindow();

    // TODO(Caleb): Move to gfx
    c.SetTargetFPS(cfg.win_props.target_fps);

    current_scene.init();

    while (!c.WindowShouldClose()) {
        // Update -------------------------------------------------------------

        if (new_scene) |new| {
            current_scene.deinit();

            current_scene = new;
            new_scene = null;

            current_scene.init();
        }

        current_scene.update();

        // Draw ---------------------------------------------------------------

        // TODO(Caleb): Move to gfx?
        c.BeginDrawing();
        defer c.EndDrawing();

        current_scene.draw();
    }

    current_scene.deinit();
}

// math --------------------------------------------------------------------------------------------

pub fn Vec2(T: type) type {
    return struct {
        x: T,
        y: T,
    };
}

pub const Vec2i = Vec2(i32);
pub const Vec2f = Vec2(f32);

// gfx ---------------------------------------------------------------------------------------------

var textures: std.ArrayList(TextureData) = undefined;

pub const WindowProperties = struct {
    size: Vec2i,
    title: [:0]const u8,
    target_fps: u16,

    pub fn init(size: Vec2i, comptime title: [:0]const u8, target_fps: u16) WindowProperties {
        return .{ .size = size, .title = title, .target_fps = target_fps };
    }
};

// TODO(Caleb): Rethink error names
pub const GraphicsError = error{
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
    data: c.Texture2D,
    size: Vec2i,

    pub fn init(id: u64, data: c.Texture2D) TextureData {
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
        const size = c.MeasureTextEx(
            c.GetFontDefault(),
            text,
            @floatFromInt(font_size),
            @as(f32, @floatFromInt(font_size)) / 10, // c's default spacing between characters
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

    fn toRaylibColor(self: Color) c.Color {
        return .{
            .r = self.r,
            .g = self.g,
            .b = self.b,
            .a = self.a,
        };
    }
};

pub fn clearBackground(color: Color) void {
    c.ClearBackground(color.toRaylibColor());
}

pub fn loadTexture(comptime path: [:0]const u8) Texture {
    const raw_texture_data = c.LoadTexture(path);
    errdefer c.UnloadTexture(raw_texture_data);

    const texture_data = TextureData.init(textures.items.len, raw_texture_data);
    textures.append(texture_data) catch unreachable; // TODO(Caleb): Handle error properly?

    return .{ .id = texture_data.id, .size = texture_data.size };
}

pub fn unloadTexture(texture: Texture) GraphicsError!void {
    if (texture.id >= textures.items.len) return GraphicsError.InvalidTextureID;
    if (!textures.items[texture.id].loaded) return GraphicsError.TextureNotLoaded;

    var texture_data = &textures.items[texture.id];
    c.UnloadTexture(texture_data.data);
    texture_data.loaded = false;
}

pub fn drawTexture(texture: Texture, pos: Vec2i, tint: Color) void {
    // TODO(Caleb): Should we return an error here? Or just log?
    if (texture.id >= textures.items.len) return;
    if (!textures.items[texture.id].loaded) return;

    const texture_data = textures.items[texture.id];
    const normalized = normalizeScreenCoords(pos);
    c.DrawTexture(texture_data.data, normalized.x, normalized.y, tint.toRaylibColor());
}

pub fn drawText(text: Text, pos: Vec2i, color: Color) void {
    const normalized = normalizeScreenCoords(pos);
    c.DrawText(text.text, normalized.x, normalized.y, text.font_size, color.toRaylibColor());
}

fn normalizeScreenCoords(v: Vec2i) Vec2i {
    var normalized = v;
    if (v.x < 0) normalized.x += cfg.win_props.size.x;
    if (v.y < 0) normalized.y += cfg.win_props.size.y;

    return normalized;
}

// scene -------------------------------------------------------------------------------------------

var scenes: std.ArrayList(Scene) = undefined;

pub const SceneInitFunction = *const fn () void;
pub const SceneDeinitFunction = *const fn () void;
pub const SceneUpdateFunction = *const fn () void;
pub const SceneDrawFunction = *const fn () void;

pub const SceneID = u64;

pub const Scene = struct {
    init: SceneInitFunction,
    deinit: SceneDeinitFunction,
    update: SceneUpdateFunction,
    draw: SceneDrawFunction,
};

const DefaultScene = struct {
    var default_scene_text: Text = undefined;
    var default_scene_text_pos: Vec2i = undefined;

    fn init() void {
        default_scene_text = Text.init("ZGE", 120);
        default_scene_text_pos = .{
            .x = @divTrunc(cfg.win_props.size.x - default_scene_text.size.x, 2),
            .y = @divTrunc(cfg.win_props.size.y - default_scene_text.size.y, 2),
        };
    }

    fn deinit() void {}

    fn update() void {}

    fn draw() void {
        clearBackground(Color.dark_gray);
        drawText(default_scene_text, default_scene_text_pos, Color.ray_white);
    }

    pub fn scene() Scene {
        return .{
            .init = DefaultScene.init,
            .deinit = DefaultScene.deinit,
            .update = DefaultScene.update,
            .draw = DefaultScene.draw,
        };
    }
};

// TODO(Caleb): Should this return an optional or an error union?
pub fn registerScene(comptime scene: Scene) ?SceneID {
    scenes.append(scene) catch return null;
    return scenes.items.len - 1;
}

// TODO(Caleb): Should this error?
pub fn setScene(id: SceneID) void {
    if (id >= scenes.items.len) return;

    new_scene = scenes.items[id];
}

// log (coming soon...) ----------------------------------------------------------------------------
// ecs (coming soon...) ----------------------------------------------------------------------------
// audio (coming soon...) --------------------------------------------------------------------------
// net (coming soon...) ----------------------------------------------------------------------------
