include("blocksys.jl")
include("matrixgen.jl")
using .blocksys
using .matrixgen
using Plots

# sizes = [16, 10000, 50000, 100000, 300000, 500000]
# sizes = [16, 10000, 50000]
# sizes = [16, 10000]
# sizes = [1000, 2500, 5000, 7500, 10000, 12500, 15000, 17500, 20000]
# sizes = [500, 1500, 2500, 3500, 4500, 5500, 6500, 7500, 8500, 10000]
sizes = [500, 1000, 1500, 2500, 3500, 4500, 5000, 5500, 6500, 7500, 8500, 10000, 12500, 15000, 17500, 20000]

# functions = [primitive_approach, gaussian_elimination, gaussian_elimination_with_choice, solve_lu, solve_lu_choices]
functions = [gaussian_elimination, gaussian_elimination_with_choice, solve_lu, solve_lu_choices]

cases = length(sizes)

struct Result
    func::Function
    times::Vector{Float64}
    memory::Vector{Int}
end

results = [Result(f, zeros(Float64, cases), zeros(Int, cases)) for f in functions]

for (i, size) in enumerate(sizes)
    # matrix_file = joinpath("data", "$size", "A.txt")
    # vector_file = joinpath("data", "$size", "b.txt")

    # A, n, l = read_matrix(matrix_file)
    # b, n_v = read_vector(vector_file)

    blockmat(size, 25, 5.0, "test_matrix.txt")
    A, n, l = read_matrix("test_matrix.txt")
    b = create_b(A, l)

    for case in results
        A_copy = deepcopy(A)
        b_copy = deepcopy(b)
        # stats = @timed case.func(A_copy, l, b_copy)
        stats = @timed case.func(A_copy, l)
        println("Size: $size, Func: $(case.func), Time: $(stats.time), Bytes: $(stats.bytes)")
      
        case.times[i] = stats.time
        case.memory[i] = stats.bytes      
    end
end


# # plot(sizes, [S.times for S in results], title="Czas - sekundy", legend=:topleft, label=["Primitive" "Gauss" "Gauss Choice" "LU" "LU Choice"])
# # savefig("times.png")

# plot(sizes, [case.times for case in results], title="Czas - sekundy", legend=:topleft, label=["Gauss" "Gauss Choice" "LU" "LU Choice"])
# savefig("times2.png")



# # plot(sizes, [S.memory for S in results], title="Zużycie pamięci", legend=:topleft, label=["Primitive" "Gauss" "Gauss Choice" "LU" "LU Choice"])
# # savefig("mem.png")

# plot(sizes, [case.memory for case in results], title="Zużycie pamięci", legend=:topleft, label=["Gauss" "Gauss Choice" "LU" "LU Choice"])
# savefig("mem2.png")