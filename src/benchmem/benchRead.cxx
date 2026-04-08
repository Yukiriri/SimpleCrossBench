using i32   = int;
using i64   = long long;
using f32   = float;
using f64   = double;
using u8    = unsigned char;
using u64   = unsigned long long;
using usize = u64;
using v32u8 = __attribute__((vector_size(32))) u8;

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

__attribute__((no_builtin)) extern "C" auto c_benchRead32Bx4(u8* mem_block, usize mem_block_size) -> void
{
    u8 v = 0;
#pragma clang loop vectorize_width(32)
#pragma clang loop interleave_count(1)
#pragma clang loop unroll_count(4)
    for (usize i = 0; i < mem_block_size; i++)
        v ^= mem_block[i];
    volatile auto anti_o2 = v;
}

__attribute__((no_builtin)) extern "C" auto c_benchRead32Bx4NT(u8* mem_block, usize mem_block_size) -> void
{
    auto mem        = (v32u8*&)mem_block;
    auto mem_length = mem_block_size / sizeof(v32u8);

    v32u8 v{};
#pragma clang loop unroll_count(4)
    for (usize i = 0; i < mem_length; i++)
        v ^= __builtin_nontemporal_load(mem + i);
    volatile auto anti_o2 = v;
}
