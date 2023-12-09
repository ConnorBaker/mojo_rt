trait HomEq:
    """A trait for types which support equality comparisons with itself."""

    fn __eq__(self, other: Self) -> Bool:
        """Returns `True` if `self` is equal to `other`."""
        ...

    fn __ne__(self, other: Self) -> Bool:
        """Returns `True` if `self` is not equal to `other`."""
        ...
