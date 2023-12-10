from types import F


trait VectorOps:
    """Trait for vector operations."""

    fn reflect(self, other: Self) -> Self:
        """Reflects this vector in the hyperplane through the origin, orthogonal to the given vector."""
        ...

    fn dot(self, other: Self) -> F:
        """Returns the dot product of this vector and the given vector."""
        ...

    fn cross(self, other: Self) -> Self:
        """Returns the cross product of this vector and the given vector."""
        ...

    fn mag_sq(self) -> F:
        """Returns the square of the magnitude of this vector."""
        ...

    fn mag(self) -> F:
        """Returns the magnitude of this vector."""
        ...
