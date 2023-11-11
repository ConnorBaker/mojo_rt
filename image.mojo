from vec3f import Vec3f
from python import Python
from python.object import PythonObject

struct Image:
    # reference count used to make the object efficiently copyable
    var rc: Pointer[Int]
    # the two dimensional image is represented as a flat array
    var pixels: Pointer[Vec3f]
    var height: Int
    var width: Int

    fn __init__(inout self, height: Int, width: Int):
        self.height = height
        self.width = width
        self.pixels = Pointer[Vec3f].alloc(self.height * self.width)
        self.rc = Pointer[Int].alloc(1)
        self.rc.store(1)

    fn __copyinit__(inout self, other: Self):
        other._inc_rc()
        self.pixels = other.pixels
        self.rc = other.rc
        self.height = other.height
        self.width = other.width

    fn __del__(owned self):
        self._dec_rc()

    fn _get_rc(self) -> Int:
        return self.rc.load()

    fn _dec_rc(self):
        let rc = self._get_rc()
        if rc > 1:
            self.rc.store(rc - 1)
            return
        self._free()

    fn _inc_rc(self):
        let rc = self._get_rc()
        self.rc.store(rc + 1)

    fn _free(self):
        self.rc.free()
        self.pixels.free()

    @always_inline
    fn set(self, row: Int, col: Int, value: Vec3f) -> None:
        self.pixels.store(self._pos_to_index(row, col), value)

    @always_inline
    fn _pos_to_index(self, row: Int, col: Int) -> Int:
        # Convert a (rol, col) position into an index in the underlying linear storage
        return row * self.width + col

    def to_numpy_image(self) -> PythonObject:
        let np = Python.import_module("numpy")
        let np_image = np.zeros((self.height, self.width, 3), np.float32)

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
            ](SIMD[DType.index, 1](self.pixels.__as_index()).value)
        )

        for row in range(self.height):
            for col in range(self.width):
                let index = self._pos_to_index(row, col)
                for dim in range(3):
                    out_pointer.store(
                        index * 3 + dim, in_pointer[index * 4 + dim]
                    )

        return np_image


    def save(self: Self, fname: String) -> None:
        let plt = Python.import_module("matplotlib.pyplot")
        # Clamp to make sure the image is in the [0, 1] range
        let img = self.to_numpy_image().clip(0.0, 1.0)
        plt.imsave(fname, img)


def load_image(fname: String) -> Image:
    let np = Python.import_module("numpy")
    let plt = Python.import_module("matplotlib.pyplot")

    let np_image = plt.imread(fname)
    let rows = np_image.shape[0].__index__()
    let cols = np_image.shape[1].__index__()
    let image = Image(rows, cols)

    let in_pointer = Pointer(
        __mlir_op.`pop.index_to_pointer`[
            _type=__mlir_type[`!kgen.pointer<scalar<f32>>`]
        ](
            SIMD[DType.index, 1](
                np_image.__array_interface__["data"][0].__index__()
            ).value
        )
    )
    let out_pointer = Pointer(
        __mlir_op.`pop.index_to_pointer`[
            _type=__mlir_type[`!kgen.pointer<scalar<f32>>`]
        ](SIMD[DType.index, 1](image.pixels.__as_index()).value)
    )
    for row in range(rows):
        for col in range(cols):
            let index = image._pos_to_index(row, col)
            for dim in range(3):
                out_pointer.store(
                    index * 4 + dim, in_pointer[index * 3 + dim]
                )
    return image

def render(image: Image) -> None:
    let np = Python.import_module("numpy")
    let plt = Python.import_module("matplotlib.pyplot")
    let colors = Python.import_module("matplotlib.colors")
    let dpi = 32
    let fig = plt.figure(1, [image.height // 10, image.width // 10], dpi)

    plt.imshow(image.to_numpy_image())
    plt.axis("off")
    plt.show()
