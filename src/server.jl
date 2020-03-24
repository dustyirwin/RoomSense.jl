using WebIO
using JSExpr # you may need to install this package
using Mux


const ObsDict = Dict{String, Tuple{Observables.AbstractObservable, Union{Nothing,Bool}}}
const ngrok = "http://d0d0ca0b.ngrok.io"
const port = rand(8000:8000)



function space_cadet(ui::OrderedDict{String,Any}, req::Dict{Any,Any})

    observs=ObsDict("go"=>(ui["go"], nothing),)

    scope = Scope(
        dom=ui["/"],
        observs=observs,
    )

    #WebIO.onjs(scope, "go",     # listen on JavaScript
    #    JSExpr.@js src -> document.getElementById("original").src = ui["orig_src"];
    #)

    on(scope, "go") do args     # listen on Julia
        fn = get_img_from_url(ui["img_url_input"][])
        rfn = register(fn)
        #ui["imgs"]["original"].props[:attributes]["src"] = ui["orig_src"]
        JSExpr.@js src -> document.getElementById("original").src = $rfn;
    end

    return scope
end


function assetserve(dirs=true)
    absdir(req) = AssetRegistry.registry["/assetserver/" * req[:params][:key]]
    branch(req -> (isfile(absdir(req)) && isempty(req[:path])) ||
    validpath(absdir(req), joinpath(req[:path]...), dirs=dirs),
    req -> fresp(joinpath(absdir(req), req[:path]...)))
end


const assetserver = @isdefined(assetserver) ? assetserver :
    route("assetserver/:key", assetserve(), Mux.notfound())

const webserver = @isdefined(webserver) ? webserver :
    @sync WebIO.webio_serve(page("/", req -> space_cadet(ui, req)), 8000)
