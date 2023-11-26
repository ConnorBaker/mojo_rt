from random import seed

from camera import Camera, CameraConfig
from hittable_list import HittableList
from point3 import Point3
from renderer import RendererConfig, Renderer
from sphere import Sphere
from unit3 import Unit3
from vec3 import Vec3
from viewport import ViewportConfig, Viewport
from color import Color


fn setup_world() -> HittableList:
    let green_horizon = Sphere(Point3(0.0, -100.5, -1.0), 100.0)
    let normal_mapped_sphere = Sphere(Point3(0.0, 0.0, -1.0), 0.5)

    var world = HittableList()
    world.value.push_back(green_horizon)
    world.value.push_back(normal_mapped_sphere)

    return world


fn setup_config() -> CameraConfig:
    alias renderer_config = RendererConfig(samples_per_pixel=2, use_lambertian=True)
    alias viewport_config = ViewportConfig(image_width=1600)
    alias config = CameraConfig(renderer_config, viewport_config)
    return config


fn write_render[config: CameraConfig](owned pixels: InlinedFixedVector[Color]) raises -> None:
    print("Writing render to file...")
    with open("./simple.ppm", "w") as f:
        f.write("P3\n")
        f.write(String(config.viewport.image_width) + " " + config.viewport.image_height + "\n")
        f.write("255\n")

        for pixel in pixels:
            pixel.write_color(f, config.renderer.samples_per_pixel)

    print("Done.")


fn do_render() raises -> None:
    alias config = setup_config()
    let camera = Camera[config]()
    let pixels = camera.render(setup_world())
    write_render[config](pixels)


fn main() raises -> None:
    seed(42)
    do_render()
