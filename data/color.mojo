from math import sqrt, pow

from data.ray3 import Ray3
from data.vector.unit3 import Unit3
from data.vector.vec3 import Vec3
from traits.hom.eq import HomEq
from types import F


@value
@register_passable("trivial")
struct Color(
    CollectionElement,
    HomEq,
    Stringable,
):
    """A color in RGB space."""

    var value: Vec3

    alias Black: Self = Self(0.0, 0.0, 0.0)
    """The color black."""
    alias White: Self = Self(1.0, 1.0, 1.0)
    """The color white."""
    alias SkyBlue: Self = Self(0.5, 0.7, 1.0)
    """The color of the sky."""

    @staticmethod
    fn __init__(x: F = 0.0, y: F = 0.0, z: F = 0.0) -> Self:
        return Vec3(x, y, z)

    @staticmethod
    fn sky_bg(r: Ray3) -> Self:
        """
        Returns a gradient background sky background color.

        Use a linear blend: blended_value = (1 - a) * start_value + a * end_value.
        Also known as a linear interpolation or "lerp".
        """
        let unit_direction: Unit3 = r.direction
        let a: F = 0.5 * (unit_direction.value.value[1] + 1.0)
        let gradient: Self = (1.0 - a) * Self.White.value + a * Self.SkyBlue.value
        return gradient

    # Begin Eq implementation
    fn __eq__(self, other: Self) -> Bool:
        return self.value == other.value

    fn __ne__(self, other: Self) -> Bool:
        return self.value != other.value

    # End Eq implementation

    # Begin Stringable implementation
    fn __str__(self) -> String:
        return "Color(value=" + str(self.value) + ")"

    # End Stringable implementation
