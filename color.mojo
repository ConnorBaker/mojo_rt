from builtin import file

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

    @always_inline
    fn __init__(x: F = 0.0, y: F = 0.0, z: F = 0.0) -> Self:
        return Self {value: Vec3(x, y, z)}

    @always_inline
    fn sample_scale(self, samples_per_pixel: Int) -> Self:
        return self.value / samples_per_pixel

    @always_inline
    fn clamp(self) -> Self:
        return Self {value: Self.INTENSITY_INTERVAL.clamp(self.value.value)}

    @always_inline
    fn to_int(self) -> SIMD[DType.uint8, 4]:
        return (256.0 * self.value.value).cast[DType.uint8]()

    @staticmethod
    @always_inline
    fn sky_bg(r: Ray3) -> Color:
        """
        Returns a gradient background sky background color.

        Use a linear blend: blended_value = (1 - a) * start_value + a * end_value.
        Also known as a linear interpolation or "lerp".
        """
        let unit_direction: Unit3 = r.direction
        let a = 0.5 * (unit_direction.value[1] + 1.0)
        let gradient = (1.0 - a) * Color.WHITE.value + a * Color.SKY_BLUE.value
        return gradient
