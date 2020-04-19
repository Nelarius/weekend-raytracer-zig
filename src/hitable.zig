const std = @import("std");
const math = std.math;
const ArrayList = std.ArrayList;
const debug = std.debug;

const mat = @import("material.zig");
const Material = @import("material.zig").Material;
const Ray = @import("ray.zig").Ray;
const Vec3f = @import("vector.zig").Vec3f;

pub const HitRecord = struct {
    t: f32,
    p: Vec3f,
    n: Vec3f,
    material: mat.Material
};

pub const Sphere = struct {
    center: Vec3f,
    radius: f32,
    material: Material,

    pub fn new(center: Vec3f, radius: f32, material: Material) Sphere {
        return Sphere{
            .center = center,
            .radius = radius,
            .material = material,
        };
    }

    pub fn hit(self: Sphere, ray: Ray, t_min: f32, t_max: f32) ?HitRecord {
        // C: circle center
        // r: circle radius
        // O: ray origin
        // D: ray direction
        // (t*D + O - C)^2 = r^2
        // t^2 * D^2 + 2 * t * D * (O - C) + (O - C) * (O - C) = r^2
        const oc = ray.origin.sub(self.center);
        const a = ray.direction.dot(ray.direction);
        const b = oc.dot(ray.direction); // the factor 2.0 was moved out of b
        const c = oc.dot(oc) - self.radius * self.radius;
        const discriminant = b * b - a * c;

        if (discriminant > 0.0) {
            {
                const t = (-b - math.sqrt(b * b - a * c)) / a;
                if (t < t_max and t > t_min) {
                    const hit_point = ray.pointAtParameter(t);
                    return HitRecord{
                        .t = t,
                        .p = hit_point,
                        .n = (hit_point.sub(self.center)).mul(1.0 / self.radius),
                        .material = self.material
                    };
                }
            }

            {
                const t = (-b + math.sqrt(b * b - a * c)) / a;
                if (t < t_max and t > t_min) {
                    const hit_point = ray.pointAtParameter(t);
                    return HitRecord{
                        .t = t,
                        .p = hit_point,
                        .n = (hit_point.sub(self.center)).mul(1.0 / self.radius),
                        .material = self.material
                    };
                }
            }
        }

        return null;
    }
};

pub const World = struct {
    spheres: ArrayList(Sphere),

    pub fn init() World {
        return World {
            .spheres = ArrayList(Sphere).init(std.testing.allocator)
        };
    }

    pub fn deinit(self: *World) void {
        self.spheres.deinit();
    }

    pub fn hit(self: *const World, ray: Ray, t_min: f32, t_max: f32) ?HitRecord {
        var maybe_hit: ?HitRecord = null;
        var closest_so_far = t_max;

        for (self.spheres.items) |sphere| {
            if (sphere.hit(ray, t_min, t_max)) |hit_rec| {
                if (hit_rec.t < closest_so_far) {
                    maybe_hit = hit_rec;
                    closest_so_far = hit_rec.t;
                }
            }
        }

        return maybe_hit;
    }
};
