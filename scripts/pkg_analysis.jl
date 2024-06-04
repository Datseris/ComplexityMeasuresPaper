using DrWatson
@quickactivate "ComplexityMeasuresPaper"
using ComplexityMeasures
using PackageAnalyzer

ancm = analyze(ComplexityMeasures)
# results: for v3.4.1:
# * Julia code in `src`: 3813 lines
# * Julia code in `ext`: 0 lines (0.0% of `test` + `src` + `ext`)
# * Julia code in `test`: 2357 lines (38.2% of `test` + `src` + `ext`)
# * documentation in `docs`: 1493 lines (28.1% of `docs` + `src` + `ext`)
# * documentation in README & docstrings: 3943 lines (50.8% of README + `src`)

aneh = analyze("https://github.com/MattWillFlood/EntropyHub.jl")

# Unfortunately this output is a bit missleading, because every single
# source code file has an extra license string.
# (which is weird since the software already has a license file.)
# In anycase, the output is:
# * Julia code in `src`: 3761 lines
# * Julia code in `ext`: 0 lines (0.0% of `test` + `src` + `ext`)
# * Julia code in `test`: 4 lines (0.1% of `test` + `src` + `ext`)
# * documentation in `docs`: 577 lines (13.3% of `docs` + `src` + `ext`)
# * documentation in README & docstrings: 2204 lines (36.9% of README + `src`)
# However, this counts all license strings as source code.