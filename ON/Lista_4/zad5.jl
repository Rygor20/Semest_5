#Igor Misiek
#Obliczenia naukowe - Lista 4

#Wywołania dla zadania 5

include("functions.jl")
using .interpolation

# e^x, [0, 1], n = 5, 10, 15

f1(x) = exp(x)
a1, b1 = 0.0, 1.0
n_values = [5, 10, 15]

for n in n_values
    rysujNnfx(f1, a1, b1, n)
end

# x^2 * sin(x), [-1, 1], n = 5, 10, 15

f2(x) = x^2 * sin(x)
a2, b2 = -1.0, 1.0

for n in n_values
    rysujNnfx(f2, a2, b2, n)
end
