#!/usr/bin/env julia

const DATA_DIR = "../07_data"
const INPUT_FILE = "input.txt"
# const INPUT_FILE = "input_test_a.txt"
# const INPUT_FILE = "input_tiny_a.txt"

const PAT_PARENT   = r"^(\w+\s\w+) bags contain (.+)"
const PAT_CHILDREN = r"(\d) (\w+\s\w+) bag"

macro assert(boolean)
    message = string("Assertion: ", boolean, " failed")
    :($(esc(boolean)) || error($message))
end

mutable struct TreeNode
    name::String
    children::Array{Tuple{TreeNode, Int}}
    parents::Array{TreeNode}
    #--------------------
    function TreeNode(name::String)
        return new(name, [], [])
    end
end

mutable struct Registry
    nodeDict::Dict{String, TreeNode}
    #--------------------
    function Registry()
        return new(Dict{String, TreeNode}())
    end
end

# ---------------------------------------- 

function countDescendents(node::TreeNode)
    result = 0
    for (child, subcount) in getNode(registry, node.name).children
        result += subcount * (1 + countDescendents(child))
    end
    return result
end

function getNode(reg::Registry, name::String)
    if get(reg.nodeDict, name, nothing) != nothing
        return reg.nodeDict[name]
    else
        newNode = TreeNode(name)
        reg.nodeDict[name] = newNode
        return newNode
    end
end

registry = Registry()
lines = readlines("$DATA_DIR/$INPUT_FILE")

for line in lines
    # println("Processling line: ", line)
    mparent = match(PAT_PARENT, line)
    parent_name = string(mparent.captures[1])
    parent_node = getNode(registry, parent_name)
    @assert mparent != nothing
    # println("Match = ", mparent.captures[1])
    for mchild in eachmatch(PAT_CHILDREN, mparent.captures[2])
        child_count = parse(Int32, mchild.captures[1])
        child_name = string(mchild.captures[2])
        child_node = getNode(registry, child_name)
        push!(parent_node.children, (child_node, child_count))
        push!(child_node.parents, parent_node)
        # println("Recorded that ", parent_node.name, " is a parent of ", child_node.name)
        # println("\tMatch: ", mchild)
        # println("\tMatch Details: $child_name, $child_count")
    end
    # println("====================")
end

# println("nodeDict has length: ", length(registry.nodeDict))
# println("nodeDict.keys has length: ", length(registry.nodeDict.keys))
# for (key, val) in registry.nodeDict
#     println(key)
# end

# TODO: Improve efficiency
shinyGoldNode = getNode(registry, "shiny gold")
searchNames = Set()
ancestryNames = Set()
push!(searchNames, shinyGoldNode.name)
while !isempty(searchNames)
    currentName = pop!(searchNames)
    if (currentName != "shiny gold") && !(currentName in ancestryNames)
        push!(ancestryNames, currentName)
    end
    for parentNode in getNode(registry, currentName).parents
        if !(parentNode.name in searchNames)
            push!(searchNames, parentNode.name)
        end
    end
end

println("========== PART 1 ==========")
println(length(ancestryNames))
println()
println("========== PART 2 ==========")
println(countDescendents(getNode(registry, "shiny gold")))
