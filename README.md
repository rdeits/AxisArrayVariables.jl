# AxisArrayVariables

[![Build Status](https://travis-ci.org/rdeits/AxisArrayVariables.jl.svg?branch=master)](https://travis-ci.org/rdeits/AxisArrayVariables.jl)
[![codecov.io](http://codecov.io/github/rdeits/AxisArrayVariables.jl/coverage.svg?branch=master)](http://codecov.io/github/rdeits/AxisArrayVariables.jl?branch=master)

This package provides a convenient way to declare [JuMP](https://github.com/JuliaOpt/JuMP.jl) variables which are stored in [AxisArrays](https://github.com/JuliaArrays/AxisArrays.jl) containers. This is useful if you have a model with multi-dimensional arrays of variables, and you don't want to keep track of your axes by their index. 

```julia
using AxisArrayVariables
using JuMP: Model
using AxisArrays: Axis

# Create a continuous variable named `x` with two axes: `time` and `side`
m = Model()
@axis_variable(m, x[time=1:5, side=[:left, :right]])

# You can now index into `x` using named axes:
@assert x[Axis{:time}(3), Axis{:side}(:left)] === x[3, 1]
@assert size(x, Axis{:time}) == 5
@assert size(x, Axis{:side}) == 2

# Axes can also be declared outside of the @axis_variable macro:
location = Axis{:location}([:here, :there])
@axis_variable(m, y[location])

# Additional arguments get passed in to the normal JuMP.@variable macro. To
# create an axis array of binary variables, you can do:
@axis_variable(m, in_contact[time=1:5], Bin)
```
