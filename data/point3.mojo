from data.vector.f4 import F4Utils
from data.vector.vec3 import Vec3
from traits.ord import Ord
from types import F4, F


@value
@register_passable("trivial")
struct Point3(Stringable, Ord):
    var value: Vec3

    alias Origin: Self = Self()

    @staticmethod
    fn __init__(x: F = 0.0, y: F = 0.0, z: F = 0.0) -> Self:
        return Vec3(x, y, z)

    fn __str__(self) -> String:
        return "Point3(value=" + str(self.value) + ")"

    # Begin implementation of Ord
    fn __lt__(self, rhs: Self) -> Bool:
        return self.value < rhs.value

    fn __le__(self, rhs: Self) -> Bool:
        return self.value <= rhs.value

    fn __gt__(self, rhs: Self) -> Bool:
        return self.value > rhs.value

    fn __ge__(self, rhs: Self) -> Bool:
        return self.value >= rhs.value

    fn __eq__(self, rhs: Self) -> Bool:
        return self.value == rhs.value

    fn __ne__(self, rhs: Self) -> Bool:
        return self.value != rhs.value

    # End implementation of Ord

    # Subtraction of points yields a vector
    fn __sub__(self, rhs: Self) -> Vec3:
        return self.value - rhs.value
