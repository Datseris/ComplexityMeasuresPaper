using DrWatson
@quickactivate "ComplexityMeasuresPaper"
using ComplexityMeasures
using Statistics
using MarketData
using CairoMakie
using DataFrames
using ProgressMeter
include(srcdir("theme.jl"))

# Input configuration
# time window
start = DateTime(2000, 1, 1)
finish = DateTime(2020, 1, 1)
frequency = "1d"

# what stocks to use
include("all_stocks.jl")

# Function for obtaining the closing value timeseries given the name of stock
function closing_stock_timeseries(name::String, start::DateTime, finish::DateTime, freq::String)
    opt = YahooOpt(period1 = start, period2 = finish, interval = freq)
    stockdata = yahoo(name, opt)
    stock_close = stockdata["Close"]
    actual_numbers = values(stock_close)
    return float.(actual_numbers)
end

function overall_price_change(timeseries)
    first_value = first(timeseries)
    last_value = last(timeseries)
    return 100(last_value - first_value)/first_value
end

# Download SNP from Yahoo Finance
snp_name = "^GSPC"
snp_timeseries = closing_stock_timeseries(snp_name, start, finish, frequency)
const snp_change = overall_price_change(snp_timeseries)

results = DataFrame()

@showprogress for stock in all_stock_names
    timeseries = nothing
    try # some of the stock market names can't be downloaded at some times of day
        timeseries = closing_stock_timeseries(stock, start, finish, frequency)
    catch error
        continue
    end
    # This code uses ComplexityMeasures.jl
    permutation = entropy_normalized(OrdinalPatterns{4}(), timeseries)
    spectral = entropy_normalized(PowerSpectrum(), timeseries)
    dispersion = entropy_normalized(Dispersion(c = 6), timeseries)
    r = std(timeseries)*0.2
    approximate = complexity(ApproximateEntropy(; r), timeseries)
    sample = complexity(SampleEntropy(; r), timeseries)
    rel_success = overall_price_change(timeseries)/snp_change
    # usage of ComplexityMeasures.jl stops here.
    push!(results, (; stock, spectral, dispersion, permutation, sample, approximate, rel_success))
end

# %% Visualize results
fig = Figure(size = (600, 400))
ax = Axis(fig[1, 1]; xlabel="relative success %", ylabel="complexity measure")
x = results.rel_success
i = 1
for ystr in names(results)
    ystr ∈ ("stock", "rel_success") && continue
    y = results[!, ystr]
    scatter!(ax, x, y; label = ystr, markersize = 15, strokecolor = :black,
    strokewidth = 0.2, color = (COLORS[i], 0.75), marker = MARKERS[i])
    i += 1
end
xlims!(ax, -2, 100)
axislegend("entropy"; ax, position = :rt, backgroundcolor = :white)
display(fig)
# wsave(plotsdir("stocks.png"), fig)
