from point3 import Point3
from unit3 import Unit3

from types import F


@value
@register_passable("trivial")
struct Ray3:
    var origin: Point3
    var direction: Unit3

    fn __getitem__(self, t: F) -> Point3:
        """
        Returns the point at the given distance along the ray.
        """
        return self.origin.value + self.direction.value * t
