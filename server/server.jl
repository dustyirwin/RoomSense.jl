
const port = rand(80:80)

function assetserve(dirs=true)
    absdir(req) = AssetRegistry.registry["/assetserver/" * req[:params][:key]]
    branch(req -> (isfile(absdir(req)) && isempty(req[:path])) ||
    validpath(absdir(req), joinpath(req[:path]...), dirs=dirs),
    req -> fresp(joinpath(absdir(req), req[:path]...)))
    end

const assetserver = route("assetserver/:key", assetserve(), Mux.notfound())

function space_cadet(req)
    global sessions
    println("HTTP request for '/' received! req: $req")
    user_id(req=Dict()) = 1  # db lookup for user_id?
    sessions[user_id()] = Dict{Symbol,Any}(
        :ui => _ui(),
        :s => [new_session()],
        :i => 1, )
    scope = sessions[user_id()][:scope] = _scope(sessions[user_id()][:ui])

    return scope end

const webserver = WebIO.webio_serve(page("/", req -> space_cadet(req)), port)
