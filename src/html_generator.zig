const std = @import("std");

pub fn replace(allocator: *std.mem.Allocator, string: []const u8, needle: []const u8, replacement: []const u8) ![]u8 {
    const size = std.mem.replacementSize(u8, string, needle, replacement);
    const output = try allocator.alloc(u8, size);
    _ = std.mem.replace(u8, string, needle, replacement, output);
    return output;
}

/// Caller owns the memory
pub fn filter_whitespace_on_sides(text: []u8, allocator: *std.mem.Allocator) ![]u8 {
    var list = std.ArrayList(u8).init(allocator.*);
    defer list.deinit();

    var hit_start: bool = false;

    for (text) |char| {
        if (!hit_start and char != ' ') {
            hit_start = true;
        }

        if (!hit_start) {
            continue;
        }

        if (char == '\n') {
            hit_start = false;
        }

        try list.append(char);
    }

    return try list.toOwnedSlice();
}

/// Modifies dest
pub fn break_into_lines(original_text: []u8, dest: *std.ArrayList([]const u8), allocator: *std.mem.Allocator) !void {
    const text = try std.fmt.allocPrint(allocator.*, "{s} \n", .{original_text});
    defer allocator.free(text);

    // const text = @as([]const u8, not_const_text);
    // defer allocator.free(text);

    var start: usize = 0;
    var end: usize = 0;
    var len: usize = 0;

    for (0.., text) |index, char| {
        if (char != '\n') {
            continue;
        }
        end = index - 1;
        len = end - start;

        if (len == 0) continue;

        std.debug.print("\nLine Into:\n  - Index -> {d}\n  - Start -> {d}\n  - End -> {d}\n  - Len -> {d}\n\n", .{ index, start, end, len });

        var line_mem = try allocator.alloc(u8, @as(usize, len));
        defer allocator.free(line_mem);
        std.mem.copyForwards(u8, line_mem[0..len], text[start..end]);

        const line_mem_replace_carrage_returns = try replace(allocator, line_mem, "\r", "");
        defer allocator.free(line_mem_replace_carrage_returns);

        const line_mem_replace_new_lines = try replace(allocator, line_mem_replace_carrage_returns, "\n", "");

        try dest.append(line_mem_replace_new_lines);

        if (index + 1 >= text.len) break;
        start = index + 1;
    }
}

pub fn starts_with(string: []u8, sub_string: []const u8) bool {
    if (string.len < sub_string.len) {
        return false;
    }

    var match = true;

    for (0.., sub_string) |index, sub_s_char| {
        const s_char = string[index];

        if (sub_s_char != s_char) {
            match = false;
            break;
        }
    }

    return match;
}

fn add_tags(allocator: *std.mem.Allocator, line: []u8, needle: []const u8, start: []const u8, end: []const u8) ![]u8 {
    const x = try replace(allocator, line, needle, start);
    defer allocator.free(x);

    const y = try allocator.alloc(u8, x.len + end.len);
    std.mem.copyForwards(u8, y[0..x.len], x[0..]);
    std.mem.copyForwards(u8, y[x.len .. x.len + end.len], end);

    // std.debug.print("line: {s} | x: {s} | y: {s}", .{ line, x, y });

    return y;
}

/// Caller owns the memory
pub fn parse_line(line: []const u8, allocator: *std.mem.Allocator) ![]u8 {
    var res = try allocator.dupe(u8, line);

    // var x = ("asd".*);
    // const H2: ParserPair = ParserPair{ .text = "##".*, .start_tag = &"<h2>".*, .end_tag = "</h2>".* };
    // const H3: ParserPair = ParserPair{ .text = "###".*, .start_tag = &"<h3>".*, .end_tag = "</h3>".* };

    if (line.len == 0) {
        return "";
    }

    // if (starts_with(line, H3.text)) {
    //     res = replace(allocator, res, H3.text, H3.start_tag);
    // }
    // if (starts_with(line, H2.text)) {
    //     res = replace(allocator, res, H2.text, H2.start_tag);
    // }
    // H6
    if (starts_with(res, "######")) {
        const updated = try add_tags(allocator, res, "######", "<h6>", "</h6>");
        allocator.free(res);
        res = updated;
    }
    // H5
    else if (starts_with(res, "#####")) {
        const updated = try add_tags(allocator, res, "#####", "<h5>", "</h5>");
        allocator.free(res);
        res = updated;
    }
    // H4
    else if (starts_with(res, "####")) {
        const updated = try add_tags(allocator, res, "####", "<h4>", "</h4>");
        allocator.free(res);
        res = updated;
    }
    // H3
    else if (starts_with(res, "###")) {
        const updated = try add_tags(allocator, res, "###", "<h3>", "</h3>");
        allocator.free(res);
        res = updated;
    }
    // H2
    else if (starts_with(res, "##")) {
        const updated = try add_tags(allocator, res, "##", "<h2>", "</h2>");
        allocator.free(res);
        res = updated;
    }
    // H1
    else if (starts_with(res, "#")) {
        const updated = try add_tags(allocator, res, "#", "<h1>", "</h1>");
        allocator.free(res);
        res = updated;
    }

    return res;
    // const start_character = line[0];
}
