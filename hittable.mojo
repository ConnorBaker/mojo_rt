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

    alias BOGUS: Self = Self {
        p: Point3 {value: Vec3 {value: NEGINF}},
        normal: Unit3 {value: Vec3 {value: NEGINF}},
        t: NEGINF,
        front_face: False,
    }

    @always_inline
    fn __init__(p: Point3, t: F, r: Ray3, outward_normal: Unit3) -> HitRecord:
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
        let front_face = r.direction.value.inner(outward_normal.value) < 0.0
        let normal = outward_normal if front_face else -outward_normal
        return Self {p: p, normal: normal, t: t, front_face: front_face}

    @always_inline
    fn __eq__(self, rhs: Self) -> Bool:
        return self.p == rhs.p and self.normal == rhs.normal and self.t == rhs.t and self.front_face == rhs.front_face

    @always_inline
    fn is_bogus(self) -> Bool:
        return self == Self.BOGUS
