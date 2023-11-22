from point3 import Point3
from unit3 import Unit3


@value
@register_passable("trivial")
struct Ray3[dtype: DType]:
    var origin: Point3[dtype]
    var direction: Unit3[dtype]

    fn __getitem__(self, t: SIMD[dtype, 1]) -> Point3[dtype]:
        """
        Returns the point at the given distance along the ray.
        """
        return self.origin.value + self.direction.value * t
