from builtin import file
from math import sqrt, pow

from interval import Interval
from vec3 import Vec3
from types import F
from camera import CameraConfig
from ray3 import Ray3
from unit3 import Unit3


@value
@register_passable("trivial")
struct Color:
    """A color in RGB space."""

    var value: Vec3

    alias INTENSITY_INTERVAL: Interval = Interval(0.0, 1.0 - 1e-5)
    alias WHITE: Self = Self {value: Vec3.repeat(1.0)}
    alias BLACK: Self = Self {value: Vec3.repeat(0.0)}
    alias SKY_BLUE: Self = Self {value: Vec3(0.5, 0.7, 1.0)}

    fn __init__(x: F = 0.0, y: F = 0.0, z: F = 0.0) -> Self:
        return Self {value: Vec3(x, y, z)}

    fn __add__(self, rhs: F) -> Self:
        return Self {value: self.value + rhs}

    fn __add__(self, rhs: Self) -> Self:
        return Self {value: self.value + rhs.value}

    fn __radd__(self, lhs: F) -> Self:
        return Self {value: self.value + lhs}

    fn __radd__(self, lhs: Self) -> Self:
        return Self {value: self.value + lhs.value}

    fn __sub__(self, rhs: F) -> Self:
        return Self {value: self.value - rhs}

    fn __sub__(self, rhs: Self) -> Self:
        return Self {value: self.value - rhs.value}

    fn __rsub__(self, lhs: F) -> Self:
        return Self {value: lhs - self.value}

    fn __rsub__(self, lhs: Self) -> Self:
        return Self {value: lhs.value - self.value}

    fn __mul__(self, rhs: F) -> Self:
        return Self {value: self.value * rhs}

    fn __mul__(self, rhs: Self) -> Self:
        return Self {value: self.value * rhs.value}

    fn __rmul__(self, lhs: F) -> Self:
        return Self {value: self.value * lhs}

    fn __rmul__(self, lhs: Self) -> Self:
        return Self {value: self.value * lhs.value}

    fn __truediv__(self, rhs: F) -> Self:
        return Self {value: self.value / rhs}

    fn __truediv__(self, rhs: Self) -> Self:
        return Self {value: self.value / rhs.value}

    fn __rtruediv__(self, lhs: F) -> Self:
        return Self {value: lhs / self.value}

    fn __rtruediv__(self, lhs: Self) -> Self:
        return Self {value: lhs.value / self.value}

    fn sample_scale(self, samples_per_pixel: Int) -> Self:
        return self.value / samples_per_pixel

    fn clamp(self) -> Self:
        return Self {value: Self.INTENSITY_INTERVAL.clamp(self.value.value)}

    fn to_int(self) -> SIMD[DType.uint8, 4]:
        return (256.0 * self).value.value.cast[DType.uint8]()

    fn linear_to_gamma(self) -> Self:
        return Self {value: sqrt(self.value.value)}

    fn gamma_to_linear(self) -> Self:
        return Self {value: pow(self.value.value, 2)}

    @staticmethod
    fn sky_bg(r: Ray3) -> Color:
        """
        Returns a gradient background sky background color.

        Use a linear blend: blended_value = (1 - a) * start_value + a * end_value.
        Also known as a linear interpolation or "lerp".
        """
        let unit_direction: Unit3 = r.direction
        let a = 0.5 * (unit_direction.value[1] + 1.0)
        let gradient = (1.0 - a) * Color.WHITE + a * Color.SKY_BLUE
        return gradient
