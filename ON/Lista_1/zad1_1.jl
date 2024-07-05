#Igor Misiek
#Obliczenia naukowe - Lista 1

# Funkcja obliczająca epsilon maszynowy iteracyjnie
function compute_epsilon(T)
    epsilon = T(1.0)
    while T(1.0) + epsilon > T(1.0)
        epsilon /= T(2.0)
    end
    return epsilon * T(2.0)
end

# Dostępne typy zmiennopozycyjne
float_types = [Float16, Float32, Float64]

# Obliczanie epsilonych maszynowych i porównanie z funkcją eps
for T in float_types
    computed_epsilon = compute_epsilon(T)
    julia_eps = eps(T)

    println("$T:")
    println("  Obliczony epsilon maszynowy: $computed_epsilon")
    println("  Epsilon z funkcji eps(): $julia_eps")
    println()
end