#!/usr/bin/env julia

const DATA_DIR   = "../18_data"
const INPUT_FILE = "input.txt"

const LPAREN = '('
const RPAREN = ')'

const OP_PLUS  = '+'
const OP_TIMES = '*'

# ---------------------------------------- 
macro assert(bool_expr)
    message = string("Assertion: ", bool_expr, " failed")
    :($(esc(bool_expr)) || error($message))
end
# ---------------------------------------- 
@enum Op op_plus op_times

mutable struct PartialExpr
    is_subexpr::Bool
    lval::Union{Int, Nothing}
    op::Union{Op, Nothing}
    # --------------------
    function PartialExpr(is_subexpr=false)
        return new(is_subexpr, nothing, nothing)
    end
end
# ---------------------------------------- 

function pexpr_addval!(pexpr, val)
    if isnothing(pexpr.lval)
        pexpr.lval = val
    else
        if isnothing(pexpr.op)
            error("Encountered digit where operator expected")
        else
            new_lval = eval_op(pexpr.lval, pexpr.op, val)
            pexpr.lval = new_lval
            pexpr.op = nothing
        end
    end
end
 
function pexpr_print(pexpr::PartialExpr)
    op_str = isnothing(pexpr.op) ? "" : (pexpr.op == op_plus ? "+" : "*")
    subexpr_str = pexpr.is_subexpr ? "(subexpr)" : ""
    output = "PExpr: $(pexpr.lval) $(op_str) $(subexpr_str)"
    println(strip(output))
end

# ---------------------------------------- 

function eval_op(arg_left::Int, op::Op, arg_right::Int)
    if op == op_plus
        return arg_left + arg_right
    elseif op == op_times
        return arg_left * arg_right
    elseif isnothing(op)
        error("operator is not set")
    else
        error("Unrecognized operator value")
    end
end

function eval_expr(expr::String)
    partials = Array{PartialExpr,1}()
    push!(partials, PartialExpr())
    for c in expr
        if isspace(c)
            continue
        end
        top = last(partials)
        if isdigit(c)
            val = parse(Int, c)
            pexpr_addval!(top, val)
        elseif c == LPAREN
            push!(partials, PartialExpr(true))
        elseif c == RPAREN
            @assert top.is_subexpr
            @assert !isnothing(top.lval)
            @assert isnothing(top.op)
            val = top.lval
            _ = pop!(partials)
            top = last(partials)
            pexpr_addval!(top, val)
        elseif c == OP_PLUS
            @assert !isnothing(top.lval)
            @assert isnothing(top.op)
            top.op = op_plus
        elseif c == OP_TIMES
            @assert !isnothing(top.lval)
            @assert isnothing(top.op)
            top.op = op_times
        else
            error("Unrecognized character: $(c)")
        end
    end
    @assert length(partials) == 1
    only = partials[1]
    @assert !isnothing(only.lval)
    @assert isnothing(only.op)
    return only.lval
end

function main(filename)
    lines::Array{String} = readlines(filename)
    result = 0
    for line in lines
        # println("line=$(line)")
        val = eval_expr(line)
        # println("\tvalue=$(val)")
        result += val
    end
    println("Total of all exprs=$(result)")
end

main("$DATA_DIR/$INPUT_FILE")
