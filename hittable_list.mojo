from utils.vector import DynamicVector

from hittable import HitRecord
from interval import Interval
from ray3 import Ray3
from sphere import Sphere


# TODO: This is monomorphic because we don't have traits yet.
@value
struct HittableList[dtype: DType]:
    var value: DynamicVector[Sphere[dtype]]

    @always_inline
    fn __init__(inout self) -> None:
        self.value = DynamicVector[Sphere[dtype]]()

    @always_inline
    fn hit(
        self,
        r: Ray3[dtype],
        ray_t: Interval[dtype],
        inout rec: HitRecord[dtype],
    ) -> Bool:
        var temp_rec = rec.__copy__()
        var hit_anything = False
        var closest_so_far = ray_t.max

        for i in range(len(self.value)):
            let object = self.value[i]
            if object.hit(r, Interval(ray_t.min, closest_so_far), temp_rec):
                hit_anything = True
                closest_so_far = temp_rec.t
                # TODO: Does this actually update rec, or just the stack copy of the value?
                rec = temp_rec

        return hit_anything
