#Igor Misiek
#Obliczenia naukowe - Lista 3

include("zeroOfFunction.jl")
using .zeroOfFunction


f1(x) = sin(x) - (1/2 * x)^2
a1, b1 = 1.5, 2.0
delta1, epsilon1 = 0.5 * 1e-5, 0.5 * 1e-5

(r1, v1, it1, err1) = mbisekcji(f1, a1, b1, delta1, epsilon1)

println("1) Metoda bisekcji:")
println("     Przybliżenie pierwiastka: $r1")
println("     Wartość funkcji w przybliżeniu: $v1")
println("     Liczba wykonanych iteracji: $it1")
println("     Błąd: $err1")


f2(x) = sin(x) - (1/2 * x)^2
pf2(x) = cos(x) - (x/2)
x02 = 1.5
delta2, epsilon2 = 0.5 * 1e-5, 0.5 * 1e-5
maxit2 = 100

(r2, v2, it2, err2) = mstycznych(f2, pf2, x02, delta2, epsilon2, maxit2)

println("\n2) Metoda Newtona:")
println("     Przybliżenie pierwiastka: $r2")
println("     Wartość funkcji w przybliżeniu: $v2")
println("     Liczba wykonanych iteracji: $it2")
println("     Błąd: $err2")


f3(x) = sin(x) - (1/2 * x)^2
x03, x13 = 1.0, 2.0
delta3, epsilon3 = 0.5 * 1e-5, 0.5 * 1e-5
maxit3 = 100

(r3, v3, it3, err3) = msiecznych(f3, x03, x13, delta3, epsilon3, maxit3)

println("\n3) Metoda siecznych:")
println("     Przybliżenie pierwiastka: $r3")
println("     Wartość funkcji w przybliżeniu: $v3")
println("     Liczba wykonanych iteracji: $it3")
println("     Błąd: $err3")