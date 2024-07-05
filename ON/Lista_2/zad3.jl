#Igor Misiek
#Obliczenia naukowe - Lista 2

using LinearAlgebra

function hilb(n::Int)
    # Function generates the Hilbert matrix  A of size n,
    #  A (i, j) = 1 / (i + j - 1)
    # Inputs:
    #	n: size of matrix A, n>=1
    #
    #
    # Usage: hilb(10)
    #
    # Pawel Zielinski
            if n < 1
             error("size n should be >= 1")
            end
            return [1 / (i + j - 1) for i in 1:n, j in 1:n]
    end

function matcond(n::Int, c::Float64)
# Function generates a random square matrix A of size n with
# a given condition number c.
# Inputs:
#	n: size of matrix A, n>1
#	c: condition of matrix A, c>= 1.0
#
# Usage: matcond(10, 100.0)
#
# Pawel Zielinski
        if n < 2
         error("size n should be > 1")
        end
        if c< 1.0
         error("condition number  c of a matrix  should be >= 1.0")
        end
        (U,S,V)=svd(rand(n,n))
        return U*diagm(0 =>[LinRange(1.0,c,n);])*V'
end

#Funkcja mająca za zadanie obliczenie błędów względnych dwóch metod rozwiązywania równania
function calculateError(m::Matrix{Float64})
    x = ones(Float64, size(m, 2))
    b = m * x
  
    xGauss = m \ b
    xInverse = inv(m) * b
  
    errorGauss = norm(x - xGauss) / norm(x)
    errorInverse = norm(x - xInverse) / norm(x)
    return cond(m), errorGauss, errorInverse;
end


#Wyświetlanie wyników dla macierzy Hilberta
println("HILBERT")
for n = 2:20
    H = hilb(n)
    cond, gauss, inverse = calculateError(H)
    # println("$n & $cond & $gauss & $inverse \\\\")
    println("$n : $cond, $gauss, $inverse")
    # println("$n : Uwarunkowanie - $cond, Gauss - $gauss, Inverse - $inverse")
end

#Wyświetlanie wyników dla macierzy losowej
println("RANDOM")
sizes = [5, 10, 20]
cond_nums = [Float64(1), Float64(10), Float64(10^3), Float64(10^7), Float64(10^12), Float64(10^16)]
for s in sizes, c in cond_nums
    M = matcond(s, c)
    cond, gauss, inverse = calculateError(M)
    # println("$s & $c & $cond & $gauss & $inverse \\\\")
    println("$s, $c : $cond, $gauss, $inverse")
    # println("$s, $c : Uwarunkowanie - $cond, Gauss - $gauss, Inverse - $inverse")
end