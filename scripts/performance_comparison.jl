using DrWatson
@quickactivate "ComplexityMeasuresPaper"
using ComplexityMeasures
using BenchmarkTools
using Random

# we use a development version of EntropyHub because its dependencies list
# is dramatically outdated, forcing bounds of dependencies into very old versions.
# We did not change the source code, only its Project.toml file.
# We wish the developer was using basic tooling for Julia packages such as CompatHelper...
import EntropyHub

# %% Permutation entropy
bc = @benchmark entropy_permutation(x; m = 4) setup = (x = randn(10_000))

be = @benchmark EntropyHub.PermEn(x; m = 4) setup = (x = randn(10_000))

# %% Sample Entropy
bc = @benchmark entropy_sample(x; m = 4, r = 0.2) setup = (x = randn(10_000))

be = @benchmark EntropyHub.SampEn(x; m = 4, r = 0.2) setup = (x = randn(10_000))

# %% dispersion
bc = @benchmark entropy(Dispersion(c = 5, m = 4, check_unique = false), x) setup = (x = randn(10_000))

be = @benchmark EntropyHub.DispEn(x; c = 5, m = 4, Logx = 2, Typex = "ncdf") setup = (x = randn(10_000))

# %% bubble
bc = @benchmark complexity(BubbleEntropy(m = 4), x) setup = (x = randn(10_000))

be = @benchmark EntropyHub.BubbEn(x; m = 4, Logx = 2) setup = (x = randn(10_000))

# %% cosine similarity
bc = @benchmark entropy(CosineSimilarityBinning(m = 4, nbins = 5), x) setup = (x = randn(10_000))

be = @benchmark EntropyHub.CoSiEn(x; m = 4, r = 0.2, Logx=2) setup = (x = randn(10_000))

# %% histogram
# Generate data
using PredefinedDynamicalSystems
Δt = 0.05
X, t = trajectory(PredefinedDynamicalSystems.lorenz96(30), Δt*10_000; Δt)

bc = @benchmark entropy(ValueHistogram(10), X)

# each dimension gets 10 grid cells, 30 dimensions means 10^30 grid cells. Out of memory.