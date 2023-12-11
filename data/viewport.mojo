from random import random_float64

from data.point3 import Point3
from data.vector.vec3 import Vec3
from types import F, DTYPE


@value
@register_passable("trivial")
struct ViewportConfig(Stringable):
    """
    Configuration for the viewfinder (pixels).

    aspect_ratio: Ratio of width to height.
    image_width: Width of the image in pixels.
    """

    var aspect_width: Int
    """Width of the image in pixels."""
    var aspect_height: Int
    """Height of the image in pixels."""
    var aspect_ratio: Float64
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

    @staticmethod
    fn __init__(
        aspect_width: Int = 16,
        aspect_height: Int = 9,
        image_width: Int = 400,
    ) -> Self:
        """
        For a more thorough description of the math, see:
        https://raytracing.github.io/books/RayTracingInOneWeekend.html#rays,asimplecamera,andbackground/sendingraysintothescene.
        """

        let aspect_ratio: F = aspect_width / aspect_height
        let image_height: Int = (image_width * aspect_height) // aspect_width
        let camera_center = Point3.Origin

        # Determine viewport dimensions
        let focal_length: F = 1.0
        let viewport_height: F = 2.0
        let viewport_width: F = viewport_height * image_width / image_height

        # Calculate the vectors across the viewport edges
        let viewport_u = Vec3(x=viewport_width)
        let viewport_v = Vec3(y=-viewport_height)
        let viewport_avg: Vec3 = (viewport_u + viewport_v) / 2.0

        # Calculate the delta vectors from pixel to pixel
        let delta_u: Vec3 = viewport_u / image_width
        let delta_v: Vec3 = viewport_v / image_height
        let delta_avg: Vec3 = (delta_u + delta_v) / 2.0

        # Calculate the location of the upper-left pixel
        let viewport_upper_left: Point3 = camera_center - Point3(z=focal_length) - viewport_avg
        let loc_00: Point3 = viewport_upper_left.value + delta_avg

        return Self {
            aspect_width: aspect_width,
            aspect_height: aspect_height,
            aspect_ratio: aspect_ratio,
            image_width: image_width,
            image_height: image_height,
            camera_center: camera_center,
            loc_00: loc_00,
            delta_u: delta_u,
            delta_v: delta_v,
        }

    fn __str__(self) -> String:
        return (
            "ViewportConfig(aspect_width="
            + str(self.aspect_width)
            + ", aspect_height="
            + str(self.aspect_height)
            + ", aspect_ratio="
            + str(self.aspect_ratio)
            + ", image_width="
            + str(self.image_width)
            + ", image_height="
            + str(self.image_height)
            + ", camera_center="
            + str(self.camera_center)
            + ", loc_00="
            + str(self.loc_00)
            + ", delta_u="
            + str(self.delta_u)
            + ", delta_v="
            + str(self.delta_v)
            + ")"
        )


@value
@register_passable("trivial")
struct Viewport:
    """Functions for the viewport."""

    @staticmethod
    fn get_pixel_center(config: ViewportConfig, x: Int, y: Int) -> Point3:
        """Gets the center of the pixel at (x, y)."""
        return config.delta_v.fma(F(y), config.delta_u.fma(F(x), config.loc_00.value))

    @staticmethod
    fn sample_pixel_square(config: ViewportConfig) -> Point3:
        """Returns a random point in the square surrounding a pixel at the origin."""
        let px: F = -0.5 * random_float64()
        let py: F = -0.5 * random_float64()
        return config.delta_v.fma(py, config.delta_u * px)
