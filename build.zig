const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const exe = b.addExecutable(.{
        .name = "smol-diceware",
        .root_source_file = .{ .cwd_relative = "main.zig" },
        .target = target,
        .optimize = .ReleaseSmall,  // Optimize for size
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
}
