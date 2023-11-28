from .hit_record import HitRecord
from .interval import Interval
from .ray3 import Ray3

# Function must be capturing because it is a struct method and closes
# over the struct instance.
alias Hittable = fn (Ray3, Interval, /) capturing -> HitRecord
"""A function signature for a hittable object."""
