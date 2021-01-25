#!/usr/bin/env julia

using Memoize
using LRUCache

const DATA_DIR   = "../19_data"
const DQUOTE = "\""
const INPUT_FILE = "input.txt"

# ---------------------------------------- 
macro assert(bool_expr)
    message = string("Assertion: ", bool_expr, " failed")
    :($(esc(bool_expr)) || error($message))
end
# ---------------------------------------- 

abstract type Rule end

struct RuleRefs <: Rule
    branches::Array{Array{Int,1},1}
end

struct RuleSimple <: Rule
    str::String
end

# ----------------------------------------

function get_valid_count(rules::Dict{Int,Rule}, rid::Int, msgs::Array{String,1})::Int
    rid2msgs = rid->get_valid_msgs(rules, rid)

    @memoize LRU{Tuple{Any, Any}, Any}(maxsize=10000) #=
 =# function get_valid_msgs(rules::Dict{Int,Rule}, rid::Int)::Set{String}
        result = nothing
        rule = rules[rid]
        if typeof(rule) == RuleSimple
            return Set([string(rule.str)])
        else  # RuleRefs
            branch2msgs = branch->msg_prod(map(rid2msgs, branch))
            return msg_union(map(branch2msgs, rule.branches))
        end
    end

    valid_msgs = get_valid_msgs(rules::Dict{Int,Rule}, rid::Int)
    return length([1 for msg in msgs if msg in valid_msgs])
end

function map2(f, arr2)
    return [[f(x) for x in coll] for coll in arr2]
end

function msg_prod(sets::Array{Set{String},1})::Set{String}
    prod = (set1, set2) -> Set([a*b for a in set1 for b in set2])
    return foldl(prod, sets)
end

function msg_union(sets::Array{Set{String},1})::Set{String}
    return reduce(union, sets; init=Set())
end

function rule_parse(rule_str::String)::Rule
    # println("Parsing $(rule_str)")
    if occursin(DQUOTE, rule_str)
	m = match(r"\"(\w+)\"", rule_str)
        if isnothing(m)
            error("Unrecognized rule syntax (simple)")
        else
            str = string(m.captures[1])
            return RuleSimple(str)
        end
    else
        m = match(r"((?:\s|\d|\|)+)", rule_str)
        if isnothing(m)
            error("Unrecognized rule syntax (subrule)")
        else
            rule_refs = m.captures[1]
            strings2 = map(split_nonempty, split(rule_refs, "|"))
            ints2 = map2(s->parse(Int, s), strings2)
            return RuleRefs(ints2)
        end
    end
end

function rules_parse(rule_strs::Array{String,1})::Dict{Int,Rule}
    rules::Dict{Int,Rule} = Dict{Int,Rule}()
    for rule_str in rule_strs
        (rid_str, rule_body) = split(rule_str, ": ")
        rid::Int = parse(Int, rid_str)
        rules[rid] = rule_parse(string(rule_body))
    end
    return rules
end

function rules_print(rules::Dict{Int,Rule})
    println("===== Rules =====")
    for rid in keys(rules)
        println("$(rid): $(rules[rid])")
    end
end

split_nonempty = s->filter(z->!isempty(z), split(s, " "))

function split_on_empty(xs)
    return split_on_pred(xs, x->isempty(x))
end

function split_on_pred(xs, pred)
    result = []
    current = []
    for x in xs
       if pred(x) && !isempty(current)
           push!(result, current)
           current = []
       else
           push!(current, x)
       end
    end
    if !isempty(current)
        push!(result, current)
    end
    return result
end

# ---------------------------------------- 

function test_all()
    test_msg_prod()
end

function test_msg_prod()
    args = [Set(["a","b"]), Set(["x","y"])]
    result = msg_prod(args)
    @assert length(result) == 4
end

# ---------------------------------------- 

function main(filename::String)
    test_all()

    lines::Array{String,1} = readlines(filename)
    sections = split_on_empty(lines)
    if length(sections) != 2
        error("Input does not contain rules and messages sections")
    end
    rule_lines::Array{String,1}, msgs::Array{String,1} = tuple(sections...)
    println("# Rule count: $(length(rule_lines))")
    println("# Msgs count: $(length(msgs))")

    rules::Dict{Int,Rule} = rules_parse(rule_lines)
    rid = 0
    valid_count = get_valid_count(rules, rid, msgs)
    println("valid_count=$(valid_count)")
end

main("$DATA_DIR/$INPUT_FILE")
