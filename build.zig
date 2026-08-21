const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib_client = b.addLibrary(.{
        .name = "tracyclient",
        .linkage = .static,
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/root.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    lib_client.root_module.addCSourceFiles(.{
        .files = &.{
            "src/stub.cpp",
            "tracy/public/TracyClient.cpp",
        },
        .flags = &.{
            "-std=c++23",
            "-Wall",
            "-Wformat",
            "-DTRACY_ENABLE",
        },
    });
    lib_client.root_module.link_libcpp = true;
    lib_client.root_module.addIncludePath(b.path("tracy/public"));

    lib_client.installHeadersDirectory(b.path("tracy/public/client"), "client", .{ .include_extensions = &.{ ".h", ".hpp" } });
    lib_client.installHeadersDirectory(b.path("tracy/public/common"), "common", .{ .include_extensions = &.{ ".h", ".hpp" } });
    lib_client.installHeadersDirectory(b.path("tracy/public/tracy"), "tracy", .{ .include_extensions = &.{ ".h", ".hpp" } });

    b.installArtifact(lib_client);

    // By making the run step depend on the default step, it will be run from the
    // installation directory rather than directly from within the cache directory.
    //run_cmd.step.dependOn(b.getInstallStep());

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    //if (b.args) |args| {
    //    run_cmd.addArgs(args);
    //}
}
