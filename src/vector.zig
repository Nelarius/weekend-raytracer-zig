const math = @import("std").math;
const Random = @import("std").rand.Random;

pub fn Vector3(comptime T: type) type {
    return packed struct {
        const Self = @This();

        x: T,
        y: T,
        z: T,

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

        pub fn elementwiseMul(lhs: Self, rhs: Self) Self {
            return Self{
                .x = lhs.x * rhs.x,
                .y = lhs.y * rhs.y,
                .z = lhs.z * rhs.z,
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

        pub fn cross(a: Self, b: Self) Self {
            return Self{
                .x = a.y * b.z - a.z * b.y,
                .y = a.z * b.x - a.x * b.z,
                .z = a.x * b.y - a.y * b.x,
            };
        }

        pub fn makeUnitVector(self: Self) Self {
            const inv_n = 1.0 / self.length();
            return Self{
                .x = inv_n * self.x,
                .y = inv_n * self.y,
                .z = inv_n * self.z,
            };
        }

        pub fn randomInUnitSphere(r: *Random) Self {
            return while (true) {
                const p = Vec3f.new(r.float(f32), r.float(f32), r.float(f32));
                if (p.lengthSquared() < 1.0) {
                    break p;
                }
                // WTF, why do we need an else for a while loop? O.o
            } else Vec3f.zero();
        }

        pub fn randomInUnitDisk(r: *Random) Self {
            return while (true) {
                const p = Vec3f.new(2.0 * r.float(f32) - 1.0, 2.0 * r.float(f32) - 1.0, 0.0);
                if (p.lengthSquared() < 1.0) {
                    break p;
                }
            } else Vec3f.zero();
        }

        pub fn reflect(self: Self, n: Self) Self {
            return self.sub(n.mul(2.0 * self.dot(n)));
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

test "Vector3.makeUnitVector" {
    const v = Vec3f.new(1.0, 2.0, 3.0);
    const uv = v.makeUnitVector();
    assert(math.fabs(uv.length() - 1.0) < epsilon);
}

test "Vector3.cross" {
    const lhs = Vec3f.new(1.0, 0.0, 2.0);
    const rhs = Vec3f.new(2.0, 1.0, 2.0);
    const res = lhs.cross(rhs);
    assert(math.fabs(res.x + 2.0) < epsilon);
    assert(math.fabs(res.y - 2.0) < epsilon);
    assert(math.fabs(res.z - 1.0) < epsilon);
}
