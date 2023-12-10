from algorithm.functional import parallelize
from math.math import divmod
from utils._optional import Optional
from utils.index import Index

from data.color import Color
from data.hit_record import HitRecord
from data.point3 import Point3
from data.ray3 import Ray3
from data.renderer import Renderer, RendererConfig
from data.vector.unit3 import Unit3
from data.vector.vec3 import Vec3
from data.viewport import Viewport, ViewportConfig
from data.world import World
from types import F4, F, DTYPE


@value
@register_passable("trivial")
struct CameraConfig(Stringable):
    """
    Utility struct to hold all the configuration for the camera.
    """

    var renderer: RendererConfig
    var viewport: ViewportConfig

    fn __str__(self) -> String:
        return "CameraConfig(renderer=" + str(self.renderer) + ", viewport=" + str(self.viewport) + ")"


@value
@register_passable("trivial")
struct Camera[config: CameraConfig](Stringable):
    """
    The camera, parameterized by the configuration.
    """

    fn __str__(self) -> String:
        return "Camera(config=" + str(config) + ")"

    fn render(self, world: World) -> Tensor[DTYPE]:
        """
        Render a scene of hittables.

        The output is a vector of colors, where each color represents the color of a pixel. The vector itself
        is a flattened 2D array in row-major order -- that means it can be written to a PPM file directly (header
        nonwithstanding).
        """
        alias H = config.viewport.image_height
        alias W = config.viewport.image_width
        alias C = 3
        var img = Tensor[DTYPE](H, W, C)

        @parameter
        fn _process(flattened_idx: Int) -> None:
            let quot_rem = divmod(flattened_idx, W)
            let h = quot_rem[0]
            let w = quot_rem[1]
            let color = self.get_pixel_color(w, h, world)

            @unroll
            for c in range(3):
                img[Index(h, w, c)] = color.value.value[c]

        parallelize[_process](H * W, 1)
        return img

    fn get_pixel_color(self, x: Int, y: Int, world: World) -> Color:
        """
        Gets the color of a pixel, given the pixel coordiantes.

        This is used when `samples_per_pixel` == 1.
        """
        let pixel_center: Point3 = Viewport.get_pixel_center(config.viewport, x, y)
        let pixel_color: Color

        # Since the filter we're using is known at compile time, we can use a conditional to
        # avoid the overhead of a branch in the loop.
        @parameter
        if config.renderer.samples_per_pixel > 1:
            pixel_color = self.pixel_box_filter(pixel_center, world)
        else:
            pixel_color = self.pixel_no_filter(pixel_center, world)

        return pixel_color

    fn pixel_no_filter(self, pixel_center: Point3, world: World) -> Color:
        """
        Gets the color of a pixel, given the pixel center and the origin of the camera ray.

        This is used when `samples_per_pixel` == 1.
        """
        alias ray_origin: Point3 = config.viewport.camera_center
        let ray_direction: Unit3 = (pixel_center - ray_origin).norm()
        let ray = Ray3(ray_origin, ray_direction)
        return self.get_ray_color(ray, world)

    fn pixel_box_filter(self, pixel_center: Point3, world: World) -> Color:
        """
        Gets the color of a pixel, given the  pixel coordiantes and the origin of the camera ray.

        This is used when `samples_per_pixel` > 1.
        This is a box filter; see more: https://my.eng.utah.edu/~cs6965/slides/pathtrace.pdf.
        """
        var pixel_color_raw: F4 = Color.Black.value.value
        for _ in range(config.renderer.samples_per_pixel):
            let sampled_pixel_center: Point3 = pixel_center.value + Viewport.sample_pixel_square(config.viewport).value
            pixel_color_raw += self.pixel_no_filter(sampled_pixel_center, world).value.value

        # Use the dictionary constructor for Vec3 because the operations prior will not change the last component.
        let pixel_color: Color = Vec3 {value: pixel_color_raw} / config.renderer.samples_per_pixel
        return pixel_color

    fn get_ray_color(self, ray: Ray3, world: World) -> Color:
        """
        Returns the color of the ray, which is the color of the closest object it hits.
        """
        var current_ray: Ray3 = ray
        var current_depth: Int = 0
        var light_attenuation: F = 1.0

        while current_depth < config.renderer.max_depth:
            let rec: Optional[HitRecord] = world.hit(current_ray, config.renderer.hit_interval)
            if not rec:
                break

            @parameter
            if config.renderer.use_lambertian:
                current_ray = Renderer.get_diffuse_ray_lambertian(rec.value())
            else:
                current_ray = Renderer.get_diffuse_ray_uniform(rec.value())

            light_attenuation *= 0.5
            current_depth += 1

        # If we've exceeded the ray bounce limit, no more light is gathered
        if current_depth >= config.renderer.max_depth:
            return Color.Black

        # Otherwise, return the background color, attenuated by the light
        return light_attenuation * Color.sky_bg(current_ray).value
