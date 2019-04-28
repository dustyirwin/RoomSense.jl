using Pkg
Pkg.activate(".")

using Statistics
using GeometricalPredicates
using FreeTypeAbstraction
using ImageSegmentation
using ImageMagick
using Interact
using Images
using Random
using Blink
using Dates


# Launch app into Blink window
working_history = []
custom_labels = Dict()
w = Window(Dict("webPreferences"=>Dict("webSecurity"=>false)))
title(w, "RoomSense v0.1"); size(w, 1200, 800)

for f in readdir("./src")
    include("./src/" * f);
end
body!(w, ui["html"])

# Electron Tools
#tools(w)
