const std = @import("std");
const c = @import("c.zig");

//export fn keyCallback(glfw_window: ?*c.GLFWwindow, key: c_int, scancode: c_int, action: c_int, mods: c_int) void {
//    _ = mods;
//    _ = scancode;
//
//    if (key == c.GLFW_KEY_ESCAPE and action == c.GLFW_PRESS) {
//        c.glfwSetWindowShouldClose(glfw_window, c.GLFW_TRUE);
//    }
//}

export fn errorCallback(err: c_int, description: [*c]const u8) void {
    std.debug.panic("GL Error({}): {s}\n", .{ err, description });
}

pub const Engine = struct {
    window: *c.GLFWwindow,

    const Self = @This();

    pub fn new() @This() {
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

        const instance = @This(){
            .window = window,
        };

        c.glfwMakeContextCurrent(window);
        _ = c.glfwSetKeyCallback(window, keyCallback);

        if (c.glewInit() != c.GLEW_OK) {
            std.debug.panic("Failed to initalize GLEW", .{});
        }

        return instance;
    }

    export fn keyCallback(glfw_window: ?*c.GLFWwindow, key: c_int, scancode: c_int, action: c_int, mods: c_int) void {
        _ = mods;
        _ = scancode;

        if (key == c.GLFW_KEY_ESCAPE and action == c.GLFW_PRESS) {
            std.log.info("Closing...", .{});
            c.glfwSetWindowShouldClose(glfw_window, c.GLFW_TRUE);
        }
    }

    pub fn clear(_: *Self) void {
        c.glfwPollEvents();

        c.glClearColor(0.2, 0.3, 0.8, 1.0);
        c.glClear(c.GL_COLOR_BUFFER_BIT | c.GL_DEPTH_BUFFER_BIT);
    }

    pub fn close_requested(self: Self) bool {
        return c.glfwWindowShouldClose(self.window) == 1;
    }

    pub fn swap_buffers(self: Self) void {
        c.glfwSwapBuffers(self.window);
    }

    pub fn deinit(self: Self) void {
        c.glfwDestroyWindow(self.window);
    }
};
