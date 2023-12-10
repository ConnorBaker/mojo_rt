from math import sqrt, rsqrt, isclose

from data.vector.vec3 import Vec3
from traits.hom.ord import HomOrd
from traits.ops.vector import VectorOps
from traits.random import Random, RandomNormal
from types import F4, F


@value
@register_passable("trivial")
struct Unit3(
    HomOrd,
    Random,
    RandomNormal,
    Stringable,
    VectorOps,
):
    """A 3D unit vector."""

    var value: Vec3

    # Begin constructors
    @staticmethod
    fn __init__(vec: Vec3) -> Self:
        var mag_sq = vec.mag_sq()
        if isclose(mag_sq, 0.0):
            # Add a small value to avoid division by zero.
            mag_sq += 1e-9
        return Self {value: vec * rsqrt(mag_sq)}

    # End constructors

    # Begin implementation of Stringable
    fn __str__(self) -> String:
        return "Unit3(value=" + str(self.value) + ")"

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

    # NOTE: For some of these, we use the dictionary constructor to avoid
    # having to pass through the sanitization step in our constructor when we take
    # in an F4.
    fn rotate_left(self) -> Self:
        """Rotate the vector left by one component."""
        return Self {value: self.value.rotate_left()}

    fn rotate_right(self) -> Self:
        """Rotate the vector right by one component."""
        return Self {value: self.value.rotate_right()}

    # Begin implementation of VectorOps
    # This exists so trying to take the cross product of a Unit3 with a Vec3
    # doesn't cause the Vec3 to be coerced into a Unit3.
    fn reflect(self, other: Vec3) -> Vec3:
        return self.value.reflect(other)

    fn reflect(self, other: Self) -> Self:
        return self.value.reflect(other)

    fn dot(self, other: Vec3) -> F:
        """Compute the dot product of two vectors."""
        return self.value.dot(other)

    fn dot(self, other: Self) -> F:
        """Compute the dot product of two vectors."""
        return self.dot(other.value)

    fn cross(self, other: Vec3) -> Vec3:
        """Compute the cross product of two vectors."""
        return self.rotate_left().value * other.rotate_right() - self.rotate_right().value * other.rotate_left()

    fn cross(self, other: Self) -> Self:
        """Compute the cross product of two vectors."""
        return self.cross(other.value)

    fn mag_sq(self) -> F:
        """Compute the squared magnitude of a vector."""
        return 1.0

    fn mag(self) -> F:
        """Compute the magnitude of a vector."""
        return 1.0

    # End implementation of VectorOps

    # Begin implementation of Random
    @staticmethod
    fn rand() -> Self:
        """Generates a random unit vector in 3D space."""
        return Self.sample_while_mag_is_zero(Vec3.rand)

    # End implementation of Random

    # Begin implementation of RandomNormal
    @staticmethod
    fn randn() -> Self:
        """
        Generates a random unit vector in 3D space which is uniformly distributed
        over the surface of a sphere.

        See: [How to generate random points on a sphere?](https://math.stackexchange.com/a/1585996)
        """
        return Self.sample_while_mag_is_zero(Vec3.randn)

    # End implementation of RandomNormal

    # Loose methods
    @staticmethod
    fn sample_while_mag_is_zero(sample_fn: fn () -> Vec3) -> Self:
        """Samples a unit vector in 3D space until it is not the zero vector."""

        @always_inline
        fn identity(v: Vec3) -> Vec3:
            return v

        return Self.sample_and_transform_while_mag_is_zero(sample_fn, identity)

    @staticmethod
    fn sample_and_transform_while_mag_is_zero(
        sample_fn: fn () -> Vec3,
        transform_fn: fn (Vec3, /) capturing -> Vec3,
    ) -> Self:
        """Samples a unit vector in 3D space until it is not the zero vector."""
        while True:
            let v = transform_fn(sample_fn())
            let mag_sq = v.mag_sq()
            # NOTE: Deferring the sqrt check until after the mag_sq check
            # is a micro-optimization.
            if not isclose(mag_sq, 0.0):
                return Self {value: v * rsqrt(mag_sq)}

    @staticmethod
    fn random_on_unit_hemisphere(normal: Self) -> Self:
        let u = Self.rand()
        return u if u.dot(normal) > 0.0 else -u

    # Negation is magnitude-preserving so we use the dictionary constructor
    fn __neg__(self) -> Self:
        return Self {value: -self.value}
