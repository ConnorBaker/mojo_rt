from utils._optional import Optional

from data.hit_record import HitRecord
from data.interval_2d import Interval2D
from data.ray3 import Ray3
from types import F


@value
trait Hittable(CollectionElement):
    """A hittable object."""

    fn dist(self, ray: Ray3, interval: Interval2D) -> F:
        """Return the distance along the ray to the hittable, or NAN if it does it not intersect the object."""
        ...

    fn hit_from_dist(self, ray: Ray3, dist: F) -> Optional[HitRecord]:
        """Return the hit record for the given ray and distance, if the distance is not NAN."""
        ...

    fn hit(self, ray: Ray3, interval: Interval2D) -> Optional[HitRecord]:
        """Return the hit record for the given ray and interval."""
        ...
