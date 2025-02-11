const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    // hello-world
    {
        const exe = b.addExecutable(.{
            .name = "hello-world",
            .root_source_file = b.path("hello-world/main.zig"),
            .target = target,
            .optimize = optimize,
            .single_threaded = true,
        });
        b.installArtifact(exe);

        const run_exe = b.addRunArtifact(exe);
        const run_step = b.step("hello-world", "Run the hello-world app");
        run_step.dependOn(&run_exe.step);
    }

    // split-file
    {
        const exe = b.addExecutable(.{
            .name = "split-file",
            .root_source_file = b.path("split-file/main.zig"),
            .target = target,
            .optimize = optimize,
        });
        b.installArtifact(exe);

        const run_exe = b.addRunArtifact(exe);
        const run_step = b.step("split-file", "Run the split-file app");
        run_step.dependOn(&run_exe.step);
    }

    // with-c
    {
        const exe = b.addExecutable(.{
            .name = "with-c",
            .root_source_file = b.path("with-c/main.zig"),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        });
        b.installArtifact(exe);

        const run_exe = b.addRunArtifact(exe);
        const run_step = b.step("with-c", "Run the with-c app");
        run_step.dependOn(&run_exe.step);
    }

    // tiny-ls
    {
        const exe = b.addExecutable(.{
            .name = "tiny-ls",
            .root_source_file = b.path("tiny-ls/main.zig"),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        });
        b.installArtifact(exe);

        const run_exe = b.addRunArtifact(exe);
        const run_step = b.step("tiny-ls", "Run the tiny-ls app");
        run_step.dependOn(&run_exe.step);
    }
}
