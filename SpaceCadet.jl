@time using Pkg
try pkg"activate ." catch
     pkg"instantiate"; pkg"activate ." end

@time using ImageSegmentation: fast_scanning, felzenszwalb, seeded_region_growing,
   prune_segments, segment_pixel_count, labels_map, segment_mean, segment_labels,
   SegmentedImage
@time using FreeTypeAbstraction: renderstring!, newface, FreeType
@time using Images: save, load, height, width, Gray, GrayA, RGB, N0f8, FixedPointNumbers
@time using Gadfly: plot, inch, draw, SVG, Guide.xlabel, Guide.ylabel, Geom.bar,
   Scale.y_log10
@time using Blink: Page, Window, title, size, body!, loadcss!, js, tools, msg, handle,
   JSString, @js_, @js
@time using ImageTransformations: imresize
@time using DataFrames: DataFrame
@time using AssetRegistry: register
@time using BSON: @save, @load
@time using Random: seed!
@time using CSV: write
@time using Dates: now
@time using ColorTypes
@time using CuArrays
@time using Interact
@time using Interact: node
@time using Flux
@time using Flux: crossentropy, Conv, train!, @epochs
#@time using Logging  # not compiled, not traced!


println("Packages loaded. Starting SpaceCadet v0.1, please wait...")

try close(w) catch end
w = Window(async=true)  # Dict("webPreferences"=>Dict("webSecurity"=>false)))
title(w, "SpaceCadet.jl v0.1"); size(w, 1200, 800);

include("./src/funcs.jl")
include("./src/ui.jl")
include("./src/events.jl")
include("./src/models.jl")

body!(w, ui["html"])

println("...complete! Coded with ♡ by dustin.irwin@cadmusgroup.com 2019.")

# Diag tools
# tools(w)
# @time using Debugger
