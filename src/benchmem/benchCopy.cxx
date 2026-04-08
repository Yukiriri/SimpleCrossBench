using i32   = int;
using i64   = long long;
using f32   = float;
using f64   = double;
using u8    = unsigned char;
using u64   = unsigned long long;
using usize = u64;
using v32u8 = __attribute__((vector_size(32))) u8;

__attribute__((no_builtin)) extern "C" auto c_benchCopy1Bx1(u8* mem_block, usize mem_block_size) -> void
{
#pragma clang loop vectorize_width(1)
#pragma clang loop interleave_count(1)
#pragma clang loop unroll(disable)
    for (usize i1 = 0, i2 = mem_block_size / 2; i1 < i2; i1++)
        mem_block[i1] = mem_block[i2 + i1];
}

__attribute__((no_builtin)) extern "C" auto c_benchCopy32Bx4(u8* mem_block, usize mem_block_size) -> void
{
#pragma clang loop vectorize_width(32)
#pragma clang loop interleave_count(1)
#pragma clang loop unroll_count(4)
    for (usize i1 = 0, i2 = mem_block_size / 2; i1 < i2; i1++)
        mem_block[i1] = mem_block[i2 + i1];
}

__attribute__((no_builtin)) extern "C" auto c_benchCopy32Bx4NT(u8* mem_block, usize mem_block_size) -> void
{
    auto mem        = (v32u8*&)mem_block;
    auto mem_length = mem_block_size / sizeof(v32u8);

#pragma clang loop unroll_count(4)
    for (usize i1 = 0, i2 = mem_length / 2; i1 < i2; i1++)
        __builtin_nontemporal_store(__builtin_nontemporal_load(mem + i1), mem + i2 + i1);
}
