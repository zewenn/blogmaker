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

        std.debug.print("\n\nLine Into:\n  - Index -> {d}\n  - Start -> {d}\n  - End -> {d}\n  - Len -> {d}\n", .{ index, start, end, len });

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
