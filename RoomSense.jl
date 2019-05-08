using Pkg
Pkg.activate(".");

using BSON
using Blink
using Interact
using Random
using Dates
using XLSX
using Flux
using Images
using Gadfly
using CuArrays
using ImageMagick
using ImageSegmentation
using FreeTypeAbstraction


# Blink window
w = Window(Dict("webPreferences"=>Dict("webSecurity"=>false)));
Blink.title(w, "RoomSense v0.1"); size(w, 1200, 800);

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
