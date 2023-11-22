from vec3 import Vec3


@value
@register_passable("trivial")
struct Point3[dtype: DType]:
    """A point in 3D space."""

    var value: Vec3[dtype]

    @always_inline
    fn __init__(x: SIMD[dtype, 1], y: SIMD[dtype, 1], z: SIMD[dtype, 1]) -> Self:
        return Self {value: Vec3[dtype](x, y, z)}

    @always_inline
    fn __neg__(self) -> Self:
        return Self {value: -self.value}

    @always_inline
    fn __sub__(self, rhs: Self) -> Vec3[dtype]:
        return self.value - rhs.value

    @always_inline
    fn __rsub__(self, lhs: Self) -> Vec3[dtype]:
        return lhs.value - self.value
