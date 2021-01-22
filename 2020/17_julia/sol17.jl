#!/usr/bin/env julia

const DATA_DIR   = "../17_data"
const INPUT_FILE = "input.txt"

@enum Activity active inactive

# ---------------------------------------- 
macro assert(bool_expr)
    message = string("Assertion: ", bool_expr, " failed")
    :($(esc(bool_expr)) || error($message))
end
# ---------------------------------------- 

struct BBox3
    xmin::Int
    xmax::Int
    ymin::Int
    ymax::Int
    zmin::Int
    zmax::Int
    # --------------------
    function BBox3(grid)
        xmin = xmax = nothing
        ymin = ymax = nothing
        zmin = zmax = nothing
        for p in keys(grid)
            if grid[p] == inactive
                continue
            end
            x = p[1]
            y = p[2]
            z = p[3]
            if isnothing(xmin) || x < xmin
               xmin = x
            end
            if isnothing(xmax) || x > xmax
               xmax = x
            end
            if isnothing(ymin) || y < ymin
               ymin = y
            end
            if isnothing(ymax) || y > ymax
               ymax = y
            end
            if isnothing(zmin) || z < zmin
               zmin = z
            end
            if isnothing(zmax) || z > zmax
               zmax = z
            end
        end
        return new(xmin, xmax, ymin, ymax, zmin, zmax)
    end
end

struct BBox4
    xmin::Int
    xmax::Int
    ymin::Int
    ymax::Int
    zmin::Int
    zmax::Int
    wmin::Int
    wmax::Int
    # --------------------
    function BBox4(grid)
        xmin = xmax = nothing
        ymin = ymax = nothing
        zmin = zmax = nothing
        wmin = wmax = nothing

        for p in keys(grid)
            if grid[p] == inactive
                continue
            end
            x = p[1]
            y = p[2]
            z = p[3]
            w = p[4]

            (isnothing(xmin) || x < xmin) && (xmin = x)
            (isnothing(xmax) || x > xmax) && (xmax = x)

            (isnothing(ymin) || y < ymin) && (ymin = y)
            (isnothing(ymax) || y > ymax) && (ymax = y)

            (isnothing(zmin) || z < zmin) && (zmin = z)
            (isnothing(zmax) || z > zmax) && (zmax = z)

            (isnothing(wmin) || w < wmin) && (wmin = w)
            (isnothing(wmax) || w > wmax) && (wmax = w)
        end
        return new(xmin, xmax, ymin, ymax, zmin, zmax, wmin, wmax)
    end
end

# ---------------------------------------- 

function Base.show(io::IO, bb::BBox3)
    print(io, "BBox3: $(bb.xmin)->x->$(bb.xmax), $(bb.ymin)->y->$(bb.ymax), $(bb.zmin)->z->$(bb.zmax)")
end

function Base.show(io::IO, bb::BBox4)
    print(io, "BBox4: $(bb.xmin)->x->$(bb.xmax), $(bb.ymin)->y->$(bb.ymax), $(bb.zmin)->z->$(bb.zmax), $(bb.wmin)->w->$(bb.wmax)")
end

function banner(txt::String)
    println('='^10, ' ', txt, ' ', '='^10)
end

const dxyzs = [ [dx,dy,dz]
                for dx in -1:1
                for dy in -1:1
                for dz in -1:1
                if !(dx==dy==dz==0)
              ]

const dps = [ [dx,dy,dz,dw]
              for dx in -1:1
              for dy in -1:1
              for dz in -1:1
              for dw in -1:1
              if !(dx==dy==dz==dw==0)
            ]

function get_states_count(grid)
    on  = length([1 for (p, state) in grid if state == active])
    off = length([1 for (p, state) in grid if state == inactive])
    return (on, off)
end

function get_nbr_count(grid, p, deltas)
    nbrs = [p+dp for dp in deltas if p+dp in keys(grid) && grid[p+dp] == active]
    return length(nbrs)
end

function get_nextgrid(prevgrid, deltas)
    states_prev = get_states_count(prevgrid)

    nextgrid = deepcopy(prevgrid)
    states_next = get_states_count(nextgrid)

    # ==================== Expand ====================
    next_keys = [p for (p, state) in nextgrid if state == active]
    for p in next_keys
        for dp in deltas
            if !(p+dp in keys(nextgrid))
                # println("@p=$(p): dp=$(dp). Adding $(p+dp)")
                nextgrid[p+dp] = inactive
            end
        end
    end

    # ==================== Cycle ====================
    # Note: We already copied, so here we only track changes
    for p in keys(nextgrid)
        nbr_count = get_nbr_count(prevgrid, p, deltas)  # active(prevgrid) == active(nextgrid)
        if get_state(prevgrid, p) == active && (nbr_count < 2 || nbr_count > 3)
            # println("INFO: $(p) --> inactive ($(nbr_count) nbrs)")
            nextgrid[p] = inactive
        elseif get_state(prevgrid, p) == inactive && nbr_count == 3
            # println("INFO: $(p) --> active   ($(nbr_count) nbrs)")
            nextgrid[p] = active
        end
    end

    # ==================== Prune ====================
    result = Dict([(p, state) for (p, state) in nextgrid if state == active])
    return result
end

function get_state(grid, p)
    return (p in keys(grid)) ? grid[p] : inactive
end

function popcount(grid)
    return length([1 for (p, state) in grid if state == active])
end

function print_grid3(label, grid)
    bb = BBox3(grid)
    println("vvvvv $(label): BBox3=$(bb) vvvvv")
    for z in bb.zmin:bb.zmax
        println("----- $(label): z=$(z) -----")
        for y in bb.ymin:bb.ymax
            for x in bb.xmin:bb.xmax
                if [x,y,z] in keys(grid)
                    print(grid[[x,y,z]] == active ? "#" : ".")
                else
                    print(".")
                end
            end
            println()
        end
        println()
    end
    println("^^^^^^^^^^^^^^^^^^^^")
end

function print_grid4(label, grid)
    bb = BBox4(grid)
    println("vvvvv $(label): BBox=$(bb) vvvvv")
    for w in bb.wmin:bb.wmax
        for z in bb.zmin:bb.zmax
            println("----- $(label): z=$(z), w=$(w)  -----")
            for y in bb.ymin:bb.ymax
                for x in bb.xmin:bb.xmax
                    state = get_state(grid, [x,y,z,w])
                    print(state == active ? "#" : ".")
                end
                println()
            end
            println()
        end
    end
    println("^^^^^^^^^^^^^^^^^^^^")
end

# ---------------------------------------- 

function part1(lines::Array{String}, verbose=false)
    banner("PART 1")

    xyzs = [ [x, y, 0] 
             for (y, row) in enumerate(lines)
             for (x, c) in enumerate(row)
             if c == '#'
           ]
    grid0 = Dict([(p, active) for p in xyzs])
    verbose && print_grid3("Original grid", grid0)

    grid1 = get_nextgrid(grid0, dxyzs)
    verbose && print_grid3("After 1 cycle", grid1)

    grid2 = get_nextgrid(grid1, dxyzs)
    verbose && print_grid3("After 2 cycles", grid2)

    grid3 = get_nextgrid(grid2, dxyzs)
    verbose && print_grid3("After 3 cycles", grid3)

    grid4 = get_nextgrid(grid3, dxyzs)
    verbose && print_grid3("After 4 cycles", grid4)

    grid5 = get_nextgrid(grid4, dxyzs)
    verbose && print_grid3("After 5 cycles", grid5)

    grid6 = get_nextgrid(grid5, dxyzs)
    verbose && print_grid3("After 6 cycles", grid6)

    println("Popcount after 6 cycles: $(popcount(grid6))")
end

function part2(lines::Array{String})
    banner("PART 2")

    ps = [[x,y,0,0] for (y, row) in enumerate(lines) for (x, c) in enumerate(row) if c == '#']
    grid0 = Dict([(p, active) for p in ps])
    # print_grid4("Original grid", grid0)

    grid1 = get_nextgrid(grid0, dps)
    grid2 = get_nextgrid(grid1, dps)
    grid3 = get_nextgrid(grid2, dps)
    grid4 = get_nextgrid(grid3, dps)
    grid5 = get_nextgrid(grid4, dps)
    grid6 = get_nextgrid(grid5, dps)
    println("Popcount after 6 cycles: $(popcount(grid6))")
end

function main(filename::String)
    lines::Array{String} = readlines(filename)
    part1(lines)
    println()
    part2(lines)
end

main("$DATA_DIR/$INPUT_FILE")
