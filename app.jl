println("Loading RoomSense v0.1, please wait...")

using Pkg
pkg"activate ."
# pkg"instantiate"

using Flux
using Zygote
using Interact
using CuArrays
using CSV: write
using Dates: now
using Random: seed!
using JLD2: @save, @load
using DataFrames: DataFrame
using ImageTransformations: imresize
using FreeTypeAbstraction: renderstring!, newface, FreeType
using Images: save, load, height, width, Gray, GrayA, RGB, N0f8, FixedPointNumbers
using Blink: Window, title, size, handle, msg, js, tools, body!, @js_
using Gadfly: plot, inch, draw, SVG, Guide.xlabel, Guide.ylabel, Geom.bar, Scale.y_log10
using ImageSegmentation: fast_scanning, felzenszwalb, seeded_region_growing, prune_segments,
    segment_pixel_count, labels_map, segment_mean, segment_labels, SegmentedImage


# WEB SECURTY SET TO OFF, DO NOT DEPLOY APP TO ANY WEBSERVER !!!
try close(w) catch end
w = Window(async=false, Dict("webPreferences"=>Dict("webSecurity"=>false)));
title(w, "RoomSense v0.1"); size(w, 1100, 700);

begin
    include("./src/funcs.jl");
    include("./src/ui.jl");
    include("./src/events.jl");

    wi = 1  # work index
    s = [Dict{Any,Any}(
        "current_img_tab"=>"Original",
        "prev_op_tab"=>"Set Scale",
        "scale"=>(1.,"ft",""),
        "selected_areas"=>Vector{Int64}())];

    #body!(w, ui["input"])
    body!(w, ui["html"])
end


println("...complete! Coded with ♡ by dustin.irwin@cadmusgroup.com 2019.")

# Mux web hosting
# using Mux
# WebIO.webio_serve(page("/", req -> ui["html"], 8000))


# Diag tools
# tools(w)
# using Debugger
