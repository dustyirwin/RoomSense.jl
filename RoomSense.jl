using Pkg
Pkg.activate(".");

using FreeTypeAbstraction
using ImageSegmentation
using ImageMagick
using Interact
using Images
using Random
using Blink
using Dates
using Flux

# globals
wi = 1;
work_history = [];
custom_labels = Dict();

# Blink window
w = Window(Dict("webPreferences"=>Dict("webSecurity"=>false)));
title(w, "RoomSense v0.1"); size(w, 1200, 800);

# Mux hosting
# using Mux

for f in readdir("./src")
    include("./src/" * f)
end; body!(w, ui["html"]);

# Electron diagnostic tools
#tools(w)
