
const port = rand(8000:9000)

function assetserve(dirs=true)
    absdir(req) = AssetRegistry.registry["/assetserver/" * req[:params][:key]]
    branch(req -> (isfile(absdir(req)) && isempty(req[:path])) ||
    validpath(absdir(req), joinpath(req[:path]...), dirs=dirs),
    req -> fresp(joinpath(absdir(req), req[:path]...)))
    end

const assetserver = route("assetserver/:key", assetserve(), Mux.notfound())

function space_cadet(req=Dict())
    global sessions
    println("HTTP request for '/' received! req: $req")
    user_id(req=Dict()) = 1  # TODO: write lookup user_id

    if !haskey(sessions, user_id()) end  # TODO: remember previous sessions

    sessions[user_id()] = Dict{Symbol,Any}(
        :ui => _ui(req),
        :s => [new_session()],
        :i => 1,
        )
    sessions[user_id()] = _scope(sessions[user_id()])
    sessions[user_id()] = events(sessions[user_id()])

    return sessions[user_id()][:scope] end

const webserver = WebIO.webio_serve(page("/", req -> space_cadet(req)), 8000)
