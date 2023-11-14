from memory.unsafe import DTypePointer, bitcast
from python import PythonObject, Python

from extra.test import eq
from extra.wrapper.cv2_test import get_test_image
from extra.wrapper.numpy import NDArray


fn test_index_vs_ptr() raises -> None:
    let ndarray = get_test_image()
    let ptr = ndarray._data
    let shape = ndarray.shape
    eq("compare_index_vs_ptr: dimensions check", 3, ndarray.ndim)
    let H = shape[0]
    let W = shape[1]
    let C = shape[2]
    for h in range(H):
        for w in range(W):
            for c in range(C):
                let indexed_value = ndarray[h, w, c].to_int()
                let ptr_value = ptr.load((h * W * C) + (w * C) + c).to_int()
                eq("compare_index_vs_ptr: value check", indexed_value, ptr_value)
    
    print("compare_index_vs_ptr: OK")


fn main() raises -> None:
    test_index_vs_ptr()
