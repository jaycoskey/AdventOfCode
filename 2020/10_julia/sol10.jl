#!/usr/bin/env julia

const DATA_DIR = "../10_data"
const INPUT_FILE    = "input.txt"
# const INPUT_FILE    = "input_test1.txt"  # 24
# const INPUT_FILE    = "input_test2.txt"

macro assert(boolean)
    message = string("Assertion: ", boolean, " failed")
    :($(esc(boolean)) || error($message))
end

function get_groups(jds)
    groups = Array{Tuple{Int, Int}, 1}()
    current_val = nothing
    current_count = 0
    for k in 1:length(jds)
        if jds[k] == current_val
            current_count += 1
        else
            if current_count > 0
                push!(groups, (current_val, current_count))
            end
            current_val = jds[k]
            current_count = 1
        end
    end
    # Add the last group
    push!(groups, (current_val, current_count))
    return groups
end

function part1(diffs)
    println("========== PART 1 ==========")
    diff1_count = length(filter(x -> x == 1, diffs))
    diff3_count = length(filter(x -> x == 3, diffs))
    result = diff1_count * diff3_count
    println("part1 result=$(result)")
end

function part2(diffs)
    println("========== PART 2 ==========")
    groups = get_groups(diffs)
    group1_sizes = [count for (num, count) in groups if num == 1]
    comb_map = Dict(1=>1, 2=>2, 3=>4, 4=>7)  # 3:111,12,21,3. 4:1111,22,13,31,121,211,112
    result = prod(map(n->comb_map[n], group1_sizes))
    println("part2 result=$(result)")
end

function main(filename::String)
    lines = readlines(filename)
    jolts = sort(map(s->parse(Int64, s), lines))
    # diffs = [jolts[k+1] - jolts[k] for k in 1:length(jolts) - 1]
    diffs = [jolts; jolts[end] + 3] - [0; jolts]  # All 1s & 3s (up to 4)

    part1(diffs)
    println()
    part2(diffs)
end

main("$DATA_DIR/$INPUT_FILE")
