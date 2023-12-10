from math.math import sqrt
from utils.index import Index

from data.interval_2d import Interval2D
from types import DTYPE


@value
@register_passable("trivial")
struct Image:
    """Tensor is assumed to be of shape HW3."""

    alias IntensityBound: Interval2D = Interval2D(0.0, 1.0 - 1e-5)
    """The interval of valid color intensities."""

    @staticmethod
    fn clamp(owned img: Tensor[DTYPE]) -> Tensor[DTYPE]:
        """Clamps the image to the valid intensity interval (inplace)."""
        for i in range(img.num_elements()):
            img[i] = Self.IntensityBound.clamp(img[i])
        return img

    @staticmethod
    fn to_int(owned img: Tensor[DTYPE]) -> Tensor[DType.uint8]:
        return (256.0 * img).astype[DType.uint8]()

    @staticmethod
    fn linear_to_gamma(owned img: Tensor[DTYPE]) -> Tensor[DTYPE]:
        """Converts a linear image to a gamma corrected image (inplace)."""
        for i in range(img.num_elements()):
            img[i] = sqrt(img[i])
        return img

    @staticmethod
    fn gamma_to_linear(owned img: Tensor[DTYPE]) -> Tensor[DTYPE]:
        """Converts a gamma corrected image to a linear image."""
        img **= 2
        return img

    @staticmethod
    fn write_render(owned img: Tensor[DTYPE]) raises -> None:
        Self.write_render(Self.to_int(Self.clamp(Self.linear_to_gamma(img))))

    @staticmethod
    fn write_render(owned img: Tensor[DType.uint8]) raises -> None:
        """Writes the pixels to a PPM file."""
        let shape = img.shape()
        let H = shape[0]
        let W = shape[1]
        let C = shape[2]

        with open("./simple.ppm", "w") as f:
            f.write("P3\n" + str(W) + " " + H + "\n255\n")

            # Write the pixels in row-major order
            for h in range(H):
                for w in range(W):
                    for c in range(C):
                        f.write(str(img[Index(h, w, c)]))
                        f.write(" ")
                    f.write("t")
                f.write("\n")
