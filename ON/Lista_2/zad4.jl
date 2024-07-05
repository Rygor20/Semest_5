#Igor Misiek
#Obliczenia naukowe - Lista 2

using Polynomials
using Printf

# Współczynniki wielomianu Wilkinsona
p=[1, -210.0, 20615.0,-1256850.0,
      53327946.0,-1672280820.0, 40171771630.0, -756111184500.0,          
      11310276995381.0, -135585182899530.0,
      1307535010540395.0,     -10142299865511450.0,
      63030812099294896.0,     -311333643161390640.0,
      1206647803780373360.0,     -3599979517947607200.0,
      8037811822645051776.0,      -12870931245150988800.0,
      13803759753640704000.0,      -8752948036761600000.0,
      2432902008176640000.0]

# Polynomial() wymaka współczynników w odwrotnej kolejności
coefficients = reverse(p)
pNatural = Polynomial(coefficients)
pFactored = fromroots(1:20)
calculatedRoots = roots(pNatural)

c = 0
for z in calculatedRoots
    global c
    c = c + 1
    cannon = abs(Float64(pNatural(z)))
    factor = abs(Float64(pFactored(z)))
    diff = Float64(abs(Float64(z) - Float64(c)))
    println("$c & $z & $cannon & $factor & $diff \\\\")
end

println()

coefficientsModified = copy(coefficients)
coefficientsModified[20] = -210.0 - (2.0^-23)
pNaturalModified = Polynomial(coefficientsModified)
calculatedRootsModified = roots(pNaturalModified)

c = 0
for z in calculatedRootsModified
    global c
    c = c + 1
    cannonModi = abs(pNaturalModified(z))
    factor = abs(pFactored(z))
    diff = abs(z - c)
    println("$c & $z & $cannonModi & $factor & $diff \\\\")
end