from math import sqrt, pow
from utils._optional import Optional

from data.hit_record import HitRecord
from data.interval_2d import Interval2D
from data.point3 import Point3
from data.ray3 import Ray3
from data.vector.unit3 import Unit3
from data.vector.vec3 import Vec3
from traits.hittable import Hittable
from types import F


@value
@register_passable("trivial")
struct Sphere(
    Hittable,
    Stringable,
):
    """A sphere in 3D space."""

    var center: Point3
    var radius: F

    fn __str__(self) -> String:
        return "Sphere(center=" + str(self.center) + ", radius=" + self.radius + ")"

    fn hit(self, r: Ray3, ray_t: Interval2D) -> Optional[HitRecord]:
        """
        Return a hit record for the given ray, if it hits the sphere. If not,
        return HitRecord.BOGUS.
        """
        let oc: Vec3 = r.origin - self.center
        # NOTE: The magnitude of the direction vector is always 1, so we can
        # ignore a throughout when multiplying or dividing by it.
        # let a: F = r.direction.value.mag_sq()
        # NOTE: We use negative half_b throughout, so compute it here to use it later.
        let neg_half_b: F = -oc.dot(r.direction.value)
        let c: F = oc.mag_sq() - pow(self.radius, 2)
        # This should be pow(half_b, 2), but the following is equivalent because squaring
        # a negative number yields a positive number.
        let discriminant: F = pow(neg_half_b, 2) - c  # * a, but a == 1

        # print("Calculating hit on", self, "for", r, "within bounds", ray_t)
        if discriminant < 0.0:
            return Optional[HitRecord](None)

        let sqrtd: F = sqrt(discriminant)
        let root: F
        let test_root_1: F = neg_half_b - sqrtd  # all divided by a, but a == 1
        let test_root_2: F = neg_half_b + sqrtd  # all divided by a, but a == 1
        if ray_t.surrounds(test_root_1):
            root = test_root_1
        elif ray_t.surrounds(test_root_2):
            root = test_root_2
        else:
            return Optional[HitRecord](None)

        let p = r.at(root)
        let t = root
        # With spheres, we can compute the normal directly from the hit point
        # and the center of the sphere by dividing the vector between them by
        # the radius of the sphere.
        # NOTE: We use Unit3's dict constructor here to avoid a redundant sqrt in
        # the __init__ constructor which calculates the magnitude.
        let outward_normal = Unit3 {value: (p - self.center) / self.radius}
        let rec = HitRecord(p, t, r, outward_normal)
        return Optional[HitRecord](rec)
