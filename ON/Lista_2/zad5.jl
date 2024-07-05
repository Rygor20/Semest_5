#Igor Misiek
#Obliczenia naukowe - Lista 2

#Funkcja zdefiniowana dla zadanej rekurencji
function logisticRecursion(p0, r, n, T)
    p = T(p0)
    for i in 1:n
        p = T(p + T(T(r)*T(p)*T(1 - p)))
        # println("   Iter $i : $p")
        println("$i & $p")
    end
    return p
end

pStart = 0.01
rStart = 3.0

println("Float 32, Pełne 40 wywołań")
pEnd32 = logisticRecursion(pStart, rStart, 40, Float32)

println("\nFloat32, 10 pierwszych z odcięciem końca i kontynuacja")
pTen32 = logisticRecursion(pStart, rStart, 10, Float32)
pTrunc = trunc(pTen32, digits=3)
println("Zaokrąglenie 10 wyniku: $pTrunc")
pRest32 = logisticRecursion(pTrunc, rStart, 30, Float32)

println("\nFloat 64, Pełne 40 wywołań")
pEnd64 = logisticRecursion(pStart, rStart, 40, Float64)