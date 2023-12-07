from data.point3 import Point3
from data.vector.unit3 import Unit3
from types import F


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
        return self.origin.value + self.direction.value * t
