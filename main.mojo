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
    let green_horizon = Sphere(Point3(y=-100.5, z=-1.0), 100.0).hit
    let normal_mapped_sphere = Sphere(Point3(z=-1.0), 0.5).hit

    # TODO: Replace with InlinedFixedVector
    var world = HittableList()
    world.add(green_horizon)
    world.add(normal_mapped_sphere)
    # TODO: Cannot instead create spheres and then access .hit inside world.add -- we recieve the following error:
    # /Users/connorbaker/Packages/mojo_rt/main.mojo:21:26: error: invalid call to 'push_back': method argument #0 cannot be converted from unknown overload to 'fn(Ray3, Interval, /) capturing -> HitRecord'
    #     world.value.push_back(green_horizon.hit)
    #     ~~~~~~~~~~~~~~~~~~~~~^~~~~~~~~~~~~~~~~~~
    # /Users/connorbaker/Packages/mojo_rt/main.mojo:21:27: note: try resolving the overloaded function first
    #     world.value.push_back(green_horizon.hit)
    #                         ^~~~~~~~~~~~~~~~~
    # TODO: Using @always_inline liberally causes the following error; I believe it has to do with us passing around a reference to a function that is inlined:
    # Assertion failed: (inserted.secoAssertion failed: (inserted.second && "expected region to containd && "expected region to contain uniquely named symbol operation uniquely named symbol operations"), function SymbolTable, filens"), function SymbolTable, file SymbolTable.cpp, line 137.
    # Assertion failed: (inserted.second && "expected region to contain uniquely named symbol operations"), function SymbolTable, file SymbolTable.cpp, line 137.
    # Please submit a bug report to https://github.com/modularml/mojo/issues and include the crash backtrace along with all the relevant source codes.
    # SymbolTable.cpp, line 137.
    # Assertion failed: (inserted.second && "expected region to contain uniquely named symbol operations"), function SymbolTable, file SymbolTable.cpp, line 137.
    # [32000:494073:20231127,135001.729329:ERROR directory_reader_posix.cc:42] opendir /Users/connorbaker/.modular/crashdb/attachments/7944c478-134f-4285-8d61-7711644dab44: No such file or directory (2)
    # [32000:494072:20231127,135001.729506:WARNING crash_report_exception_handler.cc:257] UniversalExceptionRaise: (os/kern) failure (5)
    # make: *** [build] Abort trap: 6

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
