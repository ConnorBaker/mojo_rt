from .types import F
from .vec3 import Vec3


@value
@register_passable("trivial")
struct Point3:
    """A point in 3D space."""

    var value: Vec3

    alias ORIGIN: Self = Self(0.0, 0.0, 0.0)
    """The origin point."""

    fn __init__(x: F = 0.0, y: F = 0.0, z: F = 0.0) -> Self:
        return Self {value: Vec3(x, y, z)}

    fn __eq__(self, rhs: Self) -> Bool:
        return self.value == rhs.value

    fn __neg__(self) -> Self:
        return Self {value: -self.value}

    fn __add__(self, rhs: Self) -> Self:
        return Self {value: self.value + rhs.value}

    fn __radd__(self, lhs: Self) -> Self:
        return Self {value: lhs.value + self.value}

    fn __sub__(self, rhs: Self) -> Vec3:
        return self.value - rhs.value

    fn __rsub__(self, lhs: Self) -> Vec3:
        return lhs.value - self.value
