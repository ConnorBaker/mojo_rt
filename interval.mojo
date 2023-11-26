from math import clamp
from math.limit import neginf, inf
from types import F, dtype, INF, NEGINF


@value
@register_passable("trivial")
struct Interval:
    var min: F
    var max: F

    @always_inline
    fn __init__() -> Self:
        return Interval {min: NEGINF, max: INF}

    @always_inline
    fn contains(self, x: F) -> Bool:
        """Returns true if x is in the interval, inclusive."""
        return self.min <= x and x <= self.max

    @always_inline
    fn surrounds(self, x: F) -> Bool:
        """Returns true if x is in the interval, exclusive."""
        return self.min < x and x < self.max

    @always_inline
    fn clamp[simd_width: Int](self, x: SIMD[dtype, simd_width]) -> SIMD[dtype, simd_width]:
        return clamp[dtype, simd_width](x, self.min, self.max)