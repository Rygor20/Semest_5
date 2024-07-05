include("blocksys.jl")
include("matrixgen.jl")
using .blocksys
using .matrixgen
using Test


blockmat(2500, 25, 5.0, "test_matrix.txt")
test_matrix, test_n, test_l = read_matrix("test_matrix.txt")
test_b = create_b(test_matrix, test_l)
x_ones = ones(Float64, test_n)


@testset "$(rpad("Eliminacja Gaussa", 50))" begin
    case_matrix = deepcopy(test_matrix)
    case_b = deepcopy(test_b)
    @test isapprox(gaussian_elimination(case_matrix, test_l, case_b), x_ones)
end

@testset "$(rpad("Eliminacja Gaussa - wariant z częściowym wyborem", 50))" begin
    case_matrix = deepcopy(test_matrix)
    case_b = deepcopy(test_b)
    @test isapprox(gaussian_elimination_with_choice(case_matrix, test_l, case_b), x_ones)
end

@testset "$(rpad("Rozkład LU", 50))" begin
    case_matrix = deepcopy(test_matrix)
    case_b = deepcopy(test_b)
    @test isapprox(solve_lu(case_matrix, test_l, case_b), x_ones)
end

@testset "$(rpad("Rozkład LU - wariant z częściowym wyborem", 50))" begin
    case_matrix = deepcopy(test_matrix)
    case_b = deepcopy(test_b)
    @test isapprox(solve_lu_choices(case_matrix, test_l, case_b), x_ones)
end