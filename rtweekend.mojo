import math

alias pi = 3.1415926535897932385


@always_inline
fn degrees_to_radians[dtype: DType](degrees: SIMD[dtype, 1]) -> SIMD[dtype, 1]:
    return degrees * pi / 180.0
