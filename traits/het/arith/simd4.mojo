from types import F4


trait HetSimd4Add:
    """A trait for types closed under addition with a SIMD4 value."""

    fn __add__(self, rhs: F4) -> Self:
        """Add a SIMD4 value to this value."""
        ...

    fn __radd__(self, lhs: F4) -> Self:
        """Add this value to a SIMD4 value."""
        ...


trait HetSimd4Sub:
    """A trait for types closed under subtraction with a SIMD4 value."""

    fn __sub__(self, rhs: F4) -> Self:
        """Subtract a SIMD4 value from this value."""
        ...

    fn __rsub__(self, lhs: F4) -> Self:
        """Subtract this value from a SIMD4 value."""
        ...


trait HetSimd4Mul:
    """A trait for types closed under multiplication with a SIMD4 value."""

    fn __mul__(self, rhs: F4) -> Self:
        """Multiply this value by a SIMD4 value."""
        ...

    fn __rmul__(self, lhs: F4) -> Self:
        """Multiply a SIMD4 value by this value."""
        ...


trait HetSimd4Div:
    """A trait for types closed under division with a SIMD4 value."""

    fn __truediv__(self, rhs: F4) -> Self:
        """Divide this value by a SIMD4 value."""
        ...

    fn __rtruediv__(self, lhs: F4) -> Self:
        """Divide a SIMD4 value by this value."""
        ...


trait HetSimd4Pow:
    """A trait for types closed under exponentiation with a SIMD4 value."""

    fn __pow__(self, rhs: F4) -> Self:
        """Raise this value to a SIMD4 value."""
        ...

    fn __rpow__(self, lhs: F4) -> Self:
        """Raise a SIMD4 value to this value."""
        ...


trait HetSimd4Arith(HetSimd4Add, HetSimd4Sub, HetSimd4Mul, HetSimd4Div, HetSimd4Pow):
    """A trait for types closed under arithmetic with a SIMD4 value."""

    ...
