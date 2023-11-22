from math.limit import inf

from hittable import HitRecord
from interval import Interval
from ray3 import Ray3
from unit3 import Unit3
from vec3 import Vec3


@value
@register_passable("trivial")
struct RendererConfig[dtype: DType]:
    """
    Configuration for rendering.

    Includes general rendering settings.
    """

    var samples_per_pixel: Int
    """Number of samples to take per pixel; minimum of one. Higher values enable antialiasing."""
    var max_depth: Int
    """Maximum number of bounces for a ray."""
    var hit_interval: Interval[dtype]
    """The interval of distances to check for hits. Recommended to be non-zero to avoid self-intersection (which causes "shadow acne")."""
    var use_lambertian: Bool
    """Whether to use Lambertian diffuse shading."""

    @always_inline
    fn __init__(
        samples_per_pixel: Int = 10,
        max_depth: Int = 50,
        min_intersection_distance: SIMD[dtype, 1] = 1e-3,
        use_lambertian: Bool = True,
    ) -> Self:
        return Self {
            samples_per_pixel: samples_per_pixel,
            max_depth: max_depth,
            hit_interval: Interval(min_intersection_distance, inf[dtype]()),
            use_lambertian: use_lambertian,
        }


@value
@register_passable("trivial")
struct Renderer[dtype: DType]:
    """Functions for rendering."""

    var config: RendererConfig[dtype]

    var get_diffuse_ray: fn (HitRecord[dtype]) -> Ray3[dtype]
    """Function to get a diffuse ray from a hit record."""

    @always_inline
    fn __init__(config: RendererConfig[dtype]) -> Self:
        let get_diffuse_ray_fn: fn (HitRecord[dtype]) -> Ray3[dtype]
        if config.use_lambertian:
            get_diffuse_ray_fn = Self.get_diffuse_ray_lambertian
        else:
            get_diffuse_ray_fn = Self.get_diffuse_ray_uniform

        return Self {
            config: config,
            get_diffuse_ray: get_diffuse_ray_fn,
        }

    @staticmethod
    @always_inline
    fn get_diffuse_ray_uniform(rec: HitRecord[dtype]) -> Ray3[dtype]:
        """
        Gets a randomly sampled diffuse ray from the hit point.
        This is a uniform sampling.
        """
        let diffuse_ray_direction = Unit3[dtype].random_on_unit_hemisphere(rec.normal)
        return Ray3[dtype](rec.p, diffuse_ray_direction)

    @staticmethod
    @always_inline
    fn get_diffuse_ray_lambertian(rec: HitRecord[dtype]) -> Ray3[dtype]:
        """
        Gets a diffuse ray from the hit point using a non-uniform Lambertian sampling.
        """
        while True:
            let diffuse_ray_vec: Vec3[dtype] = rec.normal.value + Unit3[dtype].rand().value
            let mag = diffuse_ray_vec.mag()
            if mag != 0.0:
                let direction = Unit3[dtype] {value: diffuse_ray_vec / mag}
                return Ray3[dtype](rec.p, direction)
