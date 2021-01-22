#!/usr/bin/env julia

const DATA_DIR   = "../18_data"
const DEBUG      = false
const INPUT_FILE = "input.txt"

const OP_PLUS  = '+'
const OP_TIMES = '*'
const OPS = [OP_PLUS, OP_TIMES]

const PAREN_LEFT  = '('
const PAREN_RIGHT = ')'
const PARENS      = [PAREN_LEFT, PAREN_RIGHT]

# ---------------------------------------- 

# Note: Form parenthetical groups from op eval
function control_precedence(c)
    if c == PAREN_LEFT
        return 0
    elseif c == OP_PLUS
        return 2
    elseif c == OP_TIMES
        return 1
    else
        error("Unrecognized operator")
    end
end

function op_eval(a, op, b)
    if op == '+'
        return a + b
    elseif op == '*'
        return a * b
    end
end

function dprintln(s)
   if DEBUG
       println(s)
   end 
end

function top_eval!(vals, controls)
    val2 = pop!(vals)
    val1 = pop!(vals)
    op = pop!(controls)
    opval = op_eval(val1, op, val2)
    push!(vals, opval)
    dprintln("\tINFO: top_eval!: val1=$(val1), op=$(op), val2=$(val2), opval=$(opval)")
end

function expr_eval(expr::String)
    dprintln("INFO: expr_eval: Evaluating $(expr)")
    vals = []
    controls = []  # Ops & lparens, but not rparens
    loc = 1
    while loc <= length(expr)
        c = expr[loc]
        if isspace(c)
            loc += 1
            continue
        end
        dprintln("INFO:    Processing token $(c)")

        if isdigit(c)
            val = parse(Int, c)
            ### loc += 1
            ### while loc <= length(expr) && isdigit(expr[loc])
            ###     val = (val * 10) + parse(Int, expr[loc])
            ###     loc += 1
            ### end
            ### loc -= 1
            push!(vals, val)
            dprintln("\tINFO: LOOP(digit): Pushed val=$(val)")
        elseif c == PAREN_LEFT
            push!(controls, c)
            dprintln("\tINFO: LOOP(lparen): Pushed control=$(c)")
        elseif c == PAREN_RIGHT  # Eval everything back to last lparen
            while !isempty(controls) && last(controls) != PAREN_LEFT
                top_eval!(vals, controls)
            end
            pop!(controls) # Remove last lparen
            dprintln("\tINFO: LOOP(rparen): Evaluated backlog and popped rparen")
        else
            @assert c in OPS

            # Evaluate previous higher-priority ops before this one
            while !isempty(controls) && control_precedence(last(controls)) >= control_precedence(c)
                # println("\tIn ops while loop: controls=$(controls)")
                top_eval!(vals, controls)
            end
            push!(controls, c)
            dprintln("\tINFO: LOOP(op): Evaluated lower-precedence ops and pushed $(c)")
        end
        loc += 1
    end

    dprintln("\tINFO: Performing clean-up")
    while !isempty(controls)
        top_eval!(vals, controls)
    end

    @assert length(vals) == 1
    @assert isempty(controls)
    return last(vals)
end

function test_eval(expr::String)
    println("Expr: $(expr)")
    val = expr_eval(expr)
    println("\tComputed value: $(val)")
    println("="^20)
end

# ---------------------------------------- 

function main(filename::String)
    lines::Array{String} = readlines(filename)
    total = 0
    for line in lines
        dprintln("="^20)
        val = expr_eval(line)        
        dprintln("val=$(val)")
        total += val
    end
    println("Total of all exprs=$(total)")
end

main("$DATA_DIR/$INPUT_FILE")
