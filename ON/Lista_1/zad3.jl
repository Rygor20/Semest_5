#Igor Misiek
#Obliczenia naukowe - Lista 1

#Całość tego programu służy wyłącznie wypisaniu w terminalu kluczonych dla zadania Wartości
#Na ich podstawie formułuję później swoje obserwacje i wyciągam wnioski

println("Bitstring 1 w Float64:")
print("  ")
println(bitstring(Float64(1)))
println("Bitstring 2 w Float64:")
print("  ")
println(bitstring(Float64(2)))

println()
println("Bitstring 1 + 2^-52 w Float64:")
print("  ")
println(bitstring(Float64(1) + Float64(2^-52)))
println("Bitstring 1 + eps(Float64) w Float64:")
print("  ")
println(bitstring(Float64(1) + Float64(eps(Float64))))
println("Bitstring 2 - 2^-52 w Float64:")
print("  ")
println(bitstring(Float64(2) - Float64(2^-52)))
println("Bitstring 2 - eps(Float64) w Float64:")
print("  ")
println(bitstring(Float64(2) - Float64(eps(Float64))))

println()
println("Wartości odpowiednio eps(Float64) i 2^-52 w Float64:")
print("  ")
println(eps(Float64))
print("  ")
println(Float64(2^-52))

#Prezentacje jak wyglądają kolejne kroki 
println()
println(bitstring(Float64(1) + Float64(2^-52)))
println(bitstring(Float64(1) + Float64(2^-52) + Float64(2^-52)))
println(bitstring(Float64(1) + Float64(2^-52) + Float64(2^-52) + Float64(2^-52)))
println()
println(bitstring(Float64(0.5) + Float64(2^-53)))
println(bitstring(Float64(0.5) + Float64(2^-53) + Float64(2^-53)))
println(bitstring(Float64(0.5) + Float64(2^-53) + Float64(2^-53) + Float64(2^-53)))
println()
println(bitstring(Float64(2) + Float64(2^-51)))
println(bitstring(Float64(2) + Float64(2^-51) + Float64(2^-51)))
println(bitstring(Float64(2) + Float64(2^-51) + Float64(2^-51) + Float64(2^-51)))