from types import F


trait ScalarAdd:
    fn __add__(self, rhs: F) -> Self:
        ...

    fn __radd__(self, lhs: F) -> Self:
        ...


trait ScalarSub:
    fn __sub__(self, rhs: F) -> Self:
        ...

    fn __rsub__(self, lhs: F) -> Self:
        ...


trait ScalarMul:
    fn __mul__(self, rhs: F) -> Self:
        ...

    fn __rmul__(self, lhs: F) -> Self:
        ...


trait ScalarDiv:
    fn __truediv__(self, rhs: F) -> Self:
        ...

    fn __rtruediv__(self, lhs: F) -> Self:
        ...


trait ScalarPow:
    fn __pow__(self, rhs: F) -> Self:
        ...

    fn __rpow__(self, lhs: F) -> Self:
        ...


trait ScalarArith(ScalarAdd, ScalarSub, ScalarMul, ScalarDiv, ScalarPow):
    """Representing types which are closed under arithmetic operations where the other operand is a scalar."""

    ...
