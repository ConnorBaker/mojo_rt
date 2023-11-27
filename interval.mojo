from math import clamp
from math.limit import neginf, inf
from types import F, DTYPE, INF, NEGINF


@value
@register_passable("trivial")
struct Interval:
    var min: F
    var max: F

    fn __init__() -> Self:
        return Interval {min: NEGINF, max: INF}

    fn contains(self, x: F) -> Bool:
        """Returns true if x is in the interval, inclusive."""
        return self.min <= x and x <= self.max

    fn surrounds(self, x: F) -> Bool:
        """Returns true if x is in the interval, exclusive."""
        return self.min < x and x < self.max

    fn clamp[simd_width: Int](self, x: SIMD[DTYPE, simd_width]) -> SIMD[DTYPE, simd_width]:
        return clamp[DTYPE, simd_width](x, self.min, self.max)
