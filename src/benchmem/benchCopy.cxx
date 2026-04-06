using i32   = int;
using i64   = long long;
using f32   = float;
using f64   = double;
using u8    = unsigned char;
using u64   = unsigned long long;
using usize = u64;
using v64u8 = __attribute__((vector_size(64))) u8;

__attribute__((no_builtin)) extern "C" auto c_benchCopy1Bx1(u8* mem_block, usize mem_block_size) -> void
{
#pragma clang loop vectorize_width(1)
#pragma clang loop interleave_count(1)
#pragma clang loop unroll(disable)
    for (usize i1 = 0, i2 = mem_block_size / 2; i1 < i2; i1++)
        mem_block[i1] = mem_block[i2 + i1];
}

__attribute__((no_builtin)) extern "C" auto c_benchCopy64Bx1(u8* mem_block, usize mem_block_size) -> void
{
#pragma clang loop vectorize_width(64)
#pragma clang loop interleave_count(1)
#pragma clang loop unroll(disable)
    for (usize i1 = 0, i2 = mem_block_size / 2; i1 < i2; i1++)
        mem_block[i1] = mem_block[i2 + i1];
}

__attribute__((no_builtin)) extern "C" auto c_benchCopy64Bx1NT(u8* mem_block, usize mem_block_size) -> void
{
    auto mem        = (v64u8*&)mem_block;
    auto mem_length = mem_block_size / sizeof(v64u8);

#pragma clang loop unroll_count(2)
    for (usize i1 = 0, i2 = mem_length / 2; i1 < i2; i1++)
        __builtin_nontemporal_store(__builtin_nontemporal_load(mem + i1), mem + i2 + i1);
}
