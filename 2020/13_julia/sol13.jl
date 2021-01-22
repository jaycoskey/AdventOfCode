#!/usr/bin/env julia

import Parsers

const DATA_DIR   = "../13_data"
const INPUT_FILE = "input.txt"

# ---------------------------------------- 
macro assert(bool_expr)
    message = string("Assertion: ", bool_expr, " failed")
    :($(esc(bool_expr)) || error($message))
end
# ---------------------------------------- 

function banner(txt::String)
    println('='^10, ' ', txt, ' ', '='^10)
end

function get_earliest_ts(freq_str)
    strs = split(strip(freq_str), ",")
    str2int = s->Parsers.tryparse(Int, string(s))
    bus_freqs = [ (eid[1]-1,eid[2]) for eid in enumerate(str2int.(strs))
                  if !isnothing(eid[2])
                ]
    println("bus_freqs=$(bus_freqs)")
    bus_freqs = sort(bus_freqs, by=eid->eid[2], rev=true)
    println("bus_freqs=$(bus_freqs)")

    ts = 0
    step = 1
    for (offset, id) in bus_freqs
        while true
            if (ts + offset) % id == 0
               step *= id
               break
            end
            ts += step
        end
    end
    return ts
end

# ---------------------------------------- 

function test()
    test_freqs("17,13,x,x,59,x,31,19", 1068781)

    test_freqs("17,x,13,19",      3417)
    test_freqs("67,7,59,61",      754018)
    test_freqs("67,x,7,59,61",    779210)
    test_freqs("67,7,x,59,61",    1261476)
    test_freqs("1789,37,47,1889", 1202161486)
end

function test_freqs(freq_str, expected)
    result = get_earliest_ts(freq_str)
    if (result == expected)
        println("\tPASS: $(result) == $(expected)")
    else
        println("\tFAIL: $(result) != $(expected)")
    end
end

function test_maxind(starting, max_ind, expected)
    println("====================")
    result = get_maxind(starting, max_ind)
    if (result == expected)
        println("Test passed: $(starting) @ $(max_ind) == $(expected)")
    else
        println("TEST FAILED: $(starting) @ $(max_ind) != $(expected)")
    end
end
 
# ---------------------------------------- 

function part1(lines)
    banner("PART 1")
    ready_time = parse(Int, lines[1])
    strs = split(strip(lines[2]), ",")
    str2int = s->Parsers.tryparse(Int, string(s))
    bus_freqs = [k for k in str2int.(strs) if !isnothing(k)]
    wait_times = [(bf, bf - (ready_time % bf)) for bf in bus_freqs]
    bus_wait = sort(wait_times, by=((bf,wt),)->wt)[1]

    println("ready_time=$(ready_time)")
    println("bus_freqs=$(bus_freqs)")
    println("wait_times=$(wait_times)")
    # println("bus_target=$(bus_target)")
    println("solution=$(bus_wait[1] * bus_wait[2])")
end

function part2(lines)
    println()
    banner("PART 2")
    result = get_earliest_ts(lines[2])
    println("result=$(result)")
end

function main()
    filename = "$DATA_DIR/$INPUT_FILE"
    lines::Array{String} = readlines(filename)
    part1(lines)
    part2(lines)
end

main()
