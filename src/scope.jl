
const ObsDict = Dict{String, Tuple{Observables.AbstractObservable, Union{Nothing,Bool}}}

const observs = ObsDict(key=>(value, nothing) for (key, value) in collect(ui["obs"]))

const scope = Scope(observs=observs)

const img_click = Observable(scope, "img_click", [])

ui["img_container"] = node(:div,
    observs["img_mask"][1],
    attributes=Dict(
        "id"=>"img_container",
        "align"=>"center",
        "style"=>"position: relative; padding: 0px; border: 0px; margin: 0px;"),
    events=Dict("click" => @js () -> $img_click[] = [
        event.pageY - document.getElementById("img_container").offsetTop,
        event.pageX,
        document.getElementById("img_container").height,
        document.getElementById("img_container").width,
        document.getElementById("img_container").naturalHeight,
        document.getElementById("img_container").naturalWidth,
        event.ctrlKey,
        event.shiftKey,
        event.altKey,
    ];)
)

ui["/"] = node(:div,
    node(:div, ui["func_panel"], attributes=Dict(
        "classList"=>"navbar", "position"=>"fixed")),
    node(:div, ui["img_container"], attributes=Dict(
        "position"=>"relative")))

scope.dom = ui["/"]
