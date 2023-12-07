trait Add:
    fn __add__(self, rhs: Self) -> Self:
        ...


trait Sub:
    fn __sub__(self, rhs: Self) -> Self:
        ...


trait Mul:
    fn __mul__(self, rhs: Self) -> Self:
        ...


trait Div:
    fn __truediv__(self, rhs: Self) -> Self:
        ...


trait Pow:
    fn __pow__(self, rhs: Self) -> Self:
        ...


trait Arith(Add, Sub, Mul, Div, Pow):
    """Representing types which are closed under arithmetic operations."""

    ...
