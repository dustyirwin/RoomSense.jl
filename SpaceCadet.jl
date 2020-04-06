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
using Interact: Widgets, Observables, Observable, OrderedDict, node, checkbox, dropdown,
    textbox, button, em, hbox, hskip, vbox, vskip, tabs, tabulator, mask, widget
using Images: save, load, height, width, Gray, GrayA, RGB, N0f8,
    FixedPointNumbers
using Gadfly: plot, inch, draw, SVG, Guide.xlabel, Guide.ylabel, Geom.bar,
    Scale.y_log10
using FreeTypeAbstraction: renderstring!, newface, FreeType
using ImageTransformations: imresize
using DataFrames: DataFrame
using BSON: @save, @load
using JSExpr: @js, Scope
using AssetRegistry: register
using Random: seed!
using CSV: write
using Dates: now
using Metalhead
using WebIO
using Flux
using Mux
using CuArrays
using Logging
#using ColorTypes

end

@time begin

println("\nComplete. Loading codebase...\n")

const wi = Observable(1)  # work index
const s = [Dict{Any,Any}(
    "scale"=>(1.,"ft",""),
    "segs_types"=>nothing,
    "selected_areas"=>Vector{Int64}())
    ];

@time include("./src/funcs.jl")
@time include("./src/ui.jl")
@time include("./src/models.jl")
@time include("./src/scope.jl")
@time include("./src/events.jl")
@time include("./src/server.jl")

println("All finished! Coded with ♡ by dustin.irwin@cadmusgroup.com 2019.")

end  # begin


# Diag tools
# tools(w)
# @time using Debugger
