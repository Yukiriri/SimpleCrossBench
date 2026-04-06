using i32   = int;
using i64   = long long;
using f32   = float;
using f64   = double;
using u8    = unsigned char;
using u64   = unsigned long long;
using usize = u64;
using v32u8 = __attribute__((vector_size(32))) u8;

constexpr auto STEP_LENGTH = 4096;

__attribute__((no_builtin)) extern "C" auto c_benchLatencyRAR(u8* mem_block, usize mem_block_size) -> usize
{
    usize ops = 0;
    for (usize i = 0; i < mem_block_size; i += STEP_LENGTH) {
        volatile auto v = mem_block[i];
        ops++;
    }

    return ops;
}

__attribute__((no_builtin)) extern "C" auto c_benchLatencyWAR(u8* mem_block, usize mem_block_size) -> usize
{
    usize ops = 0;
    for (usize i = 0; i < mem_block_size; i += STEP_LENGTH) {
        (volatile u8&)mem_block[i] = 0xAA;
        volatile u8 v              = (volatile u8&)mem_block[i];
        ops++;
    }

    return ops;
}
