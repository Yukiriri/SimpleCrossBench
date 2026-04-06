using i32   = int;
using i64   = long long;
using f32   = float;
using f64   = double;
using u8    = unsigned char;
using u64   = unsigned long long;
using usize = u64;

constexpr auto LOAD_FRACTION = 4;

__attribute__((optnone)) extern "C" auto c_benchBranch() -> f64
{
    constexpr auto ARR_SIZE = 5;

    i64 v[ARR_SIZE]{};
    for (i32 i = 0; i < (i32)(LOAD_FRACTION * 1e+6); i++) {
        if (i & 1) {
            v[0] += 1;
            if (i & 0b10) {
                v[1] += 10;
                if (i & 0b100) {
                    v[2] += 100;
                    if (i & 0b1000) {
                        v[3] += 1000;
                        if (i & 0x10000) {
                            v[4] += 10000;
                        } else if (i & 0x11000) {
                            v[4] += 11000;
                        } else if (i & 0x11100) {
                            v[4] += 11100;
                        } else if (i & 0x11110) {
                            v[4] += 11110;
                        } else if (i & 0x11111) {
                            v[4] += 11111;
                        }
                    } else if (i & 0b1100) {
                        v[3] += 1100;
                    } else if (i & 0b1110) {
                        v[3] += 1110;
                    } else if (i & 0b1111) {
                        v[3] += 1111;
                    }
                } else if (i & 0b110) {
                    v[2] += 110;
                } else if (i & 0b111) {
                    v[2] += 111;
                }
            } else if (i & 0b11) {
                v[1] += 11;
            }
        }
    }
    volatile i64 anti_o2[ARR_SIZE];
    for (i32 i = 0; i < ARR_SIZE; i++)
        anti_o2[i] = v[i];

    return LOAD_FRACTION;
}
