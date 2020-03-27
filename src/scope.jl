
const ObsDict = Dict{String, Tuple{Observables.AbstractObservable, Union{Nothing,Bool}}}

observs = ObsDict(
    "img_url_input"=>(ui["obs"]["img_url_input"], nothing),
    "go"=>(ui["obs"]["go"], nothing),
)

function space_cadet(ui::AbstractDict, observs::ObsDict)
    scope = Scope(
        dom=node(:div),
        observs=observs)

    img_click = Observable(scope, "img_click", [])

    ui["img_container"] = node(:div,
        hbox(hskip(1em), ui["img_tabs"], hskip(1em),
        ),
        attributes=Dict(
            "id"=>"img_container",
            "align"=>"center",
            "style"=>"position: relative; padding: 0px; border: 0px; margin: 0px;"),
        events=Dict("click" => @js () -> $img_click[] = [
            event.pageY - document.getElementById("img_container").offsetTop,
            event.pageX,
            document.getElementById("display").height,
            document.getElementById("display").width,
            document.getElementById("display").naturalHeight,
            document.getElementById("display").naturalWidth,
            event.ctrlKey,
            event.shiftKey,
            event.altKey,
            ];
    ))

    ui["/"] = node(:div,
        node(:div, ui["func_panel"], attributes=Dict(
            "classList"=>"navbar", "position"=>"fixed")),
        node(:div, ui["img_container"], attributes=Dict(
            "position"=>"relative")))

    scope.dom = ui["/"]

    # listen on JavaScript

    WebIO.onjs(scope, "img_url_input",
        JSExpr.@js args -> document.getElementById("display").src = args;
    )


    # listen on Julia

    on(scope, "img_url_input") do args
        try fn = get_img_from_url(args)
            ui["obs"]["img_orig_src"][] = register(fn)
            println("User image registered as $(ui["obs"]["img_orig_src"][]).")
        catch err return end
    end

    on(scope, "go") do args
        try
            ui["obs"]["go"]["is-loading"][] = true
            println("run funcs!")
        catch err return end
    end

    on(scope, "img_click") do args
        try
            println("img clicked! js returned: $args")
        catch err return end
    end

    return scope
end #
