const std = @import("std");
const c = @import("./c.zig");
const e = @import("./error.zig");
const Directory = @This();

dir: ?*c.DIR,

pub fn open(path: [*]const u8) !Directory {
    const dir = c.opendir(path);
    if (dir == null) {
        try e.errno();
    }
    return .{ .dir = dir };
}

pub fn read(self: *Directory) !?[]const u8 {
    const dir = self.dir orelse return null;
    const maybeEntry: ?*c.struct_dirent = @ptrCast(c.readdir(dir));
    const entry = maybeEntry orelse {
        try e.errno();
        try self.close();
        return null;
    };
    return entry.d_name[0..entry.d_namlen];
}

fn close(self: *Directory) !void {
    const dir = self.dir.?;
    self.dir = null;
    const ret = c.closedir(dir);
    if (ret == -1) {
        try e.errno();
    }
}

pub fn closed(self: *const Directory) bool {
    return self.dir == null;
}
