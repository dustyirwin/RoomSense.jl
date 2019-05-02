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
using JLD2
using XLSX

# user session
work_history=[]; wi = 0; prev_img_tab = "Original"

# Blink window
w = Window(Dict("webPreferences"=>Dict("webSecurity"=>false)));
title(w, "RoomSense v0.1"); size(w, 1200, 800);

# Mux hosting
# using Mux

for f in readdir("./src")
    include("./src/" * f)
end; body!(w, ui["html"]());

# Electron diagnostic tools
#tools(w)
