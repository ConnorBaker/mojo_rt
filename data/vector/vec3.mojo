from math import sqrt, pow
from random import randn_float64, random_float64

from data.vector.f4 import F4Utils
from traits.arith import Arith
from traits.arith.scalar import ScalarArith
from traits.ops.vector import VectorOps
from traits.ord import Ord
from traits.random import Random, RandomNormal
from types import F, F4


@value
@register_passable("trivial")
struct Vec3(
    Arith,
    Ord,
    Random,
    RandomNormal,
    ScalarArith,
    Stringable,
    VectorOps,
):
    """
    A 3D vector.

    Implementation-wise, it is backed by a 4-lane SIMD vector where the last component is zero.
    """

    var value: F4

    # Begin constructors
    @staticmethod
    fn __init__(x: F = 0.0, y: F = 0.0, z: F = 0.0) -> Self:
        return Self {value: F4Utils.mk(x=x, y=y, z=z)}

    @staticmethod
    fn __init__(value: F4) -> Self:
        var sanitized = value
        sanitized[3] = 0.0
        return Self {value: sanitized}

    @staticmethod
    fn repeat(value: F) -> Self:
        return Self {value: F4Utils.mk(x=value, y=value, z=value)}

    # End constructors

    # Begin implementation of Stringable
    fn __str__(self) -> String:
        return "Vec3(value=" + F4Utils.str3(self.value.value) + ")"

    # End implementation of Stringable

    # Begin implementation of Ord
    fn __lt__(self, rhs: Self) -> Bool:
        return self.value < rhs.value

    fn __le__(self, rhs: Self) -> Bool:
        return self.value <= rhs.value

    fn __gt__(self, rhs: Self) -> Bool:
        return self.value > rhs.value

    fn __ge__(self, rhs: Self) -> Bool:
        return self.value >= rhs.value

    fn __eq__(self, rhs: Self) -> Bool:
        return self.value == rhs.value

    fn __ne__(self, rhs: Self) -> Bool:
        return self.value != rhs.value

    # End implementation of Ord

    # Begin implementation of Arith
    # NOTE: By providing safe operations on Self, we can implement safe scalar
    # arithmetic by doing the broadcasting manually and then relying on our safe
    # operations.
    fn __add__(self, rhs: Self) -> Self:
        return self.value + rhs.value

    fn __sub__(self, rhs: Self) -> Self:
        return self.value - rhs.value

    fn __mul__(self, rhs: Self) -> Self:
        return self.value * rhs.value

    fn __truediv__(self, rhs: Self) -> Self:
        return self.value / (rhs.value + F4Utils.MASK_W)

    fn __pow__(self, rhs: Self) -> Self:
        return self.value ** (rhs.value + F4Utils.MASK_W)

    # End implementation of Arith

    # Begin implementation of ScalarArith
    fn __add__(self, rhs: F) -> Self:
        return self + Self.repeat(rhs)

    fn __radd__(self, lhs: F) -> Self:
        return Self.repeat(lhs) + self

    fn __sub__(self, rhs: F) -> Self:
        return self - Self.repeat(rhs)

    fn __rsub__(self, lhs: F) -> Self:
        return Self.repeat(lhs) - self

    fn __mul__(self, rhs: F) -> Self:
        return self * Self.repeat(rhs)

    fn __rmul__(self, lhs: F) -> Self:
        return Self.repeat(lhs) * self

    fn __truediv__(self, rhs: F) -> Self:
        return self / Self.repeat(rhs)

    fn __rtruediv__(self, lhs: F) -> Self:
        return Self.repeat(lhs) / self

    fn __pow__(self, rhs: F) -> Self:
        return self ** Self.repeat(rhs)

    fn __rpow__(self, lhs: F) -> Self:
        return Self.repeat(lhs) ** self

    # End implementation of ScalarArith

    # Begin implementation of VectorOps
    # NOTE: For some of these, we use the dictionary constructor to avoid
    # having to pass through the sanitization step in our constructor when we take
    # in an F4.
    fn rotate_left(self) -> Self:
        """Rotate the vector left by one component."""
        return Self {value: self.value.shuffle[1, 2, 0, 3]()}

    fn rotate_right(self) -> Self:
        """Rotate the vector right by one component."""
        return Self {value: self.value.shuffle[2, 0, 1, 3]()}

    fn dot(self, other: Self) -> F:
        """Compute the dot product of two vectors."""
        return (self * other).value.reduce_add()

    fn cross(self, other: Self) -> Self:
        """Compute the cross product of two vectors."""
        return self.rotate_left() * other.rotate_right() - self.rotate_right() * other.rotate_left()

    fn mag_sq(self) -> F:
        """Compute the squared magnitude of a vector."""
        return pow(self.value, 2).reduce_add()

    fn mag(self) -> F:
        """Compute the magnitude of a vector."""
        return sqrt(self.mag_sq())

    # End implementation of VectorOps

    # Begin implementation of Random
    @staticmethod
    fn rand() -> Self:
        return Self(
            random_float64(0.0, 1.0),
            random_float64(0.0, 1.0),
            random_float64(0.0, 1.0),
        )

    # End implementation of Random

    # Begin implementation of RandomNormal
    @staticmethod
    fn randn() -> Self:
        return Self(
            randn_float64(0.0, 1.0),
            randn_float64(0.0, 1.0),
            randn_float64(0.0, 1.0),
        )

    # End implementation of RandomNormal

    fn __neg__(self) -> Self:
        return Self {value: -self.value}

    fn sqrt(self) -> Self:
        return Self {value: sqrt(self.value)}

    fn sq(self) -> Self:
        return Self {value: pow(self.value, 2)}