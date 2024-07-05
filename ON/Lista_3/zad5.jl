#Igor Misiek
#Obliczenia naukowe - Lista 3

include("zeroOfFunction.jl")
using .zeroOfFunction

# f1(x) = 3x
# f2(x) = exp(x)
# f1 = f2  -->  f1 - f2 = 0
f(x) = 3x - exp(x)

a1, b1 = 0.0, 1.0

delta, epsilon = 1e-4, 1e-4

(r1, v1, it1, err1) = mbisekcji(f, a1, b1, delta, epsilon)

println("Metoda bisekcji dla przedziału [0, 1]:")
println("  Przybliżenie pierwiastka: $r1")
println("  Wartość funkcji w przybliżeniu: $v1")
println("  Liczba wykonanych iteracji: $it1")
println("  Błąd: $err1")

a2, b2 = 1.0, 2.0

(r2, v2, it2, err2) = mbisekcji(f, a2, b2, delta, epsilon)

println("Metoda bisekcji dla przedziału [1, 2]:")
println("  Przybliżenie pierwiastka: $r2")
println("  Wartość funkcji w przybliżeniu: $v2")
println("  Liczba wykonanych iteracji: $it2")
println("  Błąd: $err2")

a3, b3 = -0.3, 1.2

(r3, v3, it3, err3) = mbisekcji(f, a3, b3, delta, epsilon)

println("Metoda bisekcji dla przedziału [-0.3, 1.2]:")
println("  Przybliżenie pierwiastka: $r3")
println("  Wartość funkcji w przybliżeniu: $v3")
println("  Liczba wykonanych iteracji: $it3")
println("  Błąd: $err3")

a4, b4 = 1.2, 2.5

(r4, v4, it4, err4) = mbisekcji(f, a4, b4, delta, epsilon)

println("Metoda bisekcji dla przedziału [1.2, 2.5]:")
println("  Przybliżenie pierwiastka: $r4")
println("  Wartość funkcji w przybliżeniu: $v4")
println("  Liczba wykonanych iteracji: $it4")
println("  Błąd: $err4")