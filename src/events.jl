function space_cadet(ui::AbstractDict, scope::Scope)
    # listen on JavaScript

    onjs(scope, "img_url_input",
        @js args -> document.getElementById("Original").src = args;)

    onjs(scope, "Overlay_src",
        @js args -> document.getElementById("Overlay").src = args;)

    # listen on Julia

    on(scope, "img_url_input") do args
        scope.observs["go"][1]["is-loading"][] = true

        try fn = "tmp/" * split(split(args, "/")[end], "?")[begin]
            download(args, fn)
            s[wi]["Original_img"] = load(fn)
            s[wi]["Overlay_img"] = make_transparent(s[wi]["Original_img"])
            save(fn[1:end-4] * "_Overlay.jpg", s[wi]["Overlay_img"])
            scope.observs["Overlay"][1][].props[:attributes]["src"] = register(fn[1:end-4] * "_Overlay.jpg")

        catch err return

        finally scope.observs["go"][1]["is-loading"][] = false end end

    on(scope, "go") do args
        scope.observs["go"][1]["is-loading"][] = true

        try
            println("run funcs!")
            sleep(2)
            println("done!")

        catch err return

        finally scope.observs["go"][1]["is-loading"][] = false end end

    on(scope, "img_click") do args
        scope.observs["information"][1][] = node(:strong, "x: $(args[1]) y: $(args[2])")
        try println("img clicked! args: $args")
        catch end end

    on(scope, "img_tabs") do args
        if args in ["<<",">>"] return
        else
            key = scope.observs["img_tabs"][1][]
            scope.observs["img_mask"][1][:key][] = key

            try scope.observs["$(args)_src"][1][] = s[wi]["$(args)_src"]  # save registered img src to s[wi]
            catch err end
        end
        println("img tabs clicked! key: $key") end

    on(scope, "func_tabs") do args
        key = scope.observs["func_tabs"][1][]
        scope.observs["func_mask"][1][:key][] = key
        println("funcs tab clicked! key: $key") end

    return scope
end
