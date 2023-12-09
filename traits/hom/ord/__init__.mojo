from traits.hom.eq import HomEq


trait HomOrd(HomEq):
    """A trait for types which support comparison with itself."""

    fn __lt__(self, other: Self) -> Bool:
        """Returns `true` if `self` is strictly less than `other`."""
        ...

    fn __le__(self, other: Self) -> Bool:
        """Returns `true` if `self` is less than or equal to `other`."""
        ...

    fn __gt__(self, other: Self) -> Bool:
        """Returns `true` if `self` is strictly greater than `other`."""
        ...

    fn __ge__(self, other: Self) -> Bool:
        """Returns `true` if `self` is greater than or equal to `other`."""
        ...
