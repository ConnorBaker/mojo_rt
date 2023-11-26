from hittable import HitRecord
from interval import Interval
from ray3 import Ray3
from sphere import Sphere


# TODO: This is monomorphic because we don't have traits yet.
@value
struct HittableList:
    var value: DynamicVector[Sphere]

    @always_inline
    fn __init__(inout self) -> None:
        self.value = DynamicVector[Sphere]()

    @always_inline
    fn hit(
        self,
        r: Ray3,
        ray_t: Interval,
    ) -> HitRecord:
        var rec = HitRecord.BOGUS
        var closest_so_far = ray_t.max

        for i in range(len(self.value)):
            let temp_rec = self.value[i].hit(r, Interval(ray_t.min, closest_so_far))
            if not temp_rec.is_bogus():
                closest_so_far = temp_rec.t
                rec = temp_rec

        return rec
