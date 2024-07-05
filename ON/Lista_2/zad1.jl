#Igor Misiek
#Obliczenia naukowe - Lista 2

#Funckja służąca do liczenia iloczynu skalarnego wektorów x i y metodą "W przód"
function calcForward(T, x, y, length)
    sum = T(0)
    for i in 1:length
        sum += T(T(x[i]) * T(y[i]))
    end
    return sum
end

#Funckja służąca do liczenia iloczynu skalarnego wektorów x i y metodą "W tył"
function calcBackward(T, x, y, length)
    sum = T(0)
    for i in reverse(1:length)
        sum += T(T(x[i]) * T(y[i]))
    end
    return sum
end

#Funckja służąca do liczenia iloczynu skalarnego wektorów x i y metodą "Największy do najmnniejszego"
function calcFromLargest(T, x, y, length)
    products = []
    sum_pos = T(0)
    sum_neg = T(0)
    sum = T(0)

    #Liczenie iloczynów i zapis w tablicy
    for i in 1:length
        push!(products, T(T(x[i]) * T(y[i])))
    end
    
    sorted = sort(products, rev=true)

    #Znajdowanie indexu, na którym następuja zmiana znaku wartości
    counter = 1
    while sorted[counter] >= 0
        sum_pos += T(sorted[counter])
        counter += 1
    end
    for i in reverse(counter:length)
        sum_neg += T(sorted[i])
    end

    sum = T(sum_pos + sum_neg)

    return sum
end

#Funckja służąca do liczenia iloczynu skalarnego wektorów x i y metodą "Najmniejszy do największego
function calcFromSmallest(T, x, y, length)
    products = []
    sum_pos = T(0)
    sum_neg = T(0)
    sum = T(0)
    
    #Liczenie iloczynów i zapis w tablicy
    for i in 1:length
        push!(products, T(T(x[i]) * T(y[i])))
    end

    sorted = sort(products, rev=true)

    #Znajdowanie indexu, na którym następuja zmiana znaku wartości
    counter = 1
    while sorted[counter] >= 0
        counter += 1
    end
    for i in reverse(1:(counter-1))
        sum_pos += T(sorted[i])
    end
    for i in counter:length
        sum_neg += T(sorted[i])
    end

    sum = T(sum_pos + sum_neg)

    return sum
end

#Zmodyfikowe względem listy pierwszej wektory
x = [2.718281828, -3.141592654, 1.414213562, 0.577215664, 0.301029995]
y = [1486.2497, 878366.9879, -22.37492, 4773714.647, 0.000185049]

# Dostępne typy zmiennopozycyjne
float_types = [Float32, Float64]

for T in float_types
    sForward = calcForward(T, x, y, 5)
    sBackward = calcBackward(T, x, y, 5)
    sFromLargest = calcFromLargest(T, x, y, 5)
    sFromSmallest = calcFromSmallest(T, x, y, 5)

    println("$T:")
    println(" 1) 'w przód': $sForward")
    println(" 2) 'w tył': $sBackward")
    println(" 3) od największego do najmniejszego: $sFromLargest")
    println(" 4) od najmniejszego do największego: $sFromSmallest")
end

println("\n Correct value: ")
println("−1.00657107000000e−11")