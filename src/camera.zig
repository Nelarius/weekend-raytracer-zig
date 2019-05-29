const std = @import("std");
const math = std.math;
const rand = std.rand;
const Ray = @import("ray.zig").Ray;
const Vec3f = @import("vector.zig").Vec3f;

pub const Camera = struct {
    const Self = @This();

    eye: Vec3f,
    lower_left_corner: Vec3f,
    horizontal: Vec3f,
    vertical: Vec3f,
    u: Vec3f,
    v: Vec3f,
    lens_radius: f32,

    pub fn new(lookfrom: Vec3f, lookat: Vec3f, vup: Vec3f, vfov: f32, aspect: f32, aperture: f32, focus_distance: f32) Camera {
        const lens_radius = 0.5 * aperture;
        // TODO: numerical constant for PI
        const theta = vfov * 3.14159 / 180.0;
        const half_height = math.tan(0.5 * theta);
        const half_width = aspect * half_height;

        const w = lookfrom.sub(lookat).makeUnitVector();
        const u = vup.cross(w).makeUnitVector();
        const v = w.cross(u);

        const lower_left_corner = lookfrom.sub(u.mul(half_width * focus_distance)).sub(v.mul(half_height * focus_distance)).sub(w.mul(focus_distance));
        const horizontal = u.mul(2.0 * half_width * focus_distance);
        const vertical = v.mul(2.0 * half_height * focus_distance);

        return Self{ .eye = lookfrom, .lower_left_corner = lower_left_corner, .horizontal = horizontal, .vertical = vertical, .u = u, .v = v, .lens_radius = lens_radius };
    }

    pub fn makeRay(self: *const Self, r: *rand.Random, u: f32, v: f32) Ray {
        const rd = Vec3f.randomInUnitDisk(r).mul(self.lens_radius);
        const offset = self.u.mul(rd.x).add(self.v.mul(rd.y));
        const lens_pos = self.eye.add(offset);

        return Ray.new(lens_pos, self.lower_left_corner.add(self.horizontal.mul(u)).add(self.vertical.mul(v)).sub(lens_pos).makeUnitVector());
    }
};
