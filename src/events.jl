
handle(w, "img_selected") do args
    global s, ui
    @js_ w document.getElementById("go").classList = ["button is-danger is-loading"]

    s[wi]["img_fln"] = ui["img_fln"][]
    s[wi]["user_img"] = load(ui["img_fln"][])
    s[wi]["_alpha.png"] = make_transparent(s[wi]["user_img"])

    save(s[wi]["img_fln"][1:end-4] * "_alpha.png", s[wi]["_alpha.png"])

    img_info = "height: $(height(s[wi]["user_img"]))  width: $(width(s[wi]["user_img"]))"
    img_alpha = get_dummy("_alpha.png", s[wi]["img_fln"], s[wi]["_alpha.png"])

    @js_ w document.getElementById("overlay_alpha").src = $img_alpha
    @js_ w document.getElementById("img_info").innerHTML = $img_info
    @js_ w document.getElementById("toolset").hidden = false
    @js_ w document.getElementById("img_tabs").hidden = false

    ui["img_tabs"][] = "Original"
    #@js_ w msg("op_tab_change", "")
    @js_ w msg("img_tab_click", "")

    if haskey(s[wi], "_labels.png"); delete!(s[wi], "_labels.png") end
    if haskey(s[wi], "_pxplot.png"); delete!(s[wi], "_pxplot.png") end
    if haskey(s[wi], "_labels.png"); delete!(s[wi], "_seeds.png") end

    @js_ w document.getElementById("go").classList = ["button is-primary"] end

handle(w, "op_tab_change") do args
    global s, ui
    selected_op = ui["ops_tabs"][]
    println("!op_tab_change: $selected_op")

    if haskey(s[wi], "$(selected_op)_input")
        ui["input"][] = s[wi]["$(selected_op)_input"]
    else
        ui["input"][] = "" end

    s[wi]["$(selected_op)_input"] = ui["input"][]

    if selected_op == "Export Data"
        @js_ w document.getElementById("input").hidden = true
    else
        @js_ w document.getElementById("input").hidden = false end

    @js_ w msg("dropdown_selected", [])
    @async js(w, JSString(
        """document.getElementById("$(selected_op) toolset").hidden = false"""))

    for not_op in ui["ops_tabs"][:options][]
        if not_op != ui["ops_tabs"][]
            @async js(w, JSString(
                """document.getElementById("$(not_op) toolset").hidden = true"""))
    end end end

handle(w, "go") do args
    global s, wi
    println("!go clicked")
    img_fln=ui["img_fln"][]; s[wi]["$(ui["ops_tabs"][])_input"] = ui["input"][]
    @js_ w document.getElementById("go").classList = ["button is-danger is-loading"]

    if ui["ops_tabs"][] == "Set Scale"
        scale = (calc_scale(parse_input(
            ui["input"][], ui["ops_tabs"][])), ui["set_scale_funcs"][][2], ui["input"][])
        s[wi]["scale"] = scale
        scale_info = " ~px/$(s[wi]["scale"][2])²: $(ceil(s[wi]["scale"][1]))"
        @js_ w document.getElementById("scale_info").innerHTML = $scale_info

    elseif ui["ops_tabs"][] == "Export Data" && haskey(s[wi], "segs")
        js_str = export_CSV(s[wi]["segs"], s[wi]["segs_types"], s[wi]["img_fln"], s[wi]["scale"][1], s[wi]["scale"][2])
        @js_ w alert($js_str);

    elseif ui["ops_tabs"][] == "Segment Image"
        if ui["segs_funcs"][][1] == seeded_region_growing
            seeds = parse_input(ui["input"][], ui["ops_tabs"][])
            segs = seeded_region_growing(Gray.(load(img_fln)), seeds)
        elseif ',' in ui["input"][]
            args = split(ui["input"][], ',')
            segs = recursive_segmentation(ui["img_fln"][], ui["segs_funcs"][][1],
                parse(Int64, args[1]), parse(Int64, args[2]), s[wi]["scale"][1])
        else
            segs = segment_img(ui["img_fln"][],
                parse(ui["segs_funcs"][][2], ui["input"][]), ui["segs_funcs"][][1]) end

    elseif ui["ops_tabs"][] == "Modify Segments"
        segs = if ui["mod_segs_funcs"][][1] == prune_min_size
            prune_min_size(s[wi]["segs"], parse_input(ui["input"][], ui["ops_tabs"][]), s[wi]["scale"][1])
        elseif ui["mod_segs_funcs"][][1] == remove_segments
            remove_segments(s[wi]["segs"], parse_input(ui["input"][], ui["ops_tabs"][]))
        else nothing end end

    if ui["ops_tabs"][] in ["Segment Image", "Modify Segments"]
        segs_info = make_segs_info(segs)
        segs_types = haskey(s[wi], "segs_types") ? s[wi]["segs_types"] : nothing
        segs_img = make_segs_img(segs, ui["colorize"][])
        save(img_fln[1:end-4] * "_segs.png", segs_img)
        if haskey(s[wi], "_labels.png"); delete!(s[wi], "_labels.png") end
        if haskey(s[wi], "_pxplot.png"); delete!(s[wi], "_pxplot.png") end
        @js_ w document.getElementById("segs_info").innerHTML = $segs_info
        push!(s, merge(s[wi], Dict(
            "segs"=>segs,
            "segs_info"=>segs_info,
            "_segs.png"=>segs_img,
            "dd_obs"=>[dropdown(dd_opts) for i in segment_labels(segs)])))
        wi=length(s); @js_ w msg("img_tab_click", "");
        @js_ w document.getElementById("wi").innerHTML = $wi
        img_segs = get_dummy("_segs.png", s[wi]["img_fln"], s[wi]["user_img"])
        @js_ w document.getElementById("display_img").src = $img_segs end

    @js_ w document.getElementById("go").classList = ["button is-primary"] end

handle(w, "img_tab_click") do args
    global s, wi, ui
    @js_ w document.getElementById("go").classList = ["button is-danger is-loading"]
    img_fln = ui["img_fln"][]
    println("!img_tab_click: $(ui["img_tabs"][])")

    if "Original" == ui["img_tabs"][]; s[wi]["prev_img_tab"] = "Original"
        img_orig = img_fln * "?dummy=$(now())"
        @js_ w document.getElementById("display_img").src = $img_orig end

    if ui["img_tabs"][] in ["<<", ">>"]
        if ui["img_tabs"][] == "<<"; wi<=2 ? wi=1 : wi-=1
            ui["img_tabs"][] = s[wi]["prev_img_tab"]
        elseif ui["img_tabs"][] == ">>"; wi>=length(s) ? length(s) : wi+=1
            ui["img_tabs"][] = s[wi]["prev_img_tab"] end

        @js_ w document.getElementById("wi").innerHTML = $wi

        s[wi]["img_fln"] = ui["img_fln"][]
        ui["img_tabs"][] = s[wi]["prev_img_tab"]
        @js_ w msg("img_tab_click", []) end

    if wi > 1
        img_segs = get_dummy("_segs.png", s[wi]["img_fln"], s[wi]["_segs.png"])
        segs_info = s[wi]["segs_info"]
        @js_ w document.getElementById("segs_info").innerHTML = $segs_info end

    @js_ w document.getElementById("plot").hidden = true
    @js_ w document.getElementById("overlay_alpha").hidden = true
    @js_ w document.getElementById("overlay_seeds").hidden = true
    @js_ w document.getElementById("overlay_labels").hidden = true
    @js_ w document.getElementById("display_img").hidden = false

    if ui["draw_seeds"][] && haskey(s[wi], "_seeds.png")
        @js_ w document.getElementById("overlay_seeds").hidden = false end

    if haskey(s[wi], "segs")

        if ui["draw_labels"][] && ui["img_tabs"][] != "Info"
            if haskey(s[wi], "_labels.png") == false
                s[wi]["_labels.png"] = make_labels_img(s[wi]["segs"], ui["draw_labels"][], ui["font"])
                save(img_fln[1:end-4] * "_labels.png", s[wi]["_labels.png"])
                img_labels = get_dummy("_labels.png", s[wi]["img_fln"], s[wi]["_labels.png"])
                @js_ w document.getElementById("overlay_labels").src = $img_labels end
            @js_ w document.getElementById("overlay_labels").hidden = false end

        if "Segmented" == ui["img_tabs"][]; s[wi]["prev_img_tab"] = "Segmented"
            @js_ w document.getElementById("display_img").src = $img_segs end

        if "Overlayed" == ui["img_tabs"][]; s[wi]["prev_img_tab"] = "Overlayed"
            @js_ w document.getElementById("display_img").src = $img_segs
            @js_ w document.getElementById("overlay_alpha").hidden = false end

        if "Info" == ui["img_tabs"][]; s[wi]["prev_img_tab"] = "Info"
            @js_ w document.getElementById("display_img").hidden = true
            @js_ w document.getElementById("segs_details").hidden = false
            @js_ w document.getElementById("plot").hidden = false

            if haskey(s[wi], "_pxplot.svg") == false
                s[wi]["_pxplot.svg"] = make_plot_img(s[wi]["segs"], s[wi]["scale"][1])
                save(img_fln[1:end-4] * "_pxplot.svg", s[wi]["_pxplot.svg"])
                img_plot = get_dummy("_pxplot.svg", s[wi]["img_fln"], s[wi]["_pxplot.svg"])
                @js_ w document.getElementById("plot").src = $img_plot end

            if ui["predict_space_type"][]
                s[wi]["segs_types"] = get_segs_types(s[wi]["segs"], s[wi]["img_fln"], m) end

            segs_details_html, dd_obs = make_segs_details(s[wi]["segs"], s[wi]["segs_types"], s[wi]["scale"][1], s[wi]["scale"][2])
            s[wi]["segs_types"] = Dict(label=>dd_obs[label][] for label in s[wi]["segs"].segment_labels)

            try body!(sdw, html) catch;
                try close(sdw) catch end
                sdw = Window()
                size(sdw, 380, 700)
                body!(sdw, segs_details_html) end
    end end

    @js_ w document.getElementById("go").classList = ["button is-primary"] end

handle(w, "img_click") do args
    global s, wi, ui
    @js_ w document.getElementById("go").classList = ["button is-danger is-loading"]
    args[1] = Int64(floor(args[1] * (args[5] / args[3])))
    args[2] = Int64(floor(args[2] * (args[6] / args[4])))
    println(args)

    if ui["img_tabs"][] != "Info"
        s[wi]["segs_info"] = "y: $(args[1]) x: $(args[2])" end

    if haskey(s[wi], "segs") && ui["ops_tabs"][] != "Set Scale" && ui["img_tabs"][] != "Info"
        label = labels_map(s[wi]["segs"])[args[1], args[2]]
        area = ceil(segment_pixel_count(s[wi]["segs"])[label] / s[wi]["scale"][1])

        if args[8] == true
            unique!(push!(s[wi]["selected_areas"], (label, area)))
            labels = join(["$label, " for label in s[wi]["selected_areas"]])
            s[wi]["segs_info"] = "Total Area: ~$(
                sum([area for (label, area) in s[wi]["selected_areas"]])) $(
                s[wi]["scale"][1] != 1 ? "$(s[wi]["scale"][2])² " : "pixels ")" *
                "Labels: $(join(["$label, " for (label, area) in s[wi]["selected_areas"]]))"
        else
            s[wi]["selected_areas"] = Vector(); unique!(push!(s[wi]["selected_areas"], (label, area)))
            s[wi]["segs_info"] = """$(
            s[wi]["scale"][1] != 1 ? "Area: ~$area $(s[wi]["scale"][2])²" : "Pxl Ct: $area")
                Label: $(label) @ y:$(args[1]) x:$(args[2])""" end

        ui["notifications"][] = args[7] ? push!(ui["notifications"][], """$(
            s[wi]["scale"][1] != 1 ? "Area: ~$area $(s[wi]["scale"][2])²" : "Pxl Ct: $area")
            Label: $(label) @ y:$(args[1]) x:$(args[2])""") : [] end

    if ui["ops_tabs"][] == "Modify Segments" && haskey(s[wi], "segs") && ui["mod_segs_funcs"][][1] == remove_segments
        if length(s) > 0
            label = s[wi]["segs"].image_indexmap[args[1], args[2]]
            ui["input"][] = ui["input"][] * "$label, "
        else; label = 0 end end

    if ui["ops_tabs"][] == "Segment Image" && ui["segs_funcs"][][1] == seeded_region_growing
        seed_num = try parse(Int64, split(split(ui["input"][], ';')[end-1], ',')[3]) catch; 1 end
        if args[7] == true
            ui["input"][] = ui["input"][] * "$(args[1]),$(args[2]),$(seed_num + 1); "
        elseif args[9] == true
            ui["input"][] = ui["input"][] * "$(args[1]),$(args[2]),$(seed_num - (seed_num == 1 ? 0 : 1)); "
        else; ui["input"][] = ui["input"][] * "$(args[1]),$(args[2]),$seed_num; " end

        seeds = parse_input(ui["input"][], ui["ops_tabs"][])
        s[wi]["_seeds.png"] = make_seeds_img(
            seeds, height(s[wi]["user_img"]), width(s[wi]["user_img"]), ui["font"], ui["font_size"])
        save(s[wi]["img_fln"][1:end-4] * "_seeds.png", s[wi]["_seeds.png"])
        img_seeds = get_dummy("_seeds.png", s[wi]["img_fln"], s[wi]["_seeds.png"])
        @js_ w document.getElementById("overlay_seeds").src = $img_seeds; end

    if ui["ops_tabs"][] == "Set Scale"
        ui["input"][] = ui["input"][] * "$(args[7] ? args[1] : args[2])," end

    segs_info = s[wi]["segs_info"]
    @js_ w document.getElementById("segs_info").innerHTML = $segs_info
    @js_ w document.getElementById("go").classList = ["button is-primary"] end

handle(w, "dropdown_selected") do args
    if ui["ops_tabs"][] == "Segment Image"
        help_text = ui["help_text"][ui["segs_funcs"][][1]]
    elseif ui["ops_tabs"][] == "Modify Segments"
        help_text = ui["help_text"][ui["mod_segs_funcs"][][1]]
    elseif ui["ops_tabs"][] == "Set Scale"
        help_text = ui["help_text"][ui["set_scale_funcs"][][1]]
    elseif ui["ops_tabs"][] == "Export Data"
        help_text = ui["help_text"][ui["export_data_funcs"][][1]] end
    @js_ w document.getElementById("help_text").innerHTML = $help_text end
