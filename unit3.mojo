from interval import Interval
from vec3 import Vec3


@value
@register_passable("trivial")
struct Unit3[dtype: DType]:
    """A unit vector in 3D space."""

    var value: Vec3[dtype]

    @always_inline
    fn __init__(x: SIMD[dtype, 1], y: SIMD[dtype, 1], z: SIMD[dtype, 1]) -> Self:
        debug_assert(x != 0.0 or y != 0.0 or z != 0.0, "Cannot normalize the zero vector.")
        return Vec3[dtype](x, y, z).norm()

    @always_inline
    fn __init__(value: Vec3[dtype]) -> Self:
        debug_assert(value[0] != 0.0 or value[1] != 0.0 or value[2] != 0.0, "Cannot normalize the zero vector.")
        return value.norm()

    @always_inline
    fn __neg__(self) -> Self:
        # Negation does not change the magnitude of the vector.
        return Unit3[dtype] {value: -self.value}

    @staticmethod
    @always_inline
    fn rand() -> Self:
        """Generates a random unit vector in 3D space."""
        while True:
            let v = Vec3[dtype].rand()
            let mag = v.mag()
            if mag != 0.0:
                return Unit3[dtype] {value: v / mag}

    @staticmethod
    @always_inline
    fn randn() -> Self:
        """
        Generates a random unit vector in 3D space which is uniformly distributed
        over the surface of a sphere.

        See: [How to generate random points on a sphere?](https://math.stackexchange.com/a/1585996)
        """
        while True:
            let v = Vec3[dtype].randn()
            let mag = v.mag()
            if mag != 0.0:
                return Unit3[dtype] {value: v / mag}

    @staticmethod
    @always_inline
    fn random_on_unit_hemisphere(normal: Unit3[dtype]) -> Self:
        let u = Self.rand()
        return u if u.value.inner(normal.value) > 0.0 else -u
