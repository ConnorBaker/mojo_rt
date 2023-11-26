from math.limit import neginf

from point3 import Point3
from ray3 import Ray3
from unit3 import Unit3
from vec3 import Vec3
from types import F, NEGINF, INF


@value
@register_passable("trivial")
struct HitRecord:
    var p: Point3
    var normal: Unit3
    var t: F
    var front_face: Bool

    @always_inline
    fn __copy__(self) -> Self:
        return HitRecord {
            p: self.p,
            normal: self.normal,
            t: self.t,
            front_face: self.front_face,
        }

    @staticmethod
    @always_inline
    fn bogus() -> Self:
        let neginf_vec3 = Vec3 {value: NEGINF}
        return HitRecord {
            p: Point3 {value: neginf_vec3},
            normal: Unit3 {value: neginf_vec3},
            t: NEGINF,
            front_face: False,
        }

    @always_inline
    fn set_face_normal(inout self, r: Ray3, outward_normal: Unit3) -> None:
        """
        Sets the normal of the hit record to the outward normal of the
        surface hit by the ray. The outward normal is the normal that
        points in the same direction as the ray.
        """
        # NOTE: This is one way of keeping track of whether the ray
        # hit the front or the back of the surface. Another way is to
        # do it when coloring the surface. See
        # https://raytracing.github.io/books/RayTracingInOneWeekend.html#surfacenormalsandmultipleobjects/frontfacesversusbackfaces
        # for more details.
        self.front_face = r.direction.value.inner(outward_normal.value) < 0.0
        self.normal = outward_normal if self.front_face else -outward_normal

    @always_inline
    fn get_ray_uniform(self) -> Ray3:
        """
        Gets a randomly sampled diffuse ray from the hit point.
        This is a uniform sampling.
        """
        let diffuse_ray_direction = Unit3.random_on_unit_hemisphere(self.normal)
        return Ray3(self.p, diffuse_ray_direction)

    @always_inline
    fn get_ray_lambertian(self) -> Ray3:
        """
        Gets a diffuse ray from the hit point using a non-uniform Lambertian sampling.
        """
        while True:
            let diffuse_ray_vec: Vec3 = self.normal.value + Unit3.rand().value
            let mag = diffuse_ray_vec.mag()
            if mag != 0.0:
                let direction = Unit3 {value: diffuse_ray_vec / mag}
                return Ray3(self.p, direction)
