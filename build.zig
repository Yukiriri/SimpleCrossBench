const std = @import("std");
const utils = @import("build.utils.zig");

const projects = [_][]const u8{
    "benchcpu",
    "benchmem",
};

pub fn build(b: *std.Build) !void {
    // const allocator = b.allocator;

    for (utils.mainstream_targets) |target| {
        for (projects) |project| {
            const project_dir = b.fmt("src/{s}/", .{project});
            const bin_root_module = b.createModule(.{
                .root_source_file = b.path(b.pathJoin(&.{ project_dir, "main.zig" })),
                .target = b.resolveTargetQuery(target),
                .optimize = .ReleaseFast,
                .strip = true,
                .link_libc = true,
            });
            const c_srcs = try utils.listCSource(project_dir, ".cxx");
            // defer c_srcs.deinit(allocator);
            for (c_srcs.items) |c_src| {
                bin_root_module.addCSourceFile(.{ .file = b.path(c_src) });
                // std.debug.print("{s}\n", .{c_src});
            }

            const bin = b.addExecutable(.{ .name = project, .root_module = bin_root_module });
            bin.link_function_sections = true;
            bin.link_data_sections = true;
            bin.link_gc_sections = true;
            bin.use_llvm = true;

            b.install_path = "./bin/";
            const target_subpath = b.fmt("{s}-{s}", .{
                @tagName(target.os_tag.?),
                if (target.cpu_model == .explicit) target.cpu_model.explicit.name else @tagName(target.cpu_arch.?),
            });
            const bin_options = std.Build.Step.InstallArtifact.Options{
                .dest_dir = .{ .override = .{ .custom = target_subpath } },
            };
            const bin_step = b.addInstallArtifact(bin, bin_options);
            b.getInstallStep().dependOn(&bin_step.step);
        }
    }
}
