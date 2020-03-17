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
@time using Mux
#@time using Logging  # not compiled, not traced!


println("Packages loaded. Starting SpaceCadet v0.1, please wait...")

@time begin
   include("./src/funcs.jl")
   include("./src/ui.jl")
   # include("./src/events.jl")
   include("./src/models.jl")

   const port = rand(8000:8000)
   WebIO.webio_serve(page("/", req -> ui["html"]), port)
end

println("...complete! Coded with ♡ by dustin.irwin@cadmusgroup.com 2019.\n
   Go to 'localhost:$port' in your browser.")


# Diag tools
# tools(w)
# @time using Debugger
