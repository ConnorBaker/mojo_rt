from math.math import sqrt
from memory.memory import memcpy
from os.env import setenv
from python.object import PythonObject
from python.python import Python
from utils.index import Index

from data.interval_2d import Interval2D
from types import DTYPE


@value
@register_passable("trivial")
struct Image:
    """Tensor is assumed to be of shape HW3."""

    alias IntensityBound: Interval2D = Interval2D(0.0, 1.0 - 1e-9)
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
    fn to_numpy_image(owned img: Tensor[DType.float32]) raises -> PythonObject:
        let np = Python.import_module("numpy")

        let shape = img.shape()
        let H = shape[0]
        let W = shape[1]
        let C = shape[2]

        let np_img = np.zeros((H, W, C), np.float32)

        # We use raw pointers to efficiently copy the pixels to the numpy array
        let out_pointer = Pointer(
            __mlir_op.`pop.index_to_pointer`[_type = __mlir_type[`!kgen.pointer<scalar<f32>>`]](
                SIMD[DType.index, 1](np_img.__array_interface__["data"][0].__index__()).value
            )
        )
        let in_pointer = Pointer(
            __mlir_op.`pop.index_to_pointer`[_type = __mlir_type[`!kgen.pointer<scalar<f32>>`]](
                SIMD[DType.index, 1](img.data().__as_index()).value
            )
        )

        _ = memcpy(out_pointer, in_pointer, H * W * C)
        return np_img

    @staticmethod
    fn write_render(owned img: Tensor[DTYPE]) raises -> None:
        """Writes the pixels to an EXR file."""
        _ = setenv("OPENCV_IO_ENABLE_OPENEXR", "1", True)
        let cv = Python.import_module("cv2")
        let img_f32 = Self.clamp(img).astype[DType.float32]()
        let np_img_f32 = Self.to_numpy_image(img_f32)
        let np_img_f32_bgr = cv.cvtColor(np_img_f32, cv.COLOR_RGB2BGR)
        let imwrite_flags: PythonObject = [
            int(cv.IMWRITE_EXR_TYPE),
            int(cv.IMWRITE_EXR_TYPE_FLOAT),
            int(cv.IMWRITE_EXR_COMPRESSION),
            int(cv.IMWRITE_EXR_COMPRESSION_PXR24),
        ]
        _ = cv.imwrite("./simple.exr", np_img_f32_bgr, imwrite_flags)
