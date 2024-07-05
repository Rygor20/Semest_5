def negat(a, order):
    while a < 0:
        a += order
    return a

def add(a, b, order):
    return (a+b) % order

def sub(a, b, order):
    return add(a, negat(-b, order), order)

def inverse(a, order):
    for i in range(order):
        if mult(a, i, order) == 1:
            return i
    return -1

def mult(a, b, order):
    return a * b % order

def divide(a, b, order):
    inv = inverse(b, order)
    if inv == -1:
        return -1
    return mult(a, inv, order)

def power(a, pow, order):
    if pow == 0:
        return 1
    b = power(a, pow//2, order)
    b = mult(b, b, order)
    if pow % 2 == 0:
        return b
    return mult(b, a, order)
