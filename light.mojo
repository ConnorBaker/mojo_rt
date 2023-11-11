from vec3f import Vec3f


@value
@register_passable("trivial")
struct Light:
    var position: Vec3f
    var intensity: Float32
