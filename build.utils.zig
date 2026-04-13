const std = @import("std");

pub const popular_targets = [_]std.Target.Query{
    .{ .os_tag = .windows, .cpu_arch = .x86_64, .cpu_model = .{ .explicit = &std.Target.x86.cpu.x86_64 } },
    .{ .os_tag = .windows, .cpu_arch = .x86_64, .cpu_model = .{ .explicit = &std.Target.x86.cpu.x86_64_v3 } },
    .{ .os_tag = .windows, .cpu_arch = .aarch64, .cpu_model = .baseline },
    .{ .os_tag = .linux, .cpu_arch = .x86_64, .cpu_model = .{ .explicit = &std.Target.x86.cpu.x86_64 } },
    .{ .os_tag = .linux, .cpu_arch = .x86_64, .cpu_model = .{ .explicit = &std.Target.x86.cpu.x86_64_v3 } },
    .{ .os_tag = .linux, .cpu_arch = .aarch64, .cpu_model = .baseline },
    .{ .os_tag = .macos, .cpu_arch = .x86_64, .cpu_model = .{ .explicit = &std.Target.x86.cpu.x86_64 } },
    .{ .os_tag = .macos, .cpu_arch = .x86_64, .cpu_model = .{ .explicit = &std.Target.x86.cpu.x86_64_v3 } },
    .{ .os_tag = .macos, .cpu_arch = .aarch64, .cpu_model = .baseline },
};

pub const c_src_extensions = [_][]const u8{
    ".c",
    ".cpp",
    ".cxx",
    ".cc",
};

pub fn addBin(build: *std.Build, bin_name: []const u8, src_subdir: []const u8, root_src: []const u8, targets: []const std.Target.Query, optimize: std.builtin.OptimizeMode, link_libc: bool) !void {
    for (targets) |target| {
        const bin_target_subpath = build.fmt("{s}-{s}", .{
            @tagName(target.os_tag.?),
            if (target.cpu_model == .explicit) target.cpu_model.explicit.name else @tagName(target.cpu_arch.?),
        });

        const bin_root_module = build.createModule(.{
            .root_source_file = build.path(build.pathJoin(&.{ src_subdir, root_src })),
            .target = build.resolveTargetQuery(target),
            .optimize = optimize,
            .strip = optimize == .ReleaseFast or optimize == .ReleaseSmall,
            .link_libc = link_libc,
        });
        var c_src_dir = try std.fs.cwd().openDir(src_subdir, .{ .iterate = true });
        defer c_src_dir.close();
        var c_src_walker = try c_src_dir.walk(build.allocator);
        defer c_src_walker.deinit();
        // std.debug.print("{s} {s} addCSourceFile: \n", .{ bin_name, bin_target_subpath });
        while (try c_src_walker.next()) |entry| {
            if (entry.kind == .file) {
                for (c_src_extensions) |c_src_extension| {
                    if (std.mem.endsWith(u8, entry.basename, c_src_extension)) {
                        const c_src = build.pathJoin(&.{ src_subdir, entry.path });
                        bin_root_module.addCSourceFile(.{ .file = build.path(c_src) });
                        // std.debug.print("    {s} \n", .{c_src});
                    }
                }
            }
        }

        const bin_compile = build.addExecutable(.{ .name = bin_name, .root_module = bin_root_module });
        bin_compile.link_function_sections = true;
        bin_compile.link_data_sections = true;
        bin_compile.link_gc_sections = true;
        bin_compile.use_llvm = true;

        const bin_artifact = build.addInstallArtifact(bin_compile, .{ .dest_dir = .{ .override = .{ .custom = bin_target_subpath } } });

        build.getInstallStep().dependOn(&bin_artifact.step);
    }
}
