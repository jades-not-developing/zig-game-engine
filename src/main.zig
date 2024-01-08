const std = @import("std");
const c = @import("c.zig");
const Shader = @import("shader.zig").Shader;

export fn errorCallback(err: c_int, description: [*c]const u8) void {
    std.debug.panic("GL Error({}): {s}\n", .{ err, description });
}

export fn keyCallback(glfw_window: ?*c.GLFWwindow, key: c_int, scancode: c_int, action: c_int, mods: c_int) void {
    _ = mods;
    _ = scancode;

    if (key == c.GLFW_KEY_ESCAPE and action == c.GLFW_PRESS) {
        c.glfwSetWindowShouldClose(glfw_window, c.GLFW_TRUE);
    }
}

const Mesh = struct {
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
};

pub fn main() !void {
    const width = 900;
    const height = 900;

    _ = c.glfwInit();
    var window: *c.GLFWwindow = undefined;
    if (c.glfwInit() == c.GL_FALSE) {
        std.debug.panic("Failed to initialize GLFW\n", .{});
    }
    _ = c.glfwSetErrorCallback(errorCallback);
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MAJOR, 4);
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MINOR, 4);
    c.glfwWindowHint(c.GLFW_OPENGL_PROFILE, c.GLFW_OPENGL_CORE_PROFILE);

    if (c.glfwCreateWindow(@as(c_int, width), @as(c_int, height), "Hello, GLFW", null, null)) |win| {
        window = win;
    } else {
        c.glfwTerminate();
        std.debug.panic("Failed to create GLFW window", .{});
    }

    c.glfwMakeContextCurrent(window);
    _ = c.glfwSetKeyCallback(window, keyCallback);

    if (c.glewInit() != c.GLEW_OK) {
        std.debug.panic("Failed to initalize GLEW", .{});
    }

    const vertices: []const f32 = &[_]f32{
        0.5,  0.5,  0.0,
        0.5,  -0.5, 0.0,
        -0.5, -0.5, 0.0,
        -0.5, 0.5,  0.0,
    };

    const indices: []const u32 = &[_]u32{ 0, 1, 3, 1, 2, 3 };

    var mesh = Mesh.new(vertices, indices);
    try mesh.init();

    const vertShaderSource: []const u8 = @embedFile("vert.glsl");
    const fragShaderSource: []const u8 = @embedFile("frag.glsl");

    const shader = try Shader.from_source(vertShaderSource, fragShaderSource);

    while (c.glfwWindowShouldClose(window) == 0) {
        c.glfwPollEvents();

        shader.use();

        c.glClearColor(0.2, 0.3, 0.8, 1.0);
        c.glClear(c.GL_COLOR_BUFFER_BIT | c.GL_DEPTH_BUFFER_BIT);

        mesh.bind();
        c.glDrawElements(c.GL_TRIANGLES, indices.len, c.GL_UNSIGNED_INT, null);
        mesh.unbind();

        shader.stop();

        c.glfwSwapBuffers(window);
    }
}
