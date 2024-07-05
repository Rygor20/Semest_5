#Igor Misiek
#Obliczenia naukowe - Lista 5

#Moduł zawierający implementacje funkcji z listy 5

module blocksys

    using SparseArrays
    import Printf
    import LinearAlgebra: norm


    export read_vector, read_matrix, print_full_matrix, create_b, primitive_approach
    export gaussian_elimination, gaussian_elimination_with_choice
    export lu_generation, lu_generation_with_choice, x_from_lu
    export solve_lu, solve_lu_choices


    function read_vector(filename)
        file = open(filename, "r")
        n = parse(Int, readline(file))
        b = zeros(Float64, n)
        for i in 1:n
            b[i] = parse(Float64, readline(file))
        end
        close(file)
        return b, n
    end


    function read_matrix(filename)
        file = open(filename, "r")
        n, l = [parse(Int, x) for x in split(readline(file))]
        A = spzeros(Float64, n, n)
        while !eof(file)
            i, j, value = [parse(Float64, x) for x in split(readline(file))]
            A[trunc(Int, i), trunc(Int, j)] = value
        end
        close(file)

        return A, n, l
    end


    function create_b(A, l)
        n = size(A, 1)
        b = zeros(Float64, n)

        start_j = 1
        for i in 1:n
            if i > l && i <= n - l
                in_row = l + 2
            else
                in_row = l + 1
            end

            if i % l == 1 && i != 1
                start_j = i - 1
            end

            for j in start_j:start_j + in_row - 1
                if i <= n - l && j == start_j + in_row - 1
                    b[i] += A[i, j + ((i - 1) % l)]
                else
                    b[i] += A[i, j]
                end
            end
        end

        return b
    end

    function primitive_approach(A, l, b)
        return Array(A) \ b
    end


    function print_full_matrix(A, permutation=nothing)
        m, n = size(A)
        for i in 1:m
            for j in 1:n
                if isnothing(permutation)
                    value = A[i, j]
                else
                    value = A[permutation[i], j]
                end
                if value >= 0
                    Printf.@printf(" %.4f\t", value)
                else
                    Printf.@printf("%.4f\t", value)
                end
            end
            println()
        end
    end


    function gaussian_elimination(A, l, b=nothing)
        n = size(A, 1)
        x = zeros(Float64, n)
        calc_error = false

        # Gdy wektor prawych stron b nie zostanie podany jest on wyliczany na podstawie A
        # Obliczenie b = Ax, gdzie x = (1,...,1)^T ogranicza się do policzenia sum wierzy macierzy A
        # Jest to zrobione w sposób uwzględniający charakterystyczną strukturę macierzy
        if b === nothing
            calc_error = true
            x_ones = ones(Float64, n)

            b = create_b(A, l)
        end
    
        for k in 1:n-1
            column = l - (k % l)

            # Uwzględnienie w pętli pomijanie elementów, które nie wprowadzają żadnej zmiany (A[i, k] = 0.0)
            # for i in k+1:n --> for i in k+1:min(k+column, n)
            for i in k+1:min(k+column, n)
                lik = A[i, k] / A[k, k]
                A[i, k] = 0.0

                # Uwzględnienie w pętli pomijanie elementów, które nie wprowadzają żadnych zmian
                # Zmiany bazują na ograniczeniach wartości i oraz regularności macierzy Ck
                for j in k+1:min(k+l, n)
                    A[i, j] -= lik * A[k, j]
                end

                b[i] -= lik * b[k]
            end
        end
    
        # Obliczanie wartości w wektorze x i zapis do pliku
        # Dodanie wartości błędu względnego gdy wektor prawych stron b nie był podany
        result_file = "results/gauss/$(n).txt"
        open(result_file, "w") do file
            sum_error = 0
            for i in n:-1:1
                sum_val = 0.0
                for j in i+1:min(i+l, n)
                    sum_val += A[i, j] * x[j]
                end
                x[i] = (b[i] - sum_val) / A[i, i]
                sum_error += abs(x[i] - 1.0) / abs(1.0)
            end

            if calc_error
                # abs_error = abs(norm(x) - norm(x_ones)) / abs(norm(x_ones))
                abs_error = sum_error / n
                println(file, "Error: ", abs_error)
            end

            for element in x
                println(file, element)
            end
        end
    
        return x
    end


    function gaussian_elimination_with_choice(A, l, b=nothing)
        n = size(A, 1)
        x = zeros(Float64, n)
        permutation = [1:n;]
        max_rows = zeros(Int, n)
        max_row = 1
        calc_error = false

        # Gdy wektor prawych stron b nie zostanie podany jest on wyliczany na podstawie A
        # Obliczenie b = Ax, gdzie x = (1,...,1)^T ogranicza się do policzenia sum wierzy macierzy A
        # Jest to zrobione w sposób uwzględniający charakterystyczną strukturę macierzy
        if b === nothing
            calc_error = true
            x_ones = ones(Float64, n)

            b = create_b(A, l)
        end
    
        for k in 1:n-1
            column = l - (k % l)
            down_to = min(k+column, n)

            # Jako wsparcie w pamiętaniu przestawień w macierzy korzystmay z permutacji
            # Zamieniamy ze sobą wierz k-ty z wierszem, w którym występuje element w badanej kolumnie o większej wartości bezwzględnej
            # Uwzględniamy dodatkowe ograniczenie ze względu na stałe występowanie wartości zerowych od pewnego indeksu
            best_index = k
            for a in k:down_to
                if abs(A[permutation[a], k]) > abs(A[permutation[best_index], k])
                    best_index = a
                end
            end

            if best_index != k
                permutation[k], permutation[best_index] = permutation[best_index], permutation[k]
            end

            # Pamiętamy najwyższy dotychczas index wiersza, aby dostosować ilość potencjalnie niezerowych kolumn
            if permutation[k] > max_row
                max_row = permutation[k]
            elseif k > max_row
                max_row = k
            end

            max_rows[k] = max_row

            for i in k+1:down_to
                lik = A[permutation[i], k] / A[permutation[k], k]
                A[permutation[i], k] = 0.0

                # Uwzględnienie w pętli pomijanie elementów, które nie wprowadzają żadnych zmian
                # Ilość permutacji zależna od największego indeksu wiersza podmienionego z wierszem k
                for j in k+1:min(max_row+l, n)
                    A[permutation[i], j] -= lik * A[permutation[k], j]
                end

                b[permutation[i]] -= lik * b[permutation[k]]
            end
        end
    

        # Obliczanie wartości w wektorze x i zapis do pliku
        # Dodanie wartości błędu względnego gdy wektor prawych stron b nie był podany
        result_file = "results/gauss_choice/$(n).txt"
        open(result_file, "w") do file
            sum_error = 0
            for i in n:-1:1
                sum_val = 0.0
                for j in i+1:min(max_rows[i]+l, n)
                    sum_val += A[permutation[i], j] * x[j]
                end
                x[i] = (b[permutation[i]] - sum_val) / A[permutation[i], i]
                sum_error += abs(x[i] - 1.0) / abs(1.0)
            end

            if calc_error
                # abs_error = abs(norm(x) - norm(x_ones)) / abs(norm(x_ones))
                abs_error = sum_error / n
                println(file, "Error: ", abs_error)
            end

            for element in x
                println(file, element)
            end
        end
    
        return x
    end


    function lu_generation(A, l)
        n = size(A, 1)

        for k in 1:n-1
            column = l - (k % l)

            # Uwagi do pomijanych elementów jak przy funkcji gauss_choice()
            for i in k+1:min(k+column, n)
                lik = A[i, k] / A[k, k]
                A[i, k] = lik

                # Uwagi do pomijanych elementów jak przy funkcji gauss_choice()
                for j in k+1:min(k+l, n)
                    A[i, j] -= lik * A[k, j]
                end
            end
        end
    end


    function lu_generation_with_choice(A, l)
        n = size(A, 1)
        max_rows = zeros(Int, n)
        max_row = 1
        permutation = [1:n;]

        for k in 1:n-1
            column = l - (k % l)
            down_to = min(k+column, n)

            # Uwagi podobne jak przy funkcji gaussian_elimination_with_choice()
            # Uwzględniamy dodatkowe ograniczenie ze względu na stałe występowanie wartości zerowych od pewnego indeksu
            best_index = k
            for a in k:down_to
                if abs(A[permutation[a], k]) > abs(A[permutation[best_index], k])
                    best_index = a
                end
            end

            if best_index != k
                permutation[k], permutation[best_index] = permutation[best_index], permutation[k]
            end

            # Pamiętamy najwyższy dotychczas index wiersza, aby dostosować ilość potencjalnie niezerowych kolumn
            if permutation[k] > max_row
                max_row = permutation[k]
            elseif k > max_row
                max_row = k
            end

            max_rows[k] = max_row

            # Uwagi do pomijanych elementów jak przy funkcji gaussian_elimination()
            for i in k+1:down_to
                lik = A[permutation[i], k] / A[permutation[k], k]
                A[permutation[i], k] = lik

                # Uwagi do pomijanych elementów jak przy funkcji gaussian_elimination()
                for j in k+1:min(max_row+l, n)
                    A[permutation[i], j] -= lik * A[permutation[k], j]
                end
            end
        end

        return permutation, max_rows
    end


    # Znając rozkład A = LU zadanie Ax = b sprowadzamy do rozwiązania dwóch układów trójkątnych
    # Ly = b oraz Ux = y
    function x_from_lu(A, l, b, error ,p=nothing, max_rows=nothing)
        n = size(A, 1)
        x = zeros(Float64, n)
        result_file = "results/lu_choice/$(n).txt"

        if p === nothing
            result_file = "results/lu/$(n).txt"
            p = [1:n;]
        end

        if max_rows === nothing
            result_file = "results/lu/$(n).txt"
            max_rows = [1:n;]
        end

        # Wiemy, że L ma na przekątnej jedynki, z tego powodu dostajemy z mnożenia
        # a11 * b1 + a22 * b2 + ... + ann * bn = (akk = 1) = b1 + b2 + ... + bn
        # Domyślnie zatem wymnożona przekątna odpowiada wektorowi b (y zapiszemy w miejscu b dla oszczędności pamięci)
        # Będziemy w kolejnych iteracjach odejmować wartości po kolejnych kolumnach z obecnego wiersza aż do przekątnej
        start_j = 1
        for i in 2:n

            if p[i] % l == 1 && p[i] != 1
                start_j = p[i] - 1
            end

            for j in start_j:i-1
                b[p[i]] -= A[p[i], j] * b[p[j]]
            end
        end

        # U jest macierzą górnotrójkątną, dlatego liczenie x odbywa się jak dla rozwiązywania Ax = b
        open(result_file, "w") do file
            sum_error = 0
            for i in n:-1:1
                sum_val = 0.0
                for j in i+1:min(max_rows[i]+l, n)
                    sum_val += A[p[i], j] * x[j]
                end
                x[i] = (b[p[i]] - sum_val) / A[p[i], i]
                sum_error += abs(x[i] - 1.0) / abs(1.0)
            end
            
            if error == true
                # x_ones = ones(Float64, n)
                # abs_error = abs(norm(x) - norm(x_ones)) / abs(norm(x_ones))
                abs_error = sum_error / n
                println(file, "Error: ", abs_error)
            end

            for element in x
                println(file, element)
            end
        end
    
        return x

    end


    function solve_lu(A, l, b=nothing)
        error = false
        if b === nothing
            b = create_b(A, l)
            error = true
        end

        lu_generation(A, l)

        return x_from_lu(A, l, b, error)
    end

    function solve_lu_choices(A, l, b=nothing)
        error = false
        if b === nothing
            b = create_b(A, l)
            error = true
        end

        p, max = lu_generation_with_choice(A, l)

        return x_from_lu(A, l, b, error, p, max)
    end


end