const std = @import("std");

const Example = enum {
    simple,
};

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const curl = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const exe_simple = b.addExecutable(.{
        .name = "simple",
        .root_source_file = b.path("examples/simple.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    exe_simple.linkSystemLibrary("curl");
    exe_simple.root_module.addImport("curl", curl);

    const server_exe = b.addExecutable(.{
        .name = "server",
        .root_source_file = b.path("test/server.zig"),
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(exe_simple);
    b.installArtifact(server_exe);
}
