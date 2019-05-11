using Pkg
@pkg_str "activate ."
@pkg_str "precompile"

println("Loading RoomSense v0.1, please wait...")

#using Flux
#using CuArrays
#using Metalhead
#using ImageMagick
using Interact
using Dates: now
using Random: seed!
using BSON: @save, @load
using FreeTypeAbstraction: renderstring!, newface
using Images: save, load, height, width, Gray, GrayA, RGB, N0f8
using Blink: Window, title, size, handle, msg, js, body!, @js, @js_
using Gadfly: plot, inch, draw, SVGJS, Guide.xlabel, Guide.ylabel, Geom.bar, Scale.y_log10
using ImageSegmentation: fast_scanning, felzenszwalb, prune_segments, segment_pixel_count, labels_map, SegmentedImage

# Blink window
w = Window(Dict("webPreferences"=>Dict("webSecurity"=>false)));
title(w, "RoomSense v0.1"); size(w, 1200, 800);

# Mux hosting
# using Mux

begin
    for f in readdir("./src")
        include("./src/" * f) end;
    work_history = clicks = []; wi = 0; prev_img_tab = "Original"
    body!(w, ui["html"]());
end

# Electron diagnostic tools
#tools(w)

println("...complete! Coded with <3  by Dustin Irwin 2019.")
