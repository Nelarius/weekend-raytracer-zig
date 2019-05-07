const math = @import("std").math;

pub fn Vector3(comptime T: type) type {
    return packed struct {
        const Self = @This();

        pub x: T,
        pub y: T,
        pub z: T,

        pub fn new(x: T, y: T, z: T) Self {
            return Self{
                .x = x,
                .y = y,
                .z = z,
            };
        }

        pub fn zero() Self {
            return Self{
                .x = 0.0,
                .y = 0.0,
                .z = 0.0,
            };
        }

        pub fn one() Self {
            return Self{
                .x = 1.0,
                .y = 1.0,
                .z = 1.0,
            };
        }

        pub fn add(a: Self, b: Self) Self {
            return Self{
                .x = a.x + b.x,
                .y = a.y + b.y,
                .z = a.z + b.z,
            };
        }

        pub fn sub(a: Self, b: Self) Self {
            return Self{
                .x = a.x - b.x,
                .y = a.y - b.y,
                .z = a.z - b.z,
            };
        }

        pub fn mul(self: Self, s: T) Self {
            return Self{
                .x = s * self.x,
                .y = s * self.y,
                .z = s * self.z,
            };
        }

        pub fn length(self: Self) T {
            return math.sqrt(self.x * self.x + self.y * self.y + self.z * self.z);
        }

        pub fn lengthSquared(self: Self) T {
            return self.x * self.x + self.y * self.y + self.z * self.z;
        }

        pub fn dot(a: Self, b: Self) T {
            return a.x * b.x + a.y * b.y + a.z * b.z;
        }

        pub fn makeUnitVector(self: Self) Self {
            const inv_n = 1.0 / self.length();
            return Self{
                .x = inv_n * self.x,
                .y = inv_n * self.y,
                .z = inv_n * self.z,
            };
        }
    };
}

pub const Vec3f = Vector3(f32);

const assert = @import("std").debug.assert;
const epsilon: f32 = 0.00001;

test "Vector3.add" {
    const lhs = Vec3f.new(1.0, 2.0, 3.0);
    const rhs = Vec3f.new(2.0, 3.0, 4.0);
    const r = lhs.add(rhs);
    assert(math.fabs(r.x - 3.0) < epsilon);
    assert(math.fabs(r.y - 5.0) < epsilon);
    assert(math.fabs(r.z - 7.0) < epsilon);
}

test "Vector3.sub" {
    const lhs = Vec3f.new(2.0, 3.0, 4.0);
    const rhs = Vec3f.new(2.0, 4.0, 3.0);
    const r = lhs.sub(rhs);
    assert(math.fabs(r.x) < epsilon);
    assert(math.fabs(r.y + 1.0) < epsilon);
    assert(math.fabs(r.z - 1.0) < epsilon);
}

test "Vector.makeUnitVector" {
    const v = Vec3f.new(1.0, 2.0, 3.0);
    const uv = v.makeUnitVector();
    assert(math.fabs(uv.length() - 1.0) < epsilon);
}
