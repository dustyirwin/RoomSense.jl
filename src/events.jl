
function space_cadet(ui::AbstractDict, w::Scope)

    on(w, "img_url_input") do args
        ui[:go]["is-loading"][] = true

        try fn = "tmp/" * split(split(args, "/")[end], "?")[begin]
            download(args, fn)
            println("User uploaded an img! \n args: $args \n fn: $fn")

            s[i]["Original_fn"] = fn
            s[i]["Original_img"] = load(fn)
            _w = s[i]["Original_width"] = width(s[i]["Original_img"])
            _h = s[i]["Original_height"] = height(s[i]["Original_img"])
            s[i]["Overlay_img"] = make_transparent(s[i]["Original_img"])
            save(fn[1:end-4] * "_Overlay.jpg", s[i]["Overlay_img"])

            ui[:original_img][] = make_clickable_img("original", ui[:img_click], register(fn))
            ui[:overlay_img][] = node(:img, attributes=Dict(
                "src"=>register(fn[1:end-4] * "_Overlay.jpg"),
                "style"=>"top: 0px; left: 0px; opacity:0.7;"))

            ui[:img_tabs][:options][] = ["Original", "Google Maps"]

            ui["Overlay_mask"][] = 1

            ui[:img_info][] = node(:p, "width: $_w  height: $_h")
            ui[:information][] = node(:p, ui[:help_texts]["User Image"])

        catch err
        finally ui[:go]["is-loading"][] = false end end

    on(w, "go") do args
        ui[:go]["is-loading"][] = true

        try
            input_name = ui[:inputs_mask][:key][]

            println("User clicked Go! input_name: $input_name")

            go_funcs[input_name](ui, ui[:inputs][input_name][])

        catch err; println(err); return
        finally ui[:go]["is-loading"][] = false  end end

    on(w, "img_click") do args
        println("display_img clicked! args: $args")
        ui[:go]["is-loading"][] = false

        try
            ui[:click_info][] = node(:p, "y: $(args[1]) x: $(args[2])")
            selected_func = ui[:inputs_mask][:key][]

            if selected_func == "User Image" && ui[:funcs_mask][:key][] == "Set Scale"
                ui[:inputs][selected_func][] = ui[:inputs][selected_func][] * "$(args[7] ? args[1] : args[2]),"
            end

        catch err return

        finally ui[:go]["is-loading"][] = false end end

    on(w, "img_tabs") do args
        println("img tabs clicked! args: $args")
        ui[:gmap_mask][] = args == "Google Maps" ? 1 : 0
        ui[:original_mask][] = args == "Original" ? 1 : 0
        ui[:segs_mask][] = args == "Segmented" ? 1 : 0
        ui[:plots_mask][] = args == "Plots" ? 1 : 0 end

    on(w, "func_tabs") do args
        println("funcs_tabs pressed! args: $args")
        ui[:funcs_mask][:key][] = args
        ui[:inputs_mask][:key][] = ui[:funcs][args][]

        ui["Colorize_mask"][] = args in ["Segment Image", "Modify Segments"] ? 1 : 0

        if args == "Set Scale"
            ui[:img_tabs][:options][] = ["Original", "Google Maps"]
        elseif args == "Segment Image"
            ui[:img_tabs][:options][] = ["Original", "Segmented", "Plots"]
        end end

    on(w, "inputs_mask") do args
        println("inputs_mask changed! args: $args")
        ui[:information][] = node(:p, ui[:help_texts][ ui[:inputs_mask][:key][] ]) end

    on(w, "Set Scale") do args
        ui[:inputs_mask][:key][] = args end

    on(w, "Segment Image") do args
        ui[:inputs_mask][:key][] = args end

    on(w, "Modify Segments") do args
        ui[:inputs_mask][:key][] = args end

    on(w, "Export Data") do args
        ui[:inputs_mask][:key][] = args end

    on(w, "Overlay") do args
        println("Overlay clicked! args: $args")
        ui[:img_masks][:overlay_mask][] = args ? 1 : 0 end

    return w
end
