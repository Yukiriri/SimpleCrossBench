const std = @import("std");

extern fn c_benchRead1Bx1(mem_block: [*]u8, mem_block_size: usize) void;
extern fn c_benchRead32Bx4(mem_block: [*]u8, mem_block_size: usize) void;
extern fn c_benchRead32Bx4NT(mem_block: [*]u8, mem_block_size: usize) void;
extern fn c_benchWrite1Bx1(mem_block: [*]u8, mem_block_size: usize) void;
extern fn c_benchWrite32Bx4(mem_block: [*]u8, mem_block_size: usize) void;
extern fn c_benchWrite32Bx4NT(mem_block: [*]u8, mem_block_size: usize) void;
extern fn c_benchCopy1Bx1(mem_block: [*]u8, mem_block_size: usize) void;
extern fn c_benchCopy32Bx4(mem_block: [*]u8, mem_block_size: usize) void;
extern fn c_benchCopy32Bx4NT(mem_block: [*]u8, mem_block_size: usize) void;
extern fn c_benchLatencyRAR(mem_block: [*]u8, mem_block_size: usize) usize;
extern fn c_benchLatencyWAR(mem_block: [*]u8, mem_block_size: usize) usize;

fn warpedScore(comptime f: anytype, mem_block: [*]u8, mem_block_size: usize) f64 {
    const ns1 = std.time.nanoTimestamp();
    f(mem_block, mem_block_size);
    const ns2 = std.time.nanoTimestamp();
    return @as(f64, @floatFromInt(mem_block_size >> 20)) / 1024.0 / (@as(f64, @floatFromInt(ns2 - ns1)) / 1e+9);
}

fn warpedScoreLatency(comptime f: anytype, mem_block: [*]u8, mem_block_size: usize) f64 {
    const ns1 = std.time.nanoTimestamp();
    const origin_score = f(mem_block, mem_block_size);
    const ns2 = std.time.nanoTimestamp();
    return @as(f64, @floatFromInt(ns2 - ns1)) / @as(f64, @floatFromInt(origin_score));
}

const BENCH_TIME_MS = 3000;
const allocator = std.heap.page_allocator;
const MEM_BLOCK_SIZE = 512 << 20;

fn warpedBench1(f_name: []const u8, score_unit: []const u8, comptime f: anytype) !void {
    const mem_block = try allocator.alloc(u8, MEM_BLOCK_SIZE);
    defer allocator.free(mem_block);
    @memset(mem_block, 0);
    std.debug.print("\n", .{});
    const ms = std.time.milliTimestamp();
    while (std.time.milliTimestamp() - ms < BENCH_TIME_MS)
        std.debug.print("{s:<15}|{:<5.1}{s:>5}\r", .{ f_name, warpedScore(f, mem_block.ptr, mem_block.len), score_unit });
}

fn warpedBench2(f_name: []const u8, score_unit: []const u8, comptime f: anytype) !void {
    std.debug.print("\n", .{});
    const ms = std.time.milliTimestamp();
    while (std.time.milliTimestamp() - ms < BENCH_TIME_MS) {
        const mem_block = try allocator.alloc(u8, MEM_BLOCK_SIZE);
        defer allocator.free(mem_block);
        std.debug.print("{s:<15}|{:<5.1}{s:>5}\r", .{ f_name, warpedScore(f, mem_block.ptr, mem_block.len), score_unit });
    }
}

fn warpedBench3(f_name: []const u8, score_unit: []const u8, comptime f: anytype) !void {
    const mem_block = try allocator.alloc(u8, MEM_BLOCK_SIZE);
    defer allocator.free(mem_block);
    @memset(mem_block, 0);
    std.debug.print("\n", .{});
    const ms = std.time.milliTimestamp();
    var expand_index: usize = 0;
    while (std.time.milliTimestamp() - ms < BENCH_TIME_MS) {
        std.debug.print("{s:<15}|{:<5.1}{s:>5}\r", .{ f_name, warpedScoreLatency(f, mem_block.ptr + expand_index, mem_block.len - expand_index), score_unit });
        expand_index += 1;
        expand_index &= 0xFFF;
    }
}

pub fn main() !void {
    try warpedBench1("Read  1Bx1    ", "GB/s", c_benchRead1Bx1);
    try warpedBench1("Read  32Bx4   ", "GB/s", c_benchRead32Bx4);
    try warpedBench1("Read  32Bx4 NT", "GB/s", c_benchRead32Bx4NT);
    try warpedBench1("Write 1Bx1    ", "GB/s", c_benchWrite1Bx1);
    try warpedBench1("Write 32Bx4   ", "GB/s", c_benchWrite32Bx4);
    try warpedBench1("Write 32Bx4 NT", "GB/s", c_benchWrite32Bx4NT);
    try warpedBench1("Copy  1Bx1    ", "GB/s", c_benchCopy1Bx1);
    try warpedBench1("Copy  32Bx4   ", "GB/s", c_benchCopy32Bx4);
    try warpedBench1("Copy  32Bx4 NT", "GB/s", c_benchCopy32Bx4NT);
    try warpedBench2("Alloc 1Bx1    ", "GB/s", c_benchWrite1Bx1);
    try warpedBench2("Alloc 32Bx4   ", "GB/s", c_benchWrite32Bx4);
    try warpedBench2("Alloc 32Bx4 NT", "GB/s", c_benchWrite32Bx4NT);
    try warpedBench3("Latency RAR   ", "ns", c_benchLatencyRAR);
    try warpedBench3("Latency WAR   ", "ns", c_benchLatencyWAR);

    std.debug.print("\n", .{});
}
