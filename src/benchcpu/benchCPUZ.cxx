using i32   = int;
using i64   = long long;
using f32   = float;
using f64   = double;
using u8    = unsigned char;
using u64   = unsigned long long;
using usize = u64;

__attribute__((optnone)) auto benchCPUZ_callback(i64 n) -> i64
{
    if (n <= 1)
        return 1;
    return benchCPUZ_callback(n - 1) + benchCPUZ_callback(n - 2);
}

extern "C" auto c_benchCPUZ() -> f64
{
    i64 v = 0;
    for (i32 load = 0; load < 1000; load++)
        v += benchCPUZ_callback(15);
    volatile auto anti_o2 = v;

    return 1.395;
}
