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
