from random import seed

from camera import Camera
from hittable_list import HittableList
from point3 import Point3
from renderer import RendererConfig, Renderer
from sphere import Sphere
from unit3 import Unit3
from vec3 import Vec3
from viewport import ViewportConfig, Viewport


fn main() raises -> None:
    seed(42)
    alias dtype = DType.float64
    let renderer_config = RendererConfig[dtype](samples_per_pixel=2, use_lambertian=True)
    let renderer = Renderer[dtype](renderer_config)
    let viewport_config = ViewportConfig[dtype](image_width=1600)
    let viewport = Viewport[dtype](viewport_config)
    let camera = Camera[dtype](renderer, viewport, 2)

    let green_horizon = Sphere[dtype](Point3[dtype](0.0, -100.5, -1.0), 100.0)
    let normal_mapped_sphere = Sphere[dtype](Point3[dtype](0.0, 0.0, -1.0), 0.5)

    var world = HittableList[dtype]()
    world.value.push_back(green_horizon)
    world.value.push_back(normal_mapped_sphere)

    camera.render(world)
