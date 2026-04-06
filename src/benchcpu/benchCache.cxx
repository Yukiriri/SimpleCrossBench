using i32   = int;
using i64   = long long;
using f32   = float;
using f64   = double;
using u8    = unsigned char;
using u64   = unsigned long long;
using usize = u64;

constexpr auto LOAD_FRACTION = 2;

__attribute__((no_builtin)) auto benchCache(u8* buf, usize buf_size) -> f64
{
#pragma nounroll
    for (i32 load = 0; load < (i32)(LOAD_FRACTION * 1e+3); load++)
#pragma vectorize_width(32)
#pragma interleave_count(2)
        for (i32 i = 0; i < buf_size; i++)
            buf[i] = (u8)load;

    return LOAD_FRACTION;
}

__attribute__((optnone)) extern "C" auto c_benchCache16K() -> f64
{
    alignas(64) u8 buf[16 << 10];
    return benchCache(buf, sizeof(buf));
}

__attribute__((optnone)) extern "C" auto c_benchCache512K() -> f64
{
    alignas(64) u8 buf[512 << 10];
    return benchCache(buf, sizeof(buf));
}

__attribute__((optnone)) extern "C" auto c_benchCache2M() -> f64
{
    alignas(64) u8 buf[2 << 20];
    return benchCache(buf, sizeof(buf));
}
