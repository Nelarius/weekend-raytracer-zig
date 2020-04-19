const Vec3f = @import("vector.zig").Vec3f;

pub const Ray = struct {
    origin: Vec3f,
    direction: Vec3f,

    pub fn new(origin: Vec3f, direction: Vec3f) Ray {
        return Ray{
            .origin = origin,
            .direction = direction,
        };
    }

    pub fn pointAtParameter(self: Ray, t: f32) Vec3f {
        return self.origin.add(self.direction.mul(t));
    }
};

const assert = @import("std").debug.assert;
const math = @import("std").math;
const epsilon: f32 = 0.00001;

test "Ray.pointAtParameter" {
    const r = Ray.new(Vec3f.zero(), Vec3f.one());
    const p = r.pointAtParameter(1.0);
    assert(math.fabs(p.x - 1.0) < epsilon);
    assert(math.fabs(p.y - 1.0) < epsilon);
    assert(math.fabs(p.z - 1.0) < epsilon);
}
