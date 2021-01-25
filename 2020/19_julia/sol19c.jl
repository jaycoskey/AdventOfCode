#!/usr/bin/env julia

# using Memoize
# using LRUCache

const DATA_DIR   = "../19_data"
const DQUOTE = "\""

const INPUT_FILE = "input.txt"

# ----------------------------------------

function split_on_empty(xs)
    return split_on_pred(xs, x->isempty(x))
end

# The main logic behind the solution
function is_valid(rules, rule_ids, msg)
    # println("is_valid: rule_ids=$(rule_ids), msg=$(msg)")
    empties = [isempty(rule_ids), isempty(msg)]
    if any(empties)
         return all(empties)  # Better than filtering out on caller side
    end
    rule_first = rules[first(rule_ids)]
    if typeof(rule_first) == String
        # Recurse on the first char of msg
        return msg[1] == rule_first[1] && is_valid(rules, rule_ids[2:end], msg[2:end])
    else
        # Distribute the alternate cases of the first rule into required rule_ids in different calls
        return any(is_valid(rules, vcat(branch, rule_ids[2:end]), msg) for branch in rule_first)
    end
end

function rule_parse(rule_str)
    rule_id, rule_body = split(rule_str, ": ")
    rule_id = parse(Int, rule_id)
    # println("rule_parse: rule_id=$(rule_id), rule_body=$(rule_body)")
    if occursin(DQUOTE, rule_body)
        return (rule_id, string(rule_body[2:2]))
    else
        branches = [[parse(Int, opt) for opt in split_nonempty(branch)] for branch in split(rule_body, "|")]
        # println("branches=$(branches)")
        return (rule_id, branches)
    end
end

split_nonempty = s->filter(z->!isempty(z), split(s, " "))

# TODO: Is there a one-liner for this in Julia?
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

function main()
    lines::Array{String,1} = readlines("$DATA_DIR/$INPUT_FILE")
    rule_lines, msgs = split_on_empty(lines)
    rules = Dict([rule_parse(rule_str) for rule_str in rule_lines])
    valid_count = length(filter(b->b, [is_valid(rules, [0], msg) for msg in msgs]))
    println("Part 1: $(valid_count)")

    (_, rules[8])  = rule_parse("8: 42 | 42 8")
    (_, rules[11]) = rule_parse("11: 42 31 | 42 11 31")
    valid_count = length(filter(b->b, [is_valid(rules, [0], msg) for msg in msgs]))
    println("Part 2: $(valid_count)")
end

main()
