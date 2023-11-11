from image import Image
from material import Material
from sphere import Sphere
from vec3f import Vec3f
from light import Light

from algorithm import parallelize
from math import max, pow
from math.limit import inf


fn reflect(I: Vec3f, N: Vec3f) -> Vec3f:
    return I - N * (I @ N) * 2.0


fn cast_ray(
    orig: Vec3f,
    dir: Vec3f,
    spheres: DynamicVector[Sphere],
    lights: DynamicVector[Light],
    bg: Image,
) -> Material:
    var point = Vec3f.zero
    var material = Material(Vec3f.zero)
    var N = Vec3f.zero
    if not scene_intersect(orig, dir, spheres, material, point, N):
        # Background
        # Given a direction vector `dir` we need to find a pixel in the image
        let x = dir[0]
        let y = dir[1]

        # Now map x from [-1,1] to [0,w-1] and do the same for y.
        let w = bg.width
        let h = bg.height
        let col = ((1.0 + x) * 0.5 * (w - 1)).to_int()
        let row = ((1.0 + y) * 0.5 * (h - 1)).to_int()
        return Material(bg.pixels[bg._pos_to_index(row, col)])

    var diffuse_light_intensity: Float32 = 0
    var specular_light_intensity: Float32 = 0
    for i in range(lights.size):
        let light_dir = (lights[i].position - point).normalize()
        diffuse_light_intensity += lights[i].intensity * max(0, light_dir @ N)
        specular_light_intensity += (
            pow(
                max(0.0, -reflect(-light_dir, N) @ dir),
                material.specular_component,
            )
            * lights[i].intensity
        )

    let result = material.color * diffuse_light_intensity * material.albedo.data[
        0
    ] + Vec3f(1.0, 1.0, 1.0) * specular_light_intensity * material.albedo.data[1]
    let result_max = max(result[0], max(result[1], result[2]))
    # Cap the resulting vector
    if result_max > 1:
        return result * (1.0 / result_max)
    return result


fn scene_intersect(
    orig: Vec3f,
    dir: Vec3f,
    spheres: DynamicVector[Sphere],
    inout material: Material,
    inout hit: Vec3f,
    inout N: Vec3f,
) -> Bool:
    var spheres_dist = inf[DType.float32]()

    for i in range(0, spheres.size):
        var dist: Float32 = 0
        if spheres[i].intersects(orig, dir, dist) and dist < spheres_dist:
            spheres_dist = dist
            hit = orig + dir * dist
            N = (hit - spheres[i].center).normalize()
            material = spheres[i].material

    return (spheres_dist != inf[DType.float32]()).__bool__()


fn create_image_with_spheres_and_specular_lights(
    spheres: DynamicVector[Sphere],
    lights: DynamicVector[Light],
    height: Int,
    width: Int,
    bg: Image,
) -> Image:
    let image = Image(height, width)

    @parameter
    fn _process_row(row: Int):
        let y = -((2.0 * row + 1) / height - 1)
        for col in range(width):
            let x = ((2.0 * col + 1) / width - 1) * width / height
            let dir = Vec3f(x, y, -1).normalize()
            image.set(row, col, cast_ray(Vec3f.zero, dir, spheres, lights, bg).color)

    parallelize[_process_row](height)

    return image
