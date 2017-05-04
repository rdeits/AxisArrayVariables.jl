using AxisArrayVariables
using JuMP: Model, Variable
using AxisArrays: AxisArray, Axis
using Base.Test

@testset "axes as keywords" begin
    m = Model()
    @axis_variable(m, x[time=1:5])
    @test isa(x, AxisArray{Variable, 1, Array{Variable, 1}, 
                           Tuple{Axis{:time, UnitRange{Int}}}})
    @test size(x, Axis{:time}) == 5
    @test size(x) == (5,)

    m = Model()
    @axis_variable(m, x[time=1:5, side=[:left, :right]])
    @test isa(x, AxisArray{Variable, 2, Array{Variable, 2}, 
                           Tuple{Axis{:time, UnitRange{Int}},
                                 Axis{:side, Vector{Symbol}}}})
    @test size(x, Axis{:time}) == 5
    @test size(x, Axis{:side}) == 2
    @test size(x) == (5, 2)

    m = Model()
    @axis_variable(m, x[side=[:left, :right], time=1:5])
    @test isa(x, AxisArray{Variable, 2, Array{Variable, 2}, 
                           Tuple{Axis{:side, Vector{Symbol}},
                                 Axis{:time, UnitRange{Int}}}})
    @test size(x, Axis{:time}) == 5
    @test size(x, Axis{:side}) == 2
    @test size(x) == (2, 5)
end

@testset "axes as variables" begin
    time = Axis{:time}(1:5)
    side = Axis{:side}([:left, :right])

    m = Model()
    @axis_variable(m, x[time])
    @test isa(x, AxisArray{Variable, 1, Array{Variable, 1}, 
                           Tuple{Axis{:time, UnitRange{Int}}}})
    @test size(x, Axis{:time}) == 5
    @test size(x) == (5,)

    m = Model()
    @axis_variable(m, x[time, side])
    @test isa(x, AxisArray{Variable, 2, Array{Variable, 2}, 
                           Tuple{Axis{:time, UnitRange{Int}},
                                 Axis{:side, Vector{Symbol}}}})
    @test size(x, Axis{:time}) == 5
    @test size(x, Axis{:side}) == 2
    @test size(x) == (5, 2)

    m = Model()
    @axis_variable(m, x[side, time])
    @test isa(x, AxisArray{Variable, 2, Array{Variable, 2}, 
                           Tuple{Axis{:side, Vector{Symbol}},
                                 Axis{:time, UnitRange{Int}}}})
    @test size(x, Axis{:time}) == 5
    @test size(x, Axis{:side}) == 2
    @test size(x) == (2, 5)
end

@testset "mixing variables and keywords" begin
    time = Axis{:time}(1:5)

    m = Model()
    @axis_variable(m, x[time, side=[:left, :right]])
    @test isa(x, AxisArray{Variable, 2, Array{Variable, 2}, 
                           Tuple{Axis{:time, UnitRange{Int}},
                                 Axis{:side, Vector{Symbol}}}})
    @test size(x, Axis{:time}) == 5
    @test size(x, Axis{:side}) == 2
    @test size(x) == (5, 2)
end

@testset "upper and lower bounds" begin
    m = Model()
    @axis_variable(m, x[time=1:5] >= 0)
    @test all(JuMP.getlowerbound(x) .== 0)
    @test all(JuMP.getupperbound(x) .== Inf)

    m = Model()
    @axis_variable(m, x[time=1:5] <= 0)
    @test all(JuMP.getlowerbound(x) .== -Inf)
    @test all(JuMP.getupperbound(x) .== 0)

    m = Model()
    @axis_variable(m, 1 <= x[time=1:5] <= 3)
    @test all(JuMP.getlowerbound(x) .== 1)
    @test all(JuMP.getupperbound(x) .== 3)
end

@testset "variable types" begin
    m = Model()
    @axis_variable(m, x[time=1:5, side=[:left, :right]])
    @axis_variable(m, in_contact[time=1:5, side=[:left, :right]], Bin)
    @test all(JuMP.getcategory.(in_contact) .== :Bin)
    @test all(JuMP.getcategory.(x) .== :Cont)
end

function f()
    m = Model()
    @axis_variable(m, x[time=1:5, side=[:left, :right]])
    x
end

@testset "inference" begin
    @inferred(f())
end

