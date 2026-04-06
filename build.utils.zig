const std = @import("std");

pub const mainstream_targets = [_]std.Target.Query{
    .{ .os_tag = .windows, .cpu_arch = .x86_64, .cpu_model = .{ .explicit = &std.Target.x86.cpu.x86_64 } },
    .{ .os_tag = .windows, .cpu_arch = .x86_64, .cpu_model = .{ .explicit = &std.Target.x86.cpu.x86_64_v3 } },
    .{ .os_tag = .windows, .cpu_arch = .aarch64, .cpu_model = .baseline },
    .{ .os_tag = .linux, .cpu_arch = .x86_64, .cpu_model = .{ .explicit = &std.Target.x86.cpu.x86_64 } },
    .{ .os_tag = .linux, .cpu_arch = .x86_64, .cpu_model = .{ .explicit = &std.Target.x86.cpu.x86_64_v3 } },
    .{ .os_tag = .linux, .cpu_arch = .aarch64, .cpu_model = .baseline },
    .{ .os_tag = .macos, .cpu_arch = .x86_64, .cpu_model = .baseline },
    .{ .os_tag = .macos, .cpu_arch = .aarch64, .cpu_model = .baseline },
};

pub fn listCSource(sub_path: []const u8, file_extension: []const u8) !std.ArrayList([]u8) {
    const allocator = std.heap.page_allocator;
    var src_dir = try std.fs.cwd().openDir(sub_path, .{ .iterate = true });
    defer src_dir.close();
    var src_walker = try src_dir.walk(allocator);
    defer src_walker.deinit();

    var src_list = std.ArrayList([]u8).empty;
    while (try src_walker.next()) |entry| {
        if (entry.kind == .file and std.mem.endsWith(u8, entry.basename, file_extension)) {
            const src = try std.mem.concat(allocator, u8, &.{ sub_path, entry.path });
            // defer allocator.free(src);
            try src_list.append(allocator, src);
        }
    }
    return src_list;
}

// pub fn createBin(build: *std.Build, targets: []std.Target.Query) ![]std.Build.Step.Compile {
//     var a = [targets.len]std.ArrayList().Step.Compile;
//     for (targets) |target| {
//         build.addExecutable()
//     }
// }
