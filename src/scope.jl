
const ObsDict = Dict{String, Tuple{Observables.AbstractObservable, Union{Nothing,Bool}}}

observs = ObsDict(key=>(value, nothing) for (key, value) in collect(ui["obs"]))
observs["funcs"] => (ui["funcs"], nothing)
observs["img_tabs"] => (ui["img_tabs"], nothing)

function space_cadet(ui::AbstractDict, observs::ObsDict)
    scope = Scope(observs=observs)

    img_click = Observable(scope, "img_click", [])

    ui["img_container"] = node(:div,
        ui["img_tabs"],
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

    onjs(scope, "img_url_input",
        @js args -> document.getElementById("display").src = args;)

    onjs(scope, "overlay_src",
        @js args -> document.getElementById("overlay").src = args;)


    # listen on Julia

    on(scope, "img_url_input") do args
        ui["obs"]["go"]["is-loading"][] = true

        try fn = "tmp/" * split(split(args, "/")[end], "?")[begin]
            download(args, fn)
            s[wi]["user_img"] = load(fn)
            s[wi]["overlay_img"] = make_transparent(s[wi]["user_img"])
            save(fn[1:end-4] * "_overlay.jpg", s[wi]["overlay_img"])
            observs["overlay_src"][] = register(fn[1:end-4] * "_overlay.jpg")

            println("img_url_input operations complete! overlay rfn: $(observs["overlay_src"][1][])")

        catch err return

        finally ui["obs"]["go"]["is-loading"][] = false end end

    on(scope, "go") do args
        ui["obs"]["go"]["is-loading"][] = true

        try println("run funcs!")

        catch err return

        finally ui["obs"]["go"]["is-loading"][] = false
        end end

    on(scope, "img_click") do args
        try println("img clicked! key: $args")
        catch end
    end

    on(scope, "img_tabs") do args
        key = ui["img_tabs"].components[:key][]
        println("img tabs clicked! key: $key")
    end

    on(scope, "funcs") do args
        key = ui["funcs"].components[:key][]
        ui["information"]
        println("funcs clicked! key: $key")
    end

    return scope
end
