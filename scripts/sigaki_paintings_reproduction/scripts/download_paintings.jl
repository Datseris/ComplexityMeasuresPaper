using Pkg
using Images, ImageIO, JSON
using Distances
using ComplexityMeasures

"""
    download_image(url) → Array{RGB{N0f8}, 2}

Downloads an image from the given URL and returns it as an array of RGB pixels.
"""
function download_image(url)
    img = mktemp() do fn, f
        download(url, fn)
        Images.load(fn)
    end
    return img
end

# Usual greyscale transformation is fine according to the paper.
"""
    convert_to_grayscale(img) → Array{Float32, 2}
"""
function convert_to_grayscale(img)
    return Float32.(Gray.(img))
end

"""
    save_to_png(img::AbstractArray, filename)

Save a two-dimensional array to a png file.
"""
function save_to_png(img::AbstractArray, path, filename)
    full_path = joinpath(path, filename)
    save(full_path, img)
end

function number_of_artists()
    return length(readdir("./data/meta"))
end

function download_artist(artist_metadata_filename::AbstractString;
        save_folder = "./data/paintings")

    artist_identifier = join(split(artist_metadata_filename, ".")[1:end-1], "")
    painting_dicts = JSON.parsefile(joinpath("./data/meta", artist_metadata_filename))
    for (j, painting) in enumerate(painting_dicts)
        url = painting["image"]
        contentId = string(painting["contentId"])
        title = string(painting["title"])
        if isempty(title)
            title = "notitle"
        end
        filename = "$(artist_identifier)_$(contentId)_$title.png"
        if isfile(joinpath(save_folder, filename))
            println("  Already downloaded painting #$j")
            continue
        end
        # For our reproduction, we only care about paintings that has a defined style
        if haskey(painting, "style") && !isnothing(painting["style"])
            try
                img = download_image(url)
                grey_img = convert_to_grayscale(img)
                println("  Painting #$j located: $(painting["title"])")
                save_to_png(grey_img, save_folder, filename)
            catch RequestError
                println("  Didn't find image #$j")
            end
        end
        # Max 20 image download requests per second

        sleep(0.07)
    end
end

function download_artists(artist_numbers;
        save_folder = "./data/paintings",
        metadata_folder = "./data/meta")
    artist_files = readdir(metadata_folder)

    for (i, artist_file) in enumerate(artist_files[artist_numbers])
        artist_identifier = join(split(artist_file, ".")[1:end-1], "")
        println("$i: $artist_identifier")
        download_artist(artist_file; save_folder)
    end
end
