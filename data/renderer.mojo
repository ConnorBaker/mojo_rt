from math import rsqrt, isclose

from data.hit_record import HitRecord
from data.interval_2d import Interval2D
from data.ray3 import Ray3
from data.vector.unit3 import Unit3
from data.vector.vec3 import Vec3
from types import F


@value
@register_passable("trivial")
struct RendererConfig(Stringable):
    """
    Configuration for rendering.

    Includes general rendering settings.
    """

    var samples_per_pixel: Int
    """Number of samples to take per pixel; minimum of one. Higher values enable antialiasing."""
    var max_depth: Int
    """Maximum number of bounces for a ray."""
    var hit_interval: Interval2D
    """The interval of distances to check for hits. Recommended to be non-zero to avoid self-intersection (which causes "shadow acne")."""
    var use_lambertian: Bool
    """Whether to use Lambertian diffuse shading."""

    @staticmethod
    fn __init__(
        samples_per_pixel: Int = 10,
        max_depth: Int = 50,
        min_intersection_distance: F = 1e-3,
        use_lambertian: Bool = True,
    ) -> Self:
        return Self {
            samples_per_pixel: samples_per_pixel,
            max_depth: max_depth,
            hit_interval: Interval2D(min=min_intersection_distance),
            use_lambertian: use_lambertian,
        }

    fn __str__(self) -> String:
        return (
            "RendererConfig(samples_per_pixel="
            + str(self.samples_per_pixel)
            + ", max_depth="
            + str(self.max_depth)
            + ", hit_interval="
            + str(self.hit_interval)
            + ", use_lambertian="
            + str(self.use_lambertian)
            + ")"
        )


@value
@register_passable("trivial")
struct Renderer:
    """Functions for rendering."""

    @staticmethod
    fn get_diffuse_ray_uniform(rec: HitRecord) -> Ray3:
        """
        Gets a randomly sampled diffuse ray from the hit point.
        This is a uniform sampling.
        """
        let direction = Unit3.random_on_unit_hemisphere(rec.normal)
        return Ray3(rec.p, direction)

    @staticmethod
    fn get_diffuse_ray_lambertian(rec: HitRecord) -> Ray3:
        """
        Gets a diffuse ray from the hit point using a non-uniform Lambertian sampling.
        """

        @always_inline
        fn transform_fn(vec: Vec3) -> Vec3:
            return vec + rec.normal.value

        let direction = Unit3.sample_and_transform_while_mag_is_zero(Vec3.rand, transform_fn)
        return Ray3(rec.p, direction)
