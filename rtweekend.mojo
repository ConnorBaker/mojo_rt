import math

from types import F

alias pi = 3.1415926535897932385


@always_inline
fn degrees_to_radians(degrees: F) -> F:
    return degrees * pi / 180.0
