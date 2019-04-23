using Pkg
Pkg.activate(".")

using ImageSegmentation
using ImageMagick
using Images
using Blink
using Interact
using Dates
using Random
using Flux

# Launch app into Blink window
w = Window(Dict("webPreferences"=>Dict("webSecurity"=>false)))
title(w, "RoomSense v0.1"); size(w, 1200, 800)

for f in readdir("./src")
    include("./src/" * f);
end
body!(w, ui["html"])

# Electron Tools
tools(w)
