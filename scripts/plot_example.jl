using DrWatson
@quickactivate "ComplexityMeasuresPaper"
using ComplexityMeasures, CairoMakie

# Include directory with plot themeing
include(srcdir("theme.jl"))

# Plot with Makie
fig, ax = lines(randn(5))
lines!(cumsum(randn(5)))
lines!(randn(5))
fig
