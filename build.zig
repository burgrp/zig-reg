const std = @import("std");

pub fn build(builder: *std.Build) void {
    const target = builder.standardTargetOptions(.{});
    const optimize = builder.standardOptimizeOption(.{});

    const exe = builder.addExecutable(.{
        .name = "reg",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    const module = builder.addModule("clap", .{
        .source_file = .{ .path = "vendor/zig-clap/clap.zig" },
    });

    exe.addModule("clap", module);

    exe.install();

    const exe_tests = builder.addTest(.{
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    const test_step = builder.step("test", "Run unit tests");
    test_step.dependOn(&exe_tests.step);
}
