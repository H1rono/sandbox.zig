const std = @import("std");
const c = @import("./c.zig");
const e = @import("./error.zig");
const Directory = @import("./Directory.zig");

const allocator = std.heap.page_allocator;

fn writeStdout(buf: []const u8) void {
    const ptr = &buf[0];
    const size = c.write(1, ptr, buf.len);
    if (size < 0) {
        const err = std.c._errno().*;
        std.debug.panic("writing to stdout failed with errno {d}\n", .{err});
    }
}

fn writeStderr(buf: []const u8) void {
    const ptr = &buf[0];
    const size = c.write(2, ptr, buf.len);
    if (size < 0) {
        const err = std.c._errno().*;
        std.debug.panic("writing to stderr failed with errno {d}\n", .{err});
    }
}

pub fn main() anyerror!void {
    var argDir: ?[]const u8 = null;
    var args = try std.process.argsWithAllocator(allocator);
    defer args.deinit();
    for (0..2) |i| {
        const arg = args.next() orelse break;
        if (i == 1) {
            argDir = arg;
            break;
        }
    }
    const dir = argDir orelse {
        writeStderr("Usage: tiny-ls <directory>\n");
        std.process.exit(1);
    };

    const headMessage = try std.fmt.allocPrint(allocator, "Directory: {s}\n", .{dir});
    defer allocator.free(headMessage);
    writeStdout(headMessage);

    var directory = try Directory.open(dir.ptr);
    while (try directory.read()) |entry| {
        const message = try std.fmt.allocPrint(allocator, "{s}\n", .{entry});
        defer allocator.free(message);
        writeStdout(message);
    }
}
