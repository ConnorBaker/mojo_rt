from color import Color
from hittable import HitRecord
from hittable_list import HittableList
from point3 import Point3
from ray3 import Ray3
from renderer import Renderer, RendererConfig
from unit3 import Unit3
from vec3 import Vec3
from viewport import Viewport, ViewportConfig
from types import F4


@always_inline
fn gradient_bg(r: Ray3) -> Color:
    """
    Returns a gradient background.

    Use a linear blend: blended_value = (1 - a) * start_value + a * end_value.
    Also known as a linear interpolation or "lerp".
    """
    let unit_direction: Unit3 = r.direction
    let a = 0.5 * (unit_direction.value[1] + 1.0)
    let white = Color(1.0, 1.0, 1.0)
    let blue = Color(0.5, 0.7, 1.0)
    let gradient = (1.0 - a) * white.value + a * blue.value
    return gradient


@value
@register_passable("trivial")
struct CameraConfig:
    var renderer: RendererConfig
    var viewport: ViewportConfig


@value
@register_passable("trivial")
struct Camera[config: CameraConfig]:
    alias renderer: Renderer = Renderer()
    """Functions for rendering."""
    alias viewport: Viewport = Viewport()
    """Functions for the viewport."""

    fn render(self, world: HittableList) -> InlinedFixedVector[Color]:
        let ray_origin: Point3 = config.viewport.camera_center
        var colors = InlinedFixedVector[Color](config.viewport.image_width * config.viewport.image_height)

        for y in range(config.viewport.image_height):
            print_no_newline("Scanlines remaining:", config.viewport.image_height - y, "\r")
            for x in range(config.viewport.image_width):
                let pixel_center: Point3 = self.viewport.get_pixel_center(config.viewport, x, y)
                let pixel_color: Color

                @parameter
                if config.renderer.samples_per_pixel > 1:
                    pixel_color = self.pixel_box_filter(pixel_center, ray_origin, world)
                else:
                    pixel_color = self.pixel_no_filter(pixel_center, ray_origin, world)

                colors.append(pixel_color)

        print_no_newline("Scanlines remaining:", 0, "\r\n")
        print("Done.")

        return colors

    @always_inline
    fn ray_color(self, r: Ray3, world: HittableList) -> Color:
        var rec = HitRecord.bogus()
        var current_ray = r
        var current_depth = 0
        var light_attenuation = 1.0

        while current_depth < config.renderer.max_depth and world.hit(current_ray, config.renderer.hit_interval, rec):

            @parameter
            if config.renderer.use_lambertian:
                current_ray = self.renderer.get_diffuse_ray_lambertian(rec)
            else:
                current_ray = self.renderer.get_diffuse_ray_uniform(rec)

            light_attenuation *= 0.5
            current_depth += 1

        # If we've exceeded the ray bounce limit, no more light is gathered
        if current_depth >= config.renderer.max_depth:
            return Color(0.0, 0.0, 0.0)

        # Otherwise, return the background color, attenuated by the light
        return light_attenuation * gradient_bg(current_ray).value

    @always_inline
    fn pixel_no_filter(self, pixel_center: Point3, ray_origin: Point3, world: HittableList) -> Color:
        let ray_direction: Unit3 = (pixel_center - ray_origin).norm()
        let ray: Ray3 = Ray3(ray_origin, ray_direction)
        return self.ray_color(ray, world)

    @always_inline
    fn pixel_box_filter(self, pixel_center: Point3, ray_origin: Point3, world: HittableList) -> Color:
        """
        Used when `samples_per_pixel` > 1.
        This is a box filter.
        See more: https://my.eng.utah.edu/~cs6965/slides/pathtrace.pdf.
        """
        var pixel_color = F4(0.0, 0.0, 0.0, 0.0)
        for _ in range(config.renderer.samples_per_pixel):
            # Gets a randomly sampled camera ray for the pixel at (x, y).
            let pixel_sample: Point3 = pixel_center.value + self.viewport.sample_pixel_square(config.viewport).value
            let ray_direction: Unit3 = (pixel_sample - ray_origin).norm()
            let ray: Ray3 = Ray3(ray_origin, ray_direction)
            pixel_color += self.ray_color(ray, world).value.value
        return Color {value: Vec3 {value: pixel_color}}

    @staticmethod
    fn write_render(owned pixels: InlinedFixedVector[Color]) raises -> None:
        print("Writing render to file...")
        with open("./simple.ppm", "w") as f:
            f.write("P3\n")
            f.write(String(config.viewport.image_width) + " " + config.viewport.image_height + "\n")
            f.write("255\n")

            for pixel in pixels:
                let converted = pixel.sample_scale(config.renderer.samples_per_pixel).clamp().to_int()
                f.write(String(converted[0]) + " " + converted[1] + " " + converted[2] + "\n")

        print("Done.")
