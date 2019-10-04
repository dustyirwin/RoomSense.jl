using Pkg
try pkg"activate ." catch; pkg"instantiate"; pkg"activate ." end


function start()
    println("Loading RoomSense v0.1, please wait...")
    include("./src/funcs.jl");
    include("./src/ui.jl");
    include("./src/events.jl");
    include("./src/models.jl");
    println("...complete! Coded with ♡ by dustin.irwin@cadmusgroup.com 2019.")
end

@time start()


# Mux web hosting
# using Mux
# WebIO.webio_serve(page("/", req -> ui["html"], 8000))

# Diag tools
# tools(w)
# using Debugger
