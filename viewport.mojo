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

    fn __init__(
        aspect_ratio: F = 16.0 / 9.0,
        image_width: Int = 400,
    ) -> Self:
        """
        For a more thorough description of the math, see:
        https://raytracing.github.io/books/RayTracingInOneWeekend.html#rays,asimplecamera,andbackground/sendingraysintothescene.
        """

        let image_height = (image_width / aspect_ratio).to_int()
        let camera_center = Point3.ORIGIN

        # Determine viewport dimensions
        let focal_length = 1.0
        let viewport_height = 2.0
        let viewport_width = viewport_height * image_width / image_height

        # Calculate the vectors across the viewport edges
        let viewport_u = Vec3(x=viewport_width)
        let viewport_v = Vec3(y=-viewport_height)
        let viewport_avg = (viewport_u + viewport_v) / 2.0

        # Calculate the delta vectors from pixel to pixel
        let delta_u = viewport_u / image_width
        let delta_v = viewport_v / image_height
        let delta_avg = (delta_u + delta_v) / 2.0

        # Calculate the location of the upper-left pixel
        let viewport_upper_left: Point3 = camera_center - Point3(z=focal_length) - viewport_avg
        let loc_00: Point3 = viewport_upper_left + delta_avg

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

    @staticmethod
    fn get_pixel_center(config: ViewportConfig, x: Int, y: Int) -> Point3:
        """Gets the center of the pixel at (x, y)."""
        return config.loc_00 + x * config.delta_u + y * config.delta_v

    @staticmethod
    fn sample_pixel_square(config: ViewportConfig) -> Point3:
        """Returns a random point in the square surrounding a pixel at the origin."""
        let px: F = -0.5 * random_float64()
        let py: F = -0.5 * random_float64()
        return px * config.delta_u + py * config.delta_v
