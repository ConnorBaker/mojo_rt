from math import sqrt
from vec3f import Vec3f


@value
@register_passable("trivial")
struct Material:
    var color: Vec3f
    var albedo: Vec3f
    var specular_component: Float32

    fn __init__(color: Vec3f) -> Material:
        return Material {color: color, albedo: Vec3f(0, 0, 0), specular_component: 0}


alias W = 1024
alias H = 768
let shiny_yellow = Material(Vec3f(0.95, 0.95, 0.4), Vec3f(0.7, 0.6, 0), 30.0)
let green_rubber = Material(Vec3f(0.3, 0.7, 0.3), Vec3f(0.9, 0.1, 0), 1.0)
