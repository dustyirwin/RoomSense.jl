println(
"\nStarting SpaceCadet v0.1! Please wait...\n
Loading packages...\n")

using Pkg

@time begin

try pkg"activate ." catch
     pkg"instantiate"; pkg"activate ." end

using Interact: Widgets, Observables, Observable, OrderedDict, node, checkbox,
    dropdown, textbox, button, em, hbox, hskip, vbox, vskip, tabs, tabulator,
    mask, widget, Widgets.radiobuttons, Widgets.confirm, settheme!, checkboxes,
    alert
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
using PlotlyJS
using ImageIO
using ZipFile
using Logging
using Flux
using WebIO
using Plots
using Mux

#using Revise

end

@time begin

println("\nComplete. Loading codebase...\n")

const i = 1  # work index

@async s[i][:plots] = s[i][:seeds_img] = s[i][:labels_img] = nothing

new_instance = () -> Dict{Symbol,Any}(
    :scale => [1.,""],
    :preds => Dict(),
    :plots => nothing,
    :user_img => nothing,
    :seeds_img => nothing,
    :labels_img => nothing,
    :overlay_img => nothing,
    :selected_spaces => OrderedDict{Int64,Union{Missing,Int64}}(),
    :space_types => OrderedDict{Int64,Union{Missing,String}}(),
    )

# user session data
if @isdefined s
else const s = [new_instance()] end

@time include("./secrets/secrets.jl");
@time include("./src/funcs.jl");
@time include("./src/models.jl");
@time include("./src/ui.jl");
@time include("./src/scope.jl");
@time include("./src/events.jl");
@time include("./src/server.jl");

println("All finished! Coded with ♡ by dusty.irwin@gmail.com 2019.")

end  # begin
