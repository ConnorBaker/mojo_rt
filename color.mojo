from builtin import file

from interval import Interval
from vec3 import Vec3
from types import F
from camera import CameraConfig


@value
@register_passable("trivial")
struct Color:
    """A color in RGB space."""

    var value: Vec3

    alias intensity_interval: Interval = Interval(0.0, 1.0 - 1e-5)

    @always_inline
    fn __init__(x: F = 0.0, y: F = 0.0, z: F = 0.0) -> Self:
        return Self {value: Vec3(x, y, z)}

    @always_inline
    fn sample_scale(self, samples_per_pixel: Int) -> Self:
        return self.value / samples_per_pixel

    @always_inline
    fn clamp(self) -> Self:
        return Self {value: self.intensity_interval.clamp(self.value.value)}

    @always_inline
    fn to_int(self) -> SIMD[DType.uint8, 4]:
        return (256.0 * self.value.value).cast[DType.uint8]()
