#!/usr/bin/env julia

const DATA_DIR   = "../16_data"
const INPUT_FILE = "input.txt"

# ---------------------------------------- 
macro assert(boolean)
    message = string("Assertion: ", boolean, " failed")
    :($(esc(boolean)) || error($message))
end
# ---------------------------------------- 

struct Field
    name::String
    amin::Int
    amax::Int
    bmin::Int
    bmax::Int
    #--------------------
    function Field(name, amin, amax, bmin, bmax)
        return new(name, amin, amax, bmin, bmax)
    end
end

# ---------------------------------------- 

function banner(txt::String)
    println('='^10, ' ', txt, ' ', '='^10)
end

function is_solved(possible_ords)
    for key in keys(possible_ords)
        if length(possible_ords[key]) > 1
            return false
        end
    end
    return true
end

function is_ticket_valid(fields, ticket)
    for val in ticket
        if !is_value_valid(fields, val)
            return false
        end
    end
    return true
end

function is_value_valid(fields, val)
    for f in fields
        if is_value_valid_for_field(f, val)
            return true
        end
    end
    return false
end

function is_value_valid_for_field(f, val)
    return (f.amin <= val <= f.amax) || (f.bmin <= val <= f.bmax)
end

function get_error_rate(fields, other_tickets)
    result = 0
    for ticket in other_tickets
        for val in ticket
            # print("$(val)")
            if !is_value_valid(fields, val)
                # println("error_val=$(val)")
                result += val
            end
        end
    end
    return result
end

function print_possible_ords(possible_ords)
    for key in keys(possible_ords)
        println("Possible: $(key) ==> $(possible_ords[key])")
    end
end

# ---------------------------------------- 

function main()
    lines::Array{String} = readlines("$DATA_DIR/$INPUT_FILE")
    mode = "Fields"
    fields = []
    your_ticket = nothing
    other_tickets = []

    for (line_num, line) in enumerate(lines)
        # println("$(line_num): mode=$(mode): $(line)")
        if line == ""
            if mode == "Fields"
                mode = "YourTicket"
            elseif mode == "YourTicket"
                mode = "OtherTickets"
            end
        elseif mode == "Fields"
            m = match(r"([^:]+):\s(\d+)-(\d+)\sor\s(\d+)-(\d+)", line)
            name = m.captures[1]
            amin = parse(Int, m.captures[2])
            amax = parse(Int, m.captures[3])
            bmin = parse(Int, m.captures[4])
            bmax = parse(Int, m.captures[5])
            f = Field(name, amin, amax, bmin, bmax)
            push!(fields, f)
        elseif mode == "YourTicket"
            if !startswith(line, "your")
                your_ticket = map(s->parse(Int, s), split(line, ","))
            end
        elseif mode == "OtherTickets"
            if !startswith(line, "nearby")
                ticket_vals = map(s->parse(Int, s), split(line, ","))
                push!(other_tickets, ticket_vals)
            end
        else
            @assert false
        end
    end

    ####################
    # Data summary
    ####################
    println("Field count: $(length(fields))")
    println("Your ticket: $(your_ticket)")
    println("Other tix:   $(length(other_tickets))")

    ####################
    # Part 1
    ####################
    banner("PART 1")
    error_rate = get_error_rate(fields, other_tickets)
    println("Error rate=$(error_rate)")

    ####################
    # Part 2
    ####################
    println()
    banner("PART 2")
    possible_ords = Dict{String,Array{Int}}()
    for f in fields
        possible_ords[f.name] = []
        for k in 1:length(your_ticket)
            push!(possible_ords[f.name], k)
        end
    end
    # print_possible_ords(possible_ords)

    valid_tickets = filter(t->is_ticket_valid(fields, t), other_tickets)
    println("There are $(length(valid_tickets)) valid tickets")
    for vt in valid_tickets
        for (k, val) in enumerate(vt)
           for f in fields
               if k in possible_ords[f.name] && !is_value_valid_for_field(f, val)
                   # println("Note: Because of val=$(val), $(f.name) cannot lie at position $(k)")
                   deleteat!(possible_ords[f.name], findfirst(v->v==k, possible_ords[f.name]))
               end
           end
        end
    end

    sat_round = 0
    while !is_solved(possible_ords)
        sat_round += 1
        # println("Beginning SAT round #$(sat_round)")
        singletons = []
        for name in keys(possible_ords)
            if length(possible_ords[name]) == 1
                push!(singletons, possible_ords[name][1])
            end
        end
        for single in singletons
            for name in keys(possible_ords)
                if length(possible_ords[name]) > 1 && single in possible_ords[name]
                    deleteat!(possible_ords[name], findfirst(v->v==single, possible_ords[name]))
                end
            end
        end
    end
    # print_possible_ords(possible_ords)

    result = 1
    for f in fields
        if startswith(f.name, "departure")
            result *= your_ticket[possible_ords[f.name][1]]
        end
    end 
    println("Result for part two: $(result)")
end

main()
