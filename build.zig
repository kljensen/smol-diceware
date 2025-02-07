const std = @import("std");

pub fn build(b: *std.Build) void {
    const mode = b.standardReleaseOptions();
    const optimize = switch (mode) {
        .Debug => std.builtin.Mode.Debug,
        .ReleaseSafe => std.builtin.Mode.ReleaseSafe,
        .ReleaseFast => std.builtin.Mode.ReleaseFast,
        .ReleaseSmall => std.builtin.Mode.ReleaseSmall,
    };

    const exe = b.addExecutable("smol-diceware", "main.zig");
    exe.setBuildMode(mode);
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(&b.getInstallStep());
}
