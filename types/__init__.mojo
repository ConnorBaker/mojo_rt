from math.math import nan, isnan
from math.limit import inf, neginf, isinf, isfinite

alias DTYPE = DType.float64
alias F = Float64
alias F4 = SIMD[DTYPE, 4]
alias INF = inf[DTYPE]()
alias NEGINF = neginf[DTYPE]()
alias FISINF = isinf[DTYPE, 1]
alias F4ISINF = isinf[DTYPE, 4]
alias FISFINITE = isfinite[DTYPE, 1]
alias F4ISFINITE = isfinite[DTYPE, 4]
alias NAN = nan[DTYPE]()
alias FISNAN = isnan[DTYPE, 1]
alias F4ISNAN = isnan[DTYPE, 4]
