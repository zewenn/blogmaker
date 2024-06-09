const std = @import("std");

const file_handler = @import("./file_handler.zig");
const html_handler = @import("./html_generator.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var allocator = gpa.allocator();

    const str = "asdasd_asdad";

    const size = std.mem.replacementSize(u8, str, "_", " ");
    const output = try allocator.alloc(u8, size);
    defer allocator.free(output);

    _ = std.mem.replace(u8, str, "_", " ", output);

    std.debug.print("{s}", .{output});
}
