from math import fma, mul
from memory.unsafe import bitcast
from python import PythonObject, Python
from tensor import TensorShape

from extra.algorithm.recursion_scheme import Anamorphism, Catamorphism, Hylomorphism

fn to_numpy_dtype(dtype: DType) raises -> PythonObject:
    let np = Python.import_module("numpy")
    if dtype == DType.bool:
        return np.bool_
    elif dtype == DType.int8:
        return np.int8
    elif dtype == DType.int16:
        return np.int16
    elif dtype == DType.int32:
        return np.int32
    elif dtype == DType.int64:
        return np.int64
    elif dtype == DType.uint8:
        return np.uint8
    elif dtype == DType.uint16:
        return np.uint16
    elif dtype == DType.uint32:
        return np.uint32
    elif dtype == DType.uint64:
        return np.uint64
    elif dtype == DType.bfloat16:
        return np.bfloat16
    elif dtype == DType.float16:
        return np.float16
    elif dtype == DType.float32:
        return np.float32
    elif dtype == DType.float64:
        return np.float64
    else:
        raise Error("Unsupported dtype: " + dtype.__str__())

@value
struct NDArray[dtype: DType]:
    """
    A wrapper for NumPy ndarrays.
    """

    var _ref: PythonObject
    var _data: DTypePointer[dtype]
    var shape: TensorShape
    var ndim: Int

    @always_inline("nodebug")
    fn __init__(inout self: Self, owned ndarray: PythonObject) raises -> None:
        self.shape = NDArray[dtype].get_shape(ndarray)
        self.ndim = NDArray[dtype].get_ndim(ndarray)
        self._data = NDArray[dtype].get_data(ndarray)
        self._ref = ndarray^

    @always_inline("nodebug")
    fn __moveinit__(inout self: Self, owned existing: Self) -> None:
        self._ref = existing._ref ^
        self._data = existing._data ^
        self.shape = existing.shape ^
        self.ndim = existing.ndim ^

    @always_inline("nodebug")
    fn __getitem__(self: Self, *index: Int) raises -> SIMD[dtype, 1]:
        return self._data.load(NDArray[dtype].flat_idx(self.shape, index))
    
    @always_inline("nodebug")
    fn __setitem__(inout self: Self, index: VariadicList[Int], value: SIMD[dtype, 1]) -> None:
        self._data.store(NDArray[dtype].flat_idx(self.shape, index), value)

    @staticmethod
    @always_inline("nodebug")
    fn flat_idx(shape: TensorShape, index: VariadicList[Int]) -> Int:
        debug_assert(
            shape.num_elements() == len(index),
            (
                "NDArray.flat_idx: number of indices does not match number of"
                " dimensions"
            ),
        )
        # Generalized indexing formula for N-dimensional arrays, where
        # N_i is the size of the i-th dimension, and n_i is the index
        # into the i-th dimension:
        #   offset = n_n + N_n * (n_{n-1} + N_{n-1} * (... n_1 + N_1 * (n_0) ...)
        # This is exactly a left fold (notice the indices are in reverse order).

        fn co_alg(idx: Int) raises -> Tuple[Int, Tuple[Int, Int]]:
            if idx >= shape.num_elements():
                raise Error()

            return (idx + 1, (shape[idx], index[idx]))

        fn alg(accum: Int, elem: Tuple[Int, Int]) -> Int:
            let dim_size = elem.get[0, Int]()
            let idx = elem.get[1, Int]()
            return fma(accum, dim_size, idx)

        let offset = Hylomorphism[Int, Tuple[Int, Int], Int](
            Anamorphism[Int, Tuple[Int, Int]](co_alg),
            Catamorphism[Tuple[Int, Int], Int](alg, 0),
        )(0)

        return offset

    @staticmethod
    @always_inline("nodebug")
    fn from_python(owned ndarray: PythonObject) raises -> Self:
        """
        Returns a NumPy ndarray from a Python object.
        """
        return NDArray[dtype](ndarray)

    @always_inline("nodebug")
    fn to_python(owned self: Self) raises -> PythonObject:
        """
        Returns a Python object representing the NumPy ndarray.
        """
        return self._ref


    @staticmethod
    @always_inline("nodebug")
    fn get_data(ndarray: PythonObject) raises -> DTypePointer[dtype]:
        """
        Returns a pointer to the data of a NumPy ndarray.
        """
        let raw_data = ndarray.__array_interface__["data"][0]
        let address = raw_data.__index__()
        let pointer = bitcast[dtype](address)
        return pointer

    @staticmethod
    @always_inline("nodebug")
    fn get_ndim(ndarray: PythonObject) raises -> Int:
        """
        Returns the number of dimensions of a NumPy ndarray.
        """
        return ndarray.ndim.to_float64().to_int()

    @staticmethod
    @always_inline("nodebug")
    fn get_shape(ndarray: PythonObject) raises -> TensorShape:
        """
        Returns the shape of a NumPy ndarray.
        """
        let ndim = NDArray[dtype].get_ndim(ndarray)
        let shape = ndarray.shape
        var dims = DynamicVector[Int](ndim)
        for i in range(ndim):
            dims.push_back(shape[i].to_float64().to_int())
        return TensorShape(dims)
