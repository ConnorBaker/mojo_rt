from vec3f import Vec3f
from material import Material
from math import sqrt

@register_passable("trivial")
struct Sphere:
    var center: Vec3f
    var radius: Float32
    var material: Material

    fn __init__(c: Vec3f, r: Float32, material: Material) -> Self:
        return Sphere {center: c, radius: r, material: material}

    @always_inline
    fn intersects(self, orig: Vec3f, dir: Vec3f, inout dist: Float32) -> Bool:
        """This method returns True if a given ray intersects this sphere.
        And if it does, it writes in the `dist` parameter the distance to the
        origin of the ray.
        """
        let L = orig - self.center
        let a = dir @ dir
        let b = 2 * (dir @ L)
        let c = L @ L - self.radius * self.radius
        let discriminant = b * b - 4 * a * c
        if discriminant < 0:
            return False
        if discriminant == 0:
            dist = -b / 2 * a
            return True
        let q = -0.5 * (b + sqrt(discriminant)) if b > 0 else -0.5 * (
            b - sqrt(discriminant)
        )
        var t0 = q / a
        let t1 = c / q
        if t0 > t1:
            t0 = t1
        if t0 < 0:
            t0 = t1
            if t0 < 0:
                return False

        dist = t0
        return True