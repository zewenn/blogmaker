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

    const html_template = try file_handler.get_contents("public/template.html", &allocator);
    defer allocator.free(html_template);

    var body = try allocator.alloc(u8, 0);
    defer allocator.free(body);

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

            const contents_with_brs = try html_handler.replace(&allocator, no_whitespace, "\n", "\n<br>\n");
            defer allocator.free(contents_with_brs);

            const filename_no_extension = try html_handler.replace(&allocator, file, ".md", "");
            defer allocator.free(filename_no_extension);

            const section = try std.fmt.allocPrint(allocator, "<section class=\"post p-{s}\" id=\"{s}\">{s}</section><hr>", .{ filename_no_extension, filename_no_extension, contents_with_brs });
            defer allocator.free(section);

            // std.debug.print("section/{s}:\n{s}", .{ file, section });

            const x = try allocator.alloc(u8, body.len + section.len);
            std.mem.copyForwards(u8, x[0..body.len], body);
            std.mem.copyForwards(u8, x[body.len .. body.len + section.len], section);

            allocator.free(body);
            body = x;

            // var html_contents = std.ArrayList([]const u8).init(allocator);
            // defer {
            //     for (html_contents.items) |item| allocator.free(item);
            //     html_contents.deinit();
            // }

            // std.debug.print("\n--- File: {s} ---\n", .{file});
            // try html_handler.break_into_lines(no_whitespace, &html_contents, &allocator);

            // // std.debug.print("[{d}] ", .{index});
            // for (0.., html_contents.items) |index, line| {

            //     // const parsed_line = try html_handler.parse_line(line, &allocator);
            //     // defer allocator.free(parsed_line);

            //     std.debug.print("{d} - ", .{index});
            //     std.debug.print("{s}\n", .{line});
            // }
        }
    }
    const y = try std.fmt.allocPrint(allocator, "<body>{s}", .{body});
    allocator.free(body);
    body = y;

    const html_replace_title = try html_handler.replace(&allocator, html_template, "<title>", "<title>The blog");
    defer allocator.free(html_replace_title);

    const html_replace_body = try html_handler.replace(&allocator, html_replace_title, "<body>", body);
    defer allocator.free(html_replace_body);

    std.debug.print("HTML:\n{s}", .{html_replace_body});

    try file_handler.save_file("dist/index.html", html_replace_body);
}
