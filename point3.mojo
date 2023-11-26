from vec3 import Vec3

from types import F


@value
@register_passable("trivial")
struct Point3:
    """A point in 3D space."""

    var value: Vec3

    alias ORIGIN: Self = Self {value: Vec3.ZERO}

    @always_inline
    fn __init__(x: F = 0.0, y: F = 0.0, z: F = 0.0) -> Self:
        return Self {value: Vec3(x, y, z)}

    @always_inline
    fn __eq__(self, rhs: Self) -> Bool:
        return self.value == rhs.value

    @always_inline
    fn __neg__(self) -> Self:
        return Self {value: -self.value}

    @always_inline
    fn __sub__(self, rhs: Self) -> Vec3:
        return self.value - rhs.value

    @always_inline
    fn __rsub__(self, lhs: Self) -> Vec3:
        return lhs.value - self.value
