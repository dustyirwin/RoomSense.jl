println(
"\nStarting SpaceCadet v0.1! Please wait...\n
Loading packages...\n")

using Pkg

@time begin

try pkg"activate ." catch
     pkg"instantiate"; pkg"activate ." end

using ImageSegmentation: fast_scanning, felzenszwalb,
    seeded_region_growing, prune_segments, segment_pixel_count, labels_map,
    segment_mean, segment_labels, SegmentedImage
using FreeTypeAbstraction: renderstring!, newface, FreeType
using Images: save, load, height, width, Gray, GrayA, RGB, N0f8,
    FixedPointNumbers
using Gadfly: plot, inch, draw, SVG, Guide.xlabel, Guide.ylabel, Geom.bar,
    Scale.y_log10
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
using Mux
using Flux
using Flux: crossentropy, Conv, train!, @epochs
using Metalhead
using AssetRegistry
using Logging
using JSExpr


println("Loading codebase...\n")

const wi = 1  # work index
const s = [Dict{Any,Any}(
    "current_img_tab"=>"Original",
    "prev_op_tab"=>"Set Scale",
    "scale"=>(1.,"ft",""),
    "segs_types"=>nothing,
    "selected_areas"=>Vector{Int64}())];


@time include("./src/funcs.jl")
@time include("./src/models.jl")
@time include("./src/ui.jl")
@time include("./src/server.jl")
#@time include("./src/events.jl")

println("All finished! Coded with ♡ by dustin.irwin@cadmusgroup.com 2019.")

end  # begin


# Diag tools
# tools(w)
# @time using Debugger
