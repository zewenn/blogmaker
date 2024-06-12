const std = @import("std");

const file_handler = @import("./file_handler.zig");
const html_handler = @import("./html_generator.zig");

pub fn main() !void {
    // std.debug.print("Hello world!", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var allocator = gpa.allocator();

    // Deleting and creating ./dist
    {
        try file_handler.try_delete_dir("dist");
        try file_handler.try_create_dir("dist");
    }

    // Handling the files
    var files_list = std.ArrayList([]const u8).init(allocator);
    {
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

            const no_whitespace = try html_handler.filter_whitespace_on_sides(read_data, &allocator);
            defer allocator.free(no_whitespace);

            var html_contents = std.ArrayList([]const u8).init(allocator);
            defer {
                for (html_contents.items) |item| allocator.free(item);
                html_contents.deinit();
            }

            std.debug.print("\n--- File: {s} ---\n", .{file});
            try html_handler.break_into_lines(no_whitespace, &html_contents, &allocator);

            // std.debug.print("[{d}] ", .{index});
            for (0.., html_contents.items) |index, line| {
                const parsed_line = try html_handler.parse_line(line, &allocator);
                defer allocator.free(parsed_line);

                std.debug.print("{d} - ", .{index});
                std.debug.print("{s}\n", .{parsed_line});
            }
        }
    }
}
