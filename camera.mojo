from color import Color
from hittable import HitRecord
from hittable_list import HittableList
from point3 import Point3
from ray3 import Ray3
from renderer import Renderer
from unit3 import Unit3
from vec3 import Vec3
from viewport import Viewport


@always_inline
fn gradient_bg[dtype: DType](r: Ray3[dtype]) -> Color[dtype]:
    """
    Returns a gradient background.

    Use a linear blend: blended_value = (1 - a) * start_value + a * end_value.
    Also known as a linear interpolation or "lerp".
    """
    let unit_direction: Unit3[dtype] = r.direction
    let a = 0.5 * (unit_direction.value[1] + 1.0)
    let white = Color[dtype](1.0, 1.0, 1.0)
    let blue = Color[dtype](0.5, 0.7, 1.0)
    let gradient = (1.0 - a) * white.value + a * blue.value
    return gradient


@value
@register_passable("trivial")
struct Camera[dtype: DType]:
    var renderer: Renderer[dtype]
    """Functions for rendering."""
    var viewport: Viewport[dtype]
    """Functions for the viewport."""

    var samples_per_pixel: Int

    @always_inline
    fn __init__(
        viewport: Viewport[dtype],
        renderer: Renderer[dtype],
        samples_per_pixel: Int,
    ) -> Self:
        return Self {
            renderer: renderer,
            viewport: viewport,
            samples_per_pixel: samples_per_pixel,
        }

    fn render(self, world: HittableList[dtype]) raises -> None:
        # Lift the branching out of the loop and select our pixel filter.
        # NOTE: We cannot move this function to __init__ because it uses `self`.
        # TODO: Cannot use self.renderer.config.samples_per_pixel here for some reason; only self.samples_per_pixel works.
        let get_pixel_color_fn: fn (Point3[dtype], Point3[dtype], HittableList[dtype]) capturing -> Color[dtype] = (
            self.pixel_box_filter if self.samples_per_pixel > 1 else self.pixel_no_filter
        )
        let ray_origin: Point3[dtype] = self.viewport.config.camera_center

        with open("./simple.ppm", "w") as f:
            f.write("P3\n")
            f.write(String(self.viewport.config.image_width) + " " + self.viewport.config.image_height + "\n")
            f.write("255\n")

            for y in range(self.viewport.config.image_height):
                print_no_newline("Scanlines remaining:", self.viewport.config.image_height - y, "\r")
                for x in range(self.viewport.config.image_width):
                    let pixel_center: Point3[dtype] = self.viewport.get_pixel_center(x, y)
                    let pixel_color: Color[dtype] = get_pixel_color_fn(pixel_center, ray_origin, world)
                    pixel_color.write_color(
                        # f, self.renderer_config.samples_per_pixel
                        f,
                        self.samples_per_pixel,
                    )
            print_no_newline("Scanlines remaining:", 0, "\r\n")
        print("Done.")

    # @always_inline
    fn ray_color(self, r: Ray3[dtype], world: HittableList[dtype]) -> Color[dtype]:
        var rec = HitRecord[dtype].bogus()
        var current_ray = r
        var current_depth = 0
        var light_attenuation = 1.0

        while current_depth < self.renderer.config.max_depth and world.hit(
            current_ray, self.renderer.config.hit_interval, rec
        ):
            current_ray = self.renderer.get_diffuse_ray(rec)
            light_attenuation *= 0.5
            current_depth += 1

        # If we've exceeded the ray bounce limit, no more light is gathered
        if current_depth >= self.renderer.config.max_depth:
            return Color[dtype](0.0, 0.0, 0.0)

        # Otherwise, return the background color, attenuated by the light
        return light_attenuation * gradient_bg(current_ray).value

    # TODO: Can we inline these functions while still referencing them as... pointers?
    fn pixel_no_filter(
        self, pixel_center: Point3[dtype], ray_origin: Point3[dtype], world: HittableList[dtype]
    ) -> Color[dtype]:
        let ray_direction: Unit3[dtype] = (pixel_center - ray_origin).norm()
        let ray: Ray3[dtype] = Ray3[dtype](ray_origin, ray_direction)
        return self.ray_color(ray, world)

    fn pixel_box_filter(
        self, pixel_center: Point3[dtype], ray_origin: Point3[dtype], world: HittableList[dtype]
    ) -> Color[dtype]:
        """
        Used when `samples_per_pixel` > 1.
        This is a box filter.
        See more: https://my.eng.utah.edu/~cs6965/slides/pathtrace.pdf.
        """
        var pixel_color = SIMD[dtype, 4](0.0, 0.0, 0.0, 0.0)
        for _ in range(self.renderer.config.samples_per_pixel):
            # Gets a randomly sampled camera ray for the pixel at (x, y).
            let pixel_sample: Point3[dtype] = pixel_center.value + self.viewport.sample_pixel_square().value
            let ray_direction: Unit3[dtype] = (pixel_sample - ray_origin).norm()
            let ray: Ray3[dtype] = Ray3[dtype](ray_origin, ray_direction)
            pixel_color += self.ray_color(ray, world).value.value
        return Color[dtype] {value: Vec3[dtype] {value: pixel_color}}
