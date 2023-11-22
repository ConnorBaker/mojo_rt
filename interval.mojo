from math import clamp
from math.limit import neginf, inf


@value
@register_passable("trivial")
struct Interval[dtype: DType]:
    var min: SIMD[dtype, 1]
    var max: SIMD[dtype, 1]

    @always_inline
    fn __init__() -> Self:
        return Interval[dtype] {min: neginf[dtype](), max: inf[dtype]()}

    @always_inline
    fn contains(self, x: SIMD[dtype, 1]) -> Bool:
        """Returns true if x is in the interval, inclusive."""
        return self.min <= x and x <= self.max

    @always_inline
    fn surrounds(self, x: SIMD[dtype, 1]) -> Bool:
        """Returns true if x is in the interval, exclusive."""
        return self.min < x and x < self.max

    @always_inline
    fn clamp[simd_width: Int](self, x: SIMD[dtype, simd_width]) -> SIMD[dtype, simd_width]:
        return clamp[dtype, simd_width](x, self.min, self.max)
