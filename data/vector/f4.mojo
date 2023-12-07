from types import F, F4


struct F4Utils:
    alias MASK_W = Self.mk(w=1.0)

    @staticmethod
    fn mk(x: F = 0.0, y: F = 0.0, z: F = 0.0, w: F = 0.0) -> F4:
        return F4(x, y, z, w)

    @staticmethod
    fn str3(val: F4) -> String:
        return "(x=" + str(val[0]) + ", y=" + val[1] + ", z=" + val[2] + ")"
