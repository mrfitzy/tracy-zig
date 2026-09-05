const std = @import("std");

pub fn build(b: *std.Build) void {
    // build options
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // client library
    const lib_client = b.addLibrary(.{
        .name = "tracyclient",
        .linkage = .static,
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libcpp = true,
        }),
    });

    // tracy sources
    const tracy = b.dependency("tracy", .{
        .target = target,
        .optimize = optimize,
    });
    const tracy_public_path = tracy.path("public");
    const cpp_flags = &[_][]const u8{
        "-std=c++23",
        "-Wall",
        "-Wformat",
        "-DTRACY_ENABLE",
    };
    lib_client.root_module.addCSourceFiles(.{
        .root = tracy_public_path,
        .files = &.{
            "TracyClient.cpp",
        },
        .flags = cpp_flags,
    });
    lib_client.root_module.addIncludePath(tracy_public_path);

    // local sources
    lib_client.root_module.addCSourceFiles(.{
        .files = &.{
            "src/stub.cpp",
        },
        .flags = cpp_flags,
    });

    // install headers
    const header_dirs = &[_][]const u8{
        "client",
        "common",
        "tracy",
    };
    for (header_dirs) |dir| {
        lib_client.installHeadersDirectory(tracy_public_path.path(b, dir), dir, .{ .include_extensions = &.{ ".h", ".hpp" } });
    }

    // install library
    b.installArtifact(lib_client);
}
