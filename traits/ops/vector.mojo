from types import F


trait VectorOps:
    fn rotate_left(self) -> Self:
        ...

    fn rotate_right(self) -> Self:
        ...

    fn dot(self, other: Self) -> F:
        ...

    fn cross(self, other: Self) -> Self:
        ...

    fn mag_sq(self) -> F:
        ...

    fn mag(self) -> F:
        ...
