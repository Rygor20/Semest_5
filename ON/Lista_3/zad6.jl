#Igor Misiek
#Obliczenia naukowe - Lista 3

include("zeroOfFunction.jl")
using .zeroOfFunction


# Dla f1(x) = e^(1-x) - 1
f1(x) = exp(1 - x) - 1
p1(x) = -exp(1 - x)
a1, b1 = -1.0, 2.0
x01, x11 = -1.0, 2.0

# Zastosuj metody
(r1_bisect, v1_bisect, it1_bisect, err1_bisect) = mbisekcji(f1, a1, b1, 1e-5, 1e-5)
(r1_newton, v1_newton, it1_newton, err1_newton) = mstycznych(f1, p1, x01, 1e-5, 1e-5, 1000)
(r1_secant, v1_secant, it1_secant, err1_secant) = msiecznych(f1, x01, x11, 1e-5, 1e-5, 1000)

# Wyświetl wyniki dla f1
println("Dla f1(x) = e^(1-x) - 1:")

println("  Metoda bisekcji:")
println("  Przybliżenie pierwiastka: $r1_bisect")
println("  Wartość funkcji w przybliżeniu: $v1_bisect")
println("  Liczba wykonanych iteracji: $it1_bisect")
println("  Błąd: $err1_bisect\n")

println("  Metoda Newtona:")
println("  Przybliżenie pierwiastka: $r1_newton")
println("  Wartość funkcji w przybliżeniu: $v1_newton")
println("  Liczba wykonanych iteracji: $it1_newton")
println("  Błąd: $err1_newton\n")

println("  Metoda siecznych:")
println("  Przybliżenie pierwiastka: $r1_secant")
println("  Wartość funkcji w przybliżeniu: $v1_secant")
println("  Liczba wykonanych iteracji: $it1_secant")
println("  Błąd: $err1_secant\n")

# Dla f2(x) = xe^(-x)
f2(x) = x * exp(-x)
p2(x) = -exp(-x) * (x - 1)
a2, b2 = -3.0, 2.0
x02, x12 = -3.0, 2.0

# Zastosuj metody
(r2_bisect, v2_bisect, it2_bisect, err2_bisect) = zeroOfFunction.mbisekcji(f2, a2, b2, 1e-5, 1e-5)
(r2_newton, v2_newton, it2_newton, err2_newton) = zeroOfFunction.mstycznych(f2, p2, x02, 1e-5, 1e-5, 1000)
(r2_secant, v2_secant, it2_secant, err2_secant) = zeroOfFunction.msiecznych(f2, x02, x12, 1e-5, 1e-5, 1000)

# Wyświetl wyniki dla f2
println("Dla f2(x) = xe^(-x):")

println("  Metoda bisekcji:")
println("  Przybliżenie pierwiastka: $r2_bisect")
println("  Wartość funkcji w przybliżeniu: $v2_bisect")
println("  Liczba wykonanych iteracji: $it2_bisect")
println("  Błąd: $err2_bisect\n")

println("  Metoda Newtona:")
println("  Przybliżenie pierwiastka: $r2_newton")
println("  Wartość funkcji w przybliżeniu: $v2_newton")
println("  Liczba wykonanych iteracji: $it2_newton")
println("  Błąd: $err2_newton\n")

println("  Metoda siecznych:")
println("  Przybliżenie pierwiastka: $r2_secant")
println("  Wartość funkcji w przybliżeniu: $v2_secant")
println("  Liczba wykonanych iteracji: $it2_secant")
println("  Błąd: $err2_secant\n")