from memory.unsafe import DTypePointer, bitcast
from python import PythonObject, Python

from extra.test import eq
from extra.wrapper.cv2 import imread, imwrite
from extra.wrapper.numpy import NDArray


fn get_test_image() raises -> NDArray[DType.uint8]:
    return imread[DType.uint8]("simple.png")


fn test_imread() raises -> None:
    let ndarray = get_test_image()
    let shape = ndarray.shape

    let expected_height = 192
    let expected_width = 256
    let expected_channels = 3

    eq("test_imread: dimensions check", 3, ndarray.ndim)
    eq("test_imread: height check", expected_height, shape[0])
    eq("test_imread: width check", expected_width, shape[1])
    eq("test_imread: channels check", expected_channels, shape[2])

fn test_imwrite() raises -> None:
    let ndarray = get_test_image()
    let filename = "test_imwrite.png"
    _ = imwrite(filename, ndarray)
    print("test_imwrite: OK")

fn test_imread_eq_imwrite() raises -> None:
    let test_imread_img = get_test_image()
    let test_imwrite_img = imread[DType.uint8]("test_imwrite.png")
    
    eq("test_imread_eq_imwrite: dimensions check", test_imread_img.ndim, test_imwrite_img.ndim)
    eq("test_imread_eq_imwrite: height check", test_imread_img.shape[0], test_imwrite_img.shape[0])
    eq("test_imread_eq_imwrite: width check", test_imread_img.shape[1], test_imwrite_img.shape[1])
    eq("test_imread_eq_imwrite: channels check", test_imread_img.shape[2], test_imwrite_img.shape[2])

fn main() raises -> None:
    test_imread()
    test_imwrite()
    test_imread_eq_imwrite()
