using Plots

# Definiowanie funkcji
f(x) = 3x - exp(x)

# Przedziały x z zwiększoną precyzją
x_values = -3:0.01:3

# Wygenerowanie wykresu
plot(x_values, f, label="3x - e^x", xlabel="x", ylabel="f(x)", linewidth=2, legend=:bottomright)

# Dodanie osi OX i OY
hline!([0], linestyle=:dash, color=:black, label=nothing)
vline!([0], linestyle=:dash, color=:black, label=nothing)

# Zapisanie wykresu do pliku PNG
savefig("wykres.png")
