from image import Image, load_image
from vec3f import Vec3f
from light import Light
from sphere import Sphere
from material import shiny_yellow, green_rubber, H, W
from renderer import create_image_with_spheres_and_specular_lights

fn save_simple() -> None:
    let image = Image(192, 256)

    for row in range(image.height):
        for col in range(image.width):
            image.set(
                row,
                col,
                Vec3f(Float32(row) / image.height, Float32(col) / image.width, 0),
            )
    try:
        image.save("simple.png")
    except PythonException:
        print("Failed to save image")


def make_spheres() -> DynamicVector[Sphere]:
    var spheres = DynamicVector[Sphere]()
    spheres.push_back(Sphere(Vec3f(-3, 0, -16), 2, shiny_yellow))
    spheres.push_back(Sphere(Vec3f(-1.0, -1.5, -12), 2, green_rubber))
    spheres.push_back(Sphere(Vec3f(1.5, -0.5, -18), 3, green_rubber))
    spheres.push_back(Sphere(Vec3f(7, 5, -18), 4, shiny_yellow))
    return spheres

def make_lights() -> DynamicVector[Light]:
    var lights = DynamicVector[Light]()
    lights.push_back(Light(Vec3f(-20, 20, 20), 1.0))
    lights.push_back(Light(Vec3f(20, -20, 20), 0.5))
    return lights

# NOTE: Sometimes, when using `mojo run` the yellow circle won't show up.
fn main() raises -> None:
    let bg = load_image("oops_all_bash.png")
    let spheres = make_spheres()
    let lights = make_lights()
    let scene = create_image_with_spheres_and_specular_lights(spheres, lights, H, W, bg)
    scene.save("scene.png")