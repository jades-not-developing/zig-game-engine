const std = @import("std");

pub fn Vec3(comptime T: type) type {
    return struct {
        x: T,
        y: T,
        z: T,

        pub fn new(x: T, y: T, z: T) @This() {
            return @This(){
                .x = x,
                .y = y,
                .z = z,
            };
        }

        pub fn _x(self: @This()) T {
            return self.x;
        }
        pub fn _y(self: @This()) T {
            return self.y;
        }
        pub fn _z(self: @This()) T {
            return self.z;
        }

        pub fn _r(self: @This()) T {
            return self.x();
        }
        pub fn _g(self: @This()) T {
            return self.y();
        }
        pub fn _b(self: @This()) T {
            return self.z();
        }

        pub fn print(self: @This()) void {
            std.debug.print("({d}, {d}, {d})\n", .{ self.x, self.y, self.z });
        }

        pub fn add(self: @This(), other: Vec3(T)) Vec3(T) {
            return Vec3(T){
                .x = self.x + other.x,
                .y = self.y + other.y,
                .z = self.z + other.z,
            };
        }

        pub fn sub(self: @This(), other: Vec3(T)) Vec3(T) {
            return Vec3(T){
                .x = self.x - other.x,
                .y = self.y - other.y,
                .z = self.z - other.z,
            };
        }

        pub fn mul(self: @This(), other: Vec3(T)) Vec3(T) {
            return Vec3(T){
                .x = self.x * other.x,
                .y = self.y * other.y,
                .z = self.z * other.z,
            };
        }

        pub fn div(self: @This(), other: Vec3(T)) Vec3(T) {
            return Vec3(T){
                .x = self.x / other.x,
                .y = self.y / other.y,
                .z = self.z / other.z,
            };
        }

        pub fn add_single(self: @This(), other: T) Vec3(T) {
            return Vec3(T){
                .x = self.x + other,
                .y = self.y + other,
                .z = self.z + other,
            };
        }

        pub fn sub_single(self: @This(), other: T) Vec3(T) {
            return Vec3(T){
                .x = self.x - other,
                .y = self.y - other,
                .z = self.z - other,
            };
        }

        pub fn mul_single(self: @This(), other: T) Vec3(T) {
            return Vec3(T){
                .x = self.x * other,
                .y = self.y * other,
                .z = self.z * other,
            };
        }

        pub fn div_single(self: @This(), other: T) Vec3(T) {
            return Vec3(T){
                .x = self.x / other,
                .y = self.y / other,
                .z = self.z / other,
            };
        }
    };
}

test "can add 2 vec3s together" {
    const vec = Vec3(f32).new(1.0, 2.0, 3.1);
    const added = vec.add(Vec3(f32).new(4.0, 5.0, 6.0));

    try std.testing.expect(std.meta.eql(added, Vec3(f32){
        .x = 5.0,
        .y = 7.0,
        .z = 9.1,
    }));
}

test "can subtract 2 vec3s together" {
    const vec = Vec3(f32).new(1.0, 2.0, 3.1);
    const added = vec.sub(Vec3(f32).new(4.0, 5.0, 6.0));

    try std.testing.expect(std.meta.eql(added, Vec3(f32){
        .x = -3.0,
        .y = -3.0,
        .z = -2.9,
    }));
}

test "can multiply 2 vec3s together" {
    const vec = Vec3(f32).new(1.0, 2.0, 3.0);
    const added = vec.mul(Vec3(f32).new(4.0, 5.0, 6.0));

    try std.testing.expect(std.meta.eql(added, Vec3(f32){
        .x = 4.0,
        .y = 10.0,
        .z = 18.0,
    }));
}

test "can divide 2 vec3s together" {
    const vec = Vec3(f32).new(10.0, 4.0, 20.0);
    const added = vec.div(Vec3(f32).new(2.0, 4.0, 5.0));

    try std.testing.expect(std.meta.eql(added, Vec3(f32){
        .x = 5.0,
        .y = 1.0,
        .z = 4.0,
    }));
}
