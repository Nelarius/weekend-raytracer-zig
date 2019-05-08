const hitable = @import("hitable.zig");
const std = @import("std");
const Ray = @import("ray.zig").Ray;
const Vec3f = @import("vector.zig").Vec3f;

const HitRecord = hitable.HitRecord;
const Sphere = hitable.Sphere;
const World = hitable.World;

const c = @cImport({
    @cInclude("SDL.h");
});

// See https://github.com/zig-lang/zig/issues/565
// SDL_video.h:#define SDL_WINDOWPOS_UNDEFINED         SDL_WINDOWPOS_UNDEFINED_DISPLAY(0)
// SDL_video.h:#define SDL_WINDOWPOS_UNDEFINED_DISPLAY(X)  (SDL_WINDOWPOS_UNDEFINED_MASK|(X))
// SDL_video.h:#define SDL_WINDOWPOS_UNDEFINED_MASK    0x1FFF0000u
const SDL_WINDOWPOS_UNDEFINED = @bitCast(c_int, c.SDL_WINDOWPOS_UNDEFINED_MASK);

const window_width: c_int = 640;
const window_height: c_int = 320;

// For some reason, this isn't parsed automatically. According to SDL docs, the
// surface pointer returned is optional!
extern fn SDL_GetWindowSurface(window: *c.SDL_Window) ?*c.SDL_Surface;
extern fn setPixel(surf: *c.SDL_Surface, x: c_int, y: c_int, pixel: u32) void;

fn color(r: Ray, w: *const World) Vec3f {
    const maybe_hit = w.hit(r, 0.0, 1000.0);
    if (maybe_hit) |hit| {
        const n = r.pointAtParameter(hit.t).sub(Vec3f.new(0.0, 0.0, -1.0)).makeUnitVector();
        // return n.add(Vec3f.one()).mul(0.5);
        return Vec3f{
            .x = 0.5 * (n.x + 1.0),
            .y = 0.5 * (n.y + 1.0),
            .z = 0.5 * (n.z + 1.0),
        };
    } else {
        const unit_direction = r.direction.makeUnitVector();
        const t = 0.5 * (unit_direction.y + 1.0);
        return Vec3f.new(1.0, 1.0, 1.0).mul(1.0 - t).add(Vec3f.new(0.5, 0.7, 1.0).mul(t));
    }
}

fn toBgra(r: u32, g: u32, b: u32) u32 {
    return 255 << 24 | r << 16 | g << 8 | b;
}

pub fn main() !void {
    if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) {
        c.SDL_Log(c"Unable to initialize SDL: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    }
    defer c.SDL_Quit();

    const window = c.SDL_CreateWindow(c"it works", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, window_width, window_height, c.SDL_WINDOW_OPENGL) orelse {
        c.SDL_Log(c"Unable to create window: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };
    defer c.SDL_DestroyWindow(window);

    const surface = SDL_GetWindowSurface(window) orelse {
        c.SDL_Log(c"Unable to get window surface: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };

    // Ray tracing takes place here

    // 640 by 320
    const lower_left_corner = Vec3f.new(-1.6, -0.8, -1.0);
    const horizontal = Vec3f.new(3.2, 0.0, 0.0);
    const vertical = Vec3f.new(0.0, 1.6, 0.0);
    const origin = Vec3f.new(0.0, 0.0, 0.0);

    const world = World{
        .spheres = []const Sphere{
            Sphere.new(Vec3f.new(0.0, 0.0, -1.0), 0.5),
            Sphere.new(Vec3f.new(0.0, -100.5, -1.0), 100.0),
        },
    };

    {
        _ = c.SDL_LockSurface(surface);
        var idx: i32 = 0;
        while (idx < window_width * window_height) : (idx += 1) {
            const w = @mod(idx, window_width);
            const h = @divTrunc(idx, window_width);

            const u = @intToFloat(f32, w) / @intToFloat(f32, window_width);
            const v = @intToFloat(f32, h) / @intToFloat(f32, window_height);

            const camera_horizontal = horizontal.mul(u);
            const camera_vertical = vertical.mul(v);

            const r = Ray.new(origin, lower_left_corner.add(camera_horizontal).add(camera_vertical));
            const rgbf = color(r, &world);
            setPixel(surface, w, window_height - h - 1, toBgra(@floatToInt(u32, 255.99 * rgbf.x), @floatToInt(u32, 255.99 * rgbf.y), @floatToInt(u32, 255.99 * rgbf.z)));
        }
        c.SDL_UnlockSurface(surface);
    }

    if (c.SDL_UpdateWindowSurface(window) != 0) {
        c.SDL_Log(c"Error updating window surface: %s", c.SDL_GetError());
        return error.SDLUpdateWindowFailed;
    }

    var running = true;
    while (running) {
        var event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&event) != 0) {
            switch (event.@"type") {
                c.SDL_QUIT => {
                    running = false;
                },
                else => {},
            }
        }

        c.SDL_Delay(16);
    }
}
