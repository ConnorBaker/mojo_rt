from .point3 import Point3
from .types import F
from .unit3 import Unit3


@value
@register_passable("trivial")
struct Ray3:
    """A ray in 3D space."""

    var origin: Point3
    var direction: Unit3

    fn __getitem__(self, t: F) -> Point3:
        """
        Returns the point at the given distance along the ray.
        """
        return self.origin + self.direction * t
