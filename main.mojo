from random import seed, random_float64, random_si64

from data.camera import Camera, CameraConfig
from data.object_list import ObjectList
from data.point3 import Point3
from data.renderer import RendererConfig, Renderer
from data.shape.sphere import Sphere
from data.vector.vec3 import Vec3
from data.viewport import ViewportConfig, Viewport
from traits.hittable import Hittable


fn setup_world() -> ObjectList[Sphere]:
    var world = ObjectList[Sphere]()
    world.add(Sphere(Point3(y=-100.5, z=-1.0), 100.0))
    world.add(Sphere(Point3(z=-1.0), 0.5))
    return world


fn setup_config() -> CameraConfig:
    alias renderer_config = RendererConfig(samples_per_pixel=32, use_lambertian=False)
    alias viewport_config = ViewportConfig(image_width=1600)
    alias config = CameraConfig(renderer_config, viewport_config)
    return config


fn do_render() raises -> None:
    alias config = setup_config()
    alias camera = Camera[config]()
    let pixels = camera.render(setup_world())
    camera.write_render(pixels)


fn main() raises -> None:
    seed(42)
    do_render()
