using DrWatson
@quickactivate "ComplexityMeasuresPaper"
using ComplexityMeasures
using TimeseriesSurrogates
using ARFIMA
using CairoMakie
using PredefinedDynamicalSystems
using Statistics
using Random
using DelayEmbeddings

include(srcdir("theme.jl"))

# %% Setup: decide which outcome spaces to use for missing outcomes:

ospaces = [ # map delay time to concrete outcome space instance
    τ -> OrdinalPatterns(; τ, m = 4),
    τ -> OrdinalPatterns(; τ, m = 5),
    τ -> Dispersion(; τ, m = 2, c = 5),
    τ -> Dispersion(; τ, m = 3, c = 4),
    τ -> BubbleSortSwaps(; τ, m = 10),
    τ -> CosineSimilarityBinning(; τ, m = 3, nbins = 24),
]

# Generate timeseries

N = 2000 # length of timeseries
rng = Xoshiro(124314) # reproducibility

# Logistic map timeseries
ds = PredefinedDynamicalSystems.logistic(r = 4.0)
Y, t = trajectory(ds, N-1; Ttr = 100)
y = standardize(Y[:, 1])
y = y .+ 0.1 .* randn(rng, N)

# Lorenz96 timeseries
ds = PredefinedDynamicalSystems.lorenz96(8; F = 24.0)
Δt = 0.01
W, t = trajectory(ds, (N-1)*Δt; Δt, Ttr = 100)
w = standardize(W[:, 1])
w = w .+ 0.1 .* randn(rng, N)

# Arma timeseries
φ1 = SVector(0.5, 0.4)
x = arma(rng, N, 1.0, φ1)

# %% Main computation
# function that computes normalized % of missing outcomes
nmo(o, x) = 100missing_outcomes(o, x)/total_outcomes(o)

surrotype = AAFT() # amplitude-adjusted fourier transform for surrogates

# Set up figure and axes
fig, axs = axesgrid(1, 3;
    titles = ["ar(2), φ = $(φ1)", "logistic (10% w.n.)", "lorenz96 (10% w.n.)"],
    sharey = true, sharex = true, size = (800, 400),
)

# loop over timeseries and outcome spaces
for (i, t) in enumerate((x, y, w))
    # estimate delay time for embedding
    if i == 2 # logistic timeseries always has delay 1
        τ = 1
    else
        τ = estimate_delay(t, "mi_min")
        τ = max(1, τ)
    end

    sgen = surrogenerator(t, surrotype) # initialize a generator for surrogates
    for (j, ogen) in enumerate(ospaces)
        o = ogen(τ) # `o` is the concrete outcome space instance for given delay

        # Surrogate test allows us to compute the quantity of interest
        # (here missing outcomes) for input data and 1000 surrogates
        # using parallel computing
        stest = SurrogateTest(x -> nmo(o, x), t, surrotype; rng, n = 1000)
        rval, vals = fill_surrogate_test!(stest) # real value, surrogate values
        # plot the results:
        boxplot!(axs[i], fill(j, 1000), vals; show_outliers = false, orientation = :horizontal, whiskerwidth = 0.5)
        scatter!(axs[i], rval, j; strokecolor = :white, strokewidth = 2.0, markersize = 25)
    end
end
for ax in axs; ax.yticks = eachindex(ospaces); end

axs[2].xlabel = "missing outcomes (%)"
Label(fig[2, :],
"""
outcome space: 1 = ordinal (m = 4), 2 = ordinal (m = 5), 3 = dispersion (m = 2, c = 5),
4 = dispersion (m = 3, c = 4), 5 = bubble sort swaps (m = 10), 6 = cosine similarity (m = 3, nbins = 24)
""";
)

display(fig)

wsave(plotsdir("missing.png"), fig)