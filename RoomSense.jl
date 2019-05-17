using Pkg
@pkg_str "activate ."
#@pkg_str "precompile"

println("Loading RoomSense v0.1, please wait...")

using Flux
using Interact
using Dates: now
using Random: seed!
using JLD2: @save, @load
using FreeTypeAbstraction: renderstring!, newface
using Images: save, load, height, width, Gray, GrayA, RGB, N0f8
using Blink: Window, title, size, handle, msg, js, tools, body!, @js, @js_
using Gadfly: plot, inch, draw, SVG, Guide.xlabel, Guide.ylabel, Geom.bar, Scale.y_log10
using ImageSegmentation: fast_scanning, felzenszwalb, seeded_region_growing, prune_segments, segment_pixel_count,
    labels_map, segment_mean, SegmentedImage

# Blink window
w = Window(async=false, Dict("webPreferences"=>Dict("webSecurity"=>false)));
title(w, "RoomSense v0.1"); size(w, 1200, 800);

# Electron diagnostic tools
#tools(w)

begin
    for f in readdir("./src")
        include("./src/" * f) end;
    s=[Dict{Any,Any}("prev_img_tab"=>"Original")]; wi=1;
    body!(w, ui["html"]);
end

"""
# Mux web hosting
using Mux
@app RoomSense = (
  Mux.defaults,
  page(respond(body!(Window(Dict("webPreferences"=>Dict("webSecurity"=>false))), ui["html"]))),
  page("/about",
       probabilty(0.1, respond("<h1>Boo!</h1>")),
       respond("<h1>About Me</h1>")),
  page("/user/:user", respond(w)),
  Mux.notfound());
serve(RoomSense)
"""

println("...complete! Coded with ♡ by dustin.irwin@cadmusgroup.com 2019.")
