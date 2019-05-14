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
using ImageSegmentation: fast_scanning, felzenszwalb, prune_segments, segment_pixel_count,
    labels_map, segment_mean, SegmentedImage

# Blink window
w = Window(async=false, Dict("webPreferences"=>Dict("webSecurity"=>false)));
title(w, "RoomSense v0.1"); size(w, 1200, 800);

# Electron diagnostic tools
#tools(w)

begin
    for f in readdir("./src")
        include("./src/" * f) end;
    work_history=[]; wi=0; prev_img_tab="Original";
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

<<<<<<< HEAD
println("...complete! Coded with ♡ by dusty.irwin@gmail.com for Cadmus Group 2019.")
=======
println("...complete! Coded with ♡ by Dustin Irwin for Cadmus Group 2019.")
>>>>>>> a19e0e84b8be3836f4385229ccb8b8c1ad2da158
