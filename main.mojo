from random import seed

from mojo_rt.camera import Camera, CameraConfig
from mojo_rt.hittable import Hittable
from mojo_rt.hittable_list import HittableList
from mojo_rt.point3 import Point3
from mojo_rt.renderer import RendererConfig, Renderer
from mojo_rt.sphere import Sphere
from mojo_rt.viewport import ViewportConfig, Viewport


fn setup_world() -> HittableList:
    let green_horizon: Hittable = Sphere(Point3(y=-100.5, z=-1.0), 100.0).hit()
    let normal_mapped_sphere: Hittable = Sphere(Point3(z=-1.0), 0.5).hit()

    var world = HittableList()
    world.add(green_horizon)
    world.add(normal_mapped_sphere)

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
