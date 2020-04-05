
const ngrok = "http://d0d0ca0b.ngrok.io"
const port = rand(8000:8000)


function assetserve(dirs=true)
    absdir(req) = AssetRegistry.registry["/assetserver/" * req[:params][:key]]
    branch(req -> (isfile(absdir(req)) && isempty(req[:path])) ||
    validpath(absdir(req), joinpath(req[:path]...), dirs=dirs),
    req -> fresp(joinpath(absdir(req), req[:path]...)))
end


const assetserver = @isdefined(assetserver) ? assetserver :
    route("assetserver/:key", assetserve(), Mux.notfound())

const webserver = @isdefined(webserver) ? webserver :
    @sync WebIO.webio_serve(page("/", req -> space_cadet(ui, scope)), 8000)
