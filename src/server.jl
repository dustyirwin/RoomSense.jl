

function assetserve(dirs=true)
    absdir(req) = AssetRegistry.registry["/assetserver/" * req[:params][:key]]
    branch(req -> (isfile(absdir(req)) && isempty(req[:path])) ||
           validpath(absdir(req), joinpath(req[:path]...), dirs=dirs),
           req -> fresp(joinpath(absdir(req), req[:path]...)))
end


const port = rand(8000:8000)


@app space_cadet = (
    Mux.defaults,
    page("/", req -> ui["html"]),
    page("/test", req -> node(:img, src=ri)),
    Mux.notfound()
)


serve(space_cadet, port)

const assetserver = route("assetserver/:key", assetserve(), Mux.notfound())

const ngrok = "http://f65482c8.ngrok.io"
