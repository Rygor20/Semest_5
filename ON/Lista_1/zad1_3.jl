#Igor Misiek
#Obliczenia naukowe - Lista 1

#Funkcja licząca iteracyjnie wartość MAX
function compute_MAX(T)
    MAX = T(1.0)
    while !isinf(T(MAX * 2.0))
        MAX *= T(2.0)
    end
    MAX *= (T(2.0) - eps(T))
    return MAX
end

# Dostępne typy zmiennopozycyjne
float_types = [Float16, Float32, Float64]

for T in float_types
    computed_MAX = compute_MAX(T)
    julia_floatmax = floatmax(T)
    
    println("$T:")
    println("  Obliczona MAX: $computed_MAX")
    println("  Wartość z funkcji floatmax: $julia_floatmax")
    println()
end