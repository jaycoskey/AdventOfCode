#!/usr/bin/env julia

import Parsers

const DATA_DIR   = "../14_data"
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

function get_adjvals(floating_bits)
    result = Int[]  # Array{Int,1}()
    num_floating_bits = length(floating_bits)
    for comb_id in 0:2^num_floating_bits-1
        comb_bitvec = get_bitvals(comb_id)
        adj_vals = [ 2^floating_bits[k] for (k,bitval) in enumerate(comb_bitvec)
                     if bitval == 1
                   ]
        adj_val = length(adj_vals) > 0 ? sum(adj_vals) : 0
        push!(result, adj_val)
    end
    return result
end

function get_bitvals(val)
    result = []
    for k in 0:100
        val_mod_2 = val % 2
        push!(result, val_mod_2 == 0 ? 0 : 1)
        val >>= 1
        if val == 0
            return result
        end
    end
end

function get_bitvec(val)
    result = BitVector()
    for k in 0:100
        val_mod_2 = val % 2
        push!(result, val_mod_2 == 0 ? 0 : 1)
        val >>= 1
        if val == 0
            return result
        end
    end
end

# ---------------------------------------- 

function part1(lines)
    banner("PART 1")
    mask0 = nothing
    mask1 = nothing
    memory = Dict{Int, Int}()
    for line in lines
        # println("line=$(line)")
        if line[1:4] == "mask"
            m = match(r"^[^=]+=\s([01X]+)", line)
            mask_str = m.captures[1]
            mask0 = 0
            mask1 = 0
            for k in 0:length(mask_str)-1
                c = mask_str[length(mask_str) - k]
                mask0 += (c == '0') ? 2^k : 0
                mask1 += (c == '1') ? 2^k : 0
            end
            # println("mask0 = $(mask0)")
            # println("mask1 = $(mask1)")
        elseif line[1:3] == "mem"
            m = match(r"^mem\[(\d+)\]\s=\s(\d+)", line)
            loc = parse(Int, m.captures[1])
            val = parse(Int, m.captures[2])
            val = (val | mask1) & (~mask0)
            # println("\tmem[$(loc)] = $(val)")
            memory[loc] = val
        end
    end
    mem_total = sum(values(memory))
    println("mem_total=$(mem_total)")
end

function part2(lines)
    banner("PART 2")
    mem0 = nothing
    mem1 = nothing
    mem_x = nothing
    floating_bits = nothing
    memory = Dict{Int, Int}()

    for line in lines
        # println("====================")
        # println("line=$(line)")
        if startswith(line, "mask")
            m = match(r"^[^=]+=\s([01X]+)", line)
            mask_str = m.captures[1]
            mem0 = 0
            mem1 = 0
            mem_x = 0
            mask_x_count = 0
            floating_bits = []

            for k in 0:length(mask_str)-1
                c = mask_str[length(mask_str) - k]
                mem1  += (c == '1') ? 2^k : 0
                mem_x += (c == 'X') ? 2^k : 0
                if c == 'X'
                    append!(floating_bits, k)  # length(mask_str)
                end
            end
            # println("mem0 = $(mem0)")
            # println("mem1 = $(mem1)")
        elseif startswith(line, "mem")
            m = match(r"^mem\[(\d+)\]\s=\s(\d+)", line)
            mem_raw = parse(Int, m.captures[1])
            val = parse(Int, m.captures[2])

            mem_base = (mem_raw | mem1) & ~mem_x
            for adjval in get_adjvals(floating_bits)
                mem = mem_base + adjval
                memory[mem] = val
            end
        end
    end
    mem_total = sum(values(memory))
    println("mem_total=$(mem_total)")
end

function main(filename::String)
    lines::Array{String} = readlines(filename)
    part1(lines)
    println()
    part2(lines)
end

main("$DATA_DIR/$INPUT_FILE")
