from types import F


trait HetScalarAdd:
    """A trait for types closed under addition with a scalar value."""

    fn __add__(self, rhs: F) -> Self:
        """Add a scalar value to this value."""
        ...

    fn __radd__(self, lhs: F) -> Self:
        """Add this value to a scalar value."""
        ...


trait HetScalarSub:
    """A trait for types closed under subtraction with a scalar value."""

    fn __sub__(self, rhs: F) -> Self:
        """Subtract a scalar value from this value."""
        ...

    fn __rsub__(self, lhs: F) -> Self:
        """Subtract this value from a scalar value."""
        ...


trait HetScalarMul:
    """A trait for types closed under multiplication with a scalar value."""

    fn __mul__(self, rhs: F) -> Self:
        """Multiply this value by a scalar value."""
        ...

    fn __rmul__(self, lhs: F) -> Self:
        """Multiply a scalar value by this value."""
        ...


trait HetScalarDiv:
    """A trait for types closed under division with a scalar value."""

    fn __truediv__(self, rhs: F) -> Self:
        """Divide this value by a scalar value."""
        ...

    fn __rtruediv__(self, lhs: F) -> Self:
        """Divide a scalar value by this value."""
        ...


trait HetScalarPow:
    """A trait for types closed under exponentiation with a scalar value."""

    fn __pow__(self, rhs: F) -> Self:
        """Raise this value to a scalar value."""
        ...

    fn __rpow__(self, lhs: F) -> Self:
        """Raise a scalar value to this value."""
        ...


trait HetScalarArith(HetScalarAdd, HetScalarSub, HetScalarMul, HetScalarDiv, HetScalarPow):
    """A trait for types closed under arithmetic with a scalar value."""

    ...
