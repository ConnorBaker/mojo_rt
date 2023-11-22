from math import sqrt, pow

from hittable import HitRecord
from interval import Interval
from point3 import Point3
from ray3 import Ray3
from unit3 import Unit3
from vec3 import Vec3


@value
@register_passable("trivial")
struct Sphere[dtype: DType]:
    var center: Point3[dtype]
    var radius: SIMD[dtype, 1]
    # var material: Material

    @always_inline
    fn hit(
        self,
        r: Ray3[dtype],
        ray_t: Interval[dtype],
        inout rec: HitRecord[dtype],
    ) -> Bool:
        let oc: Vec3[dtype] = r.origin - self.center
        # TODO: Isn't r.direction.value.mag_sq() always 1.0?
        let a: SIMD[dtype, 1] = r.direction.value.mag_sq()
        let half_b: SIMD[dtype, 1] = oc.inner(r.direction.value)
        let c: SIMD[dtype, 1] = oc.mag_sq() - pow(self.radius, 2)
        let discriminant: SIMD[dtype, 1] = pow(half_b, 2) - a * c

        if discriminant < 0.0:
            return False

        # TODO: Factor out common constants like -half_b / a,
        # rewrite with FMA, and use min/max chains with the bounds
        # to avoid the branches.
        let sqrtd: SIMD[dtype, 1] = sqrt(discriminant)
        var root: SIMD[dtype, 1] = (-half_b - sqrtd) / a
        if not ray_t.surrounds(root):
            root = (-half_b + sqrtd) / a
            if not ray_t.surrounds(root):
                return False

        rec.t = root
        rec.p = r[root]
        # With spheres, we can compute the normal directly from the hit point
        # and the center of the sphere by dividing the vector between them by
        # the radius of the sphere.
        # We use Unit3's dict constructor here to avoid a redundant sqrt in
        # the Vec3 constructor which calculates the magnitude.
        let outward_normal: Unit3[dtype] = Unit3[dtype] {value: (rec.p - self.center) / self.radius}
        rec.set_face_normal(r, outward_normal)

        return True

    # @always_inline
    # fn intersects(self, o: Vec3, u: Vec3) -> Float32:
    #     """
    #     Returns the distance to the origin of the ray if it intersects the
    #     sphere, or a negative value otherwise.
    #     See https://en.wikipedia.org/wiki/Line-sphere_intersection.

    #     #### Parameters

    #     - `o`: The origin of the ray
    #     - `u`: The direction of the ray (must be normalized)
    #     """
    #     debug_assert(u.magnitude_sq() == 1.0, "Ray direction must be normalized")

    #     # The distance vector of the ray origin to the sphere center is used
    #     # multiple times, so we precompute it here
    #     let L = o - self.center
    #     let u_dot_L = u @ L
    #     let nabla = u_dot_L**2 - (L.magnitude_sq() - self.radius**2)

    #     # The ray misses the sphere and we can return early
    #     if nabla < 0:
    #         return neginf[DType.float32]()

    #     # We have either two unique points of intersection, or one point of
    #     # intersection (the ray grazes the sphere).
    #     let neg_u_dot_L = -u_dot_L
    #     let sqrt_nabla = sqrt(nabla)
    #     let d1 = neg_u_dot_L + sqrt_nabla
    #     let d2 = neg_u_dot_L - sqrt_nabla

    #     # We want the smallest positive distance
    #     let min_d = min(max(0.0, d1), max(0.0, d2))

    #     return neginf[DType.float32]() if min_d == 0.0 else min_d
