#!/usr/bin/env julia

const DATA_DIR   = "../12_data"
const DEG2RAD    = pi / 180.0
const INPUT_FILE = "input.txt"

# ---------------------------------------- 
macro assert(bool_expr)
    message = string("Assertion: <<$bool_expr>> failed")
    :($(esc(bool_expr)) || error($message))
end
# ---------------------------------------- 

function manhattan_dist(p)
    return abs(p[1]) + abs(p[2])
end

function part1(cmds)
    println("========== PART 1 ==========")
    state_pos = [0.0, 0.0]
    state_dir = 0.0

    for (opt, val) in cmds
        # println("Part1: opt, val=$opt, $val")
        if opt == 'N';     state_pos[2] += val
        elseif opt == 'S'; state_pos[2] -= val
        elseif opt == 'W'; state_pos[1] -= val
        elseif opt == 'E'; state_pos[1] += val
        elseif opt == 'L'; state_dir += val
        elseif opt == 'R'; state_dir -= val
        elseif opt == 'F'
            dx = val * cos(state_dir * pi / 180.0)
            dy = val * sin(state_dir * pi / 180.0)
            state_pos += [dx, dy]
        end
        # println("\t", "Part 1: Current pos=$(state_pos[1]),$(state_pos[2]), dir=$(state_dir)")
    end
    dist = round(manhattan_dist(state_pos), digits=2)
    println("Part 1: Distance from original location = $(dist)")
end

function part2(cmds)
    println()
    println("========== PART 2 ==========")
    state_pos = [0.0, 0.0]
    state_dir = [10.0, 1.0]

    for (opt, val) in cmds
        # println("Part 2: opt=$opt, val=$(val)")
        if opt == 'N';     state_dir[2] += val
        elseif opt == 'S'; state_dir[2] -= val
        elseif opt == 'W'; state_dir[1] -= val
        elseif opt == 'E'; state_dir[1] += val
        elseif opt == 'L' || opt == 'R'
            cs = cos(val * DEG2RAD)
            sn = sin(val * DEG2RAD)
            if (opt == 'R')
                sn = -1.0 * sn
            end
            new_dir = [cs -sn; sn cs] * state_dir
            state_dir = new_dir
        elseif opt == 'R'
            state_dir -= val
        elseif opt == 'F'
            dx = val * state_dir[1]
            dy = val * state_dir[2]
            state_pos += [dx, dy]
        end
        # println("\tPart 2: Current pos=$(state_pos[1]),$(state_pos[2]), dir=$(state_dir)")
    end
    dist = round(manhattan_dist(state_pos), digits=2)
    println("Part 2: Distance from original location = $(dist)")
end

# ---------------------------------------- 

function main()
    filename = "$DATA_DIR/$INPUT_FILE"
    lines = readlines(filename)
    cmds = map(s->(s[1], parse(Float64, s[2:end])), lines)

    part1(cmds)
    part2(cmds)
end

main()
