@value
@register_passable("trivial")
struct Anamorphism[A: AnyType, B: AnyType]:
    """
    An anamorphism is the dual of a catamorphism. It takes a generator function
    and a seed value, and repeatedly applies the generator function to the
    current value to produce a new value and a new seed. The process terminates
    when the generator function raises an exception.
    """

    var co_alg: fn (A) raises capturing -> Tuple[A, B]

    @always_inline("nodebug")
    fn __call__(self: Self, initial: A) -> DynamicVector[B]:
        var _initial = initial
        var accumulated = DynamicVector[B]()
        try:
            while True:
                let pair = self.co_alg(_initial)
                _initial = pair.get[0, A]()
                accumulated.push_back(pair.get[1, B]())
        finally:
            return accumulated


@value
@register_passable("trivial")
struct Catamorphism[A: AnyType, B: AnyType]:
    """
    A catamorphism is a fold. It takes a combining function, a default value,
    and values to combine, and repeatedly applies the combining function to
    the current value and the next value to produce a new value. The process
    terminates when there are no more values to combine.

    NOTE: This implementation is the equivalent of a left fold -- Mojo is a strict
    language and does not provide facilities for lazy evaluation, so right folds
    are not possible.
    """

    var alg: fn (B, A) capturing -> B
    var final: B

    # NOTE: Including values as a parameter here would be more consistent with
    # the other two structures, but it would also require a DynamicVector to be
    # register_passable, which it is not.

    @always_inline("nodebug")
    fn __call__(self: Self, values: DynamicVector[A]) -> B:
        var final = self.final
        for i in range(values.size):
            final = self.alg(final, values[i])
        return final


@value
@register_passable("trivial")
struct Hylomorphism[A: AnyType, B: AnyType, C: AnyType]:
    """
    A hylomorphism is a combination of an anamorphism and a catamorphism.
    This implementation fusion-optimizes the two into a single loop, so
    there is no intermediate data structure.
    """

    var ana: Anamorphism[A, B]
    var cata: Catamorphism[B, C]

    @always_inline("nodebug")
    fn __call__(self: Self, initial: A) -> C:
        var _initial = initial
        var final = self.cata.final
        try:
            while True:
                let pair = self.ana.co_alg(_initial)
                _initial = pair.get[0, A]()
                final = self.cata.alg(final, pair.get[1, B]())
        finally:
            return final
