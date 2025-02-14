ENV["COLORSCHEME"] = "JuliaDynamics" # or others, see docs
ENV["BGCOLOR"] = :transparent        # anything for `backgroundcolor` of Makie
ENV["AXISCOLOR"] = :black            # color of all axis elements (labels, spines, ticks)

using MakieForProjects # this has now set the theme already!
using CairoMakie

# you may further edit the set theme by using
figwidth = 800 # pixels, one column
figheight = 800
Makie.update_theme!(;
    size = (figwidth, figheight),
)