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
include("ui.jl")
include("funcs.jl")
# load!(w, "ui.js")  # jl events
body!(w, ui["html"](""))
go_event(w)

# Blink tools
opentools(w)

img = load(ui["img_filename"][])
size(w, size(img, 2), size(img, 1))
tmp_img_filename = "$(ui["img_filename"][][1:end-4])_$(now())"
save(tmp_img_filename, seg_img(img))
@async body!(w, ui["html"](tmp_img_filename))
ui["img_filename"][][1:end-4]
