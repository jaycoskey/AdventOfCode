#!/usr/bin/env julia

const MAX_IND = 2020

# ---------------------------------------- 
macro assert(boolean)
    message = string("Assertion: ", boolean, " failed")
    :($(esc(boolean)) || error($message))
end
# ---------------------------------------- 

function banner(txt::String)
    println('='^10, ' ', txt, ' ', '='^10)
end

function get_maxind(starting, max_ind)
    val2ind          = Dict{Int, Int}()
    prev_val         = nothing
    is_prev_val_seen = nothing

    for k_val in enumerate(starting)
        k = k_val[1]
        val = k_val[2]
        is_prev_val_seen = in(val, keys(val2ind))
        prev_val = val
        val2ind[val] = k
        # println("@$(k): val2ind=$(val2ind)")
    end

    for k in length(starting) + 1 : max_ind
        if k % 1000000 == 0
            print(".")
        end
        if is_prev_val_seen
            val = (k - 1) - val2ind[prev_val]
            val2ind[prev_val] = k - 1
            # println("\tk=$(k): $(prev_val) SEEN. New val = $(val)")
        else
            val = 0
            val2ind[prev_val] = k - 1
            # println("\tk=$(k): $(prev_val) NOT seen. New val = 0")
        end
        is_prev_val_seen = in(val, keys(val2ind))
        prev_val = val
        # println("\t@$(k): $(starting) ---> $(val)")
    end

    # println("@ $(max_ind): $(prev_val)") 
    return prev_val 
end
     
# ----------------------------------------

function test_maxind(starting, max_ind, expected)
    result = get_maxind(starting, max_ind)
    if (result == expected)
        println("Test passed: $(starting) @ $(max_ind) == $(expected)")
    else
        println("TEST FAILED: $(starting) @ $(max_ind) != $(expected)")
    end
end

# ----------------------------------------

function main()
    test_maxind([0, 3, 6], 9, 4)

    test_maxind([1, 3, 2], MAX_IND, 1)
    test_maxind([2, 1, 3], MAX_IND, 10)
    test_maxind([1, 2, 3], MAX_IND, 27)
    test_maxind([2, 3, 1], MAX_IND, 78)
    test_maxind([3, 2, 1], MAX_IND, 438)
    test_maxind([3, 1, 2], MAX_IND, 1836)

    banner("PART 1")
    starting = [1,0,18,10,19,6]
    result = get_maxind(starting, MAX_IND)
    println("PART 1: $(starting) --> $(result)")
    println()
    banner("PART 2")
    starting = [1,0,18,10,19,6]
    result = get_maxind(starting, 30_000_000)
    println("\nPART 2: $(starting) --> $(result)")
end

main()
