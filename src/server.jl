
const ObsDict = Dict{String, Tuple{Observables.AbstractObservable, Union{Nothing,Bool}}}
const ngrok = "http://d0d0ca0b.ngrok.io"
const port = rand(8000:8000)

ui = build_ui()

function space_cadet(ui)
    observs = ObsDict(
        "go"=>(ui["go"], nothing),)

    scope  = Scope(
        dom=ui["html"],
        observs=observs)

    on(scope, "go") do args # listen on Julia#
        println("User pressed Go!") end

    return scope
end

@sync WebIO.webio_serve(page("/", req -> space_cadet(ui)), port)


#WebIO.webio_serve(page("/results", req -> space_cadet_server), 8006)


# updates to this update the UI

welcome_img = AssetRegistry.register("./assets/astronaut.jpg")
ui["imgs"]["original"].props[:attributes]["src"] = welcome_img

fieldnames(typeof(ui["imgs"]["original"]))


ui["imgs"]["original"].props[:attributes]["src"] = ""


ui["imgs"]["original"].props[:attributes]["src"]

@app space_cadet_server = (
Mux.defaults,
page(respond(ui["html"])),
page("/results", respond("<h1>Results Page!</h1>")),
page("/assign_spacetypes", req -> "<h1>space type editor here!</h1>"),
Mux.notfound(),
)

on(ui["go"]) do args # listen on Julia#
    println("User pressed Go!")
end
