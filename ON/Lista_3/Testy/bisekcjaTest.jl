#Igor Misiek
#Obliczenia naukowe - Lista 3
#Program do szybkiego testowania wyników metody bisekcji

include("../zeroOfFunction.jl")
using .zeroOfFunction

f(x) = x^2 - 4
a, b = -1.7, 3.2
delta, epsilon = 0.5 * 1e-5, 0.5 * 1e-5

(r, v, it, err) = mbisekcji(f, a, b, delta, epsilon)

println("Test metody bisekcji:")
println("   Przybliżenie pierwiastka: $r")
println("   Wartość funkcji w przybliżeniu: $v")
println("   Liczba wykonanych iteracji: $it")
println("   Błąd: $err")