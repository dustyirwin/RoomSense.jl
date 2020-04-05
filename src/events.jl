function space_cadet(ui::AbstractDict, scope::Scope)
    # listen on JavaScript

    onjs(scope, "img_url_input",
        @js args -> document.getElementById("Original").src = args;)

    onjs(scope, "Overlay_src",
        @js args -> document.getElementById("Overlay").src = args;)

    # listen on Julia

    on(scope, "img_url_input") do args
        observs["go"][1]["is-loading"][] = true

        try fn = "tmp/" * split(split(args, "/")[end], "?")[begin]
            download(args, fn)
            s[wi]["Original_img"] = load(fn)
            s[wi]["Overlay_img"] = make_transparent(s[wi]["Original_img"])
            save(fn[1:end-4] * "_Overlay.jpg", s[wi]["Overlay_img"])
            observs["Overlay_src"][] = register(fn[1:end-4] * "_Overlay.jpg")

            println("img_url_input operations complete! overlay rfn: $(observs["Overlay_src"][1][])")

        catch err return

        finally observs["go"][1]["is-loading"][] = false end end

    on(scope, "go") do args
        observs["go"][1]["is-loading"][] = true

        try
            println("run funcs!")
            sleep(2)
            println("done!")

        catch err return

        finally observs["go"][1]["is-loading"][] = false
        end end

    on(scope, "img_click") do args
        try println("img clicked! key: $args")
        catch end end

    on(scope, "img_tabs") do args
        key = observs["img_tabs"][1][]
        println("img tabs clicked! key: $key") end

    on(scope, "funcs") do args
        key = observs["func_tabs"][1][]
        println("funcs clicked! key: $key") end

    return scope
end
