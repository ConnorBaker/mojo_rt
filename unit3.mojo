from interval import Interval
from vec3 import Vec3

from types import F, F4


@value
@register_passable("trivial")
struct Unit3:
    """A unit vector in 3D space."""

    var value: Vec3

    alias I: Self = Self {value: Vec3.I}
    alias J: Self = Self {value: Vec3.J}
    alias K: Self = Self {value: Vec3.K}

    @always_inline
    fn __init__(x: F, y: F, z: F) -> Self:
        debug_assert(x != 0.0 or y != 0.0 or z != 0.0, "Cannot normalize the zero vector.")
        return Vec3(x, y, z).norm()

    @always_inline
    fn __init__(value: Vec3) -> Self:
        debug_assert(
            value[0] != 0.0 or value[1] != 0.0 or value[2] != 0.0,
            "Cannot normalize the zero vector.",
        )
        return value.norm()

    @always_inline
    fn __eq__(self, other: Self) -> Bool:
        return self.value == other.value

    @always_inline
    fn __neg__(self) -> Self:
        # Negation does not change the magnitude of the vector.
        return Unit3 {value: -self.value}

    @always_inline
    fn __add__(self, rhs: Self) -> Vec3:
        return self.value + rhs.value

    @always_inline
    fn __add__(self, rhs: Vec3) -> Vec3:
        return self.value + rhs

    @always_inline
    fn __add__(self, rhs: F) -> Vec3:
        return self.value + rhs

    @always_inline
    fn __radd__(self, lhs: Self) -> Vec3:
        return lhs.value + self.value

    @always_inline
    fn __radd__(self, lhs: Vec3) -> Vec3:
        return lhs + self.value

    @always_inline
    fn __radd__(self, lhs: F) -> Vec3:
        return lhs + self.value

    @always_inline
    fn __sub__(self, rhs: Self) -> Vec3:
        return self.value - rhs.value

    @always_inline
    fn __sub__(self, rhs: Vec3) -> Vec3:
        return self.value - rhs

    @always_inline
    fn __sub__(self, rhs: F) -> Vec3:
        return self.value - rhs

    @always_inline
    fn __rsub__(self, lhs: Self) -> Vec3:
        return lhs.value - self.value

    @always_inline
    fn __rsub__(self, lhs: Vec3) -> Vec3:
        return lhs - self.value

    @always_inline
    fn __rsub__(self, lhs: F) -> Vec3:
        return lhs - self.value

    @always_inline
    fn __mul__(self, rhs: Self) -> Vec3:
        return self.value * rhs.value

    @always_inline
    fn __mul__(self, rhs: Vec3) -> Vec3:
        return self.value * rhs

    @always_inline
    fn __mul__(self, rhs: F) -> Vec3:
        return self.value * rhs

    @always_inline
    fn __rmul__(self, lhs: Self) -> Vec3:
        return lhs.value * self.value

    @always_inline
    fn __rmul__(self, lhs: Vec3) -> Vec3:
        return lhs * self.value

    @always_inline
    fn __rmul__(self, lhs: F) -> Vec3:
        return lhs * self.value

    @always_inline
    fn inner(self, rhs: Self) -> F:
        return (self.value * rhs.value).value.reduce_add()

    @staticmethod
    @always_inline
    fn rand() -> Self:
        """Generates a random unit vector in 3D space."""
        return Self.sample_while_mag_is_zero(Vec3.rand)

    @staticmethod
    @always_inline
    fn randn() -> Self:
        """
        Generates a random unit vector in 3D space which is uniformly distributed
        over the surface of a sphere.

        See: [How to generate random points on a sphere?](https://math.stackexchange.com/a/1585996)
        """
        return Self.sample_while_mag_is_zero(Vec3.randn)

    @staticmethod
    @always_inline
    fn sample_while_mag_is_zero(sample_fn: fn () -> Vec3) -> Self:
        """Samples a unit vector in 3D space until it is not the zero vector."""
        while True:
            let v = sample_fn()
            let mag = v.mag()
            if mag != 0.0:
                return Unit3 {value: v / mag}

    @staticmethod
    @always_inline
    fn random_on_unit_hemisphere(normal: Unit3) -> Self:
        let u = Self.rand()
        return u if u.value.inner(normal.value) > 0.0 else -u
