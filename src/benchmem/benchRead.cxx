using i32   = int;
using i64   = long long;
using f32   = float;
using f64   = double;
using u8    = unsigned char;
using u64   = unsigned long long;
using usize = u64;
using v64u8 = __attribute__((vector_size(64))) u8;

__attribute__((no_builtin)) extern "C" auto c_benchRead1Bx1(u8* mem_block, usize mem_block_size) -> void
{
    u8 v = 0;
#pragma clang loop vectorize_width(1)
#pragma clang loop interleave_count(1)
#pragma clang loop unroll(disable)
    for (usize i = 0; i < mem_block_size; i++)
        v ^= mem_block[i];
    volatile auto anti_o2 = v;
}

__attribute__((no_builtin)) extern "C" auto c_benchRead64Bx1(u8* mem_block, usize mem_block_size) -> void
{
    u8 v = 0;
#pragma clang loop vectorize_width(64)
#pragma clang loop interleave_count(1)
#pragma clang loop unroll(disable)
    for (usize i = 0; i < mem_block_size; i++)
        v ^= mem_block[i];
    volatile auto anti_o2 = v;
}

__attribute__((no_builtin)) extern "C" auto c_benchRead64Bx1NT(u8* mem_block, usize mem_block_size) -> void
{
    auto mem        = (v64u8*&)mem_block;
    auto mem_length = mem_block_size / sizeof(v64u8);

    v64u8 v{};
#pragma clang loop unroll_count(2)
    for (usize i = 0; i < mem_length; i++)
        v ^= __builtin_nontemporal_load(mem + i);
    volatile auto anti_o2 = v;
}
