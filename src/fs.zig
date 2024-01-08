const std = @import("std");

pub fn read_file(allocator: std.mem.Allocator, file: []const u8) ![]u8 {
    const file_handle = try std.fs.cwd().openFile(file, .{});
    defer file_handle.close();

    const file_size = try file_handle.getEndPos();

    const read_buf = try file_handle.readToEndAlloc(allocator, file_size);

    var new_buf = std.ArrayList(u8).init(allocator);

    var buf_iter = std.mem.window(u8, read_buf, 1, 1);
    while (buf_iter.next()) |item| {
        try new_buf.append(item[0]);
    }
    try new_buf.append(0x00);

    return new_buf.items;
}
