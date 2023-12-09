trait HomAdd:
    """A trait for types closed under addition."""

    fn __add__(self, rhs: Self) -> Self:
        """Addition of two elements of the same type."""
        ...


trait HomSub:
    """A trait for types closed under subtraction."""

    fn __sub__(self, rhs: Self) -> Self:
        """Subtraction of two elements of the same type."""
        ...


trait HomMul:
    """A trait for types closed under multiplication."""

    fn __mul__(self, rhs: Self) -> Self:
        """Multiplication of two elements of the same type."""
        ...


trait HomDiv:
    """A trait for types closed under division."""

    fn __truediv__(self, rhs: Self) -> Self:
        """Division of two elements of the same type."""
        ...


trait HomPow:
    """A trait for types closed under exponentiation."""

    fn __pow__(self, rhs: Self) -> Self:
        """Power of two elements of the same type."""
        ...


trait HomArith(HomAdd, HomSub, HomMul, HomDiv, HomPow):
    """A trait for types closed under arithmetic operations."""

    ...
