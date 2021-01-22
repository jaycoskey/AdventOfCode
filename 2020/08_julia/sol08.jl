#!/usr/bin/env julia

using Formatting: printfmt

const DATA_DIR = "../08_data"
const INPUT_FILE = "input.txt"
# const INPUT_FILE = "input_test.txt"

macro assert(bool_expr)
    message = string("Assertion: ", bool_expr, " failed")
    :($(esc(bool_expr)) || error($message))
end

@enum CommandType nop acc jmp

mutable struct Command
    cmd_type::CommandType
    cmd_val::Int32    
    #--------------------
    function Command(line)
        (a, b) = split(strip(line), " ") 
        return new(getproperty(Main, Symbol(a)), parse(Int32, b))
    end
end

mutable struct VM
    vm_code::Array{Command}
    vm_pc::Int32
    vm_acc::Int32
    vm_executed::Set{Int32}
    #--------------------
    function VM(code)
        return new(code, 1, 0, Set{Int32}())
    end
end

# ---------------------------------------- 

function is_jmp(x)
    return x[2].cmd_type == jmp
end

function fst(pair)
    return pair[1]
end

function vm_exec_cmd(vm::VM)
    push!(vm.vm_executed, vm.vm_pc)
    cmd = vm.vm_code[vm.vm_pc]
    ct = cmd.cmd_type
    if ct == nop
        # println("About to execute noop")
        vm.vm_pc += 1
    elseif ct == acc
        # println("About to execute acc ", cmd.cmd_val)
        vm.vm_acc += cmd.cmd_val
        vm.vm_pc += 1
    elseif ct == jmp
        # println("About to execute jmp ", cmd.cmd_val)
        vm.vm_pc += cmd.cmd_val
    else
        error("Internal error: Unrecognized command type") 
    end
end

function vm_run(vm::VM)
    vm.vm_pc = 1
    while true
        if vm.vm_pc in vm.vm_executed
            return ("loop", vm.vm_acc)
        elseif vm.vm_pc == length(vm.vm_code) + 1
            return ("completed", vm.vm_acc)
        else
            vm_exec_cmd(vm)
        end
    end
end 

function vm_run_until_loop(vm::VM)
    vm.vm_pc = 1
    while !(vm.vm_pc in vm.vm_executed)
        vm_exec_cmd(vm)
    end 
    println("PC=", vm.vm_pc, " for 2nd time. acc=", vm.vm_acc)
end

# ---------------------------------------- 

function part1()
    println("========== PART 1 ==========")
    lines = readlines("$DATA_DIR/$INPUT_FILE")
    code = map(Command, lines)
    vm = VM(code)
    vm_run_until_loop(vm)
end

function part2()
    println("========== PART 2 ==========")
    lines = readlines("$DATA_DIR/$INPUT_FILE")
    println("# Number of lines=", length(lines))
    code = map(Command, lines)
    jmp_inds = [ecmd[1] for ecmd in enumerate(code) if ecmd[2].cmd_type == jmp]
    for cmd_ind in 1:1:length(code)
        if code[cmd_ind].cmd_type == jmp
            # println("Swapping cmd#$cmd_ind from jmp to nop")
            code_fixed = deepcopy(code)
            code_fixed[cmd_ind].cmd_type = nop
        elseif code[cmd_ind].cmd_type == nop
            # println("Swapping cmd#$cmd_ind from nop to jmp")
            code_fixed = deepcopy(code)
            code_fixed[cmd_ind].cmd_type = jmp
        else
            continue
        end

        vm = VM(code_fixed)
        (exit_code, exit_value) = vm_run(vm)
        if exit_code == "completed"
            println("# Swapped cmd #$(cmd_ind)")
            printfmt(
                "(exit_code, exit_value)=($exit_code, $exit_value)\n"
                , exit_code, exit_value
            )
            exit(0)
        end
    end
    println("Did not find cmd swap that causes successful program termination.\n")
end

# ---------------------------------------- 

function main()
    part1()
    part2()
end

main()
