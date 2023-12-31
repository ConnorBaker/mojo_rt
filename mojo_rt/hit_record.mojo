from .color import Color
from .material import Material, Lambertian
from .point3 import Point3
from .ray3 import Ray3
from .types import F, INF
from .unit3 import Unit3
from .vec3 import Vec3


@value
@register_passable("trivial")
struct HitRecord:
    """A record of a ray hitting a surface."""

    var p: Point3
    """The point at which the ray hit the surface."""
    var normal: Unit3
    """The normal of the surface at the point of intersection."""
    var t: F
    """The length of the ray at the point of intersection."""
    var front_face: Bool
    """Whether the ray hit the front or the back of the surface."""
    var material: Material
    """The material of the surface."""

    alias BOGUS: Self = Self {
        p: Point3 {value: Vec3 {value: INF}},
        normal: Unit3 {value: Vec3 {value: INF}},
        t: INF,
        front_face: False,
        material: Lambertian(Color(0.0, 0.0, 0.0)).get_material(),
    }
    """A bogus hit record."""

    fn __init__(p: Point3, t: F, r: Ray3, outward_normal: Unit3, material: Material) -> HitRecord:
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
        let front_face = r.direction.inner(outward_normal) < 0.0
        let normal = outward_normal if front_face else -outward_normal
        return Self {p: p, normal: normal, t: t, front_face: front_face, material: material}

    fn __eq__(self, rhs: Self) -> Bool:
        """Equality modulo material."""
        return self.p == rhs.p and self.normal == rhs.normal and self.t == rhs.t and self.front_face == rhs.front_face

    fn is_bogus(self) -> Bool:
        return self == Self.BOGUS
