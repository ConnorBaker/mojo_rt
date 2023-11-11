from vec3f import Vec3f
from sphere import Sphere

fn cast_ray(orig: Vec3f, dir: Vec3f, sphere: Sphere) -> Vec3f:
    # TODO: Mutability? Why?
    var dist: Float32 = 0
    if not sphere.intersects(orig, dir, dist):
        return Vec3f(0.02, 0.02, 0.02)

    return sphere.material.color