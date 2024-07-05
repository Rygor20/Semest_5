#Igor Misiek
#Obliczenia naukowe - Lista 1

#Zadana w zadaniu funkcja f(x)
function f(x)
    return Float64(sin(x) + cos(3x))
end

#Funkcja zwracająca przybliżenie pochodnej w punkcie x z wartością zmiennej h
function approx_derivative(x, h)
    return Float64((f(x + h) - f(x)) / h)
end

x0 = Float64(1.0)
exact_derivative = Float64(cos(1) - 3sin(3)) # Dokładna wartość pochodnej

for n = 0:54
    h = Float64(2.0^(-n))
    sum = Float64(1 + h)
    println("  Wartość 1+h: $sum")
    approx_value = approx_derivative(x0, h)
    error = abs(exact_derivative - approx_value)
    println("n = $n, ˜f′(x0) = $approx_value")
    println("  Błąd: |f′(x0) − ˜f′(x0)| = $error")
end
