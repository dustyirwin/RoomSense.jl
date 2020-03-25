using WebIO
using JSExpr # you may need to install this package
using Mux


const ObsDict = Dict{String, Tuple{Observables.AbstractObservable, Union{Nothing,Bool}}}
const ngrok = "http://d0d0ca0b.ngrok.io"
const port = rand(8000:8000)



function space_cadet(ui::OrderedDict{String,Any}, req::Dict{Any,Any})

    observs=ObsDict(
        "img_url_input"=>(ui["obs"]["img_url_input"], true),
        "img_click"=>(ui["obs"]["img_click"], true),
        "go"=>(ui["obs"]["go"], true),
    )

    scope = Scope(
        dom=ui["/"],
        observs=observs,
    )

    WebIO.onjs(scope, "img_url_input",       # listen on JavaScript
        JSExpr.@js args -> document.getElementById("original").src = args;
    )

    WebIO.onjs(scope, "go",
        JSExpr.@js args -> document.getElementById("go").classList = ["button is-danger is-loading"];
    )


    on(scope, "img_url_input") do args          # listen on Julia
        try fn = get_img_from_url(args)
            ui["obs"]["img_orig_src"][] = register(fn)
        catch err return end
    end

    on(scope, "go") do args
        try
            ui["obs"]["go"].components[Symbol("is-loading")] = true
            println("run funcs!")
        catch err return end
    end

    return scope
end #


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
