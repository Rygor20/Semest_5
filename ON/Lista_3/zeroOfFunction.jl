#Igor Misiek
#Obliczenia naukowe - Lista 3

#Moduł zawierający implementacje metod obliczania zer funkcji
#Ich funkcjonowanie bazuje na pseudo kodach z wykładu
module zeroOfFunction


    export mbisekcji, mstycznych, msiecznych
    
    function mbisekcji(f, a::Float64, b::Float64, delta::Float64, epsilon::Float64)
        u = f(a)
        v = f(b)
        e = b - a
        it = 0
        err = 0
        
        if sign(f(a)) == sign(f(b))
            err = 1
            return (NaN, NaN, it, err)
        end
        
        while abs(e) > delta || abs(v) > epsilon
            e /= 2
            c = a + e
            w = f(c)
            it += 1
            
            if abs(e) <= delta || abs(w) <= epsilon
                return (c, w, it, err)
            end
            
            if sign(w) != sign(u)
                b = c
                v = w
            else
                a = c
                u = w
            end
        end

        return (a + e / 2, f(a + e / 2), it, err) #default case
    end


    function mstycznych(f,pf,x0::Float64, delta::Float64, epsilon::Float64, maxit::Int)
        x = x0
        it = 0
        err = 0
        fx = f(x0)

        if abs(f(x)) <= epsilon
            return (x, fx, it, err)
        end
        
        while it < maxit

            dfx = pf(x)
            if abs(dfx) < eps(Float64)
                err = 2
                return (x, fx, it, err)
            end
            
            it += 1

            x = x - fx / dfx
            fx = f(x)
            
            if abs(x - x0) <= delta || abs(fx) <= epsilon
                return (x, fx, it, err)
            end

            x0 = x
        end
        
        err = 1
        return (x, fx, it, err)
    end

    function msiecznych(f, x0::Float64, x1::Float64, delta::Float64, epsilon::Float64, maxit::Int)
        a = x0
        b = x1
        fa = f(a)
        fb = f(b)
        it = 0
        err = 0
        
        while it < maxit
            it += 1

            if abs(fa) > abs(fb)
                a, b = b, a
                fa, fb = fb, fa
            end
            
            s = (b - a) / (fb - fa)
            b, fb = a, fa
            a -= fa * s
            fa = f(a)
            
            if abs(b - a) <= delta || abs(fa) <= epsilon
                return (a, fa, it, err)
            end

        end
        
        err = 1
        return (a, fa, maxit, err)
    end


end