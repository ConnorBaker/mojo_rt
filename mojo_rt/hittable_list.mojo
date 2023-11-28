from .hit_record import HitRecord
from .hittable import Hittable
from .interval import Interval
from .ray3 import Ray3


@value
struct HittableList:
    """A list of hittable objects."""

    var value: DynamicVector[Hittable]

    fn __init__(inout self) -> None:
        self.value = DynamicVector[Hittable]()

    fn add(inout self, h: Hittable) -> None:
        self.value.push_back(h)

    # TODO: This is essentially a `map` followed by a `foldl1` to find the minimum.
    fn hit(self, r: Ray3, ray_t: Interval) -> HitRecord:
        """
        Return the closest hit record for the given ray in the given interval.

        If there is no hit, return HitRecord.BOGUS.
        """
        var rec = HitRecord.BOGUS
        var closest_so_far = ray_t.max

        for i in range(self.value.size):
            let new_interval = Interval(ray_t.min, closest_so_far)
            let new_rec = self.value[i](r, new_interval)
            if not new_rec.is_bogus():
                closest_so_far = new_rec.t
                rec = new_rec

        return rec
