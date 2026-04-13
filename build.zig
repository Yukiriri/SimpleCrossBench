const std = @import("std");
const utils = @import("build.utils.zig");

pub fn build(b: *std.Build) !void {
    b.install_path = "./bin/";
    try utils.addBin(b, "benchcpu", "./src/benchcpu/", "main.zig", &utils.popular_targets, .ReleaseFast, true);
    try utils.addBin(b, "benchmem", "./src/benchmem/", "main.zig", &utils.popular_targets, .ReleaseFast, true);
}
