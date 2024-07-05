#Igor Misiek
#Obliczenia naukowe - Lista 1

#Funkcja wyliczająca epsilon maszynowy wzorem Kahana
function calculate_macheps(T)
    macheps = T(3) * (T(4) / T(3) - T(1)) - T(1)
    return macheps
end

# Dostępne typy zmiennopozycyjne
float_types = [Float16, Float32, Float64]

for T in float_types
    macheps = calculate_macheps(T)
    julia_eps = eps(T)
    
    println("$T:")
    println("  Obliczony macheps: $macheps")
    println("  Epsilon z funkcji eps(): $julia_eps")
    println()
end
