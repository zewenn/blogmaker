const std = @import("std");

const file_handler = @import("./file_handler.zig");

pub fn main() !void {
    std.debug.print("Hello world!", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var allocator = gpa.allocator();

    var files_list = std.ArrayList([]const u8).init(allocator);

    try file_handler.get_files("md", &files_list, &allocator);

    defer {
        for (files_list.items) |e| allocator.free(e);
        files_list.deinit();
    }

    for (files_list.items) |file| {
        const path = try std.fmt.allocPrint(allocator, "md/{s}", .{file});
        defer allocator.free(path);

        const read_data = try file_handler.get_contents(path, &allocator);
        defer allocator.free(read_data);

        // std.debug.print("[{d}] ", .{index});
        std.debug.print("\n--- File: {s} ---\n", .{file});
        std.debug.print("{s}\n", .{read_data});
    }
}
