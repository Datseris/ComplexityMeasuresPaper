
using Distributed
addprocs(7)
@everywhere using Images
@everywhere using FileIO
@everywhere using JLD2
@everywhere using ComplexityMeasures, Distances
@everywhere using Dates
@everywhere using Distances
@everywhere using StatsBase
@everywhere using Distributed
@everywhere using SharedArrays

@everywhere function painting_filenames(; paintings_folder = "./data/paintings")
    return readdir(paintings_folder)
end

@everywhere function process_painting!(i::Int, paintings, results_per_painting, painting_filename;
        paintings_folder = "./data/paintings")

    current_time = Dates.format(now(), "YYYY_MM_dd HH:MM:SS")
    if i % 50 == 0
        #println("$(current_time) $i/$(length(paintings))")
    end
    #if i % 500 == 0
        #save("reproduction_$(current_time).jld2", "results_per_painting", results_per_painting)
    #end
    return Float32.(FileIO.load("$(paintings_folder)/$(painting_filename)"))
end

@everywhere function spatial_analysis(stencil, filename; est_type = :permutation, c = 3, periodic = false,
        paintings_folder = "./data/paintings", dist = JSDivergence(), subset::Bool = false, n_subset = 400)

    paintings = painting_filenames(; paintings_folder)
    n_paintings = length(paintings)

    # The filenames of all paintings.
    if subset
        indices = sample(1:length(paintings), n_subset, replace = false) |> sort
        paintings = painting_filenames(; paintings_folder)[indices]
    end

    results_per_painting = SharedArray{Tuple{Float64, Float64}}((length(paintings), 1))
    results_artist_paintingid = Vector{String}(undef, length(paintings))
    for i in eachindex(paintings)
        painting_filename = paintings[i]
        artist_paintingid = split(painting_filename, ".")[1]
        results_artist_paintingid[i] = artist_paintingid
    end

    @sync @distributed for i in eachindex(paintings)
        painting_filename = paintings[i]
        current_time = Dates.format(now(), "YYYY_MM_dd_HH:MM")

        if i % 1 == 0
            println("$(current_time) | i = $i/$(n_paintings) | candidates\t$(paintings_folder)/$(painting_filename) | $(Distributed.myid())")
        end
        if !(split(painting_filename, ".")[2] == "png")
            continue
        end
        # Convert image to Float32 array.
        x = process_painting!(i, paintings, results_per_painting, painting_filename; paintings_folder)

        if est_type == :permutation
            o = SpatialOrdinalPatterns(stencil, x; periodic)
        elseif est_type == :dispersion
            o = SpatialDispersion(stencil, x; c, periodic)
        else
            throw(ArgumentError("$est_type is not a valid estimator type"))
        end
        s = StatisticalComplexity(; o, dist = dist,
            pest = RelativeAmount(),
            hest = PlugIn(Shannon()),)

        # Compute and store result.
        results_per_painting[i] = entropy_complexity(s, x)
    end
    results_dict = Dict{String, Tuple{Float64, Float64}}()
    for (artist_painting_id, t) in zip(results_artist_paintingid, Array(results_per_painting))  # tuple `t` is (h, c)
        results_dict[artist_painting_id] = t
    end
    # Save all results together.
    current_time = Dates.format(now(), "YYYY_MM_dd_HH:MM")
    save("output/reproduction_$(filename)_$(current_time).jld2", "results_per_painting", results_dict)

    return results_dict
end
