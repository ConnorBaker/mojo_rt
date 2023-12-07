from types import F4


trait VectorAdd:
    fn __add__(self, rhs: F4) -> Self:
        ...

    fn __radd__(self, lhs: F4) -> Self:
        ...


trait VectorSub:
    fn __sub__(self, rhs: F4) -> Self:
        ...

    fn __rsub__(self, lhs: F4) -> Self:
        ...


trait VectorMul:
    fn __mul__(self, rhs: F4) -> Self:
        ...

    fn __rmul__(self, lhs: F4) -> Self:
        ...


trait VectorDiv:
    fn __truediv__(self, rhs: F4) -> Self:
        ...

    fn __rtruediv__(self, lhs: F4) -> Self:
        ...


trait VectorPow:
    fn __pow__(self, rhs: F4) -> Self:
        ...

    fn __rpow__(self, lhs: F4) -> Self:
        ...


trait VectorArith(VectorAdd, VectorSub, VectorMul, VectorDiv, VectorPow):
    """Representing types which are closed under arithmetic operations where the other operand is a vector."""

    ...
