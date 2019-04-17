using FreeTypeAbstraction
using ImageSegmentation
using ImageMagick
using Images
using Blink
using Interact
using Random
using Dates


# Launch app into Blink window
w = Window(async=false, Dict("webPreferences"=>Dict("webSecurity"=>false)))
title(w, "RoomSense v0.1")
include("ui.jl");
include("funcs.jl")
body!(w, ui["html"]())

# Blink tools
opentools(w)

# workspace
