using Pkg
try pkg"activate ." catch
    pkg"instantiate"; pkg"activate ." end

using ImageSegmentation: fast_scanning, felzenszwalb, seeded_region_growing, prune_segments,
    segment_pixel_count, labels_map, segment_mean, segment_labels, SegmentedImage
using FreeTypeAbstraction: renderstring!, newface, FreeType
using Images: save, load, height, width, Gray, GrayA, RGB, N0f8, FixedPointNumbers
using Gadfly: plot, inch, draw, SVG, Guide.xlabel, Guide.ylabel, Geom.bar, Scale.y_log10
using Blink: Window, title, size, body!, loadcss!, js, tools, msg, handle, JSString, @js_
using ImageTransformations: imresize
using DataFrames: DataFrame
using BSON: @save, @load
using Random: seed!
using CSV: write
using Dates: now
using Interact
using Flux
using Zygote
#using CuArrays


begin
    println("Loading SpaceCadet v0.1, please wait...")
    include("./src/funcs.jl")
    include("./src/ui.jl")
    include("./src/events.jl")
    include("./src/models.jl")
    println("...complete! Coded with ♡ by dustin.irwin@cadmusgroup.com 2019.")
end


# Mux web hosting
# using Mux
# WebIO.webio_serve(page("/", req -> ui["html"], 8000))

# Diag tools
# tools(w)
# using Debugger
