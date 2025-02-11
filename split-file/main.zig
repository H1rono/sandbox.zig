const std = @import("std");
const lib = @import("./lib.zig");

pub fn main() void {
    const result = lib.add(1, 2);
    std.debug.print("1 + 2 = {}\n", .{result});
}
