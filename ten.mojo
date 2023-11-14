from tensor import Tensor, TensorSpec, TensorShape
from random import rand
from math import clamp, exp2
from python import PythonObject, Python
from memory.buffer import NDBuffer
from utils.list import DimList
from memory import memcpy
import pointer

# fn get_tensor_ptr[dtype: DType](tensor: Tensor[dtype]) raises -> DTypePointer[dtype]:
#     """
#     Returns a pointer to the data of a Mojo tensor.
#     """
#     let index = tensor.data().__as_index()
#     let scalar_index = SIMD[DType.index, 1](index).value
#     let ptr = DTypePointer[dtype](
#         __mlir_op.`pop.index_to_pointer`[_type = dtype_to_mlir(dtype)](scalar_index)
#     )
#     return ptr


# fn simd_float_uint[
#     width: Int, float: DType, uint: DType
# ](v: SIMD[float, width]) -> SIMD[uint, width]:
#     """
#     Convert a SIMD vector of float to uint by scaling by the floats by max value of the uint type
#     and then casting to the uint type.
#     """
#     let max = exp2[float, 1](bitwidthof[uint]()) - 1.0
#     return (max * v).cast[uint]()


# fn simd_uint_float[
#     width: Int, float: DType, uint: DType
# ](v: SIMD[uint, width]) -> SIMD[float, width]:
#     """
#     Convert a SIMD vector of uint to float by casting to float and then dividing by the max value
#     of the uint type.
#     """
#     let max = exp2[float, 1](bitwidthof[uint]()) - 1.0
#     return v.cast[float]() / max


# fn tensor_to_numpy[
#     dtype: DType, H: Int, W: Int, C: Int
# ](tensor: Tensor[dtype]) raises -> PythonObject:
#     """
#     Converts a Mojo tensor to a NumPy ndarray.
#     """
#     let np = Python.import_module("numpy")
#     alias numpy_dtype = dtype_to_numpy(dtype)
#     let ndarray = np.zeros((H, W, C), numpy_dtype)
#     let ndarray_ptr = get_ndarray_ptr[dtype](ndarray)
#     let tensor_ptr = get_tensor_ptr[dtype](tensor)
#     for h in range(H):
#         for w in range(W):
#             for c in range(C):
#                 let index = c + W * (w + H * h)
#                 let val = tensor_ptr.load(index)
#                 ndarray_ptr.store(index, val)
#     return ndarray


# fn numpy_to_tensor[
#     dtype: DType, H: Int, W: Int, C: Int
# ](ndarray: PythonObject) raises -> Tensor[dtype]:
#     """
#     Converts a NumPy ndarray to a Mojo tensor.
#     """
#     let np = Python.import_module("numpy")
#     let tensor = Tensor[dtype](TensorShape(H, W, C))
#     let ndarray_ptr = get_ndarray_ptr[dtype](ndarray)
#     # let tensor_ptr = get_tensor_ptr[dtype](tensor)
#     # for h in range(H):
#     #     for w in range(W):
#     #         for c in range(C):
#     #             let index = c + W * (w + H * h)
#     #             let val = ndarray_ptr.load(index)
#     #             tensor_ptr.store(index, val)
#     return tensor


# @value
# struct Image[dtype: DType, H: Int, W: Int, C: Int]:
#     var data: Tensor[dtype]

#     fn __init__(inout self: Self) -> None:
#         self.data = Tensor[dtype](TensorShape(H, W, C))

#     fn write_png(self: Self, fname: String) raises -> None:
#         let cv2: PythonObject = Python.import_module("cv2")
#         let ndarray = tensor_to_numpy[dtype, H, W, C](self.data)
#         _ = cv2.imwrite(fname, ndarray)

#     @staticmethod
#     fn read_png(fname: String) raises -> Self:
#         let cv2: PythonObject = Python.import_module("cv2")
#         let ndarray = cv2.imread(fname)
#         let tensor = numpy_to_tensor[dtype, H, W, C](ndarray)
#         return Self(tensor)


fn read_image[dtype: DType](fname: String) raises -> Tensor[dtype]:
    let cv2: PythonObject = Python.import_module("cv2")
    let ndarray = cv2.imread(fname)
    let ndarray_ptr = pointer.to_ndarray[dtype](ndarray)

    let height = ndarray.shape[0].to_float64().to_int()
    let width = ndarray.shape[1].to_float64().to_int()
    let channels = ndarray.shape[2].to_float64().to_int()

    let tensor = Tensor[dtype](TensorShape(height, width, channels))
    let tensor_ptr = tensor.data()

    print("Copying", height * width * channels, "elements.")

    # memcpy(tensor_ptr, ndarray_ptr, height * width * channels)

    # Manual copy -- sometimes memcpy doesn't work and the tensor is all zeros.
    for h in range(height):
        for w in range(width):
            for c in range(channels):
                let index = (h * width + w) * channels + c
                let val = ndarray_ptr.load(index)
                print("Index: ", index)
                print("Value: ", val)
                # TODO: Including the print statement with array access causes the copy to work.
                # Perhaps the 
                print("Actual: ", ndarray[h][w][c])
                tensor_ptr.store(index, val)

                # print("Index: ", index)
                # print("Value: ", ndarray_ptr.load(index))
                # print("Actual: ", ndarray[h][w][c])
    return tensor


fn main() raises -> None:
    let t = read_image[DType.uint8]("simple.png")
    print(t)
    # alias H = 192
    # alias W = 256
    # alias C = 3

    # let cv2: PythonObject = Python.import_module("cv2")
    # let ndarray = cv2.imread("simple.png")
    # print("Shape: ", ndarray.shape)
    # print("DType: ", ndarray.dtype)
    # print("First triplet of each row by index: ")
    # for h in range(H):
    #     print("Row:", h)
    #     print_no_newline("Value: [")
    #     for c in range(C):
    #         print_no_newline(" ")
    #         print_no_newline(ndarray[h][0][c])
    #     print(" ]")

    # let ndarray_ptr: DTypePointer[DType.uint8] = pointer.to_ndarray[DType.uint8](
    #     ndarray
    # )
    # print("Address:", ndarray_ptr.__as_index())
    # print("First triplet of each row by pointer: ")
    # for h in range(H):
    #     print("Row:", h)
    #     print_no_newline("Value: [")
    #     for c in range(C):
    #         print_no_newline(" ")
    #         print_no_newline(ndarray_ptr.load(h * W * C + c))
    #     print(" ]")

    # print("Modifying first triplet of each row by pointer: ")
    # for h in range(H):
    #     for c in range(C):
    #         let val = clamp(ndarray_ptr.load(h * W * C + c) + 1, 0, 255)
    #         ndarray_ptr.store(h * W * C + c, val)

    # print("First triplet of each row by pointer: ")
    # for h in range(H):
    #     print("Row:", h)
    #     print_no_newline("Value: [")
    #     for c in range(C):
    #         print_no_newline(" ")
    #         print_no_newline(ndarray_ptr.load(h * W * C + c))
    #     print(" ]")

    # print("First triplet of each row by index: ")
    # for h in range(H):
    #     print("Row:", h)
    #     print_no_newline("Value: [")
    #     for c in range(C):
    #         print_no_newline(" ")
    #         print_no_newline(ndarray[h][0][c])
    #     print(" ]")
    # let tensor = Tensor[DType.uint8](TensorShape(H, W, C))
    # let tensor_ptr = tensor.data()
    # memcpy[DType.uint8](tensor_ptr, ndarray_ptr, H * W * C)
    # print(tensor)

    # for h in range(H):
    #     for w in range(W):
    #         for c in range(C):
    #             print("Element: ", h, w, c)
    #             print("Value: ", tensor[h, w, c])
    #             # let index = (h * W + w) * C + c
    #             # print("Index: ", index)
    #             # print("Value: ", ndarray_ptr.load(index))
    #             # print("Actual: ", ndarray[h][w][c])
