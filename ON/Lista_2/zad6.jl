#Igor Misiek
#Obliczenia naukowe - Lista 2

using Plots

#Funkcja zdefiniowana dla zadanej rekurencji
function calcNext(x, c)
    return Float64(Float64(Float64(x) * Float64(x)) + Float64(c))
end

#Zadane w poleceniu wartości zmiennej c oraz początkowego x
cValues = [-2.0, -2.0, -2.0, -1.0, -1.0, -1.0, -1.0]
xValues = [1.0, 2.0, 1.99999999999999, 1.0, -1.0, 0.75, 0.25]

wyniki = []

for i in 1:7
    c = Float64(cValues[i])
    x = Float64(xValues[i])
    wyniki_dla_danej_pary = Float64[]
    
    for _ in 1:40
        println(x)
        push!(wyniki_dla_danej_pary, x)
        x = calcNext(x, c)
    end

    push!(wyniki, wyniki_dla_danej_pary)
    print("-----------------------------\n")
end

for i in 1:40
    for j in 1:7
        print(wyniki[j][i])
        if j < 7
            print(" & ")
        end
    end
    println("\\\\")
end

plot(size=(1600, 1000), xlabel="Krok", ylabel="Wartość x", legend=true)

for i in 1:7
    plot!(wyniki[i], label="x_$(i)")
end

savefig("graphs.png")