#Igor Misiek
#Obliczenia naukowe - Lista 4

#Testy z ręcznie policzonymi wynikami

include("functions.jl")
using .interpolation
using Test

@testset "$(rpad("Testy Interpolacji", 25))" begin
  f = x -> 2*x^3 + x^2 + 3*x + 7
  x = [0.0, 1.0, 2.0, 3.0, 4.0, 5.0]
  f_values = [f(x[1]), f(x[2]), f(x[3]), f(x[4]), f(x[5]), f(x[6])]
  ilorazy = ilorazyRoznicowe(x, f_values)

  @test ilorazy[1] == 7.0
  @test ilorazy[2] == 6.0
  @test ilorazy[3] == 7.0
  @test ilorazy[4] == 2.0
  @test ilorazy[5] == 0.0
  @test ilorazy[6] == 0.0
  @test warNewton(x, ilorazy, x[1]) == f(x[1])
  @test warNewton(x, ilorazy, x[2]) == f(x[2])
  @test warNewton(x, ilorazy, x[3]) == f(x[3])
  @test warNewton(x, ilorazy, x[4]) == f(x[4])
  @test warNewton(x, ilorazy, x[5]) == f(x[5])
  @test warNewton(x, ilorazy, x[6]) == f(x[6])
  coefficients = naturalna(x, ilorazy)
  @test coefficients[1] == 7.0
  @test coefficients[2] == 3.0
  @test coefficients[3] == 1.0
  @test coefficients[4] == 2.0
  @test coefficients[5] == 0.0
  @test coefficients[6] == 0.0
end