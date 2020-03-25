

const ngrok = "http://d0d0ca0b.ngrok.io"
const port = rand(8000:8000)


function space_cadet(ui::AbstractDict, observs::ObsDict, events::AbstractDict)

    scope = Scope(
        dom=ui["/"],
        observs=observs,
    )

    WebIO.onjs(scope, "img_url_input",       # listen on JavaScript
        JSExpr.@js args -> document.getElementById("display").src = args;
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
            println("run funcs!")
        catch err return end
    end

    on(scope, "img_click") do args
        try
            println("img clicked!")
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
    @sync WebIO.webio_serve(page("/", req -> space_cadet(ui, observs, events)), 8000)
