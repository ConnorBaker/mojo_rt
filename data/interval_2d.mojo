from math import clamp

from types import F, DTYPE, INF, NEGINF


@value
@register_passable("trivial")
struct Interval2D(Stringable):
    """A closed interval of numbers."""

    var min: F
    var max: F

    fn __init__(min: F = NEGINF, max: F = INF) -> Self:
        return Self {min: min, max: max}

    fn contains(self, x: F) -> Bool:
        """Returns true if x is in the interval, inclusive."""
        return self.min <= x and x <= self.max

    fn surrounds(self, x: F) -> Bool:
        """Returns true if x is in the interval, exclusive."""
        return self.min < x and x < self.max

    fn clamp[simd_width: Int](self, x: SIMD[DTYPE, simd_width]) -> SIMD[DTYPE, simd_width]:
        """Clamps x to the interval."""
        return clamp[DTYPE, simd_width](x, self.min, self.max)

    fn __str__(self) -> String:
        return "Interval2D(min=" + str(self.min) + ", max=" + str(self.max) + ")"
