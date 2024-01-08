const std = @import("std");

pub const Vec3 = struct {
    e0: f32,
    e1: f32,
    e2: f32,

    const Self = @This();

    pub fn new(e0: f32, e1: f32, e2: f32) Self {
        return Self{
            .e0 = e0,
            .e1 = e1,
            .e2 = e2,
        };
    }

    pub fn x(self: Self) f32 {
        return self.e0;
    }

    pub fn y(self: Self) f32 {
        return self.e1;
    }

    pub fn z(self: Self) f32 {
        return self.e2;
    }

    pub fn r(self: Self) f32 {
        return self.e0;
    }

    pub fn g(self: Self) f32 {
        return self.e1;
    }

    pub fn b(self: Self) f32 {
        return self.e2;
    }

    pub fn print(self: Self) void {
        std.debug.print("({d}, {d}, {d})\n", .{ self.e0, self.e1, self.e2 });
    }
};
