using Pkg
pkg"activate ."
# pkg"instantiate"

println("Loading RoomSense v0.1, please wait...")

@time begin
    include("./src/funcs.jl");
    include("./src/ui.jl");
    include("./src/events.jl");
    include("./src/models.jl");
end

println("...complete! Coded with ♡ by dustin.irwin@cadmusgroup.com 2019.")

# Mux web hosting
# using Mux
# WebIO.webio_serve(page("/", req -> ui["html"], 8000))


# Diag tools
# tools(w)
# using Debugger
