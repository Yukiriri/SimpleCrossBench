using i32   = int;
using i64   = long long;
using f32   = float;
using f64   = double;
using u8    = unsigned char;
using u64   = unsigned long long;
using usize = u64;

constexpr auto LOAD_FRACTION     = 2;
constexpr auto SUPERSCALAR_COUNT = 16;

auto benchALU_idiv(i32& a, i32& b) -> void
{
    a /= (b | 1);
}
auto benchALU_idiv(i64& a, i64& b) -> void
{
#ifdef __amd64__
    i64 d;
    asm volatile(
        "cqo;"
        "idivq %[divisor];"
        : "=a"(a), "=d"(d)
        : [divisor] "c"(b | 1), [dividend] "a"(a));
#else
    a /= (b | 1);
#endif
}

template <typename T>
auto benchALU(T* arr1, T* arr2) -> f64
{
    for (i32 load = 0; load < (i32)(LOAD_FRACTION * 1e+6); load++) {
#pragma unroll
        for (i32 i = 0; i < SUPERSCALAR_COUNT; i++)
            arr1[i] += arr2[i];
#pragma unroll
        for (i32 i = 0; i < SUPERSCALAR_COUNT; i++)
            arr2[i] *= arr1[i];
#pragma unroll
        for (i32 i = 0; i < SUPERSCALAR_COUNT; i++)
            arr1[i] -= arr2[i];
#pragma unroll
        for (i32 i = 0; i < SUPERSCALAR_COUNT; i++)
            benchALU_idiv(arr2[i], arr1[i]);
#pragma unroll
        for (i32 i = 0; i < SUPERSCALAR_COUNT; i++)
            arr1[i] &= arr2[i];
#pragma unroll
        for (i32 i = 0; i < SUPERSCALAR_COUNT; i++)
            arr2[i] ^= arr1[i];
#pragma unroll
        for (i32 i = 0; i < SUPERSCALAR_COUNT; i++)
            arr1[i] |= arr2[i];
    }

    return LOAD_FRACTION * SUPERSCALAR_COUNT * 7;
}

__attribute__((optnone)) extern "C" auto c_benchALU32() -> f64
{
    i32 arr1[SUPERSCALAR_COUNT]{0xAA};
    i32 arr2[SUPERSCALAR_COUNT]{0x55};
    return benchALU(arr1, arr2);
}

__attribute__((optnone)) extern "C" auto c_benchALU64() -> f64
{
    i64 arr1[SUPERSCALAR_COUNT]{0xAA};
    i64 arr2[SUPERSCALAR_COUNT]{0x55};
    return benchALU(arr1, arr2);
}
