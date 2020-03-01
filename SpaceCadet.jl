 using ImageSegmentation: fast_scanning, felzenszwalb, seeded_region_growing,
    prune_segments, segment_pixel_count, labels_map, segment_mean, segment_labels,
    SegmentedImage
 using FreeTypeAbstraction: renderstring!, newface, FreeType
 using Images: save, load, height, width, Gray, GrayA, RGB, N0f8, FixedPointNumbers
 using Gadfly: plot, inch, draw, SVG, Guide.xlabel, Guide.ylabel, Geom.bar,
    Scale.y_log10
 using Blink: Page, Window, title, size, body!, loadcss!, js, tools, msg, handle,
    JSString, @js_
 using ImageTransformations: imresize
 using DataFrames: DataFrame
 using AssetRegistry: register
 using BSON: @save, @load
 using Random: seed!
 using CSV: write
 using Dates: now
 using ColorTypes
 using Interact


println("Packages loaded. Starting SpaceCadet v0.1, please wait...")


try close(w) catch end
# WEB SECURTY SET TO OFF, DO NOT DEPLOY APP TO ANY WEBSERVER !!!
w = Window(async=true)  # Dict("webPreferences"=>Dict("webSecurity"=>false)))
title(w, "SpaceCadet.jl v0.1"); size(w, 1200, 800);

include("./src/funcs.jl")
include("./src/ui.jl")
include("./src/events.jl")

body!(w, ui["html"])

println("...complete! Coded with ♡ by dustin.irwin@cadmusgroup.com 2019.")

# Diag tools
# tools(w)
#  using Debugger
