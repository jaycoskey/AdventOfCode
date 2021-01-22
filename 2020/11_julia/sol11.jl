#!/usr/bin/env julia

const DATA_DIR   = "../11_data"
const INPUT_FILE = "input.txt"

const SEAT_EMPTY    = 'L'
const SEAT_FLOOR    = '.'
const SEAT_OCCUPIED = '#'

# ----------------------------------------
macro assert(bool_expr)
    message = string("Assertion: ", bool_expr, " failed")
    :($(esc(bool_expr)) || error($message))
end
# ----------------------------------------

function nbhd_1(seats, row, col)
    row_max = length(seats)
    col_max = length(seats[1])

    nbrs = Tuple{Int, Int}[]
    for row_adj in (row - 1:row + 1)
        for col_adj in (col - 1:col + 1)
            if (row_adj == row && col_adj == col)
                continue
            end
            if (1 <= row_adj <= row_max && 1 <= col_adj <= col_max)
               push!(nbrs, (row_adj, col_adj))
            end
        end
    end
    return nbrs
end

function nbhd_2(seats, row, col)
    row_max = length(seats)
    col_max = length(seats[1])
    nbrs = []
    dirs = [[dr, dc] for dr in -1:1 for dc in -1:1 if (dr != 0 || dc != 0)]
    for dir in dirs
        current = [row, col]
        while true
            current += dir
            if !is_in_range(row_max, col_max, current[1], current[2])
                break
            end
            if ( is_empty(seats, current[1], current[2])
               || is_occ(seats, current[1], current[2])
               )
                push!(nbrs, current)
                break
            end
        end
    end
    return nbrs
end

function nbhd_occ_count(seats, row, col, nbhd_rule)
    nbhd_occ_count = 0
    nbhd = nbhd_rule(seats, row, col)
    for nbr in nbhd
        if is_occ(seats, nbr[1], nbr[2])
            nbhd_occ_count += 1
        end
    end
    return nbhd_occ_count
end

function get_next_seats(seats, nbhd_rule, nbhd_thresh, verbose=false)
    result = deepcopy(seats)
    for row in 1:length(seats)
        for col in 1:length(seats[1])
            if ( (is_empty(seats, row, col)
                 && nbhd_occ_count(seats, row, col, nbhd_rule) == 0)
               )
                result[row][col] = SEAT_OCCUPIED
            elseif ( is_occ(seats, row, col)
                       && nbhd_occ_count(seats, row, col, nbhd_rule) >= nbhd_thresh
                   )
                result[row][col] = SEAT_EMPTY
            end
        end
    end
    return result
end

function is_empty(seats, row, col)
    result = seats[row][col] == SEAT_EMPTY
    return result
end

function is_in_range(row_max, col_max, row, col)
    return 1 <= row <= row_max && 1 <= col <= col_max
end

function is_occ(seats, row, col)
    result = seats[row][col] == SEAT_OCCUPIED
    return result
end

function occs(seats)
    result = 0
    for row in 1:length(seats)
        for col in 1:length(seats[1])
            if is_occ(seats, row, col)
                result += 1
            end
        end
    end
    return result
end

function show(seats)
    for row in seats
        for seat in row
            print(seat)
        end
        println()
    end
end

function test_show_versions(seats)
    version = 1
    while version <= 6
        println("VERSION $version:")
        show(seats)

        seats = get_next_seats(seats)
        version += 1
        version < 6 && println("====================")
    end
end

# ----------------------------------------

function get_occupied_count(seats, nbhd_rule, nbhd_thresh)
    round_num = 0
    while true
        round_num += 1
        # println("Round # = $(round_num)")
        next_seats = get_next_seats(seats, nbhd_rule, nbhd_thresh)
        # println("INFO: next_seats={next_seats}, seats={seats}")
        if all(next_seats .== seats)
            println("Count of stably occupied seats=$(occs(seats))")
            break
        end
        seats = next_seats
    end
end

function main()
    filename = "$DATA_DIR/$INPUT_FILE"
    seats = map(s->[c for c in s], readlines(filename))
    println("========== PART 1 ==========")
    get_occupied_count(seats, nbhd_1, 4)
    println()
    println("========== PART 1 ==========")
    get_occupied_count(seats, nbhd_2, 5)
end

main()
