
function space_cadet(ui::AbstractDict, w::Scope)

    on(w, "img_url_input") do args
        w.observs["go"][1]["is-loading"][] = true

        try fn = "tmp/" * split(split(args, "/")[end], "?")[begin]
            download(args, fn)
            s[ wi[] ]["Original_img"] = load(fn)
            s[ wi[] ]["Overlay_img"] = make_transparent(s[ wi[] ]["Original_img"])
            save(fn[1:end-4] * "_Overlay.jpg", s[ wi[] ]["Overlay_img"])

            w.observs["display"][1][] = node(:img, attributes=Dict(
                "src"=>register(fn), "style"=>"opacity: 1.0;"))

            w.observs["overlay"][1][] = node(:img, attributes=Dict(
                "src"=>register(fn[1:end-4] * "_Overlay.jpg"),
                "style"=>"position: absolute; top: 0px; left: 0px; opacity: 0.9;"))

            w.observs["img_info"][1][] = node(:p,
                "height: $(height(s[ wi[] ]["Original_img"])) px width: $(width(s[ wi[] ]["Original_img"]))")

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
        w.observs["information"][1][] = node(:p, "x: $(args[1]) y: $(args[2])")
        try println("img clicked! args: $args")
        catch end end

    on(w, "img_tabs") do args
        if args in ["<<",">>"] return
        else
            key = w.observs["img_tabs"][1][]
            w.observs["imgs_mask"][1][:key][] = key end

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
    #w.observs["information"][1][] = node(:p, ui["information"][func])

    #dd_name = w.observs["funcs_mask"][1][:key][]
    #i = ui["funcs"][dd_name].components[:index][]
    #op_name = [keys(ui["funcs"][dd_name].components[:options][])...][i]
    #w.observs["inputs_mask"][1][:key][] = op_name

    #println("$op_name selected!")

    return w
end
