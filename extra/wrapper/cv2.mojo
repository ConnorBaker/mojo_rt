from python import PythonObject, Python

from extra.wrapper.numpy import NDArray


@always_inline("nodebug")
fn imread[dtype: DType](path: String) raises -> NDArray[dtype]:
    # NOTE: As a result of implicit conversion, the type of the return value processed by
    # the NDArray constructor.
    return Python.import_module("cv2").imread(path)


@always_inline("nodebug")
fn imwrite[dtype: DType](path: String, ndarray: NDArray[dtype]) raises -> None:
    _ = Python.import_module("cv2").imwrite(path, ndarray.to_python())
