from random import random_float64

from point3 import Point3
from vec3 import Vec3

from types import F


@value
@register_passable("trivial")
struct ViewportConfig:
    """
    Configuration for the viewfinder (pixels).
    """

    var aspect_ratio: F
    """Ratio of width to height."""
    var image_width: Int
    """Width of the image in pixels."""
    var image_height: Int
    """Height of the image in pixels."""
    var camera_center: Point3
    """Center of the camera."""
    var loc_00: Point3
    """Location of the top-left pixel."""
    var delta_u: Vec3
    """Change in location of the pixel in the u direction."""
    var delta_v: Vec3
    """Change in location of the pixel in the v direction."""

    @always_inline
    fn __init__(
        aspect_ratio: F = 16.0 / 9.0,
        image_width: Int = 400,
    ) -> Self:
        """
        For a more thorough description of the math, see:
        https://raytracing.github.io/books/RayTracingInOneWeekend.html#rays,asimplecamera,andbackground/sendingraysintothescene.
        """

        let image_height: Int = (image_width / aspect_ratio).to_int()
        let camera_center = Point3(0.0, 0.0, 0.0)

        # Determine viewport dimensions
        let focal_length: F = 1.0
        let viewport_height: F = 2.0
        let viewport_width: F = viewport_height * image_width / image_height

        # Calculate the vectors across the viewport edges
        let viewport_u = Vec3(viewport_width, 0.0, 0.0)
        let viewport_v = Vec3(0.0, -viewport_height, 0.0)
        let viewport_avg: Vec3 = (viewport_u + viewport_v) / 2.0

        # Calculate the delta vectors from pixel to pixel
        let delta_u: Vec3 = viewport_u / image_width
        let delta_v: Vec3 = viewport_v / image_height
        let delta_avg: Vec3 = (delta_u + delta_v) / 2.0

        # Calculate the location of the upper-left pixel
        let viewport_upper_left: Point3 = camera_center - Point3(0.0, 0.0, focal_length) - viewport_avg
        let loc_00: Point3 = viewport_upper_left.value + delta_avg

        return Self {
            aspect_ratio: aspect_ratio,
            image_width: image_width,
            image_height: image_height,
            camera_center: camera_center,
            loc_00: loc_00,
            delta_u: delta_u,
            delta_v: delta_v,
        }


@value
@register_passable("trivial")
struct Viewport:
    """Functions for the viewport."""

    var config: ViewportConfig

    @always_inline
    fn get_pixel_center(self, x: Int, y: Int) -> Point3:
        """Gets the center of the pixel at (x, y)."""
        return self.config.loc_00.value + x * self.config.delta_u + y * self.config.delta_v

    @always_inline
    fn sample_pixel_square(self) -> Point3:
        """Returns a random point in the square surrounding a pixel at the origin."""
        let px: F = -0.5 * random_float64()
        let py: F = -0.5 * random_float64()
        return px * self.config.delta_u + py * self.config.delta_v
