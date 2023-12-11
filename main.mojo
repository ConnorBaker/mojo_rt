from builtin.io import _printf
from random import seed
from time import now

from data.camera import Camera, CameraConfig
from data.image import Image
from data.renderer import RendererConfig
from data.viewport import ViewportConfig
from data.world import World
from types import DTYPE


fn setup_config() -> CameraConfig:
    alias renderer_config = RendererConfig(samples_per_pixel=1, use_lambertian=False)
    alias viewport_config = ViewportConfig(image_width=4800)
    return CameraConfig(renderer_config, viewport_config)


fn do_render(seed_value: Int) raises -> Tensor[DTYPE]:
    seed(seed_value)
    alias camera = Camera[setup_config()]()
    alias world = World()
    print("Beginning render...")
    let time_start = now()
    let img = camera.render(world)
    let time_end = now()
    let time_elapsed_sec = (time_end - time_start) * 1e-9
    _printf("Rendered in %.3f seconds\n", time_elapsed_sec)
    return img


fn write_render(img: Tensor[DTYPE]) raises -> None:
    print("Writing render to file...")
    let time_start = now()
    Image.write_render(img)
    let time_end = now()
    let time_elapsed_sec = (time_end - time_start) * 1e-9
    _printf("Written in %.3f seconds\n", time_elapsed_sec)


fn main() raises -> None:
    write_render(do_render(42))
