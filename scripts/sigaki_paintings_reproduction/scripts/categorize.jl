using JSON

function gather_all_paintings(; meta_dir = "./data/meta")
    d = Dict{String, Dict{String, Any}}()

    artist_files = readdir(meta_dir)
    for (i, artist_file) in enumerate(artist_files)
        artist_identifier = join(split(artist_file, ".")[1:end-1], "")
        #println("$i: $artist_identifier")
        painting_dicts = JSON.parsefile(joinpath(meta_dir, artist_file))
        for painting in painting_dicts
            contentId = repr(painting["contentId"])
            d[contentId] = painting
        end
    end
    return d
end

function classify_paintings(; meta_dir = "./data/meta")
    artist_files = readdir(meta_dir)

    classifications = Dict{String, String}()

    for (i, artist_file) in enumerate(artist_files)
        artist_identifier = join(split(artist_file, ".")[1:end-1], "")
        #println("$i: $artist_identifier")
        painting_dicts = JSON.parsefile(joinpath(meta_dir, artist_file))

        for painting in painting_dicts
            contentId = repr(painting["contentId"])
            if haskey(painting, "style") && !isnothing(painting["style"])
                classifications[contentId] = painting["style"]
            end
        end
    end
    return classifications
end

function paintings_in_different_styles(; meta_dir = "./data/meta")
    artist_files = readdir(meta_dir)

    classifications = Dict{String, Vector{String}}()

    for (i, artist_file) in enumerate(artist_files)
        artist_identifier = join(split(artist_file, ".")[1:end-1], "")
        #println("$i: $artist_identifier")
        painting_dicts = JSON.parsefile(joinpath(meta_dir, artist_file))

        for painting in painting_dicts
            contentId = repr(painting["contentId"])
            if haskey(painting, "style") && !isnothing(painting["style"])
                if haskey(classifications, painting["style"])
                    push!(classifications[painting["style"]], contentId)
                else
                    classifications[painting["style"]] = [contentId]
                end
            end
        end
    end
    return classifications
end

function unique_styles(; meta_dir = "./data/meta")
    style_contents = paintings_in_different_styles(; meta_dir)
    styles = keys(style_contents)

    unique_styles = Vector{String}(undef, 0)
    for style in styles
        labels = split(style, ", ")
        for label in labels
            if !(label in unique_styles)
                push!(unique_styles, label)
            end
        end
    end
    return unique_styles
end

function painting_counts_per_style(; meta_dir = "./data/meta")
    artist_files = readdir(meta_dir)
    labels = unique_styles(; meta_dir)

    painting_counts = Dict{String, Int}()
    for (i, artist_file) in enumerate(artist_files)
        painting_dicts = JSON.parsefile(joinpath(meta_dir, artist_file))
        for painting in painting_dicts
            if haskey(painting, "style") && !isnothing(painting["style"])
                styles_for_this_painting = split(painting["style"], ", ")
                for style in styles_for_this_painting
                    if haskey(painting_counts, style)
                        painting_counts[style] += 1
                    else
                        painting_counts[style] = 0
                    end
                end
            end
        end
    end
    return painting_counts
end

function painting_counts_per_style_at_threshold(; threshold = 200)
    painting_counts = painting_counts_per_style()
    for label in keys(painting_counts)
        if painting_counts[label] < threshold
            delete!(painting_counts, label)
        end
    end
    return painting_counts
end

function sorted_painting_counts_at_threshold(; threshold = 200, rev = true)
    painting_counts = painting_counts_per_style_at_threshold(; threshold)

    lbls = Vector{String}(undef, 0)
    cts = Vector{Int}(undef, 0)

    for (lbl, ct) in painting_counts
        push!(lbls, lbl)
        push!(cts, ct)
    end

    idxs = sortperm(cts; rev)

    return lbls[idxs], cts[idxs]
end

#paintings_classifications = classify_paintings()
# style_contents = paintings_in_different_styles()
# labels = unique_styles()

# painting_counts_per_style()
# painting_counts_per_style_at_threshold(threshold = 200)

# lbls, cts = sorted_painting_counts_at_threshold(threshold = 250)
