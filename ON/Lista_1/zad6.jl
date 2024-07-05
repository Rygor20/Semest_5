#Igor Misiek
#Obliczenia naukowe - Lista 1

#Zadana w zadaniu funkcja f(x)
function f(x)
    return Float64(sqrt(Float64(Float64(x^2) + 1)) - 1)
end

#Zadana w zadaniu funkcja g(x)
function g(x)
    return Float64(Float64(x^2) / Float64(sqrt(Float64(x^2) + 1) + 1))
end

x_values = [8.0^(-i) for i in 1:15]

for x in x_values
    f_result = f(x)
    g_result = g(x)
    difference = Float64(f_result - g_result)
    
    println("x = $x")
    println("f(x) = $f_result")
    println("g(x) = $g_result")
    println("f(x) - g(x) = $difference")
    
    println()
end