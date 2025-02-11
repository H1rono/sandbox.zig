const std = @import("std");
const c = @cImport({
    @cInclude("errno.h");
    @cInclude("unistd.h");
});

const allocator = std.heap.page_allocator;

fn writeStdout(buf: []const u8) void {
    const ptr = &buf[0];
    _ = c.write(1, ptr, buf.len);
}

fn writeStderr(buf: []const u8) void {
    const ptr = &buf[0];
    _ = c.write(2, ptr, buf.len);
}

pub fn main() anyerror!void {
    var argDir: ?[]const u8 = null;
    var args = std.process.args();
    for (0..2) |i| {
        const arg = args.next() orelse break;
        if (i == 1) {
            argDir = arg;
            break;
        }
    }
    const dir = argDir orelse {
        _ = writeStderr("Usage: tiny-ls <directory>\n");
        std.process.exit(1);
    };

    const message = try std.fmt.allocPrint(allocator, "Directory: {s}\n", .{dir});
    defer allocator.free(message);
    _ = writeStdout(message);
}
