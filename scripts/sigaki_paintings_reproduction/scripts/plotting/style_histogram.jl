
using CairoMakie
using Makie: barplot, pseudolog10
include("../categorize.jl")

# Creates a bar plot of the different styles that have more than a given
# threshold number of paintings.
function fig_histogram(; threshold = 250, rev = false,
        size = (900, 1800),
        colorscale = :viridis,
        )
    labels, counts = sorted_painting_counts_at_threshold(; threshold, rev)
   #[labels counts]
    fig = Figure(; size)
    ax = CairoMakie.Axis(fig[1, 1];
        yticks = (1:length(labels), labels),
        xticks = (
            [100; collect(200:100:900); 1000; collect(2000:1000:9000); 10000; collect(20000:10000:50000)],
            [L"10^2"; ["" for x in 200:100:900]; L"10^3"; ["" for x in 2000:1000:9000]; L"10^4"; ["" for x in 20000:10000:50000]],
        ),
        xscale = pseudolog10
        #xtickformat = values -> ["$(round(value, digits = 0))" for value in values]
    )
    xlims!(ax, (50, 50000))
    ylims!(ax, (0, length(labels) + 1))
    barplot!(ax, 1:length(labels), counts;
        direction = :x,
        bar_labels = map(ct -> string(round(Int, ct)), counts),
        color = counts,
        colormap= cgrad(colorscale, rev = true), # cgrad and Symbol, mycmap
        #flip_labels_at = maximum(counts) / 2,
        )
    return fig

end
