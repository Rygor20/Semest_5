#Igor Misiek
#Obliczenia naukowe - Lista 2

using Plots

#Zapis funkcji rekurencyjnej
f(x) = exp(x) * log(1 + exp(-x))

#Ustalenie wartości dla osi x i y
x = -50:0.0001:50
y = f.(x)

plot(x, y, label="Wykres funkcji f(x) = e^x * ln(1 + e^-x)", xlabel="x", ylabel="f(x)", legend=true)

savefig("julia_plot.png")
