from ray3 import Ray3
from interval import Interval
from hit_record import HitRecord

# Function must be capturing because it is a struct method and closes
# over the struct instance.
alias Hittable = fn (Ray3, Interval, /) capturing -> HitRecord
