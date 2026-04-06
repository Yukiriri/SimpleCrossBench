using i32   = int;
using i64   = long long;
using f32   = float;
using f64   = double;
using u8    = unsigned char;
using u64   = unsigned long long;
using usize = u64;

constexpr auto LOAD_FRACTION     = 2;
constexpr auto SUPERSCALAR_COUNT = 16;

template <typename T>
auto benchFPU(T* arr1, T* arr2) -> f64
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
            arr2[i] /= arr1[i];
    }

    return LOAD_FRACTION * SUPERSCALAR_COUNT * 4;
}

__attribute__((optnone)) extern "C" auto c_benchFPU32() -> f64
{
    f32 arr1[SUPERSCALAR_COUNT]{0xAA};
    f32 arr2[SUPERSCALAR_COUNT]{0x55};
    return benchFPU(arr1, arr2);
}

__attribute__((optnone)) extern "C" auto c_benchFPU64() -> f64
{
    f64 arr1[SUPERSCALAR_COUNT]{0xAA};
    f64 arr2[SUPERSCALAR_COUNT]{0x55};
    return benchFPU(arr1, arr2);
}
