using CairoMakie # or GLMakie, CairoMakie, etc.
import Downloads

ENV["COLORCHEME"] = "JuliaDynamics" # or others, see `plottheme.jl`

try
    Downloads.download(
        "https://raw.githubusercontent.com/Datseris/plottheme/main/plottheme.jl",
        joinpath(@__DIR__, "plottheme.jl")
    )
catch
end

include("plottheme.jl")

# include online theme
set_theme!(default_theme)

figwidth = 800 # pixels, one column
figheight = 800
# do any adjustments
update_theme!(;
    resolution = (figwidth, figheight),
    Lines = (
        cycle = Cycle([:color, :linestyle], covary = true),
        linewidth = 4,
    ),
)