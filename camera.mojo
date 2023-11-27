from color import Color
from hittable import HitRecord
from hittable_list import HittableList
from point3 import Point3
from ray3 import Ray3
from renderer import Renderer, RendererConfig
from unit3 import Unit3
from vec3 import Vec3
from viewport import Viewport, ViewportConfig
from types import F4, mk_F4


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
        let ray_origin: Point3 = Self.config.viewport.camera_center
        var colors = InlinedFixedVector[Color](Self.config.viewport.image_width * Self.config.viewport.image_height)
        for y in range(Self.config.viewport.image_height):
            for x in range(Self.config.viewport.image_width):
                let pixel_center: Point3 = self.viewport.get_pixel_center(Self.config.viewport, x, y)
                let pixel_color: Color

                @parameter
                if Self.config.renderer.samples_per_pixel > 1:
                    pixel_color = self.pixel_box_filter(pixel_center, ray_origin, world)
                else:
                    pixel_color = self.pixel_no_filter(pixel_center, ray_origin, world)

                colors.append(pixel_color)

        return colors

    fn ray_color(self, r: Ray3, world: HittableList) -> Color:
        var rec = HitRecord.BOGUS
        var current_ray = r
        var current_depth = 0
        var light_attenuation = 1.0

        while current_depth < Self.config.renderer.max_depth:
            rec = world.hit(current_ray, Self.config.renderer.hit_interval)
            if rec.is_bogus():
                break

            @parameter
            if Self.config.renderer.use_lambertian:
                current_ray = self.renderer.get_diffuse_ray_lambertian(rec)
            else:
                current_ray = self.renderer.get_diffuse_ray_uniform(rec)

            light_attenuation *= 0.5
            current_depth += 1

        # If we've exceeded the ray bounce limit, no more light is gathered
        if current_depth >= Self.config.renderer.max_depth:
            return Color.BLACK

        # Otherwise, return the background color, attenuated by the light
        return light_attenuation * Color.sky_bg(current_ray)

    fn pixel_no_filter(self, pixel_center: Point3, ray_origin: Point3, world: HittableList) -> Color:
        let ray_direction: Unit3 = (pixel_center - ray_origin).norm()
        let ray: Ray3 = Ray3(ray_origin, ray_direction)
        return self.ray_color(ray, world)

    fn pixel_box_filter(self, pixel_center: Point3, ray_origin: Point3, world: HittableList) -> Color:
        """
        Used when `samples_per_pixel` > 1.
        This is a box filter.
        See more: https://my.eng.utah.edu/~cs6965/slides/pathtrace.pdf.
        """
        var pixel_color = Color.BLACK
        for _ in range(Self.config.renderer.samples_per_pixel):
            # Gets a randomly sampled camera ray for the pixel at (x, y).
            let pixel_sample: Point3 = pixel_center + self.viewport.sample_pixel_square(Self.config.viewport)
            let ray_direction: Unit3 = (pixel_sample - ray_origin).norm()
            let ray: Ray3 = Ray3(ray_origin, ray_direction)
            pixel_color = self.ray_color(ray, world) + pixel_color
        return pixel_color

    @staticmethod
    fn write_render(owned pixels: InlinedFixedVector[Color]) raises -> None:
        with open("./simple.ppm", "w") as f:
            f.write("P3\n")
            f.write(String(Self.config.viewport.image_width) + " " + Self.config.viewport.image_height + "\n")
            f.write("255\n")

            for pixel in pixels:
                let converted = (
                    pixel.sample_scale(Self.config.renderer.samples_per_pixel).linear_to_gamma().clamp().to_int()
                )
                f.write(String(converted[0]) + " " + converted[1] + " " + converted[2] + "\n")
