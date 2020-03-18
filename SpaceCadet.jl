println("Starting SpaceCadet v0.1, please wait...")

@time begin

using Pkg
try pkg"activate ." catch
     pkg"instantiate"; pkg"activate ." end

using ImageSegmentation: fast_scanning, felzenszwalb, seeded_region_growing,
   prune_segments, segment_pixel_count, labels_map, segment_mean, segment_labels,
   SegmentedImage
using FreeTypeAbstraction: renderstring!, newface, FreeType
using Images: save, load, height, width, Gray, GrayA, RGB, N0f8, FixedPointNumbers
using Gadfly: plot, inch, draw, SVG, Guide.xlabel, Guide.ylabel, Geom.bar,
   Scale.y_log10
<<<<<<< HEAD
using Blink: Page, Window, title, size, body!, loadcss!, js, tools, msg, handle,
   JSString, @js_, @js
using ImageTransformations: imresize
using DataFrames: DataFrame
using AssetRegistry: register
using BSON: @save, @load
using Random: seed!
using CSV: write
using Dates: now
using ColorTypes
using CuArrays
using Interact
using Interact: node
using Flux
using Flux: crossentropy, Conv, train!, @epochs
using Mux
#using Logging  # not compiled, not traced!


include("./src/funcs.jl")
include("./src/ui.jl")
# include("./src/events.jl")
include("./src/models.jl")

const port = rand(8000:8000)
WebIO.webio_serve(page("/", req -> ui["html"]), port)

println("...complete!

Go to 'localhost:$port' in your browser.

Coded with ♡ by dustin.irwin@cadmusgroup.com 2020.")

end  # begin
=======
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

>>>>>>> 10a49c5aee0f0ecdd2832c61eb9cf7c86f02293a

# Diag tools
# tools(w)
# using Debugger
