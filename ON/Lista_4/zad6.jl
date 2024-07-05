#Igor Misiek
#Obliczenia naukowe - Lista 4

#Wywołania dla zadania 6

include("functions.jl")
using .interpolation

# |x|, [-1, 1], n = 5, 10, 15

f3(x) = abs(x)
a3, b3 = -1.0, 1.0
n_values = [5, 10, 15]

for n in n_values
    rysujNnfx(f3, a3, b3, n)
end

# 1 / (1 + x^2), [-5, 5], n = 5, 10, 15 (zjawisko Runge’go)

f4(x) = 1 / (1 + x^2)
a4, b4 = -5.0, 5.0

for n in n_values
    rysujNnfx(f4, a4, b4, n)
end