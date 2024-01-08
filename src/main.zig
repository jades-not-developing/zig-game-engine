const std = @import("std");
const c = @import("c.zig");
const Shader = @import("shader.zig").Shader;
const Mesh = @import("mesh.zig").Mesh;
const engine = @import("engine.zig");
const Engine = engine.Engine;
const Vec3 = @import("math/vec3.zig").Vec3;

const mach = @import("mach");

pub fn main() !void {
    const v = Vec3.new(0.0, 0.0, 0.0);
    v.print();

    var engine_instance = Engine.new();
    defer engine_instance.deinit();

    const mesh_1_vertices: []const f32 = &[_]f32{
        0.0, 0.0, 0.0,
        1.0, 0.0, 0.0,
        0.0, 1.0, 0.0,
        1.0, 1.0, 0.0,
        0.0, 0.0, 1.0,
        1.0, 0.0, 1.0,
        0.0, 1.0, 1.0,
        1.0, 1.0, 1.0,
    };

    const mesh_1_indices: []const u32 = &[_]u32{
        // front
        0, 1, 2,
        2, 3, 0,

        // right
        1, 5, 6,
        6, 2, 1,

        // back
        7, 6, 5,
        5, 4, 7,

        // left
        4, 0, 3,
        3, 7, 4,

        // bottom
        4, 5, 1,
        1, 0, 4,

        // top
        3, 2, 6,
        6, 7, 3,
    };

    const mesh_2_vertices: []const f32 = &[_]f32{
        -0.5, -0.5, 0.0,
        0.5,  -0.5, 0.0,
        0.0,  0.5,  0.0,
    };

    const mesh_2_indices: []const u32 = &[_]u32{ 0, 1, 2 };

    var mesh_1 = try Mesh.new(mesh_1_vertices, mesh_1_indices);
    try mesh_1.init();
    defer mesh_1.deinit();

    var mesh_2 = try Mesh.new(mesh_2_vertices, mesh_2_indices);
    try mesh_2.init();
    defer mesh_2.deinit();

    const shader = try Shader.from_source(@embedFile("vert.glsl"), @embedFile("frag.glsl"));

    while (!engine_instance.close_requested()) {
        engine_instance.clear();

        shader.use();

        mesh_1.bind();
        mesh_1.render();
        mesh_1.unbind();

        mesh_2.bind();
        mesh_2.render();
        mesh_2.unbind();

        shader.stop();

        engine_instance.swap_buffers();
    }
}
