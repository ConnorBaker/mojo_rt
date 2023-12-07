from data.point3 import Point3
from data.ray3 import Ray3
from data.vector.unit3 import Unit3
from data.vector.vec3 import Vec3
from traits.eq import Eq
from types import F, NEGINF


@value
@register_passable("trivial")
struct HitRecord(Eq, Stringable):
    """A record of a ray hitting a surface."""

    var p: Point3
    """The point at which the ray hit the surface."""
    var normal: Unit3
    """The normal of the surface at the point of intersection."""
    var t: F
    """The length of the ray at the point of intersection."""
    var front_face: Bool
    """Whether the ray hit the front or the back of the surface."""

    alias BOGUS: Self = Self {
        p: Point3.Origin,
        normal: Unit3 {value: Vec3(NEGINF, NEGINF, NEGINF)},
        t: NEGINF,
        front_face: False,
    }

    fn is_bogus(self) -> Bool:
        return self == Self.BOGUS

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
        let front_face: Bool = r.direction.dot(outward_normal) < 0.0
        let normal: Unit3 = outward_normal if front_face else -outward_normal
        return Self {p: p, normal: normal, t: t, front_face: front_face}

    # Begin Eq implementation
    fn __eq__(self, rhs: Self) -> Bool:
        return self.p == rhs.p and self.normal == rhs.normal and self.t == rhs.t and self.front_face == rhs.front_face

    fn __ne__(self, rhs: Self) -> Bool:
        return not (self == rhs)

    # End Eq implementation

    # Begin Stringable implementation
    fn __str__(self) -> String:
        return (
            "HitRecord(p="
            + str(self.p)
            + ", normal="
            + str(self.normal)
            + ", t="
            + self.t
            + ", front_face="
            + self.front_face
            + ")"
        )
