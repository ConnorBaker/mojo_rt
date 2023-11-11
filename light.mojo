from vec3f import Vec3f


@register_passable("trivial")
struct Light:
    var position: Vec3f
    var intensity: Float32

    fn __init__(p: Vec3f, i: Float32) -> Self:
        return Light {position: p, intensity: i}
