const std = @import("std");

extern fn c_benchALU32() f64;
extern fn c_benchALU64() f64;
extern fn c_benchFPU32() f64;
extern fn c_benchFPU64() f64;
extern fn c_benchFPU80() f64;
extern fn c_benchBranch() f64;
extern fn c_benchCache16K() f64;
extern fn c_benchCache512K() f64;
extern fn c_benchCache2M() f64;
extern fn c_benchCPUZ() f64;

fn warpedScore(comptime f: anytype) f64 {
    const ns1 = std.time.nanoTimestamp();
    const origin_score = f();
    const ns2 = std.time.nanoTimestamp();
    return origin_score / (@as(f64, @floatFromInt(ns2 - ns1)) / 1e+9);
}

const BENCH_TIME_MS = 3000;

fn warpedBench(f_name: []const u8, comptime f: anytype) void {
    std.debug.print("\n", .{});
    const ms = std.time.milliTimestamp();
    while (std.time.milliTimestamp() - ms < BENCH_TIME_MS)
        std.debug.print("{s:<15}|{:<7.1}\r", .{ f_name, warpedScore(f) });
}

pub fn main() !void {
    warpedBench("ALU32     ", c_benchALU32);
    warpedBench("ALU64     ", c_benchALU64);
    warpedBench("FPU32     ", c_benchFPU32);
    warpedBench("FPU64     ", c_benchFPU64);
    warpedBench("Branch    ", c_benchBranch);
    warpedBench("Cache 16K ", c_benchCache16K);
    warpedBench("Cache 512K", c_benchCache512K);
    warpedBench("Cache 2M  ", c_benchCache2M);
    warpedBench("CPUZ      ", c_benchCPUZ);

    std.debug.print("\n", .{});
}
