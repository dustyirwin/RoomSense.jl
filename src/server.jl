
const port = rand(8000:8000)

# Asset("./css/space_cadet.css")

function assetserve(dirs=true)
    absdir(req) = AssetRegistry.registry["/assetserver/" * req[:params][:key]]
    branch(req -> (isfile(absdir(req)) && isempty(req[:path])) ||
    validpath(absdir(req), joinpath(req[:path]...), dirs=dirs),
    req -> fresp(joinpath(absdir(req), req[:path]...))) end


@isdefined(assetserver) ? assetserver :
const assetserver = route("assetserver/:key", assetserve(), Mux.notfound())

@isdefined(webserver) ? webserver :
const webserver = WebIO.webio_serve(page("/", req -> space_cadet(ui)), 8000)
