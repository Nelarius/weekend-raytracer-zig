const HitRecord = @import("hitable.zig").HitRecord;
const math = @import("std").math;
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

    pub fn scatter(self: Lambertian, hit: HitRecord, rand: *Random) Scatter {
        const target = hit.p.add(hit.n.add(Vec3f.randomInUnitSphere(rand)));
        const attenuation = self.albedo;
        const scattered_ray = Ray.new(hit.p, target.sub(hit.p).makeUnitVector());
        return Scatter.new(attenuation, scattered_ray);
    }
};

pub const Metal = struct {
    albedo: Vec3f,
    fuzz: f32,

    pub fn scatter(self: Metal, ray: Ray, hit: HitRecord, rand: *Random) Scatter {
        const reflected = ray.direction.reflect(hit.n.makeUnitVector());
        const attenuation = self.albedo;
        const scattered = Ray.new(hit.p, reflected.add(Vec3f.randomInUnitSphere(rand).mul(self.fuzz)).makeUnitVector());
        return Scatter.new(attenuation, scattered);
    }
};

fn refract(v: Vec3f, n: Vec3f, ni_over_nt: f32) ?Vec3f {
    // ni * sin(i) = nt * sin(t)
    // sint(t) = sin(i) * (ni / nt)
    const uv = v.makeUnitVector();
    const dt = uv.dot(n);
    const discriminant = 1.0 - ni_over_nt * ni_over_nt * (1.0 - dt * dt);

    if (discriminant > 0.0) {
        // ni_over_nt * (uv - dt * n) - (n * sqrt(discriminant))
        return uv.sub(n.mul(dt)).mul(ni_over_nt).sub(n.mul(math.sqrt(discriminant)));
    }

    return null;
}

fn schlick(cosine: f32, refraction_index: f32) f32 {
    var r0 = (1.0 - refraction_index) / (1.0 + refraction_index);
    r0 = r0 * r0;
    return r0 + (1.0 - r0) * math.pow(f32, (1.0 - cosine), 5.0);
}

pub const Dielectric = struct {
    pub refraction_index: f32,

    pub fn scatter(self: Dielectric, ray: Ray, hit: HitRecord, rand: *Random) Scatter {
        // If the ray direction and hit normal are in the same half-sphere
        var outward_normal: Vec3f = undefined;
        var ni_over_nt: f32 = undefined;
        var cosine: f32 = undefined;

        if (ray.direction.dot(hit.n) > 0.0) {
            outward_normal = Vec3f.new(-hit.n.x, -hit.n.y, -hit.n.z);
            ni_over_nt = self.refraction_index;
            cosine = self.refraction_index * ray.direction.dot(hit.n) / ray.direction.length();
        } else {
            outward_normal = hit.n;
            ni_over_nt = 1.0 / self.refraction_index;
            cosine = -ray.direction.dot(hit.n) / ray.direction.length();
        }

        if (refract(ray.direction, outward_normal, ni_over_nt)) |refracted_dir| {
            const reflection_prob = schlick(cosine, self.refraction_index);
            return if (rand.float(f32) < reflection_prob) Scatter.new(Vec3f.one(), Ray.new(hit.p, ray.direction.reflect(hit.n).makeUnitVector())) else Scatter.new(Vec3f.one(), Ray.new(hit.p, refracted_dir.makeUnitVector()));
        } else {
            return Scatter.new(Vec3f.one(), Ray.new(hit.p, ray.direction.reflect(hit.n).makeUnitVector()));
        }
    }
};

pub const Material = union(enum) {
    Lambertian: Lambertian,
    Metal: Metal,
    Dielectric: Dielectric,

    pub fn lambertian(albedo: Vec3f) Material {
        return Material{ .Lambertian = Lambertian{ .albedo = albedo } };
    }

    pub fn metal(albedo: Vec3f, fuzz: f32) Material {
        return Material{ .Metal = Metal{ .albedo = albedo, .fuzz = fuzz } };
    }

    pub fn dielectric(refraction_index: f32) Material {
        return Material{ .Dielectric = Dielectric{ .refraction_index = refraction_index } };
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
