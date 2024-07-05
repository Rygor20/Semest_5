include("blocksys.jl")
include("matrixgen.jl")
using .blocksys
using .matrixgen

matrix, n_m, l_m = read_matrix("data/50000/A.txt")
b_vector, n_v = read_vector("data/50000/b.txt")

# println("Matrix:")
# print_full_matrix(matrix)

println()
# result = gaussian_elimination(matrix, l_m, b_vector)
# result = gaussian_elimination(matrix, l_m)

# result = solve_lu(matrix, l_m)
result = solve_lu_choices(matrix, l_m)

# println()
# println("Matrix:")
# print_full_matrix(matrix)

# println()
# println(result)