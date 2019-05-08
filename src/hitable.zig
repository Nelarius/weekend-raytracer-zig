const math = @import("std").math;
const Ray = @import("ray.zig").Ray;
const Vec3f = @import("vector.zig").Vec3f;

pub const HitRecord = struct {
    pub t: f32,
    pub p: Vec3f,
    pub n: Vec3f,
};

pub const Sphere = struct {
    pub center: Vec3f,
    pub radius: f32,

    pub fn new(center: Vec3f, radius: f32) Sphere {
        return Sphere{
            .center = center,
            .radius = radius,
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
        const discriminant = 4.0 * b * b - 4.0 * a * c;

        if (discriminant > 0.0) {
            {
                const t = (-b - math.sqrt(b * b - a * c)) / a;
                if (t < t_max and t > t_min) {
                    const hit_point = ray.pointAtParameter(t);
                    return HitRecord{
                        .t = t,
                        .p = hit_point,
                        .n = (hit_point.sub(self.center)).mul(1.0 / self.radius),
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
                    };
                }
            }
        }

        return null;
    }
};

pub const World = struct {
    pub spheres: []const Sphere,

    pub fn hit(self: *const World, ray: Ray, t_min: f32, t_max: f32) ?HitRecord {
        var maybe_hit: ?HitRecord = null;
        var closest_so_far = t_max;

        for (self.spheres) |sphere| {
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
