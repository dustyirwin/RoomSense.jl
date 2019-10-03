using Pkg
pkg"activate ."
# pkg"instantiate"

println("Loading RoomSense v0.1, please wait...")

@time begin
    include("./src/funcs.jl");
    include("./src/ui.jl");
    include("./src/events.jl");
    include("./src/models.jl");

    wi = 1  # work index
    s = [Dict{Any,Any}(
        "current_img_tab"=>"Original",
        "prev_op_tab"=>"Set Scale",
        "scale"=>(1.,"ft",""),
        "selected_areas"=>Vector{Int64}(),
        "model"=>model)];

    body!(w, ui["html"])
end

println("...complete! Coded with ♡ by dustin.irwin@cadmusgroup.com 2019.")

# Mux web hosting
# using Mux
# WebIO.webio_serve(page("/", req -> ui["html"], 8000))


# Diag tools
# tools(w)
# using Debugger
