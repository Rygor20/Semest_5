#Igor Misiek
#Obliczenia naukowe - Lista 1

#Funckja licząca wartość eta maszynową przez dzielenie przez 2
function compute_eta(T)
    eta = T(1.0)
    while T(eta / 2) > T(0.0)
        eta /= T(2.0)
    end
    return eta
end

# Dostępne typy zmiennopozycyjne
float_types = [Float16, Float32, Float64]

for T in float_types
    computed_eta = compute_eta(T)
    julia_nextfloat = nextfloat(T(0.0))
    
    println("$T:")
    println("  Obliczona eta maszynowa: $computed_eta")
    println("  Wynik funkcji nextfloat: $julia_nextfloat")
    println()
end

min32 = floatmin(Float32)
min64 = floatmin(Float64)

#Wypisanie w terminalu wartości funkcji floatmin()
println("Funkcje floatmin():")
println("  Wynik floatmin(Float32): $min32")
println("  Wynik floatmin(Float64): $min64")