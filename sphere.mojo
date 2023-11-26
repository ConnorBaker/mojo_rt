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
    # var material: Material

    @always_inline
    fn hit(
        self,
        r: Ray3,
        ray_t: Interval,
        inout rec: HitRecord,
    ) -> Bool:
        let oc: Vec3 = r.origin - self.center
        # TODO: Isn't r.direction.value.mag_sq() always 1.0?
        let a: F = r.direction.value.mag_sq()
        let half_b: F = oc.inner(r.direction.value)
        let c: F = oc.mag_sq() - pow(self.radius, 2)
        let discriminant: F = pow(half_b, 2) - a * c

        if discriminant < 0.0:
            return False

        # TODO: Factor out common constants like -half_b / a,
        # rewrite with FMA, and use min/max chains with the bounds
        # to avoid the branches.
        let sqrtd: F = sqrt(discriminant)
        var root: F = (-half_b - sqrtd) / a
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
        let outward_normal: Unit3 = Unit3 {value: (rec.p - self.center) / self.radius}
        rec.set_face_normal(r, outward_normal)

        return True
