from random import seed

from mojo_rt.camera import Camera, CameraConfig
from mojo_rt.color import Color
from mojo_rt.hittable import Hittable
from mojo_rt.hittable_list import HittableList
from mojo_rt.material import Lambertian, Material
from mojo_rt.point3 import Point3
from mojo_rt.renderer import RendererConfig, Renderer
from mojo_rt.sphere import Sphere
from mojo_rt.viewport import ViewportConfig, Viewport


fn setup_world() -> HittableList:
    # Materials
    let material_ground: Material = Lambertian(Color(0.8, 0.8, 0.0)).get_material()
    let material_center: Material = Lambertian(Color(0.1, 0.2, 0.5)).get_material()

    # Hittables
    let ground_sphere: Hittable = Sphere(Point3(y=-100.5, z=-1.0), 100.0, material_ground).get_hittable()
    let center_sphere: Hittable = Sphere(Point3(z=-1.0), 0.5, material_center).get_hittable()

    # World
    var world = HittableList()
    world.add(ground_sphere)
    world.add(center_sphere)

    return world


fn setup_config() -> CameraConfig:
    alias renderer_config = RendererConfig(samples_per_pixel=2, use_lambertian=True)
    alias viewport_config = ViewportConfig(image_width=1600)
    alias config = CameraConfig(renderer_config, viewport_config)
    return config


fn do_render() raises -> None:
    alias config = setup_config()
    let camera = Camera[config]()
    let pixels = camera.render(setup_world())
    camera.write_render(pixels)


fn main() raises -> None:
    seed(42)
    do_render()
