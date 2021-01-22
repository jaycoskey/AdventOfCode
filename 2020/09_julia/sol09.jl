#!/usr/bin/env julia

const DATA_DIR = "../09_data"
const IS_TEST = false

if IS_TEST
    const INPUT_FILE    = "input_test.txt"
    const PREAMBLE_SIZE = 5
else
    const INPUT_FILE    = "input.txt"
    const PREAMBLE_SIZE = 25
end

macro assert(bool_expr)
    message = string("Assertion: ", bool_expr, " failed")
    :($(esc(bool_expr)) || error($message))
end

function does_contain_distinct_sum(window, val)
    for i in 1:length(window)-1
        for j in i+1:length(window)
            if val == window[i] + window[j]
                return (true, i, j)
            end
        end
    end
    return (false, 0, 0)
end

function get_encryption_weakness(vals, val)
    for width in 2 : length(vals) - 1
        for start in 1 : length(vals) - width + 1
            # println("\t(width, start) = ($(width), $(start))")
            src_range = vals[start : start + width - 1]
            if sum(src_range) == val
                return (true, start, width)
            end
        end
    end
    return (false, 0, 0)
end

function main(filename::String, preamble_size::Int64)
    lines = readlines(filename)
    vals = map(s->parse(Int64, s), lines)
    for k in PREAMBLE_SIZE + 1 : 1 : length(vals)
        # println("size of vals=$(length(vals)), k=$(k)")
        (is_valid, i, j) = does_contain_distinct_sum(
            view(vals, k-PREAMBLE_SIZE : k), vals[k]
            )
        if is_valid
            val_i = vals[k - PREAMBLE_SIZE + i]
            val_j = vals[k - PREAMBLE_SIZE + j]
            # println("At position $(k): $(vals[k]) = $(val_i) + $(val_j)")
        else
            println("========== PART 1 ==========")
            println("At position $(k): $(vals[k]) is not a distinct sum from the lagging window")
            (did_find_sum, start, width) = get_encryption_weakness(vals, vals[k])
            println()
            println("========== PART 2 ==========")
            if did_find_sum
                items = @view vals[start : start + width - 1]
                mn = minimum(items)
                mx = maximum(items)
                println("Target is the sum of numbers ranging from $(mn) to $(mx)")
                println("items=$(items)")
                println("$(mn) + $(mx) = $(mn + mx)")
            else
                println("Did not find range that sums to target")
            end
            return 0
        end
    end
    println("All values after preamble are distinct sums from lagging window")
end

main("$DATA_DIR/$INPUT_FILE", PREAMBLE_SIZE)
