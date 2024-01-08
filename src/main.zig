const std = @import("std");
const c = @import("c.zig");
const Shader = @import("shader.zig").Shader;
const Mesh = @import("mesh.zig").Mesh;

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

    var mesh = try Mesh.new(vertices, indices);
    try mesh.init();
    defer mesh.deinit();

    const shader = try Shader.from_source(@embedFile("vert.glsl"), @embedFile("frag.glsl"));

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
