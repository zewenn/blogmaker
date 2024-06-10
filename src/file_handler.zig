const std = @import("std");

/// On success caller owns the returned buffer
pub fn get_contents(path: []const u8, allocator: *std.mem.Allocator) ![]u8 {
    const buf = try std.fs.cwd().readFileAlloc(allocator.*, path, 8192);
    return buf;
}

pub fn get_files(dir_path: []const u8, files_list: *std.ArrayList([]const u8), allocator: *std.mem.Allocator) !void {
    var dir_cont = try std.fs.cwd().openDir(dir_path, .{ .iterate = true });
    defer dir_cont.close();

    var it = dir_cont.iterate();

    while (try it.next()) |file| {
        // std.debug.print("fak: {s}", .{file.name});
        try files_list.append(try allocator.dupe(u8, file.name));
    }
}

pub fn try_create_dir(path: []const u8) !void {
    std.fs.cwd().makeDir(path) catch |err| switch (err) {
        error.PathAlreadyExists => {
            std.log.info("\"{s}\" already exists.\n\n", .{path});
            return;
        },
        else => return err,
    };
}

pub fn try_delete_dir(path: []const u8) !void {
    std.fs.cwd().deleteTree(path) catch |err| switch (err) {
        error.NotDir => {
            std.log.info("\"{s}\" already exists.\n\n", .{path});
            return;
        },
        else => return err,
    };
}
