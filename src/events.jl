
const ObsDict = Dict{String, Tuple{Observables.AbstractObservable, Union{Nothing,Bool}}}

observs = ObsDict(
    "img_url_input"=>(ui["obs"]["img_url_input"], true),
    "img_click"=>(ui["obs"]["img_click"], true),
    "go"=>(ui["obs"]["go"], true),
)

events = Dict(
    "img_click" => ("img_click", JSExpr.@js args -> console.log(args) ),
    
)
