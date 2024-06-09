const std = @import("std");

pub fn replace(allocator: *std.mem.Allocator, string: []const u8, needle: []const u8, replacement: []const u8) ![]u8 {
    const size = std.mem.replacementSize(u8, string, needle, replacement);
    const output = try allocator.alloc(u8, size);
    _ = std.mem.replace(u8, string, needle, replacement, output);
    return output;
}
