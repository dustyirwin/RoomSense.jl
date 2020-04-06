
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

            w.observs["img_info"][1][] = node(:strong,
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
        w.observs["information"][1][] = node(:strong, "x: $(args[1]) y: $(args[2])")
        try println("img clicked! args: $args")
        catch end end

    on(w, "img_tabs") do args
        if args in ["<<",">>"] return
        else
            key = w.observs["img_tabs"][1][]
            w.observs["imgs_mask"][1][:key][] = key end

        println("img tabs clicked! key: $key") end

    on(w, "func_tabs") do args
        w.observs["funcs_mask"][1][:key][] = args
        f = w.observs["inputs_mask"][1][:key][] = ui["funcs"][args][]
        w.observs["information"][1][] = node(:strong, ui["help_texts"][f])
        println("func tab clicked! key: $args")
    end

    on(w, [keys(ui["inputs"])...]) do args
        dd_name = w.observs["funcs_mask"][1][:key][]
        i = ui["funcs"][dd_name].components[:index][]
        op_name = [keys(ui["funcs"][dd_name].components[:options][])...][i]
        w.observs["inputs_mask"][1][:key][] = op_name
        func = ui["funcs"][ w.observs["func_tabs"][1][] ][]
        w.observs["information"][1][] = node(:strong, ui["information"][op_name])

        println("$op_name selected!")
    end

    return w
end

ui["funcs"]["Set Scale"][]
