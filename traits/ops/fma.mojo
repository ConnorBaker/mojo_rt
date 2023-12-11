from types import F, F4


trait FMAOps:
    """Trait for fused multiply-add operations."""

    fn fma(self, b: F, c: F) -> Self:
        ...

    fn fma(self, b: F, c: F4) -> Self:
        ...

    fn fma(self, b: F, c: Self) -> Self:
        ...

    fn fma(self, b: F4, c: F) -> Self:
        ...

    fn fma(self, b: F4, c: F4) -> Self:
        ...

    fn fma(self, b: F4, c: Self) -> Self:
        ...

    fn fma(self, b: Self, c: F) -> Self:
        ...

    fn fma(self, b: Self, c: F4) -> Self:
        ...

    fn fma(self, b: Self, c: Self) -> Self:
        """Returns the fused multiply-add of this vector and the given vectors."""
        ...
