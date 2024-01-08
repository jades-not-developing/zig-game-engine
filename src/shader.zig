const std = @import("std");
const c = @import("c.zig");
const math = @import("math/main.zig");
const Vec3 = math.Vec3;
const fs = @import("./fs.zig");

const GL_COMPILE_SUCCESS = 0x8B81;

const ShaderError = error{CompileError};

const ShaderType = enum {
    Vertex,
    Fragment,
};

pub const Shader = struct {
    id: c_uint,
    uniform_cache: std.StringHashMap(c_int),
    vertex_source: []const u8,
    fragment_source: []const u8,

    pub fn from_source(vertex_source: []const u8, fragment_source: []const u8) !@This() {
        const vsh = try gen_vertex_shader(vertex_source);
        const fsh = try gen_fragment_shader(fragment_source);

        const program = c.glCreateProgram();
        c.glAttachShader(program, vsh);
        c.glAttachShader(program, fsh);
        c.glLinkProgram(program);

        var compile_success: c.GLint = undefined;
        c.glGetProgramiv(program, c.GL_COMPILE_STATUS, &compile_success);

        var error_log_len: c_int = 0;
        c.glGetProgramiv(program, c.GL_INFO_LOG_LENGTH, &error_log_len);

        if (error_log_len > 0) {
            const message = c.malloc(@intCast(error_log_len)) orelse return error.OutOfMemory;
            c.glGetProgramInfoLog(program, error_log_len, &error_log_len, @ptrCast(message));

            std.debug.print("!@! Shader Linker Failed !@!\n", .{});
            _ = c.printf("!@!      OpenGl Log      !@!\n%s\n", message);
            return error.CompileError;
        }

        return @This(){
            .id = program,
            .uniform_cache = std.StringHashMap(c_int).init(std.heap.page_allocator),
            .fragment_source = fragment_source,
            .vertex_source = vertex_source,
        };
    }

    pub fn new(vertex_file: []const u8, fragment_file: []const u8) !@This() {
        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        const allocator = arena.allocator();

        const vertex_file_source = try fs.read_file(allocator, vertex_file);
        defer allocator.free(vertex_file_source);

        const fragment_file_source = try fs.read_file(allocator, fragment_file);
        defer allocator.free(fragment_file_source);

        const vsh = try gen_vertex_shader(vertex_file_source);
        const fsh = try gen_fragment_shader(fragment_file_source);

        const program = c.glCreateProgram();
        c.glAttachShader(program, vsh);
        c.glAttachShader(program, fsh);
        c.glLinkProgram(program);

        var compile_success: c.GLint = undefined;
        c.glGetProgramiv(program, c.GL_COMPILE_STATUS, &compile_success);

        var error_log_len: c_int = 0;
        c.glGetProgramiv(program, c.GL_INFO_LOG_LENGTH, &error_log_len);

        if (error_log_len > 0) {
            const message = c.malloc(@intCast(error_log_len)) orelse return error.OutOfMemory;
            c.glGetProgramInfoLog(program, error_log_len, &error_log_len, @ptrCast(message));

            std.debug.print("!@! Shader Linker Failed !@!\n", .{});
            _ = c.printf("!@!      OpenGl Log      !@!\n%s\n", message);
            return error.CompileError;
        }

        return @This(){
            .id = program,
            .uniform_cache = std.StringHashMap(c_int).init(std.heap.page_allocator),
            .fragment_source = fragment_file_source,
            .vertex_source = vertex_file_source,
        };
    }

    pub fn use(self: @This()) void {
        c.glUseProgram(self.id);
    }

    pub fn stop(self: @This()) void {
        _ = self;
        c.glUseProgram(0);
    }

    pub fn deinit(self: *@This()) void {
        c.glDeleteProgram(self.id);
        self.uniform_cache.deinit();
    }

    pub fn uniform_vec3(self: *@This(), location: []const u8, vec: Vec3(f32)) !void {
        c.glUniform3f(
            try self.uniform_location(location),
            vec._x(),
            vec._y(),
            vec._z(),
        );
    }

    fn uniform_location(self: *@This(), name: []const u8) !c_int {
        const cache_entry = self.uniform_cache.get(name);
        if (cache_entry) |entry| {
            std.debug.print("Cache hit!\n", .{});
            return entry;
        } else {
            const location = c.glGetUniformLocation(self.id, name.ptr);
            std.debug.print("Pushing {any} with key `{s}`\n", .{ location, name });
            try self.uniform_cache.put(name, location);
            return location;
        }
    }

    fn gen_vertex_shader(source: []const u8) !c_uint {
        const id = c.glCreateShader(c.GL_VERTEX_SHADER);
        const source_ptr: ?[*]const u8 = source.ptr;
        c.glShaderSource(id, 1, &source_ptr, null);
        c.glCompileShader(id);

        var compile_success: c.GLint = undefined;
        c.glGetShaderiv(id, c.GL_COMPILE_STATUS, &compile_success);

        var error_log_len: c_int = 0;
        c.glGetShaderiv(id, c.GL_INFO_LOG_LENGTH, &error_log_len);

        if (error_log_len > 0) {
            const message = c.malloc(@intCast(error_log_len)) orelse return error.OutOfMemory;
            c.glGetShaderInfoLog(id, error_log_len, &error_log_len, @ptrCast(message));

            std.debug.print("!@! Vertex Shader Compilation Failed !@!\n", .{});
            std.debug.print("!@!              Source              !@!\n", .{});
            var line_iter = std.mem.split(u8, source, "\n");
            var i: u64 = 1;
            while (line_iter.next()) |line| {
                std.debug.print("[{}] {s}\n", .{ i, line });
                i += 1;
            }
            _ = c.printf("!@!            OpenGl Log            !@!\n%s\n", message);
            return error.CompileError;
        }

        return id;
    }

    fn gen_fragment_shader(source: []const u8) !c_uint {
        const id = c.glCreateShader(c.GL_FRAGMENT_SHADER);
        const source_ptr: ?[*]const u8 = source.ptr;
        c.glShaderSource(id, 1, &source_ptr, null);
        c.glCompileShader(id);

        var compile_success: c.GLint = undefined;
        c.glGetShaderiv(id, c.GL_COMPILE_STATUS, &compile_success);

        var error_log_len: c_int = 0;
        c.glGetShaderiv(id, c.GL_INFO_LOG_LENGTH, &error_log_len);

        if (error_log_len > 0) {
            const message = c.malloc(@intCast(error_log_len)) orelse return error.OutOfMemory;
            c.glGetShaderInfoLog(id, error_log_len, &error_log_len, @ptrCast(message));

            std.debug.print("!@! Fragment Shader Compilation Failed !@!\n", .{});
            std.debug.print("!@!              Source              !@!\n", .{});
            var line_iter = std.mem.split(u8, source, "\n");
            var i: u64 = 1;
            while (line_iter.next()) |line| {
                std.debug.print("[{}] {s}\n", .{ i, line });
                i += 1;
            }
            _ = c.printf("!@!            OpenGl Log            !@!\n%s\n", message);
            return error.CompileError;
        }

        return id;
    }
};
