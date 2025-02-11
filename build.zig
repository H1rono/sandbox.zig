const std = @import("std");

pub fn build(b: *std.Build) void {
    // hello-world
    {
        const exe = b.addExecutable(.{
            .name = "hello-world",
            .root_source_file = b.path("hello-world/main.zig"),
            .target = b.standardTargetOptions(.{}),
            .optimize = b.standardOptimizeOption(.{}),
            .single_threaded = true,
        });
        b.installArtifact(exe);

        const run_exe = b.addRunArtifact(exe);
        const run_step = b.step("hello-world", "Run the hello-world app");
        run_step.dependOn(&run_exe.step);
    }
}
