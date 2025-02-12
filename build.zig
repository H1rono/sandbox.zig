const std = @import("std");

const Builder = struct {
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,

    pub fn executable(self: *const Builder, name: []const u8) !void {
        const root_source_file = try std.fmt.allocPrint(self.b.allocator, "{s}/main.zig", .{name});
        const exe = self.b.addExecutable(.{
            .name = name,
            .root_source_file = self.b.path(root_source_file),
            .target = self.target,
            .optimize = self.optimize,
            .link_libc = true,
        });
        self.b.installArtifact(exe);

        const run_exe = self.b.addRunArtifact(exe);
        const description = try std.fmt.allocPrint(self.b.allocator, "Run the {s} app", .{name});
        const run_step = self.b.step(name, description);
        run_step.dependOn(&run_exe.step);
    }
};

pub fn build(b: *std.Build) anyerror!void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const builder: Builder = .{
        .b = b,
        .target = target,
        .optimize = optimize,
    };

    inline for (.{ "hello-world", "split-file", "with-c", "tiny-ls" }) |name| {
        try builder.executable(name);
    }
}
