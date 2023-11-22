from math.limit import neginf

from point3 import Point3
from ray3 import Ray3
from unit3 import Unit3
from vec3 import Vec3


@value
@register_passable("trivial")
struct HitRecord[dtype: DType]:
    var p: Point3[dtype]
    var normal: Unit3[dtype]
    var t: SIMD[dtype, 1]
    var front_face: Bool

    @always_inline
    fn __copy__(self) -> Self:
        return HitRecord[dtype] {
            p: self.p,
            normal: self.normal,
            t: self.t,
            front_face: self.front_face,
        }

    @staticmethod
    @always_inline
    fn bogus() -> Self:
        let neginf_vec3 = Vec3[dtype] {value: neginf[dtype]()}
        return HitRecord[dtype] {
            p: Point3[dtype] {value: neginf_vec3},
            normal: Unit3[dtype] {value: neginf_vec3},
            t: neginf[dtype](),
            front_face: False,
        }

    @always_inline
    fn set_face_normal(inout self, r: Ray3[dtype], outward_normal: Unit3[dtype]) -> None:
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
    fn get_ray_uniform(self) -> Ray3[dtype]:
        """
        Gets a randomly sampled diffuse ray from the hit point.
        This is a uniform sampling.
        """
        let diffuse_ray_direction = Unit3[dtype].random_on_unit_hemisphere(self.normal)
        return Ray3[dtype](self.p, diffuse_ray_direction)

    @always_inline
    fn get_ray_lambertian(self) -> Ray3[dtype]:
        """
        Gets a diffuse ray from the hit point using a non-uniform Lambertian sampling.
        """
        while True:
            let diffuse_ray_vec: Vec3[dtype] = self.normal.value + Unit3[dtype].rand().value
            let mag = diffuse_ray_vec.mag()
            if mag != 0.0:
                let direction = Unit3[dtype] {value: diffuse_ray_vec / mag}
                return Ray3[dtype](self.p, direction)
