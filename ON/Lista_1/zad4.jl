#Igor Misiek
#Obliczenia naukowe - Lista 1

#Funkcja do znajdowania x spełniającego założenia zadania
function find_x()
    x = Float64(1)
    while Float64(x * Float64(1/x)) == 1
        x += eps(Float64)  # Przesunięcie o najmniejszą możliwą wartość w arytmetyce Float64
    end
    return x
end

x = find_x()
value = Float64(x * Float64(1/x))
println("Znaleziona najmniejsza liczba x: $x")
println("Wartość: $value")