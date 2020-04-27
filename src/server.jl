
const p = rand(8000:8000)

function assetserve(dirs=true)
    absdir(req) = AssetRegistry.registry["/assetserver/" * req[:params][:key]]
    branch(req -> (isfile(absdir(req)) && isempty(req[:path])) ||
    validpath(absdir(req), joinpath(req[:path]...), dirs=dirs),
    req -> fresp(joinpath(absdir(req), req[:path]...)))
    end


const assetserver = route("assetserver/:key", assetserve(), Mux.notfound())

const webserver = WebIO.webio_serve(page("/", req -> space_cadet(ui)), 8000)
