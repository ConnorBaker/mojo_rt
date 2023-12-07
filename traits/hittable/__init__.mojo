from utils._optional import Optional

from data.hit_record import HitRecord
from data.interval_2d import Interval2D
from data.ray3 import Ray3


@value
trait Hittable(CollectionElement):
    """A hittable object."""

    fn hit(self, ray: Ray3, interval: Interval2D) -> Optional[HitRecord]:
        """Return the hit record for the given ray and interval."""
        ...
