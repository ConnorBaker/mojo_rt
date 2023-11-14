from extra.wrapper import cv2_test, numpy_test

# TODO: Address sanitizer and thread sanitizer. ASAN crashes on MacOS due to a missing symbol.
# TSAN is reporting stack overflow.

fn main() raises -> None:
    cv2_test.main()
    numpy_test.main()
