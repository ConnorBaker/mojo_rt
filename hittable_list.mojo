from hittable import Hittable
from hit_record import HitRecord
from interval import Interval
from ray3 import Ray3
from sphere import Sphere


@value
struct HittableList:
    # Workaround for not having a way to implement interfaces
    var value: DynamicVector[Hittable]

    fn __init__(inout self) -> None:
        self.value = DynamicVector[Hittable]()

    fn add(inout self, h: Hittable) -> None:
        self.value.push_back(h)

    fn hit(self, r: Ray3, ray_t: Interval) -> HitRecord:
        var rec = HitRecord.BOGUS
        var closest_so_far = ray_t.max

        for i in range(len(self.value)):
            let new_interval = Interval(ray_t.min, closest_so_far)
            let new_rec = self.value[i](r, new_interval)
            if not new_rec.is_bogus():
                closest_so_far = new_rec.t
                rec = new_rec

        return rec
