const std = @import("std");
const c = @import("c.zig");
const Shader = @import("shader.zig").Shader;
const Mesh = @import("mesh.zig").Mesh;
const engine = @import("engine.zig");
const Engine = engine.Engine;

pub fn main() !void {
    var engine_instance = Engine.new();
    defer engine_instance.deinit();

    const vertices: []const f32 = &[_]f32{
        0.0, 0.0, 0.0,
        1.0, 0.0, 0.0,
        0.0, 1.0, 0.0,
        1.0, 1.0, 0.0,
        0.0, 0.0, 1.0,
        1.0, 0.0, 1.0,
        0.0, 1.0, 1.0,
        1.0, 1.0, 1.0,
    };

    const indices: []const u32 = &[_]u32{
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

    var mesh = try Mesh.new(vertices, indices);
    try mesh.init();
    defer mesh.deinit();

    const shader = try Shader.from_source(@embedFile("vert.glsl"), @embedFile("frag.glsl"));

    while (!engine_instance.close_requested()) {
        engine_instance.clear();

        shader.use();
        mesh.bind();

        c.glDrawElements(c.GL_TRIANGLES, indices.len, c.GL_UNSIGNED_INT, null);

        mesh.unbind();
        shader.stop();

        engine_instance.swap_buffers();
    }
}
