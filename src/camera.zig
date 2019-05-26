const std = @import("std");
const math = std.math;
const Ray = @import("ray.zig").Ray;
const Vec3f = @import("vector.zig").Vec3f;

pub const Camera = struct {
    const Self = @This();

    pub eye: Vec3f,
    pub lower_left_corner: Vec3f,
    pub horizontal: Vec3f,
    pub vertical: Vec3f,

    pub fn new(lookfrom: Vec3f, lookat: Vec3f, vup: Vec3f, vfov: f32, aspect: f32) Camera {
        // TODO: numerical constant
        const theta = vfov * 3.14159 / 180.0;
        const half_height = math.tan(0.5 * theta);
        const half_width = aspect * half_height;

        const w = lookfrom.sub(lookat).makeUnitVector();
        const u = vup.cross(w).makeUnitVector();
        const v = w.cross(u);

        const lower_left_corner = lookfrom.sub(u.mul(half_width)).sub(v.mul(half_height)).sub(w);
        const horizontal = u.mul(2.0 * half_width);
        const vertical = v.mul(2.0 * half_height);

        return Self{ .eye = lookfrom, .lower_left_corner = lower_left_corner, .horizontal = horizontal, .vertical = vertical };
    }

    pub fn makeRay(self: *const Self, u: f32, v: f32) Ray {
        return Ray.new(self.eye, self.lower_left_corner.add(self.horizontal.mul(u)).add(self.vertical.mul(v)).sub(self.eye).makeUnitVector());
    }
};
