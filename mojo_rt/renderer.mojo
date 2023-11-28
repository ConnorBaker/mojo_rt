from .hit_record import HitRecord
from .interval import Interval
from .ray3 import Ray3
from .types import F, INF
from .unit3 import Unit3
from .vec3 import Vec3


@value
@register_passable("trivial")
struct RendererConfig:
    """
    Configuration for rendering.

    Includes general rendering settings.
    """

    var samples_per_pixel: Int
    """Number of samples to take per pixel; minimum of one. Higher values enable antialiasing."""
    var max_depth: Int
    """Maximum number of bounces for a ray."""
    var hit_interval: Interval
    """The interval of distances to check for hits. Recommended to be non-zero to avoid self-intersection (which causes "shadow acne")."""
    var use_lambertian: Bool
    """Whether to use Lambertian diffuse shading."""

    fn __init__(
        samples_per_pixel: Int = 10,
        max_depth: Int = 50,
        min_intersection_distance: F = 1e-3,
        use_lambertian: Bool = True,
    ) -> Self:
        return Self {
            samples_per_pixel: samples_per_pixel,
            max_depth: max_depth,
            hit_interval: Interval(min_intersection_distance, INF),
            use_lambertian: use_lambertian,
        }


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
        let diffuse_ray_direction = Unit3.random_on_unit_hemisphere(rec.normal)
        return Ray3(rec.p, diffuse_ray_direction)

    @staticmethod
    fn get_diffuse_ray_lambertian(rec: HitRecord) -> Ray3:
        """
        Gets a diffuse ray from the hit point using a non-uniform Lambertian sampling.
        """
        while True:
            let diffuse_ray_vec: Vec3 = rec.normal + Unit3.rand()
            let mag = diffuse_ray_vec.mag()
            if mag != 0.0:
                let direction = Unit3 {value: diffuse_ray_vec / mag}
                return Ray3(rec.p, direction)
