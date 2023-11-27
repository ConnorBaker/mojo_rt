from math import pow, rsqrt, sqrt
from random import random_float64, randn_float64

from unit3 import Unit3
from types import F4, F, mk_F4, mk_F4_repeat


@value
@register_passable("trivial")
struct Vec3:
    """
    A 3D vector.
    """

    var value: F4

    alias _div_add_mask: F4 = mk_F4(w=1.0)
    alias ZERO: Self = Self {value: mk_F4()}
    alias ONE: Self = Self {value: mk_F4_repeat(1.0)}
    alias I: Self = Self {value: mk_F4(x=1.0)}
    alias J: Self = Self {value: mk_F4(y=1.0)}
    alias K: Self = Self {value: mk_F4(z=1.0)}

    @staticmethod
    fn repeat(value: F) -> Self:
        return Self {value: mk_F4_repeat(value)}

    fn __init__(x: F = 0.0, y: F = 0.0, z: F = 0.0) -> Self:
        return Self {value: mk_F4(x, y, z)}

    fn __init__(value: F4) -> Self:
        var _value = value
        _value[3] = 0
        return Self {value: _value}

    fn __eq__(self, rhs: Self) -> Bool:
        return self.value == rhs.value

    fn __add__(self, rhs: Self) -> Self:
        # As Vec3, these are guaranteed to have a last component of zero.
        # Since zero is the identity for addition, we can just add the
        # vectors and return the result.
        return self.value + rhs.value

    fn __add__(self, rhs: F) -> Self:
        return self.value + mk_F4_repeat(rhs)

    fn __radd__(self, lhs: Self) -> Self:
        return lhs.value + self.value

    fn __radd__(self, lhs: F) -> Self:
        return mk_F4_repeat(lhs) + self.value

    fn __sub__(self, rhs: Self) -> Self:
        # As Vec3, these are guaranteed to have a last component of zero.
        # Since zero is the identity for subtraction, we can just subtract
        # the vectors and return the result.
        return self.value - rhs.value

    fn __sub__(self, rhs: F) -> Self:
        return self.value - mk_F4_repeat(rhs)

    fn __rsub__(self, lhs: Self) -> Self:
        return lhs.value - self.value

    fn __rsub__(self, lhs: F) -> Self:
        return mk_F4_repeat(lhs) - self.value

    fn __mul__(self, rhs: Self) -> Self:
        # As Vec3, these are guaranteed to have a last component of zero.
        # Since zero is the dominator for multiplication, we can just multiply
        # the vectors and return the result.
        return self.value * rhs.value

    fn __mul__(self, rhs: F) -> Self:
        # Zero is a dominator for multiplication, so no need to broadcast
        # the rhs to a SIMD vector and zero the last component.
        # NOTE: Assumes RHS is not a special float value (e.g. NaN, Inf).
        return self.value * rhs

    fn __rmul__(self, lhs: Self) -> Self:
        return lhs.value * self.value

    fn __rmul__(self, lhs: F) -> Self:
        return lhs * self.value

    fn __truediv__(self, rhs: Self) -> Self:
        # To avoid division by zero, we add one to the last component of the
        # divisor, then zero the last component of the result.
        # Since the lhs is a Vec3, we know the last component is zero, so the
        # result of the last component is also zero.
        return self.value / (rhs.value + Self._div_add_mask)

    fn __truediv__(self, rhs: F) -> Self:
        # Broadcast the rhs to a vector where the last component is one, then
        # perform the division.
        return self.value / F4(rhs, rhs, rhs, 1)

    fn __rtruediv__(self, lhs: Self) -> Self:
        return lhs.value / (self.value + Self._div_add_mask)

    fn __rtruediv__(self, lhs: F) -> Self:
        # Cannot divide by zero, so we must broadcast the lhs to a SIMD vector
        # and manually zero the last component.
        return mk_F4_repeat(lhs) / (self.value + Self._div_add_mask)

    fn __neg__(self) -> Self:
        return -self.value

    fn __getitem__(self, idx: Int) -> F:
        return self.value[idx]

    fn __setitem__(inout self, idx: Int, value: F):
        self.value[idx] = value

    fn inner(self, rhs: Self) -> F:
        return (self.value * rhs.value).reduce_add()

    fn outer(self, other: Self) -> Self:
        let selfL = self.rl()
        let selfR = self.rr()
        let otherL = other.rl()
        let otherR = other.rr()
        let crossed = (selfL * otherR) - (selfR * otherL)
        return crossed

    fn norm(self) -> Unit3:
        # Use construction via dictionary to avoid infinite recursion.
        let mag = self.mag()
        debug_assert(mag != 0.0, "Cannot normalize a zero vector.")
        return Unit3 {value: self.value / mag}

    fn mag_sq(self) -> F:
        return pow(self.value, 2).reduce_add()

    fn mag(self) -> F:
        return sqrt(self.mag_sq())

    fn rl(self) -> Self:
        # TODO: Is shuffle faster than doing some combination of masking and multiplying?
        return self.value.shuffle[1, 2, 0, 3]()

    fn rr(self) -> Self:
        return self.value.shuffle[2, 0, 1, 3]()

    fn reflect(self, normal: Self) -> Self:
        return self.value - 2 * self.inner(normal) * normal.value

    @staticmethod
    fn rand() -> Self:
        return F4(
            random_float64(0.0, 1.0),
            random_float64(0.0, 1.0),
            random_float64(0.0, 1.0),
            0.0,
        )

    @staticmethod
    fn randn() -> Self:
        return F4(
            randn_float64(0.0, 1.0),
            randn_float64(0.0, 1.0),
            randn_float64(0.0, 1.0),
            0.0,
        )
