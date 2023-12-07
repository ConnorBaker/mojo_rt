from traits.eq import Eq


trait Ord(Eq):
    fn __lt__(self, other: Self) -> Bool:
        ...

    fn __le__(self, other: Self) -> Bool:
        ...

    fn __gt__(self, other: Self) -> Bool:
        ...

    fn __ge__(self, other: Self) -> Bool:
        ...
