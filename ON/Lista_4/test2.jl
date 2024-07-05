include("functions.jl")
using .interpolation

f = x -> 2*x^3 + x^2 + 3*x + 7

x = [-1.0, 0.0, 1.0, 2.0]

f_values = [-1.0, 0.0, -1.0, 2.0]

println(
    naturalna(
        x, ilorazyRoznicowe(x, f_values)
    )
)