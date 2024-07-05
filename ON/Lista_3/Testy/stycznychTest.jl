#Igor Misiek
#Obliczenia naukowe - Lista 3
#Program do szybkiego testowania wyników metody Newtona (siecznych)

include("../zeroOfFunction.jl")
using .zeroOfFunction

f(x) = x^2 - 4
pf(x) = 2x
x0 = 1.5
delta, epsilon = 0.5 * 1e-5, 0.5 * 1e-5
maxit = 100

(r, v, it, err) = mstycznych(f, pf, x0, delta, epsilon, maxit)

println("Test metody Newtona:")
println("   Przybliżenie pierwiastka: $r")
println("   Wartość funkcji w przybliżeniu: $v")
println("   Liczba wykonanych iteracji: $it")
println("   Błąd: $err")