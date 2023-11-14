fn eq(msg: String, expected: Int, actual: Int) raises -> None:
    if expected != actual:
        raise Error(
            msg + ": expected " + String(expected) + " but got " + String(actual)
        )
    else:
        print(msg + ": OK")
