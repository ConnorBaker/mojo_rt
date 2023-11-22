from math import pow, rsqrt, sqrt
from random import random_float64, randn_float64

from unit3 import Unit3


@value
@register_passable("trivial")
struct Vec3[dtype: DType]:
    """
    A 3D vector.
    """

    # Maintaining the invariant that the last component remain zero
    # is a bit tricky.
    # It precludes us from using SIMD operations which broadcast a scalar
    # to a SIMD vector, since the last component of the result can be nonzero.
    # There are a number of ways to handle this:
    #
    # 1. Use a helper function which always sets the last component to zero.
    # 2. Manually create a SIMD vector with the last component zeroed (or equivalent identity under the operation).
    #
    # We take the second approach here, since it is more efficient.

    var value: SIMD[dtype, 4]

    @always_inline
    fn __init__(all: SIMD[dtype, 1]) -> Self:
        let value = SIMD[dtype, 4](all, all, all, 0)
        return Self {value: value}

    @always_inline
    fn __init__(x: SIMD[dtype, 1], y: SIMD[dtype, 1], z: SIMD[dtype, 1]) -> Self:
        let value = SIMD[dtype, 4](x, y, z, 0)
        return Self {value: value}

    @always_inline
    fn __init__(value: SIMD[dtype, 4]) -> Self:
        var _value = value
        _value[3] = 0
        return Self {value: _value}

    @always_inline
    fn __eq__(self, rhs: Self) -> Bool:
        return self.value == rhs.value

    @always_inline
    fn __add__(self, rhs: Self) -> Self:
        # As Vec3, these are guaranteed to have a last component of zero.
        # Since zero is the identity for addition, we can just add the
        # vectors and return the result.
        return self.value + rhs.value

    @always_inline
    fn __add__(self, rhs: SIMD[dtype, 1]) -> Self:
        return self.value + SIMD[dtype, 4](rhs, rhs, rhs, 0)

    @always_inline
    fn __radd__(self, lhs: Self) -> Self:
        return lhs.value + self.value

    @always_inline
    fn __radd__(self, lhs: SIMD[dtype, 1]) -> Self:
        return SIMD[dtype, 4](lhs, lhs, lhs, 0) + self.value

    @always_inline
    fn __sub__(self, rhs: Self) -> Self:
        # As Vec3, these are guaranteed to have a last component of zero.
        # Since zero is the identity for subtraction, we can just subtract
        # the vectors and return the result.
        return self.value - rhs.value

    @always_inline
    fn __sub__(self, rhs: SIMD[dtype, 1]) -> Self:
        return self.value - SIMD[dtype, 4](rhs, rhs, rhs, 0)

    @always_inline
    fn __rsub__(self, lhs: Self) -> Self:
        return lhs.value - self.value

    @always_inline
    fn __rsub__(self, lhs: SIMD[dtype, 1]) -> Self:
        return SIMD[dtype, 4](lhs, lhs, lhs, 0) - self.value

    @always_inline
    fn __mul__(self, rhs: Self) -> Self:
        # As Vec3, these are guaranteed to have a last component of zero.
        # Since zero is the dominator for multiplication, we can just multiply
        # the vectors and return the result.
        return self.value * rhs.value

    @always_inline
    fn __mul__(self, rhs: SIMD[dtype, 1]) -> Self:
        # Zero is a dominator for multiplication, so no need to broadcast
        # the rhs to a SIMD vector and zero the last component.
        # NOTE: Assumes RHS is not a special float value (e.g. NaN, Inf).
        return self.value * rhs

    @always_inline
    fn __rmul__(self, lhs: Self) -> Self:
        return lhs.value * self.value

    @always_inline
    fn __rmul__(self, lhs: SIMD[dtype, 1]) -> Self:
        return lhs * self.value

    @always_inline
    fn __truediv__(self, rhs: Self) -> Self:
        # To avoid division by zero, we add one to the last component of the
        # divisor, then zero the last component of the result.
        # Since the lhs is a Vec3, we know the last component is zero, so the
        # result of the last component is also zero.
        return self.value / (rhs.value + SIMD[dtype, 4](0.0, 0.0, 0.0, 1.0))

    @always_inline
    fn __truediv__(self, rhs: SIMD[dtype, 1]) -> Self:
        # Broadcast the rhs to a vector where the last component is one, then
        # perform the division.
        return self.value / SIMD[dtype, 4](rhs, rhs, rhs, 1)

    @always_inline
    fn __rtruediv__(self, lhs: Self) -> Self:
        return lhs.value / (self.value + SIMD[dtype, 4](0.0, 0.0, 0.0, 1.0))

    @always_inline
    fn __rtruediv__(self, lhs: SIMD[dtype, 1]) -> Self:
        # Cannot divide by zero, so we must broadcast the lhs to a SIMD vector
        # and manually zero the last component.
        return SIMD[dtype, 4](lhs, lhs, lhs, 0) / (self.value + SIMD[dtype, 4](0.0, 0.0, 0.0, 1.0))

    @always_inline
    fn __neg__(self) -> Self:
        return -self.value

    @always_inline
    fn __getitem__(self, idx: Int) -> SIMD[dtype, 1]:
        return self.value[idx]

    @always_inline
    fn inner(self, rhs: Self) -> SIMD[dtype, 1]:
        return (self.value * rhs.value).reduce_add()

    @always_inline
    fn outer(self, other: Self) -> Self:
        let selfL = self.rl()
        let selfR = self.rr()
        let otherL = other.rl()
        let otherR = other.rr()
        let crossed = (selfL * otherR) - (selfR * otherL)
        return crossed

    @always_inline
    fn norm(self) -> Unit3[dtype]:
        # Use construction via dictionary to avoid infinite recursion.
        let mag = self.mag()
        debug_assert(mag != 0.0, "Cannot normalize a zero vector.")
        return Unit3[dtype] {value: self.value / mag}

    @always_inline
    fn mag_sq(self) -> SIMD[dtype, 1]:
        return pow(self.value, 2).reduce_add()

    @always_inline
    fn mag(self) -> SIMD[dtype, 1]:
        return sqrt(self.mag_sq())

    @always_inline
    fn rl(self) -> Self:
        # TODO: Is shuffle faster than doing some combination of masking and multiplying?
        return self.value.shuffle[1, 2, 0, 3]()

    @always_inline
    fn rr(self) -> Self:
        return self.value.shuffle[2, 0, 1, 3]()

    @always_inline
    fn reflect(self, normal: Self) -> Self:
        return self.value - 2 * self.inner(normal) * normal.value

    @staticmethod
    @always_inline
    fn rand(min: SIMD[dtype, 1] = 0.0, max: SIMD[dtype, 1] = 1.0) -> Self:
        let min_f64 = min.cast[DType.float64]()
        let max_f64 = max.cast[DType.float64]()
        return SIMD[dtype, 4](
            random_float64(min_f64, max_f64).cast[dtype](),
            random_float64(min_f64, max_f64).cast[dtype](),
            random_float64(min_f64, max_f64).cast[dtype](),
            0.0,
        )

    @staticmethod
    @always_inline
    fn randn(mean: SIMD[dtype, 1] = 0.0, variance: SIMD[dtype, 1] = 1.0) -> Self:
        let mean_f64 = mean.cast[DType.float64]()
        let variance_f64 = variance.cast[DType.float64]()
        return SIMD[dtype, 4](
            randn_float64(mean_f64, variance_f64).cast[dtype](),
            randn_float64(mean_f64, variance_f64).cast[dtype](),
            randn_float64(mean_f64, variance_f64).cast[dtype](),
            0.0,
        )
