
function space_cadet(ui::AbstractDict, w::Scope)

    on(w, "img_url_input") do args

        ui[:go]["is-loading"][] = true

        try fn = "tmp/" * split(split(args, "/")[end], "?")[begin]
            download(args, fn)
            println("User uploaded an img! \n args: $args \n fn: $fn")
            ui[:go_mask][] = 1

            s[i][:user_fn] = fn
            s[i][:user_img] = load(fn)
            _w = s[i][:user_width] = width(s[i][:user_img])
            _h = s[i][:user_height] = height(s[i][:user_img])
            s[i][:overlay_fn] = fn[1:end-4] * "_overlay.png"
            s[i][:overlay_img] = make_transparent(s[i][:user_img])
            save(s[i][:overlay_fn], s[i][:overlay_img])
            s[i][:plots] == nothing

            ui[:labels_img][] = node(:img)

            ui[:user_img][] = make_clickable_img(
                "user_img", ui[:img_click], register(fn) * "?dummy=$(now())")
            ui[:overlay_img][] = make_clickable_img(
                "overlay_img", ui[:img_click], register(s[i][:overlay_fn]) * "?dummy=$(now())")

            ui[:func_tabs][] = "Set Scale"
            ui[:img_info][] = node(:p, "width: $_w  height: $_h")
            ui[:information][] = node(:p, ui[:help_texts]["User Image"])
            ui["Overlay_mask"][] = 1
            ui[:img_tabs][:options][] = ["Original"]
            ui[:img_tabs][] = "Original"

        catch err
        finally ui[:go]["is-loading"][] = false end end

    on(w, "go") do args

        ui[:go]["is-loading"][] = true

        try
            input_name = ui[:inputs_mask][:key][]

            println("User clicked Go! input_name: $input_name")

            if ui[:func_tabs][] in ["Segment Image", "Modify Segments"]
                global s, i # load globals
                push!(s, s[i]) # advance session
                i += 1  # advance index

                # s[i][:segs_details] = nothing
                s[i][:labels_img] = nothing
                s[i][:plots] = nothing

                # run func with input(s)
                go_funcs[input_name](ui, ui[:inputs][input_name][])

                # update ui
                ui[:img_tabs][:options][] = unique!(push!(ui[:img_tabs][:options][], "Segmented"))
                ui[:img_tabs][:options][] = length(s[i][:segs].segment_labels) < 500 ?
                    unique!(push!(ui[:img_tabs][:options][], "Plots")) : ui[:img_tabs][:options][]
                ui[:step][] = node(:strong, "step: $i")
                ui[:img_info][] = node(:p, "
                    height: $(height(s[i][:user_img]))
                    width: $(width(s[i][:user_img]))
                    segments: $(length(s[i][:segs].segment_labels))")

            else
                go_funcs[input_name](ui, ui[:inputs][input_name][])
                end

        catch err
        finally ui[:go]["is-loading"][] = false end end

    on(w, "img_click") do args
        ui[:go]["is-loading"][] = true
        func = ui[:inputs_mask][:key][]
        args[1] = Int64(ceil(args[1] * (args[5] / args[3])))
        args[2] = Int64(ceil(args[2] * (args[6] / args[4])))

        println("args: $args")

        if func == "User Image"
            ui[:inputs][func][] = ui[:inputs][func][] * "$(args[7] ? args[1] : args[2]),"
            ui[:click_info][] = node(:p, "y: $(args[1]) x: $(args[2])")

        elseif ui[:img_tabs][] in ["Original", "Segmented"] && haskey(s[i], :segs)
            label = s[i][:segs].image_indexmap[args[1], args[2]]
            area = ceil(segment_pixel_count(s[i][:segs])[label] / s[i][:scale][1])
            n_segs = length(s[i][:segs].segment_labels)
            if ui[:highlight_mask][] == 0 && args[7]; ui[:highlight_mask][] = 1 end

            # click, no mods
            ui[:click_info][] = node(:p, "label: $label size:
                $(s[i][:scale][1] != 1. ? "$area unit²" :
                "$area pxs")" * " @ y: $(args[1]) x: $(args[2])")

            # highlight segment(s), ctrl key: 7
            if args[7] && !args[8]
                s[i][:selected_segs] = Dict{Int64,Union{Missing,Int64}}()
                s[i][:selected_segs][label] = area
                update_highlight_img(deepcopy(s[i][:user_img]))

            # combine segment click info(s), shift key: 8, remove segment, alt key: 9
            elseif args[8]
                args[9] ? s[i][:selected_segs][label]=missing : s[i][:selected_segs][label]=area
                ui[:click_info][] = node(:p,
                    "Total Area: ~$(sum([v for (k,v) in s[i][:selected_segs] if !(v isa Missing)])) "*
                    "$(s[i][:scale][1] != 1 ? "unit²" : "pxs")  Labels: $(join(["$k, " for (k,v) in s[i][:selected_segs] if !(v isa Missing)]))"
                    )
                if args[7]; update_highlight_img(deepcopy(s[i][:user_img])) end

            else
                ui[:highlight_mask][] = 0
                s[i][:selected_segs] = Dict{Int64,Union{Missing,Int64}}()
            end end

        if func == "Prune Segment"
            ui[:input][func][] = s[i][:segs].image_indexmap[args[1], args[2]] end

        if func == "Seeded Region Growing"
            seed_num = try parse(Int64, split(split(ui[:input][func][], ';')[end-1], ',')[3]) catch; 1 end

            if args[7]
                ui[:input][func][] = ui[:input][func][] * "$(args[1]),$(args[2]),$(seed_num + 1); "
            elseif args[9]
                ui[:input][func][] = ui[input][func][] * "$(args[1]),$(args[2]),$(seed_num - (seed_num == 1 ? 0 : 1)); "
            else; ui[:input][func][] = ui[:input][func][] * "$(args[1]),$(args[2]),$seed_num; " end

            seeds = parse_input(ui[:input][func][])

            s[i][:seeds_img] = make_seeds_img(
                seeds, s[i][:user_height], s[i][:user_width], ui[:font], ui[:font_size])
            s[i][:seeds_fn] = s[i][:user_fn][1:end-4] * "_seeds.png"
            save(s[i][:seeds_fn], s[i][:seeds_img])

            ui[:seeds_img][] = make_clickable_img(
                "seeds_img", ui[:img_click], register(s[i][:seeds_fn]) * "?dummy=$(now())")
            end

        ui[:go]["is-loading"][] = false
        end

    on(w, "img_tabs") do args
        ui[:go]["is-loading"][] = true
        println("img tabs clicked! args: $args")

        ui[:gmap_mask][] = args == "Google Maps" ? 1 : 0
        ui[:user_mask][] = args == "Original" ? 1 : 0
        ui[:segs_mask][] = args == "Segmented" ? 1 : 0
        ui[:labels_mask][] = args == "Plots" ? 0 : 1
        ui[:overlay_mask][] = args == "Plots" ? 0 : 1
        ui[:seeds_mask][] = args == "Plots" ? 0 : 1
        ui[:plots_mask][] = args == "Plots" ? 1 : 0

        if args == "Plots" && s[i][:plots] == nothing
            s[i][:plots] = PlotlyJS.plot([values(s[i][:segs].segment_pixel_count)...])
            ui[:plots][] = node(:div, s[i][:plots])
            end

        ui[:go]["is-loading"][] = false end

    on(w, "func_tabs") do args
        println("funcs_tabs pressed! args: $args")
        ui[:funcs_mask][:key][] = args
        ui[:inputs_mask][:key][] = ui[:funcs][args][]

        ui["CadetPred_mask"][] = args == "Export Data" ? 1 : 0
        ui["Colorize_mask"][] = args in ["Segment Image", "Modify Segments"] ? 1 : 0
        ui["Labels_mask"][] = args in ["Segment Image", "Modify Segments"] ? 1 : 0

        ui["Labels_mask"][] = haskey(s[i], :labels_img) ? 1 : ui["Labels_mask"][]
        ui["Seeds_mask"][] = haskey(s[i], :seeds_img) ? 1 : ui["Seeds_mask"][]
        end

    on(w, "inputs_mask") do args
        println("inputs_mask changed! args: $args")

        if ui[:inputs_mask][:key][] == "Google Maps"
            ui[:img_tabs][:options][] = unique!(push!(ui[:img_tabs][:options][], "Google Maps")) end

        if ui[:inputs_mask][:key][] == "Seeded Region Growing"
            ui["Seeds_mask"][] = 1 end

        ui[:information][] = node(:p, ui[:help_texts][ ui[:inputs_mask][:key][] ])
        end

    on(w, "Set Scale") do args
        ui[:inputs_mask][:key][] = args
        end

    on(w, "Segment Image") do args
        ui[:inputs_mask][:key][] = args end

    on(w, "Modify Segments") do args
        ui[:inputs_mask][:key][] = args end

    on(w, "Export Data") do args
        ui[:inputs_mask][:key][] = args end

    on(w, "Overlay") do args
        println("Overlay clicked! args: $args")
        ui[:img_masks][:overlay_mask][] = args ? 1 : 0 end

    on(w, "Labels") do args
        ui[:go]["is-loading"][] = true

        println("Labels clicked! args: $args")

        if args && haskey(s[i], :segs) && length(s[i][:segs].segment_labels) > 500
            segs_ln = length(s[i][:segs].segment_labels)
            txt = "You are attempting to label $segs_ln segments. This operation could take a very long time. Continue?"
            ui[:confirm](txt) do resp
                resp ? update_labels_img(ui) : ui["Labels"][] = false
            end
        elseif args && haskey(s[i], :segs)
            update_labels_img(ui)
        end

        ui[:img_masks][:labels_mask][] = args ? 1 : 0

        ui[:go]["is-loading"][] = false
        end

    return w
end
