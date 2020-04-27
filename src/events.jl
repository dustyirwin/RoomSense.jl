
function space_cadet(ui::AbstractDict)
    w = ui[:scope]

    on(w, "img_url_input") do args
        global s, i # load globals
        ui[:go]["is-loading"][] = true

        try fn = "./tmp/" * split(split(args, "/")[end], "?")[begin]
            download(args, fn)
            @async println("User uploaded an img! \n args: $args \n fn: $fn")
            s[i][:user_img] = load(fn)
            _w = s[i][:user_width] = width(s[i][:user_img])
            _h = s[i][:user_height] = height(s[i][:user_img])

            if _w * _h > 1920 * 1080
                txt = "Images larger than FHD resolution are not supported. Reduce the image size below e.g. 1920 x 1080 pixels and try again."
                ui[:alert](txt)
                return end

            @async ui[:func_tabs][] = "Set Scale"
            @async s[i][:plots] = s[i][:seeds_img] = s[i][:labels_img] = nothing

            @sync begin
                s[i][:user_fn] = fn
                @async ui[:user_img][] = make_clickable_img("user_img",
                    ui[:img_click], ui[:img_keydown], register(fn) * "?dummy=$(now())")

                s[i][:overlay_img] = make_transparent(s[i][:user_img])
                s[i][:overlay_fn] = fn[1:end-4] * "_overlay.png"
                save(s[i][:overlay_fn], s[i][:overlay_img])
                @async ui[:overlay_img][] = make_clickable_img("overlay_img",
                    ui[:img_click], ui[:img_keydown], register(s[i][:overlay_fn]) * "?dummy=$(now())")

                # reset ui
                @async ui[:img_info][] = node(:p, "width: $_w  height: $_h")
                @async ui[:information][] = node(:p, ui[:help_texts]["User Image"])
                @async ui[:img_tabs][:options][] = ["Original"]
                @async ui[:img_tabs][] = "Original"
                @async ui["Overlay"][] = true
            end

        catch err
        finally ui[:go]["is-loading"][] = false end end

    on(w, "go") do args

        ui[:go]["is-loading"][] = true

        try
            global s, i # load globals
            input_name = ui[:inputs_mask][:key][]
            println("User clicked Go! input_name: $input_name")

            if ui[:func_tabs][] in ["Segment Image", "Modify Segments"]
                push!(s, s[i]) # advance session
                i += 1  # advance index

                @sync begin
                    # cleanup s[i]
                    @async s[i][:segs_details] = nothing
                    @async s[i][:labels_img] = nothing
                    @async s[i][:plots] = nothing

                    # run func with input(s)
                    @sync go_funcs[input_name](ui, ui[:inputs][input_name][])

                    # update ui
                    @async ui[:img_tabs][:options][] = unique!(push!(ui[:img_tabs][:options][], "Segmented"))
                    @async ui[:img_tabs][:options][] = unique!(push!(ui[:img_tabs][:options][], "Plots"))
                    @async ui[:step][] = node(:strong, "step: $i")
                    @async ui[:img_info][] = node(:p, "
                        height: $(height(s[i][:user_img]))
                        width: $(width(s[i][:user_img]))
                        segments: $(length(s[i][:segs].segment_labels))")
                    end

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

        elseif ui[:img_tabs][] in ["Original", "Segmented", "Export Data"] && haskey(s[i], :segs)
            label = s[i][:segs].image_indexmap[args[1], args[2]]
            area = ceil(segment_pixel_count(s[i][:segs])[label] / s[i][:scale][1])
            n_segs = length(s[i][:segs].segment_labels)
            if ui[:highlight_mask][] == 0 && args[7]; ui[:highlight_mask][] = 1 end

            # click, no mods
            ui[:click_info][] = node(:p, "
                label: $label
                size: $(s[i][:scale][1] != 1. ? "$area $(ui["Units"][])²" :
                    "$area pxs") $(haskey(s[i][:space_types], label) ? "
                type: $(s[i][:space_types][label])" : "")
                @ y: $(args[1]) x: $(args[2])")

            # highlight segment(s), ctrl key: 7
            if args[7] && !args[8]
                s[i][:selected_spaces] = OrderedDict{Int64,Union{Missing,Int64}}()
                s[i][:selected_spaces][label] = area
                update_highlight_img(deepcopy(s[i][:user_img]))

            # combine segment click info(s), shift key: 8, remove segment, alt key: 9
            elseif args[8]
                args[9] ? s[i][:selected_spaces][label]=missing : s[i][:selected_spaces][label]=area
                ui[:click_info][] = node(:p,
                    "Total Area: ~$(sum([v for (k,v) in s[i][:selected_spaces] if !(v isa Missing)])) "*
                    "$(s[i][:scale][1] != 1 ? "$(ui["Units"][])²" : "pxs")  Labels: $(join(["$k, " for (k,v) in s[i][:selected_spaces] if !(v isa Missing)]))"
                    )
                if args[7]; update_highlight_img(deepcopy(s[i][:user_img])) end

            else
                if length(keys(s[i][:selected_spaces])) > 2
                    ui[:confirm]("This action will clear all selected segments. Continue?") do resp
                    if resp
                        s[i][:selected_spaces] = Dict{Int64,Union{Missing,Int64}}()
                        ui[:highlight_mask][] = 0
                    else
                        return
                    end end
                else
                    s[i][:selected_spaces] = Dict{Int64,Union{Missing,Int64}}()
                    ui[:highlight_mask][] = 0
            end end end

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
                "seeds_img", ui[:img_click], ui[:img_keydown], register(s[i][:seeds_fn]) * "?dummy=$(now())")
            end

        ui[:go]["is-loading"][] = false
        end

    on(w, "img_tabs") do args
        ui[:go]["is-loading"][] = true
        println("img tabs clicked! args: $args")

        ui[:img_url_mask][] = args == "Original" ? 1 : 0
        ui[:gmap_mask][] = args == "Google Maps" ? 1 : 0
        ui[:user_mask][] = args == "Original" ? 1 : 0
        ui[:segs_mask][] = args == "Segmented" ? 1 : 0
        ui[:labels_mask][] = args == "Plots" ? 0 : ui["Labels"][] == true ? 1 : 0
        ui[:overlay_mask][] = args == "Plots" ? 0 : ui["Overlay"][] == true ? 1 : 0
        ui[:highlight_mask][] = args == "Plots" ? 0 : ui[:highlight_mask][]
        ui[:plots_mask][] = args == "Plots" ? 1 : 0


        ui["Labels_mask"][] = args != "Plots" && haskey(s[i], :segs) ? 1 : 0
        ui["Overlay_mask"][] = args in ["Plots", "Original"] ? 0 : 1
        ui["Colorize_mask"][] = args in ["Plots", "Original", "Google Maps"] ? 0 : 1

        if args == "Plots" && s[i][:plots] == nothing
            s[i][:plots] = PlotlyJS.plot([values(s[i][:segs].segment_pixel_count)...])
            ui[:plots][] = node(:div, s[i][:plots])
            end

        ui[:go]["is-loading"][] = false end

    on(w, "func_tabs") do args
        println("funcs_tabs pressed! args: $args")

        ui[:funcs_mask][:key][] = args
        ui[:inputs_mask][:key][] = ui[:funcs][args][]

        ui[:units_mask][] = args == "Set Scale" ? 1 : 0
        ui["Colorize_mask"][] = args in ["Segment Image", "Modify Segments"] ? 1 : 0
        ui["Labels_mask"][] = args in ["Original", "Segment Image", "Modify Segments"] &&
            haskey(s[i], :segs) ? 1 : 0
        end # do

    on(w, "inputs_mask") do args
        args = ui[:inputs_mask][:key][]
        println("inputs_mask changed! args: $args")

        ui["CadetPred_mask"][] = args == "Assign Space Types" ? 1 : 0
        ui["Colorize_mask"][] = args == "Assign Space Types" ? 0 : ui["Colorize_mask"][]

        if args == "Google Maps"
            ui[:img_tabs][:options][] = unique!(push!(ui[:img_tabs][:options][], "Google Maps"))
        else
            ui[:img_tabs][:options][] = filter!(x -> x != "Google Maps", ui[:img_tabs][:options][])
            end

        if args == "Seeded Region Growing"; ui["Seeds_mask"][] = 1 end

        ui[:information][] = node(:p, ui[:help_texts][ args ])
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

        if args && haskey(s[i], :segs)
            segs_ln = length(s[i][:segs].segment_labels)

            if length(s[i][:segs].segment_labels) > 1000
                txt = "You are attempting to label $segs_ln segments. This operation could take a very long time. Continue?"
                ui[:confirm](txt) do resp
                    resp ? update_labels_img(ui) : ui["Labels"][] = false
                    end
            else
                update_labels_img(ui)
        end end

        ui[:img_masks][:labels_mask][] = args ? 1 : 0

        ui[:go]["is-loading"][] = false
        end

    on(w, "Assign Space Types") do args
        println("Space type selected! args: $args")
        s[i][:selected_spaces] = args == "altKey" ?  #  <-- enable downKey func to NOT retain existing selected_spaces on drop_down change
            OrderedDict{Int64,Union{Missing,String}}() : s[i][:selected_spaces]

        for k in keys(s[i][:space_types])
            try if s[i][:space_types][k] == ui[:space_types][args]
                s[i][:selected_spaces][k] = s[i][:segs].segment_pixel_count[k]
                end
            catch; continue
            end end

        update_highlight_img(deepcopy(s[i][:user_img]))
        ui[:highlight_mask][] = 1
        end

    return w end
