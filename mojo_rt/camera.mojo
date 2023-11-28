from .color import Color
from .hit_record import HitRecord
from .hittable_list import HittableList
from .point3 import Point3
from .ray3 import Ray3
from .renderer import Renderer, RendererConfig
from .unit3 import Unit3
from .viewport import Viewport, ViewportConfig


@value
@register_passable("trivial")
struct CameraConfig:
    """
    Utility struct to hold all the configuration for the camera.
    """

    var renderer: RendererConfig
    var viewport: ViewportConfig


@value
@register_passable("trivial")
struct Camera[config: CameraConfig]:
    """
    The camera, parameterized by the configuration.
    """

    fn render(self, world: HittableList) -> DynamicVector[Color]:
        """
        Render a scene of hittables.

        The output is a vector of colors, where each color represents the color of a pixel. The vector itself
        is a flattened 2D array in row-major order -- that means it can be written to a PPM file directly (header
        nonwithstanding).
        """
        let ray_origin: Point3 = Self.config.viewport.camera_center
        var colors = DynamicVector[Color]()
        # To render out in row-major order, we need to fix the y coordinate and iterate over x.
        for y in range(Self.config.viewport.image_height):
            for x in range(Self.config.viewport.image_width):
                let pixel_center: Point3 = Viewport.get_pixel_center(Self.config.viewport, x, y)
                let pixel_color: Color

                # Since the filter we're using is known at compile time, we can use a conditional to
                # avoid the overhead of a branch in the loop.
                @parameter
                if Self.config.renderer.samples_per_pixel > 1:
                    pixel_color = self.pixel_box_filter(pixel_center, ray_origin, world)
                else:
                    pixel_color = self.pixel_no_filter(pixel_center, ray_origin, world)

                colors.push_back(pixel_color)

        return colors

    fn ray_color(self, r: Ray3, world: HittableList) -> Color:
        """
        Returns the color of the ray, which is the color of the closest object it hits.
        """
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
                current_ray = Renderer.get_diffuse_ray_lambertian(rec)
            else:
                current_ray = Renderer.get_diffuse_ray_uniform(rec)

            light_attenuation *= 0.5
            current_depth += 1

        # If we've exceeded the ray bounce limit, no more light is gathered
        if current_depth >= Self.config.renderer.max_depth:
            return Color.BLACK

        # Otherwise, return the background color, attenuated by the light
        return light_attenuation * Color.sky_bg(current_ray)

    fn pixel_no_filter(self, pixel_center: Point3, ray_origin: Point3, world: HittableList) -> Color:
        """
        Gets the color of a pixel, given the center of the pixel and the origin of the camera ray.

        This is used when `samples_per_pixel` == 1.
        """
        let ray_direction: Unit3 = Unit3(pixel_center - ray_origin)
        let ray: Ray3 = Ray3(ray_origin, ray_direction)
        return self.ray_color(ray, world)

    fn pixel_box_filter(self, pixel_center: Point3, ray_origin: Point3, world: HittableList) -> Color:
        """
        Gets the color of a pixel, given the center of the pixel and the origin of the camera ray.

        This is used when `samples_per_pixel` > 1.
        This is a box filter; see more: https://my.eng.utah.edu/~cs6965/slides/pathtrace.pdf.
        """
        var pixel_color = Color.BLACK
        for _ in range(Self.config.renderer.samples_per_pixel):
            # Gets a randomly sampled camera ray for the pixel at (x, y).
            # TODO: Pixel sample may be close enough to zero that we cannot norm it.
            let pixel_sample: Point3 = pixel_center + Viewport.sample_pixel_square(Self.config.viewport)
            let ray_direction: Unit3 = Unit3(pixel_sample - ray_origin)
            let ray: Ray3 = Ray3(ray_origin, ray_direction)
            pixel_color = self.ray_color(ray, world) + pixel_color
        return pixel_color / Self.config.renderer.samples_per_pixel

    @staticmethod
    fn write_render(pixels: DynamicVector[Color]) raises -> None:
        """Writes the pixels to a PPM file."""

        with open("./simple.ppm", "w") as f:
            f.write("P3\n")
            f.write(String(Self.config.viewport.image_width) + " " + Self.config.viewport.image_height + "\n")
            f.write("255\n")

            for i in range(pixels.size):
                let converted = pixels[i].linear_to_gamma().clamp().to_int()
                f.write(String(converted[0]) + " " + converted[1] + " " + converted[2] + "\n")
