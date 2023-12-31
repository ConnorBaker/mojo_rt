from .types import F, mk_F4
from .vec3 import Vec3


@value
@register_passable("trivial")
struct Unit3:
    """A unit vector in 3D space."""

    var value: Vec3

    # NOTE: We use the dict syntax to avoid calling the __init__ method and thus
    # avoid the normalization check.
    alias I: Self = Self {value: Vec3.I}
    alias J: Self = Self {value: Vec3.J}
    alias K: Self = Self {value: Vec3.K}

    fn __init__(x: F, y: F, z: F) -> Self:
        let vec3 = Vec3(x, y, z)
        let mag = vec3.mag()
        debug_assert(mag != 0.0, "Cannot normalize a zero vector.")
        return Unit3 {value: vec3 / mag}

    fn __init__(value: Vec3) -> Self:
        let mag = value.mag()
        debug_assert(mag != 0.0, "Cannot normalize a zero vector.")
        return Unit3 {value: value / mag}

    fn __eq__(self, other: Self) -> Bool:
        return self.value == other.value

    fn __neg__(self) -> Self:
        # Negation does not change the magnitude of the vector.
        return Unit3 {value: -self.value}

    fn __add__(self, rhs: Self) -> Vec3:
        return self.value + rhs.value

    fn __add__(self, rhs: Vec3) -> Vec3:
        return self.value + rhs

    fn __add__(self, rhs: F) -> Vec3:
        return self.value + rhs

    fn __radd__(self, lhs: Self) -> Vec3:
        return lhs.value + self.value

    fn __radd__(self, lhs: Vec3) -> Vec3:
        return lhs + self.value

    fn __radd__(self, lhs: F) -> Vec3:
        return lhs + self.value

    fn __sub__(self, rhs: Self) -> Vec3:
        return self.value - rhs.value

    fn __sub__(self, rhs: Vec3) -> Vec3:
        return self.value - rhs

    fn __sub__(self, rhs: F) -> Vec3:
        return self.value - rhs

    fn __rsub__(self, lhs: Self) -> Vec3:
        return lhs.value - self.value

    fn __rsub__(self, lhs: Vec3) -> Vec3:
        return lhs - self.value

    fn __rsub__(self, lhs: F) -> Vec3:
        return lhs - self.value

    fn __mul__(self, rhs: Self) -> Vec3:
        return self.value * rhs.value

    fn __mul__(self, rhs: Vec3) -> Vec3:
        return self.value * rhs

    fn __mul__(self, rhs: F) -> Vec3:
        return self.value * rhs

    fn __rmul__(self, lhs: Self) -> Vec3:
        return lhs.value * self.value

    fn __rmul__(self, lhs: Vec3) -> Vec3:
        return lhs * self.value

    fn __rmul__(self, lhs: F) -> Vec3:
        return lhs * self.value

    fn inner(self, rhs: Self) -> F:
        return (self.value * rhs.value).value.reduce_add()

    fn reflect(self, normal: Self) -> Vec3:
        return self - 2.0 * self.inner(normal) * normal

    fn reflect(self, normal: Vec3) -> Vec3:
        return self - 2.0 * self.inner(normal) * normal

    @staticmethod
    fn rand() -> Self:
        """Generates a random unit vector in 3D space."""
        return Self.sample_while_mag_is_zero(Vec3.rand)

    @staticmethod
    fn randn() -> Self:
        """
        Generates a random unit vector in 3D space which is uniformly distributed
        over the surface of a sphere.

        See: [How to generate random points on a sphere?](https://math.stackexchange.com/a/1585996)
        """
        return Self.sample_while_mag_is_zero(Vec3.randn)

    @staticmethod
    fn sample_while_mag_is_zero(sample_fn: fn () -> Vec3) -> Self:
        """Samples a unit vector in 3D space until it is not the zero vector."""
        while True:
            let v = sample_fn()
            let mag = v.mag()
            if mag != 0.0:
                return Unit3 {value: v / mag}

    @staticmethod
    fn random_on_unit_hemisphere(normal: Unit3) -> Self:
        let u = Self.rand()
        return u if u.value.inner(normal.value) > 0.0 else -u
