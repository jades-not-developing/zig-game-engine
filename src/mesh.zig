const std = @import("std");
const c = @import("c.zig");

pub const Mesh = struct {
    vertices: [1024]f32 = [1]f32{0} ** 1024,
    indices: [1024]u32 = [1]u32{0} ** 1024,

    vertexCount: u32 = 0,
    indexCount: u32 = 0,

    vao: u32 = undefined,
    vbo: u32 = undefined,
    ibo: u32 = undefined,

    const Self = @This();

    pub fn new(vertices: []const f32, indices: []const u32) @This() {
        var mesh: @This() = .{};
        std.mem.copyForwards(f32, mesh.vertices[0..vertices.len], vertices);
        std.mem.copyForwards(u32, mesh.indices[0..indices.len], indices);
        mesh.vertexCount = @as(u32, @truncate(vertices.len));
        mesh.indexCount = @as(u32, @truncate(indices.len));

        return mesh;
    }

    pub fn init(self: *Self) !void {
        c.glGenVertexArrays(1, &self.vao);
        c.glBindVertexArray(self.vao);

        c.glGenBuffers(1, &self.vbo);
        c.glBindBuffer(c.GL_ARRAY_BUFFER, self.vbo);
        c.glBufferData(c.GL_ARRAY_BUFFER, self.vertexCount * @sizeOf(f32), &self.vertices, c.GL_STATIC_DRAW);
        c.glVertexAttribPointer(0, 3, c.GL_FLOAT, c.GL_FALSE, 3 * @sizeOf(f32), null);
        c.glEnableVertexAttribArray(0);

        c.glGenBuffers(1, &self.ibo);
        c.glBindBuffer(c.GL_ELEMENT_ARRAY_BUFFER, self.ibo);
        c.glBufferData(c.GL_ELEMENT_ARRAY_BUFFER, self.indexCount * @sizeOf(u32), &self.indices, c.GL_STATIC_DRAW);

        self.unbind();
    }

    pub fn bind(self: Self) void {
        c.glBindVertexArray(self.vao);
        c.glBindBuffer(c.GL_ELEMENT_ARRAY_BUFFER, self.ibo);
    }

    pub fn unbind(_: Self) void {
        c.glBindVertexArray(0);
        c.glBindBuffer(c.GL_ELEMENT_ARRAY_BUFFER, 0);
    }

    pub fn deinit(self: Self) void {
        c.glDeleteVertexArrays(1, &self.vao);
        c.glDeleteBuffers(1, &self.vbo);
        c.glDeleteBuffers(1, &self.ibo);
    }
};
