from math import rsqrt


@value
@register_passable("trivial")
struct Vec3f:
    var data: SIMD[DType.float32, 4]

    alias zero = Vec3f(0, 0, 0)
    alias one = Vec3f(1, 1, 1)

    @always_inline
    fn __init__(x: Float32, y: Float32, z: Float32) -> Self:
        return Vec3f {data: SIMD[DType.float32, 4](x, y, z, 0)}

    @always_inline
    fn __sub__(self, rhs: Vec3f) -> Vec3f:
        return self.data - rhs.data

    @always_inline
    fn __add__(self, rhs: Vec3f) -> Vec3f:
        return self.data + rhs.data

    @always_inline
    fn __matmul__(self, rhs: Vec3f) -> Float32:
        return (self.data * rhs.data).reduce_add()

    @always_inline
    fn __mul__(self, rhs: Float32) -> Vec3f:
        return self.data * rhs

    @always_inline
    fn __rmul__(self, lhs: Float32) -> Vec3f:
        return lhs * self.data

    @always_inline
    fn __neg__(self) -> Vec3f:
        return -self.data

    @always_inline
    fn __getitem__(self, idx: Int) -> SIMD[DType.float32, 1]:
        return self.data[idx]

    @always_inline
    fn normalize(self) -> Vec3f:
        return self.data * rsqrt(self.magnitude_sq())

    @always_inline
    fn magnitude_sq(self) -> Float32:
        return (self.data**2).reduce_add()

    @always_inline
    fn magnitude(self) -> Float32:
        return self.magnitude_sq() ** 0.5

    @always_inline
    fn cross(self, other: Vec3f) -> Vec3f:
        let self_zxy = self.data.shuffle[2, 0, 1, 3]()
        let other_zxy = other.data.shuffle[2, 0, 1, 3]()
        let crossed = (self_zxy * other.data - self.data * other_zxy).shuffle[
            2, 0, 1, 3
        ]()
        debug_assert(crossed[3] == 0, "Cross product should have 0 in the w component")
        return crossed
