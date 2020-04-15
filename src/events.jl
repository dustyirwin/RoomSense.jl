
function space_cadet(ui::AbstractDict, w::Scope)

    on(w, "img_url_input") do args
        w.observs["go"][1]["is-loading"][] = true

        try fn = "tmp/" * split(split(args, "/")[end], "?")[begin]
            download(args, fn)
            s[ wi[] ]["Original_img"] = load(fn)
            s[ wi[] ]["Overlay_img"] = make_transparent(s[ wi[] ]["Original_img"])
            save(fn[1:end-4] * "_Overlay.jpg", s[ wi[] ]["Overlay_img"])

            w.observs["original"][1][] = node(:img, attributes=Dict(
                "src"=>register(fn), "style"=>"opacity: 0.9;"))

            w.observs["overlay"][1][] = node(:img, attributes=Dict(
                "src"=>register(fn[1:end-4] * "_Overlay.jpg"),
                "style"=>"position: absolute; top: 0px; left: 0px; opacity: 0.9;")
            )

            w.observs["img_info"][1][] = node(:p,
                "height: $(height(s[ wi[] ]["Original_img"])) px width: $(width(s[ wi[] ]["Original_img"]))"
            )

            println("User uploaded a valid img url! user img rfn: $(register(fn))")

        catch err return

        finally w.observs["go"][1]["is-loading"][] = false end end

    on(w, "go") do args
        w.observs["go"][1]["is-loading"][] = true

        try
            println("run funcs!")
            sleep(2)
            println("done!")

        catch err return

        finally w.observs["go"][1]["is-loading"][] = false end end

    on(w, "img_click") do args
        w.observs["click_info"][1][] = node(:p, "x: $(args[1]) y: $(args[2])")

        func_key = w.observs["funcs_mask"][1][:key][]

        if func_key in ["Feet", "Meters"]
            ui["inputs"][func_key][] = ui["inputs"][func_key][] * "$(args[7] ? args[1] : args[2]),"
        end

        try println("img clicked! args: $args")
        catch end end

    on(w, "img_tabs") do args
        key = w.observs["img_tabs"][1][]
        w.observs["imgs_mask"][1][:key][] = key

        println("img tabs clicked! key: $key") end

    on(w, "func_tabs") do args
        println("func_tabs clicked! key: $args")
        func_name = ui["funcs"][args][]
        println("func_name: $func_name")
        w.observs["funcs_mask"][1][:key][] = args
        w.observs["inputs_mask"][1][:key][] = func_name end

    on(w, "inputs_mask") do args
        println("inputs_mask changed! args: $args")
        w.observs["information"][1][] = node(:p,
            ui["help_texts"][ w.observs["inputs_mask"][1][:key][] ]) end

    on(w, "Set Scale") do args
        w.observs["inputs_mask"][1][:key][] = args end

    on(w, "Segment Image") do args
        w.observs["inputs_mask"][1][:key][] = args end

    on(w, "Modify Segments") do args
        w.observs["inputs_mask"][1][:key][] = args end

    on(w, "Export Data") do args
        w.observs["inputs_mask"][1][:key][] = args end

    on(w, "<<") do args
        println("<< pressed! args: $args") end

    on(w, ">>") do args
        println(">> pressed! args: $args") end

    return w
end
