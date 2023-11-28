from math.limit import inf, neginf

alias DTYPE = DType.float64
alias F4 = SIMD[DTYPE, 4]
alias F = Float64
alias INF = inf[DTYPE]()
alias NEGINF = neginf[DTYPE]()


fn mk_F4(x: F = 0.0, y: F = 0.0, z: F = 0.0, w: F = 0.0) -> F4:
    return F4(x, y, z, w)
