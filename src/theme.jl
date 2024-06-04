if !any(name -> isdefined(Main, name), [:Makie, :GLMakie, :CairoMakie])
    using CairoMakie
end
import Downloads

# decide theme:
ENV["COLORSCHEME"] = "JuliaDynamics" # or others, see `plottheme.jl`
ENV["BGCOLOR"] = :white              # anything for `backgroundcolor` of Makie
ENV["AXISCOLOR"] = :black            # color of all axis elements (labels, spines, ticks)

try
    Downloads.download(
        "https://raw.githubusercontent.com/Datseris/plottheme/main/plottheme.jl",
        joinpath(@__DIR__, "_plottheme.jl")
    )
    cp(joinpath(@__DIR__, "_plottheme.jl"), joinpath(@__DIR__, "plottheme.jl"); force = true)
    rm(joinpath(@__DIR__, "_plottheme.jl"); force = true)
catch
end

include("plottheme.jl")

# do any adjustments
figwidth = 800 # pixels, one column
figheight = 800
update_theme!(;
    size = (figwidth, figheight),
)