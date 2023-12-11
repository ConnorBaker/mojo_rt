from data.point3 import Point3
from data.vector.unit3 import Unit3
from data.vector.vec3 import Vec3
from types import DTYPE, F


@value
@register_passable("trivial")
struct Ray3(Stringable):
    """A ray in 3D space."""

    var origin: Point3
    var direction: Unit3

    fn __str__(self) -> String:
        return "Ray3" + "(origin=" + str(self.origin) + ", direction=" + str(self.direction) + ")"

    fn at(self, t: F) -> Point3:
        """
        Returns the point at the given distance along the ray.
        """
        return Point3(self.direction.value.fma(t, self.origin.value))
