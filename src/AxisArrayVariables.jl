__precompile__()

module AxisArrayVariables

using JuMP
using AxisArrays
using MacroTools

export @axis_variable

@static if VERSION >= v"0.6-"  # arguments parse as :kw in 0.5 and := in 0.6
    const kw_head = :(=)
else
    const kw_head = :kw
end

macro axis_variable(m, varexpr, args...)
    jump_args = Expr[esc(e) for e in args]
    (var, axis_args, lb, ub) = @match varexpr begin
        (var_[axis_args__] |
        (var_[axis_args__] <= ub_) |
        (var_[axis_args__] >= lb_) |
        (lb_ <= var_[axis_args__] <= ub_)) => (var, axis_args, lb, ub)
    end
    if var === nothing || axis_args === nothing
        error("Unrecognized expression")
    end
    if lb !== nothing
        unshift!(jump_args, Expr(kw_head, esc(:lowerbound), esc(lb)))
    end
    if ub !== nothing
        unshift!(jump_args, Expr(kw_head, esc(:upperbound), esc(ub)))
    end
    axes = []
    domains = Expr[]
    for arg in axis_args
        if @capture(arg, name_ = domain_)
            push!(axes, Expr(:call, Expr(:curly, :Axis, QuoteNode(name)), esc(domain)))
            push!(domains, esc(domain))
        else
            push!(axes, esc(arg))
            push!(domains, esc(arg))
        end
    end
    range_exprs = [:(1:length($a)) for a in domains]
    quote
        ranges = $(Expr(:vect, range_exprs...))
        vars = let
            local $(esc(var))
            $(Expr(:macrocall, Symbol("@variable"), esc(m), Expr(:ref, esc(var), range_exprs...), jump_args...))
        end
        $(esc(var)) = $(Expr(:call, :AxisArray, :vars, axes...))
    end
end

end
