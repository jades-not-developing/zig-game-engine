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

    const vertices = [_]f32{
        -0.5, -0.5, 0.0,
        0.5,  -0.5, 0.0,
        0.0,  0.5,  0.0,
    };

    var vao: c_uint = undefined;
    c.glGenVertexArrays(1, &vao);
    c.glBindVertexArray(vao);

    var vbo: c_uint = undefined;
    c.glGenBuffers(1, &vbo);
    c.glBindBuffer(c.GL_ARRAY_BUFFER, vbo);
    c.glBufferData(c.GL_ARRAY_BUFFER, vertices.len * @sizeOf(f32), &vertices, c.GL_STATIC_DRAW);
    c.glVertexAttribPointer(0, 3, c.GL_FLOAT, c.GL_FALSE, 3 * @sizeOf(f32), null);
    c.glEnableVertexAttribArray(0);

    c.glBindBuffer(c.GL_ARRAY_BUFFER, 0);
    c.glBindVertexArray(0);

    const vertShaderSource: []const u8 = @embedFile("vert.glsl");
    const fragShaderSource: []const u8 = @embedFile("frag.glsl");

    const shader = try Shader.from_source(vertShaderSource, fragShaderSource);

    while (c.glfwWindowShouldClose(window) == 0) {
        c.glfwPollEvents();

        shader.use();

        c.glClearColor(0.2, 0.3, 0.8, 1.0);
        c.glClear(c.GL_COLOR_BUFFER_BIT | c.GL_DEPTH_BUFFER_BIT);

        c.glBindVertexArray(vao);
        c.glDrawArrays(c.GL_TRIANGLES, 0, 3);

        shader.stop();

        c.glfwSwapBuffers(window);
    }
}
