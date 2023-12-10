from math import sqrt, pow
from utils._optional import Optional

from data.hit_record import HitRecord
from data.interval_2d import Interval2D
from data.point3 import Point3
from data.ray3 import Ray3
from data.vector.unit3 import Unit3
from data.vector.vec3 import Vec3
from traits.hittable import Hittable
from types import F, NAN, FISNAN


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

    fn dist(self, ray: Ray3, interval: Interval2D) -> F:
        """
        Return the distance along the ray to the nearest intersection with the sphere,
        or NAN if there is no intersection.
        """
        # The constant factor of `a` is factored out throught the calculation
        # to avoid redundant multiplications and divisions because our ray contains
        # a unit normal vector.
        let oc: Vec3 = ray.origin - self.center
        let neg_half_b: F = -oc.dot(ray.direction.value)
        let c: F = oc.mag_sq() - pow(self.radius, 2)
        let discriminant: F = pow(neg_half_b, 2) - c

        if discriminant < 0.0:
            return NAN

        let sqrtd: F = sqrt(discriminant)
        let test_root_1: F = neg_half_b - sqrtd
        if interval.surrounds(test_root_1):
            return test_root_1

        let test_root_2: F = neg_half_b + sqrtd
        if interval.surrounds(test_root_2):
            return test_root_2

        return NAN

    fn hit_from_dist(self, ray: Ray3, dist: F) -> Optional[HitRecord]:
        """
        Return a hit record for the given ray, if it hits the sphere.
        """
        if FISNAN(dist):
            return Optional[HitRecord](None)

        # With spheres, we can compute the normal directly from the hit point
        # and the center of the sphere by dividing the vector between them by
        # the radius of the sphere.
        # NOTE: We use Unit3's dict constructor here to avoid a redundant sqrt in
        # the __init__ constructor which calculates the magnitude.
        let p = ray.at(dist)
        let outward_normal = Unit3 {value: (p - self.center) / self.radius}
        let rec = HitRecord(p, dist, ray, outward_normal)
        return Optional[HitRecord](rec)

    fn hit(self, ray: Ray3, interval: Interval2D) -> Optional[HitRecord]:
        """
        Return a hit record for the given ray, if it hits the sphere.
        """
        return self.hit_from_dist(ray, self.dist(ray, interval))
