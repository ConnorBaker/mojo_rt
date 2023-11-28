from math import isclose

from .color import Color
from .hit_record import HitRecord
from .ray3 import Ray3
from .types import F, INF
from .unit3 import Unit3
from .vec3 import Vec3

alias Material = fn (
    Ray3,  # Ray in
    HitRecord, /,  # Hit record
) capturing -> Tuple[
    Bool,  # Did the ray scatter?
    Color,  # Attenuation
    Ray3,  # Scattered ray
]


@value
@register_passable("trivial")
struct Lambertian:
    var albedo: Color

    fn scatter(self, r_in: Ray3, rec: HitRecord, /) -> Tuple[Bool, Color, Ray3]:
        let scatter_direction: Vec3 = rec.normal + Unit3.rand()
        let scatter_direction_mag = scatter_direction.mag()
        let scatter_direction_unit: Unit3
        if isclose(scatter_direction_mag, 0.0):
            scatter_direction_unit = rec.normal
        else:
            scatter_direction_unit = Unit3 {value: scatter_direction / scatter_direction_mag}

        # NOTE: Lambertian always scatters.
        let did_scatter = True
        let scattered = Ray3(rec.p, scatter_direction_unit)
        let attenuation = self.albedo
        return (did_scatter, attenuation, scattered)


@value
@register_passable("trivial")
struct Metal:
    var albedo: Color

    fn scatter(self, r_in: Ray3, rec: HitRecord, /) -> Tuple[Bool, Color, Ray3]:
        """
        Gets a reflected ray from the hit point.
        """
        let reflected: Unit3 = Unit3(r_in.direction.reflect(rec.normal))
        let scattered = Ray3(rec.p, reflected)
        let did_scatter = True
        let attenuation = self.albedo
        return (did_scatter, attenuation, scattered)
