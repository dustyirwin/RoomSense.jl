using Pkg
pkg"activate ."
#pkg"up; precompile"

println("Loading RoomSense v0.1, please wait...")

using Interact
using CSV: write
using Dates: now
using Random: seed!
using JLD2: @save, @load
using DataFrames: DataFrame
using FreeTypeAbstraction: renderstring!, newface
using Images: save, load, height, width, Gray, GrayA, RGB, N0f8
using Blink: Window, title, size, handle, msg, js, tools, body!, @js, @js_
using Gadfly: plot, inch, draw, SVG, Guide.xlabel, Guide.ylabel, Geom.bar, Scale.y_log10
using ImageSegmentation: fast_scanning, felzenszwalb, seeded_region_growing, prune_segments,
    segment_pixel_count, labels_map, segment_mean, SegmentedImage


# Blink window  !!! WEB SECURTY SET TO OFF, DO NOT DEPLOY APP TO ANY WEBSERVER !!!
w = Window(async=false, Dict("webPreferences"=>Dict("webSecurity"=>false)));
title(w, "RoomSense v0.1"); size(w, 1100, 700);


# Electron diagnostic tools
#tools(w)


wi = 1
clicks = []

for file in readdir("./src")
    include("./src/$file") end

s = [Dict{Any,Any}(
    "prev_img_tab"=>"Original",
    "prev_op_tab"=>"Set Scale",
    "scale"=>Nothing)]

body!(w, ui["html"])


# Mux web hosting
# using Mux
# WebIO.webio_serve(page("/", req -> ui["html"], 8000))

println("...complete! Coded with ♡ by dustin.irwin@cadmusgroup.com 2019.")
