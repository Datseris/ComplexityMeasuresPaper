
using CairoMakie
using CairoMakie.Makie.Colors
using GeometryTypes
using JLD2
using Statistics

include("../categorize.jl")
function fig2_extract_analysis(filename;
        result_path = "./output/",
        dict_name = "results_per_painting",
    )

    hc_dict = JLD2.load(joinpath(result_path, filename))[dict_name]

    painting_filenames = Vector{String}(undef, 0)
    hs = Vector{Float64}(undef, 0)
    cs = Vector{Float64}(undef, 0)

    for (k, v) in hc_dict
        push!(painting_filenames, k)
        push!(hs, v[1])
        push!(cs, v[2])
    end

    return painting_filenames, hs, cs
end

function fig2_hs_cs_per_style(filename;
        result_path = "./output/",
        dict_name = "results_per_painting",
        meta_dir = "/data/meta/"
    )
    painting_filenames, hs, cs = fig2_extract_analysis(filename; result_path, dict_name)
    styles = unique_styles()
    paintings_classifications = classify_paintings(; meta_dir)
    all_paintings = gather_all_paintings(; meta_dir)

    styles_hs = Dict{String, Vector{Float64}}()
    styles_cs = Dict{String, Vector{Float64}}()
    for style in styles
        styles_hs[style] = Float64[]
        styles_cs[style] = Float64[]
    end

    for (i, painting_filename) in enumerate(painting_filenames)
        painting_id = last(split(painting_filename, "_"))
        if painting_id == ""
            continue
        end
        labels = split(all_paintings[painting_id]["style"], ", ")
        for label in Base.string.(labels)
            push!(styles_hs[label], hs[i])
            push!(styles_cs[label], cs[i])
        end
    end

    hs = [styles_hs[style] for style in styles]
    cs = [styles_cs[style] for style in styles]
    return styles, hs, cs
end

function fig2_summary_stats(filename;
    meta_dir = "./data/meta",
    result_path = "./output/",
    dict_name = "results_per_painting",
    threshold = 100, lq = 0.025, uq = 0.975)
    styles, styles_hs, styles_cs = fig2_hs_cs_per_style(filename; result_path, dict_name, meta_dir)

    # Filter styles with less than `threshold` paintings
    idxs_toofew = findall(length.(values(styles_hs)) .< threshold)
    deleteat!(styles, idxs_toofew)
    deleteat!(styles_hs, idxs_toofew)
    deleteat!(styles_cs, idxs_toofew)

    h_means = zeros(length(styles))
    h_meds = zeros(length(styles))
    h_lq = zeros(length(styles))
    h_uq = zeros(length(styles))
    c_means = zeros(length(styles))
    c_meds = zeros(length(styles))
    c_lq = zeros(length(styles))
    c_uq = zeros(length(styles))

    for (i, (hs, cs)) in enumerate(zip(styles_hs, styles_cs))
        h_means[i] = mean(hs)
        h_meds[i] = quantile(hs, 0.5)
        h_lq[i] = quantile(hs, lq)
        h_uq[i] = quantile(hs, uq)
        c_means[i] = mean(cs)
        c_meds[i] = quantile(cs, 0.5)
        c_lq[i] = quantile(cs, lq)
        c_uq[i] = quantile(cs, uq)
    end
    return styles, h_means, h_meds, h_lq, h_uq, c_means, c_meds, c_lq, c_uq
end

function set_opacity(col, alpha)
    return RGBA{Float32}(col.r, col.g, col.b, alpha)
end

# Optional legend.
function fig2_legend!(filename, ax_legend;
        markersize = 10, labelsize = 10,
        meta_dir = "./data/meta",
        result_path = "./output/",
        dict_name = "results_per_painting",
        threshold = 300,)

    styles, hs_means, hs_meds, hs_lq, hs_uq, cs_means, cs_meds, cs_lq, cs_uq =
        fig2_summary_stats(filename; meta_dir, result_path, dict_name,
        threshold)

    sortidxs = sortperm(styles)

    c = distinguishable_colors(length(styles))
    cols = to_colormap(c)
    markers = get_markers(length(styles))

	legend_elems = [[MarkerElement(color = col, marker=marker, markersize = markersize,
    strokecolor = :black)] for (col, marker) in zip(c, markers)]

    leg = axislegend(ax_legend, legend_elems[sortidxs], styles[sortidxs];
        rowgap = -6, position = :lc, ncolumns = 2,
        orientation = :vertical)
    leg.labelsize = labelsize
    #leg.framevisible = false
    leg.padding = (0.0f0, 2.0f0, 0.0f0, 2.0f0)
    hidedecorations!(ax_legend)
    hidespines!(ax_legend)
    return ax_legend
end

function fig2_scatter_means!(filename, ax;
        meta_dir = "./data/meta",
        result_path = "./output/",
        dict_name = "results_per_painting",
        threshold = 3,
        lq = 0.025, uq = 0.975,
        errorbar_alpha = 0.3,
        markersize = 12,
        )
    styles, hs_means, hs_meds, hs_lq, hs_uq, cs_means, cs_meds, cs_lq, cs_uq =
            fig2_summary_stats(filename; meta_dir, result_path, dict_name,
                threshold, lq, uq)
    #@show styles, hs_meds, hs_lq, hs_uq
    markers = get_markers(length(styles))
    c = distinguishable_colors(length(styles))
    cols = to_colormap(c)
    cols_alpha = set_opacity.(cols, errorbar_alpha)
    errorbars!(ax, hs_meds, cs_meds, hs_meds .- hs_lq, hs_uq .- hs_meds,
       direction = :x,
        colormap = cols_alpha,
        color = 1:length(styles),
   )
    errorbars!(ax, hs_meds, cs_meds, cs_meds .- cs_lq, cs_uq .- cs_meds,
        direction = :y,
        colormap = cols_alpha,
        color = 1:length(styles),
    )
    p = scatter!(ax, hs_meds, cs_meds,
        color = 1:length(styles),
        colormap = cols,
        markersize = markersize,
        marker = markers,
    )

    return styles
end


function get_markers(n::Int)
    markers = [:circle, :rect, :diamond, :cross, :xcross, :utriangle, :dtriangle, :star5, :hexagon, :pentagon]
    selected_markers = Vector{Symbol}(undef, n)
    for i in 1:n
        selected_markers[i] = markers[(i - 1) % length(markers) + 1]
    end
    return selected_markers
end

function square_boxes!(ax, origins_of_colorboxes::Vector{Point2f}, color = :black)
    ax.xreversed = false
    ax.yreversed = true
    for x in 0:4, y in 0:4
        pts = [Point2f(x,y), Point2f(x,y+1), Point2f(x+1, y+1), Point2f(x+1, y)]
        box_color = first(pts) in origins_of_colorboxes ? :black : :gray77
        poly!(ax, pts; strokewidth = 5, color = box_color, strokecolor = :white)
    end
    hidespines!(ax)
    hidedecorations!(ax)
    return ax
end

# https://juliadatascience.io/makie_layouts
function add_axis_inset(pos; bgcolor=:snow2, #pos = fig[1, 1], for example
    halign, valign, width=Relative(0.3),height=Relative(0.3))
    inset_box_ax = Axis(pos;
        limits = (0, 4, 0, 4),
        aspect = 1,
        width, height, halign, valign,
        tellwidth = false, tellheight=false,
        alignmode=Mixed(bottom=10, left = -130),
        backgroundcolor=bgcolor)
    # bring content upfront
    translate!(inset_box_ax.scene, 0, 0, 10)
    return inset_box_ax
end


function final_fig(fns::AbstractString...;
        halign = :center,
        valign = :bottom,
        threshold = 500,
        kw...)

    size = (300*(length(fns)), 300)
    xlabel = "Entropy (H)"
    ylabel = "Complexity (C)"
    ylims = (-0.02, 0.3)
    xlims = (-0.02, 1.02)
    yticks = (0:0)
    fig = Figure(; size)
    yminorgridvisible = true
    axes = Vector{Axis}(undef, 0)
    for (plot_idx, fn) in enumerate(fns)

        ax = Axis(fig[1, plot_idx]; xlabel, ylabel, yminorgridvisible,
            limits = ((0.25, 1),nothing), aspect = 1,)

        fig2_scatter_means!(fn, ax; threshold, kw...)
        ax_inset = add_axis_inset(fig[1, plot_idx]; halign, valign)

        if occursin("permutation", fn)
            square_boxes!(ax_inset, [Point2f(0,0), Point2f(0, 1), Point2f(1, 1), Point2f(1, 0)])
        else
            square_boxes!(ax_inset, [Point2f(0,0), Point2f(0, 2), Point2f(2, 0), Point2f(2, 2)])
        end
        push!(axes, ax)
    end
    linkxaxes!(axes...)
    linkyaxes!(axes...)
    # # optional legend displaying the styles that have more than `threshold` paintings.
    # ax_legend = Axis(fig[:, 2])
    # fig2_legend!(first(fns), ax_legend; markersize = 11, labelsize = 11, threshold,)
    fig
end
