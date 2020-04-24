println(
"\nStarting SpaceCadet v0.1! Please wait...\n
Loading packages...\n")

using Pkg

@time begin

try pkg"activate ." catch
     pkg"instantiate"; pkg"activate ." end

using Interact: Widgets, Observables, Observable, OrderedDict, node, checkbox,
    dropdown, textbox, button, em, hbox, hskip, vbox, vskip, tabs, tabulator,
    mask, widget, Widgets.radiobuttons, Widgets.confirm, settheme!
using ImageSegmentation: fast_scanning, felzenszwalb, seeded_region_growing,
    prune_segments, segment_pixel_count, labels_map, segment_mean,
    segment_labels, SegmentedImage
using Images: save, load, height, width, Gray, GrayA, RGB, N0f8,
    FixedPointNumbers
using FreeTypeAbstraction: renderstring!, FTFont
using InteractBulma: compile_theme, examplefolder
using ImageTransformations: imresize
using AssetRegistry: register
using DataFrames: DataFrame
using BSON: @save, @load
using JSExpr: @js, Scope
using Random: seed!
using CSV: write
using Dates: now
using Metalhead
using ImageIO
using Logging
using NNlib
using WebIO
using Plots
using Mux

end

@time begin

println("\nComplete. Loading codebase...\n")

const i = 1  # work index

if @isdefined s  # user session data
else const s = Dict{Symbol,Any}[ Dict(
    :scale => [1.,""],
    :segs_types => nothing,
    :selected_areas => Tuple{Int64,Int64}[]
    )] end

plotly()  # Plotly backend

@time include("./secrets/secrets.jl")
@time include("./src/funcs.jl")
@time include("./src/models.jl")
@time include("./src/ui.jl")
@time include("./src/scope.jl")
@time include("./src/events.jl")
@time include("./src/server.jl")

println("All finished! Coded with ♡ by dustin.irwin@cadmusgroup.com 2019.")

end  # begin
