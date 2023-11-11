from tensor import Tensor, TensorSpec, TensorShape
from utils.index import Index
from random import rand
from math import clamp, exp2
from python import PythonObject, Python
from memory.buffer import NDBuffer
from utils.list import DimList

fn simd_float_uint[
    W: Int, Float: DType.type, UInt: DType.type
](v: SIMD[Float, W]) -> SIMD[UInt, W]:
    """
    Convert a SIMD vector of float to uint by scaling by the floats by max value of the uint type
    and then casting to the uint type.
    """
    let max = (exp2[Float, 1](bitwidthof[UInt]()) - 1.0)
    return (max * v).cast[UInt]()


fn simd_uint_float[
    W: Int, Float: DType.type, UInt: DType.type
](v: SIMD[UInt, W]) -> SIMD[Float, W]:
    """
    Convert a SIMD vector of uint to float by casting to float and then dividing by the max value
    of the uint type.
    """
    let max = (exp2[Float, 1](bitwidthof[UInt]()) - 1.0)
    return v.cast[Float]() / max

fn to_numpy[H: Int, W: Int, C: Int](image: Image[H,W,C]) raises -> PythonObject:
    let np = Python.import_module("numpy")
    let np_image = np.zeros((H, W, C), np.float32)

    # We use raw pointers to efficiently copy the pixels to the numpy array
    let out_pointer = Pointer(
        __mlir_op.`pop.index_to_pointer`[
            _type=__mlir_type[`!kgen.pointer<scalar<f32>>`]
        ](
            SIMD[DType.index, 1](
                np_image.__array_interface__["data"][0].__index__()
            ).value
        )
    )
    let in_pointer = Pointer(
        __mlir_op.`pop.index_to_pointer`[
            _type=__mlir_type[`!kgen.pointer<scalar<f32>>`]
        ](SIMD[DType.index, 1](image.data.data().__as_index()).value)
    )

    for h in range(H):
      for w in range(W):
        for c in range(C):
            let index = c + W * (w + H * h)
            out_pointer.store(index, in_pointer[index])
        
    return np_image

fn from_numpy[H: Int, W: Int, C: Int](ndarray: PythonObject) raises -> Image[H,W,C]:
    let np = Python.import_module("numpy")
    let image = Image[H,W,C]()

    # We use raw pointers to efficiently copy the pixels to the numpy array
    let in_pointer = Pointer(
        __mlir_op.`pop.index_to_pointer`[
            _type=__mlir_type[`!kgen.pointer<scalar<f32>>`]
        ](
            SIMD[DType.index, 1](
                ndarray.__array_interface__["data"][0].__index__()
            ).value
        )
    )
    let out_pointer = Pointer(
        __mlir_op.`pop.index_to_pointer`[
            _type=__mlir_type[`!kgen.pointer<scalar<f32>>`]
        ](SIMD[DType.index, 1](image.data.data().__as_index()).value)
    )

    for h in range(H):
      for w in range(W):
        for c in range(C):
            let index = c + W * (w + H * h)
            out_pointer.store(index, in_pointer[index])
    
    return image

@value
struct Image[Ty: DType.type, H: Int, W: Int, C: Int]:
    var data: Tensor[Ty]

    fn __init__(inout self: Self) -> None:
        self.data = Tensor[Ty](TensorShape(H, W, C))

    fn write_png(self: Self, fname: String) raises -> None:
        let cv2: PythonObject = Python.import_module("cv2")
        let buffer = NDBuffer[3, DimList(H, W, C), Ty](self.data.data())
        with open(fname, "w") as f:
            cv2.imwrite(fname, buffer.)
            f.write("P3\n")
            f.write(String(H) + " " + W + "\n")
            f.write("255\n")
            for i in range(H):
                for j in range(W):
                    # TODO: Channels may not be a power of two?
                    let rgb = simd_float32_uint8(self.data.simd_load[C](i, j))
                    f.write(String(rgb[0]) + " " + rgb[1] + " " + rgb[2] + "\n")
            f.write("\n")

    # TODO: No regex, will have to roll my own parser :(
    fn read_ppm(self: Self, fname: String) raises -> None:
        with open(fname, "r") as f:
            let raw_file = f.read()
            let lines = raw_file
            assert line == "P3\n"
            line = f.readline()
            let dims = line.split(" ")
            assert dims[0] == String(H)
            assert dims[1] == String(W)
            line = f.readline()
            assert line == "255\n"
            for i in range(H):
                for j in range(W):
                    let rgb = f.readline().split(" ")
                    self.data.simd_store[C](i, j, simd_uint8_float64[C](rgb))
            line = f.readline()
            assert line == "\n"


fn write_ppm_gradient(fname: String) raises -> None:
    let H = 256
    let W = 256
    with open(fname, "w") as f:
        f.write("P3\n")
        f.write(String(H) + " " + W + "\n")
        f.write("255\n")
        for i in range(H):
            for j in range(W):
                let r = simd_float64_uint8(i / (W - 1))
                let g = simd_float64_uint8(j / (H - 1))
                f.write(String(r) + " " + g + " 0\n")
        f.write("\n")


fn main() raises -> None:
    # let H = 256
    # let W = 256
    # let C = 3

    # # Create the tensor of dimensions H, W, C
    # # and fill with random values.
    # let image = rand[DType.float32](H, W, C)

    # # Write the image to a file.
    # write_ppm_gradient("./image.ppm")
    # let f: Float64 = 256.6
    # print(clamp[DType.float64, 1](f, 0, 255).cast[DType.uint8]())
    for i in range(256):
        let f_in: Float64 = i / 255.0
        let i_out: UInt8 = simd_float64_uint8[1](f_in)
        let f_out: Float64 = simd_uint8_float64[1](i_out)
        print("f_in: ", f_in)
        print("i_out: ", i_out)
        print("f_out: ", f_out)
