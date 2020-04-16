
function space_cadet(ui::AbstractDict, w::Scope)

    on(w, "img_url_input") do args
        w.observs["go"][1]["is-loading"][] = true

        try fn = "tmp/" * split(split(args, "/")[end], "?")[begin]
            download(args, fn)
            s[ wi[] ]["Original_img"] = load(fn)
            s[ wi[] ]["Overlay_img"] = make_transparent(s[ wi[] ]["Original_img"])
            save(fn[1:end-4] * "_Overlay.jpg", s[ wi[] ]["Overlay_img"])
            s[ wi[] ]["Overlay_rfn"] = register(fn[1:end-4] * "_Overlay.jpg")

            _w = width(s[ wi[] ]["Original_img"])
            _h = height(s[ wi[] ]["Original_img"])

            w.observs["original"][1][] = node(:img, attributes=Dict(
                "src"=>register(fn), "style"=>"opacity: 0.9;"))

            w.observs["map"][1][] = node(:div, map(_w+20, _h+20))

            w.observs["img_info"][1][] = node(:p, "width: $_w px height: $_h px")

            w.observs["checkboxes_mask"][1][] = 1

            w.observs["img_tabs"][1][:options][] = ["Original", "Google Maps"]

            w.observs["information"][1][] = node(:p, ui["help_texts"]["User Image"])

            println("User uploaded a valid img url! user img rfn: $(register(fn))")

        catch err return

        finally w.observs["go"][1]["is-loading"][] = false end end

    on(w, "go") do args
        w.observs["go"][1]["is-loading"][] = true

        try
            input = w.observs["inputs_mask"][1][:key][]
            #funcs[input](ui["inputs"][input][])
            println("go pressed, reached end of instructions! input: $input")

        catch err return

        finally w.observs["go"][1]["is-loading"][] = false end end

    on(w, "img_click") do args
        w.observs["click_info"][1][] = node(:p, "x: $(args[1]) y: $(args[2])")

        selected_func = w.observs["inputs_mask"][1][:key][]
        if selected_func == "User Image"
            ui["inputs"][selected_func][] = ui["inputs"][selected_func][] * "$(args[7] ? args[1] : args[2]),"
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

    on(w, "Overlay") do args
        src = args ? s[ wi[] ]["Overlay_rfn"] : ""

        w.observs["overlay"][1][] = node(:img, attributes=Dict(
            "src"=>src,
            "style"=>"position: absolute; top: 0px; left: 0px; opacity: 0.5;"))

            println("Overlay clicked!") end

    return w
end
