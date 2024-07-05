#Igor Misiek
#Obliczenia naukowe - Lista 4

#Moduł zawierający implementacje funkcji z listy 4

module interpolation


    using Plots


    export ilorazyRoznicowe, warNewton, naturalna, rysujNnfx


    function ilorazyRoznicowe(x::Vector{Float64}, f::Vector{Float64})
        n = length(x)
        fx = copy(f)
    
        for i in 2:n
            for j in n:-1:i
                fx[j] = (fx[j] - fx[j-1]) / (x[j] - x[j-i+1])
            end
        end
    
        return fx
    end


    function warNewton(x::Vector{Float64}, fx::Vector{Float64}, t::Float64)
        n = length(x)
        nt = fx[n]
    
        for i in (n-1):-1:1
            nt = fx[i] + (t - x[i]) * nt
        end
    
        return nt
    end

    
    function naturalna(x::Vector{Float64}, fx::Vector{Float64})
        n = length(x)
        a = copy(fx)
    
        for i in (n-1):-1:1
            a[i] = fx[i] - a[i + 1] * x[i]
            for j in (i+1):(n-1)
                a[j] = a[j] - a[j+1] * x[i]
            end
        end
    
        return a
    end

    function rysujNnfx(f, a::Float64, b::Float64, n::Int)
        x = collect(range(a, stop=b, length=n+1))
        y = f.(x)
    
        ilorazy = ilorazyRoznicowe(x, y)
    
        points = 50 * (n+1)
        xs = range(a, stop=b, length=points)
        poly = [warNewton(x, ilorazy, xi) for xi in xs]
        func = f.(xs)
    
        plot(xs, poly, label="Wielomian interpolacyjny")
        plot!(xs, func, label="Funkcja interpolowana", legend=:topleft)
    
        xlabel!("x")
        ylabel!("y")
    
        filename = string(f) * " : " * string(n) * ".png"
        savefig(filename)
    end


end