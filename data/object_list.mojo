from utils._optional import Optional

from data.hit_record import HitRecord
from data.interval_2d import Interval2D
from data.ray3 import Ray3
from traits.hittable import Hittable
from types import F


@value
struct ObjectList[H: Hittable](Hittable):
    """A list of hittable objects."""

    var value: DynamicVector[H]

    fn __init__(inout self) -> None:
        self.value = DynamicVector[H]()

    fn add(inout self, h: H) -> None:
        self.value.push_back(h)

    # TODO: This is essentially a `map` followed by a `foldl1` to find the minimum.
    # fn hit(self, r: Ray3, ray_t: Interval2D) -> Maybe[HitRecord]:
    fn hit(self, r: Ray3, ray_t: Interval2D) -> Optional[HitRecord]:
        """
        Return the closest hit record for the given ray in the given interval.

        If there is no hit, return HitRecord.BOGUS.
        """
        var rec = Optional[HitRecord](None)
        var closest_so_far: F = ray_t.max

        for i in range(self.value.size):
            let new_interval = Interval2D(ray_t.min, closest_so_far)
            let new_rec = self.value[i].hit(r, new_interval)
            if new_rec:
                rec = new_rec
                closest_so_far = rec.value().t

        return rec
