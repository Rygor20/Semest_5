#Igor Misiek
#Obliczenia naukowe - Lista 3
#Program do szybkiego testowania wyników metody siecznych

include("../zeroOfFunction.jl")
using .zeroOfFunction

f(x) = x^2 - 4
x0, x1 = -1.7, 3.2
delta, epsilon = 0.5 * 1e-5, 0.5 * 1e-5
maxit = 100

(r, v, it, err) = msiecznych(f, x0, x1, delta, epsilon, maxit)

println("Test metody siecznych:")
println("   Przybliżenie pierwiastka: $r")
println("   Wartość funkcji w przybliżeniu: $v")
println("   Liczba wykonanych iteracji: $it")
println("   Błąd: $err")