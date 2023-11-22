from builtin import file, coroutine


@always_inline("nodebug")
fn write_ppm_header(f: FileHandle, image_width: Int, image_height: Int) raises -> None:
    """
    Write the header of a PPM file to the given file name and return the file handle.
    """
    f.write("P3\n")
    f.write(String(" ").join(image_width, image_height) + "\n")
    f.write("255\n")


@always_inline("nodebug")
fn write_ppm_line(f: FileHandle, r: Int, g: Int, b: Int) raises -> None:
    f.write(String(" ").join(r, g, b) + "\n")


fn main() raises -> None:
    alias image_width = 256
    alias image_height = 256

    let green_scale_factor = 255.999 / (image_height - 1.0)
    let red_scale_factor = 255.999 / (image_width - 1.0)

    with open("./temp.ppm", "w") as f:
        write_ppm_header(f, image_width, image_height)

        var img = InlinedFixedVector[Tuple[Int, Int], image_width * image_height](image_width * image_height)
        for j in range(image_height):
            let g = (j * green_scale_factor).to_int()
            for i in range(image_width):
                let r = (i * red_scale_factor).to_int()
                img.append((r, g))

        for thing in img:
            let r = thing.get[0, Int]()
            let g = thing.get[1, Int]()
            write_ppm_line(f, r, g, 0)

        f.write("\n")
