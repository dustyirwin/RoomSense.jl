using WebIO
using JSExpr # you may need to install this package
using Mux


const ObsDict = Dict{String, Tuple{Observables.AbstractObservable, Union{Nothing,Bool}}}
const ngrok = "http://d0d0ca0b.ngrok.io"
const port = rand(8000:8000)


function space_cadet(ui::OrderedDict{String,Any}, req::Dict{Any,Any})

    observs=ObsDict(
        "go"=>(ui["go"], nothing),)

    scope = Scope(
        dom=ui["/"](req),
        observs=observs,
    )

    WebIO.onjs(scope, "go",     # listen on JavaScript
        JSExpr.@js src -> document.getElementById("original").src = src;
    )

    on(scope, "go") do args     # listen on Julia
        println("User pressed Go!")
    end

    return scope
end


function assetserve(dirs=true)
    absdir(req) = AssetRegistry.registry["/assetserver/" * req[:params][:key]]
    branch(req -> (isfile(absdir(req)) && isempty(req[:path])) ||
    validpath(absdir(req), joinpath(req[:path]...), dirs=dirs),
    req -> fresp(joinpath(absdir(req), req[:path]...)))
end


ui = build_ui()

welcome_img = AssetRegistry.register("./assets/astronaut.jpg")

ui["imgs"]["original"].props[:attributes]["src"] = welcome_img


const assetserver = @isdefined(assetserver) ? assetserver :
    route("assetserver/:key", assetserve(), Mux.notfound())

const webserver = @isdefined(webserver) ? webserver :
    @sync WebIO.webio_serve(page("/", req -> space_cadet(ui, req)), 8000)
