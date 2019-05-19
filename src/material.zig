const HitRecord = @import("hitable.zig").HitRecord;
const Random = @import("std").rand.Random;
const Ray = @import("ray.zig").Ray;
const Vec3f = @import("vector.zig").Vec3f;

pub const Scatter = struct {
    pub attenuation: Vec3f,
    pub ray: Ray,

    pub fn new(attenuation: Vec3f, ray: Ray) Scatter {
        return Scatter{
            .attenuation = attenuation,
            .ray = ray,
        };
    }
};

pub const Lambertian = struct {
    pub albedo: Vec3f,

    pub fn scatter(self: Lambertian, hit: HitRecord, rand: *Random) ?Scatter {
        const target = hit.p.add(hit.n.add(Vec3f.randomInUnitSphere(rand)));
        const attenuation = self.albedo;
        const scattered_ray = Ray.new(hit.p, target.sub(hit.p));
        return Scatter.new(attenuation, scattered_ray);
    }
};

pub const Metal = struct {
    albedo: Vec3f,
    fuzz: f32,

    pub fn scatter(self: Metal, ray: Ray, hit: HitRecord, rand: *Random) ?Scatter {
        const reflected = ray.direction.reflect(hit.n.makeUnitVector());
        const attenuation = self.albedo;
        const scattered = Ray.new(hit.p, reflected.add(Vec3f.randomInUnitSphere(rand).mul(self.fuzz)));
        return Scatter.new(attenuation, scattered);
    }
};

pub const Material = union(enum) {
    Lambertian: Lambertian,
    Metal: Metal,

    pub fn lambertian(albedo: Vec3f) Material {
        return Material{ .Lambertian = Lambertian{ .albedo = albedo } };
    }

    pub fn metal(albedo: Vec3f, fuzz: f32) Material {
        return Material{ .Metal = Metal{ .albedo = albedo, .fuzz = fuzz } };
    }
};

const std = @import("std");
const assert = std.debug.assert;

test "complex union" {
    const complex_union = Material{ .Lambertian = Lambertian{ .attenuation = Vec3f.new(1.0, 0.0, 0.0) } };
    assert(complex_union.Lambertian.attenuation.x == 1.0);
}

test "switch expression" {
    const complex_union = Material{ .Lambertian = Lambertian{ .attenuation = Vec3f.new(1.0, 0.0, 0.0) } };
    assert(complex_union.Lambertian.attenuation.x == 1.0);

    const val = switch (complex_union) {
        Material.Lambertian => |l| l.attenuation.x,
        Material.Metal => |m| m.albedo.x,
    };
    assert(val == 1.0);
}
