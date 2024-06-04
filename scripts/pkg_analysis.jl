using DrWatson
@quickactivate "ComplexityMeasuresPaper"
using ComplexityMeasures
using PackageAnalyzer

ancm = analyze(ComplexityMeasures)
# results: for v3.5.0:
# * Julia code in `src`: 3834 lines
# * documentation in `docs`: 1953 lines (33.7% of `docs` + `src` + `ext`)
# * Julia code in `test`: 2406 lines (38.6% of `test` + `src` + `ext`)
# * documentation in README & docstrings: 4031 lines (51.3% of README + `src`)

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
