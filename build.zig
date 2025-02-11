const std = @import("std");

pub fn build(b: *std.Build) void {
    const helloWorld = b.addExecutable(.{
        .name = "hello-world",
        .root_source_file = b.path("hello-world/main.zig"),
        .target = b.standardTargetOptions(.{}),
        .optimize = b.standardOptimizeOption(.{}),
        .single_threaded = true,
    });
    b.installArtifact(helloWorld);
}
