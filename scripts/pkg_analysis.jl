using DrWatson
@quickactivate "ComplexityMeasuresPaper"
using ComplexityMeasures
using PackageAnalyzer

ancm = analyze(ComplexityMeasures)
# results: for v3.7.3:
# * Julia code in `src`: 3841 lines
# * Julia code in `test`: 2425 lines (38.7% of `test` + `src` + `ext`)
# * documentation in `docs`: 1954 lines (33.7% of `docs` + `src` + `ext`)
# * documentation in README & docstrings: 4066 lines (51.4% of README + `src`)

aneh = analyze("https://github.com/MattWillFlood/EntropyHub.jl")

# Unfortunately this output is a bit missleading, because every single
# source code file has an extra license string which inflates the
# lines of source code.
# (and it is is weird practice since the software already has a license file.)
# In anycase, the output for v2.0.0 is:
# * Julia code in `src`: 4994 lines
# * Julia code in `test`: 4 lines (0.1% of `test` + `src` + `ext`)
# * documentation in `docs`: 771 lines (13.4% of `docs` + `src` + `ext`)
# * documentation in README & docstrings: 3019 lines (37.7% of README + `src`)
