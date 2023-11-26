from math import sqrt, pow

from hittable import HitRecord
from interval import Interval
from point3 import Point3
from ray3 import Ray3
from unit3 import Unit3
from vec3 import Vec3

from types import F


@value
@register_passable("trivial")
struct Sphere:
    var center: Point3
    var radius: F

    @always_inline
    fn hit(
        self,
        r: Ray3,
        ray_t: Interval,
    ) -> HitRecord:
        let oc: Vec3 = r.origin - self.center
        # NOTE: The magnitude of the direction vector is always 1, so we can
        # ignore a throughout when multiplying or dividing by it.
        # let a: F = r.direction.value.mag_sq()
        # NOTE: We use negative half_b throughout, so compute it here to use it later.
        let neg_half_b: F = -oc.inner(r.direction.value)
        let c: F = oc.mag_sq() - pow(self.radius, 2)
        # This should be pow(half_b, 2), but the following is equivalent because squaring
        # a negative number yields a positive number.
        let discriminant: F = pow(neg_half_b, 2) - c  # * a, but a == 1

        if discriminant < 0.0:
            return HitRecord.BOGUS

        let sqrtd: F = sqrt(discriminant)
        let root: F
        let test_root_1: F = neg_half_b - sqrtd  # all divided by a, but a == 1
        let test_root_2: F = neg_half_b + sqrtd  # all divided by a, but a == 1
        if ray_t.surrounds(test_root_1):
            root = test_root_1
        elif ray_t.surrounds(test_root_2):
            root = test_root_2
        else:
            return HitRecord.BOGUS

        let p = r[root]
        let t = root
        # With spheres, we can compute the normal directly from the hit point
        # and the center of the sphere by dividing the vector between them by
        # the radius of the sphere.
        # We use Unit3's dict constructor here to avoid a redundant sqrt in
        # the Vec3 constructor which calculates the magnitude.
        let outward_normal: Unit3 = Unit3 {value: (p - self.center) / self.radius}
        return HitRecord(p, t, r, outward_normal)
