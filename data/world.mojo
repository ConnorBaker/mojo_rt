from utils._optional import Optional
from utils.vector import InlinedFixedVector

from data.hit_record import HitRecord
from data.interval_2d import Interval2D
from data.point3 import Point3
from data.ray3 import Ray3
from data.shape.sphere import Sphere


@value
@register_passable("trivial")
struct World(Stringable):
    """Functions for rendering."""

    var spheres: VariadicList[Sphere]

    fn __init__() -> Self:
        return Self {
            spheres: VariadicList[Sphere](
                Sphere(Point3(y=-100.5, z=-1.0), 100.0),
                Sphere(Point3(z=-1.0), 0.5),
            )
        }

    fn __str__(self) -> String:
        var base: String = "WorldConfig(spheres=["
        for i in range(len(self.spheres)):
            base = base + str(self.spheres[i])
            if i < len(self.spheres) - 1:
                base += ", "
        base += "])"
        return base

    fn hit(self, ray: Ray3, interval: Interval2D) -> Optional[HitRecord]:
        """
        Return the closest hit record for the given ray in the given interval.
        """
        var rec = Optional[HitRecord](None)
        var closest_so_far = interval.max

        for sphere in self.spheres:
            let new_interval = Interval2D(interval.min, closest_so_far)
            let new_rec = sphere.hit(ray, new_interval)
            if new_rec:
                rec = new_rec
                closest_so_far = rec.value().t

        return rec
