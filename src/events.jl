handle(w, "op_tab_change") do args
    global s
    println("!op_tab_change: $(ui["ops_tabs"][])")
    s[wi]["$(s[wi]["prev_op_tab"])_input"] = ui["input"][]
    ui["input"][] = haskey(s[wi], "$(ui["ops_tabs"][])_input") ? s[wi]["$(ui["ops_tabs"][])_input"] : "";
    s[wi]["prev_op_tab"] = ui["ops_tabs"][]
    selected_op = ui["ops_tabs"][]

    @js_ w msg("dropdown_selected", []);
    @js_ w document.getElementById("help_text").innerHTML = "";
    @async js(w, WebIO.JSString("""document.getElementById("$selected_op").hidden = false;"""))
    @async js(w, WebIO.JSString("""document.getElementById("$selected_op toolset").hidden = false;"""))

    for op in ui["ops_tabs"][:options][]
        if op != selected_op
            @async js(w, WebIO.JSString("""document.getElementById("$op").hidden = true;"""))
            @async js(w, WebIO.JSString("""document.getElementById("$op toolset").hidden = true;"""))
    end end end

handle(w, "img_selected") do args
    global s
    @js_ w document.getElementById("go").classList = ["button is-danger is-loading"];
    try s[wi]["img_fln"] = ui["img_fln"][]
        s[wi]["user_img"] = load(ui["img_fln"][])
        s[wi]["_alpha.png"] = s[wi]["_seeds.png"] = s[wi]["_labels.png"] = make_transparent(s[wi]["user_img"]);
        save(s[wi]["img_fln"][1:end-4] * "_alpha.png", s[wi]["_alpha.png"])
        img_info = "height: $(height(s[wi]["user_img"]))  width: $(width(s[wi]["user_img"]))"
        ui["img_tabs"][] = "Original";
        @js_ w document.getElementById("img_info").innerHTML = $img_info;
        @js_ w document.getElementById("toolset").hidden = false;
        @js_ w document.getElementById("img_tabs").hidden = false;
        @js_ w msg("op_tab_change", "Set Scale");
        @js_ w msg("img_tab_click", "Original");
    catch err; println(err); @js_ w alert("Error loading image file.");
    finally @js_ w document.getElementById("go").classList = ["button is-primary"]; end end

handle(w, "go") do args
    global s, wi;
    println("!go clicked")
    img_fln=ui["img_fln"][]; s[wi]["$(ui["ops_tabs"][])_input"] = ui["input"][]
    @js_ w document.getElementById("go").classList = ["button is-danger is-loading"];

    try if ui["ops_tabs"][] == "Set Scale"
        scale = (calc_scale(parse_input(ui["input"][])), ui["set_scale_funcs"][][2], ui["input"][])
        s[wi]["scale"] = scale
        scale_info = "$(round(s[wi]["scale"][1])) pixels per $(s[wi]["scale"][2])^2"
        segs_details = haskey(s[wi], "segs") ? make_segs_details(s[wi]["segs"]) : ""
        @js_ w document.getElementById("segs_details").innerHTML = $segs_details;
        @js_ w document.getElementById("scale_info").innerHTML = $scale_info;

    elseif ui["ops_tabs"][] == "Export Data"
        js_str = export_CSV(""); @js_ w alert($js_str);

    elseif ui["ops_tabs"][] == "Segment Image"
        pt = @elapsed begin
        if ui["segs_funcs"][][1] == seeded_region_growing
            seeds = parse_input(ui["input"][])
            segs = seeded_region_growing(Gray.(load(ui["img_fln"][])), seeds)
        elseif ',' in ui["input"][]
            args = split(ui["input"][], ',')
            segs = recursive_segmentation(
                ui["img_fln"][], ui["segs_funcs"][][1], parse(Int64, args[1]), parse(Int64, args[2]))
        else;
            segs = segment_img(ui["img_fln"][], parse(
            ui["segs_funcs"][][2], ui["input"][]), ui["segs_funcs"][][1]) end end

    elseif ui["ops_tabs"][] == "Modify Segments"
        pt = @elapsed begin
        segs = ui["mod_segs_funcs"][][1](s[wi]["segs"], parse_input(ui["input"][])) end end

    if ui["ops_tabs"][] in ["Segment Image", "Modify Segments"]
        segs_info = make_segs_info(segs, pt)
        segs_details = make_segs_details(segs)
        segs_img = make_segs_img(segs, ui["colorize"][])
        labels_img = make_labels_img(segs, ui["draw_labels"][])
        pxplot_img = make_plot_img(segs, ui["draw_plot"][])
        save(img_fln[1:end-4] * "_segs.png", segs_img)
        save(img_fln[1:end-4] * "_labels.png", labels_img)
        draw(SVG(img_fln[1:end-4] * "_pxplot.svg", 6inch, 4inch), pxplot_img)
        @js_ w document.getElementById("segs_details").innerHTML = $segs_details;
        @js_ w document.getElementById("segs_info").innerHTML = $segs_info;
        push!(s, merge(s[wi], Dict(
            "segs"=>segs,
            "_segs.png"=>segs_img,
            "_labels.png"=>labels_img,
            "_pxplot.svg"=>pxplot_img,
            "segs_info"=>segs_info)))
        wi=length(s); @js_ w msg("img_tab_click", ""); end

    catch err; println(err); @js_ w alert(
        "An error has occured, please check your inputs. If the probem persists, contact...")
    finally
        @js_ w document.getElementById("go").classList = ["button is-primary"]; end end

handle(w, "img_tab_click") do args
    global s, wi
    img_fln = ui["img_fln"][]; current_img_tab = s[wi]["current_img_tab"]
    println("!img_tab_click: $(ui["img_tabs"][])")

    if ui["img_tabs"][] == "<<"; wi<=2 ? wi=1 : wi-=1;
    elseif ui["img_tabs"][] == ">>"; wi>=length(s) ? length(s) : wi+=1 end
    if ui["img_tabs"] in ["<<",">>"]
        ui["img_tabs"][] = current_img_tab
        @js_ w msg("img_tab_click", current_img_tab); end

    if wi > 1
        ui["img_fln"][] = s[wi]["img_fln"];
        segs_info = s[wi]["segs_info"]
        segs_details = make_segs_details(s[wi]["segs"])
        dummy_segs = get_dummy("_segs.png")
        @js_ w document.getElementById("segs_details").hidden = false;
        @js_ w document.getElementById("segs_details").innerHTML = $segs_details;
        @js_ w document.getElementById("segs_info").innerHTML = $segs_info; end

    if haskey(s[wi], "_pxplot.svg") && ui["draw_plot"][]
        dummy_plot = get_dummy("_pxplot.svg")
        @js_ w document.getElementById("plot").hidden = false;
        @js_ w document.getElementById("plot").src = $dummy_plot;
    else; @js_ w document.getElementById("plot").hidden = true; end

    if haskey(s[wi], "_labels.png") && ui["draw_labels"][]
        dummy_labels = get_dummy("_labels.png")
        @js_ w document.getElementById("overlay_labels").src = $dummy_labels;
    else; @js_ w document.getElementById("overlay_labels").src = ""; end

    if haskey(s[wi], "_seeds.png") && ui["draw_seeds"][]
        dummy_seeds = get_dummy("_seeds.png")
        @js_ w document.getElementById("overlay_seeds").src = $dummy_seeds;
    else; @js_ w document.getElementById("overlay_seeds").src = ""; end

    if "Original" in [ui["img_tabs"][], args]; s[wi]["current_img_tab"] = "Original"
        dummy_original = img_fln * "?dummy=$(now())"
        @js_ w document.getElementById("overlay_alpha").src = "";
        @js_ w document.getElementById("display_img").src = $dummy_original;
    elseif "Segmented" in [ui["img_tabs"][], args]; s[wi]["current_img_tab"] = "Segmented"
        dummy_segs = wi > 1 ? dummy_segs : ""
        @js_ w document.getElementById("overlay_alpha").src = "";
        @js_ w document.getElementById("display_img").src = $dummy_segs;
    elseif "Overlayed" in [ui["img_tabs"][], args]; s[wi]["current_img_tab"] = "Overlayed"
        dummy_alpha = wi > 1 ? get_dummy("_alpha.png") : ""
        dummy_segs = wi > 1 ? dummy_segs : ""
        @js_ w document.getElementById("overlay_alpha").src = $dummy_alpha;
        @js_ w document.getElementById("display_img").src = $dummy_segs; end end

handle(w, "dropdown_selected") do args
    if ui["ops_tabs"][] == "Segment Image"
        help_text = ui["help_text"][ui["segs_funcs"][][1]]
    elseif ui["ops_tabs"][] == "Modify Segments"
        help_text = ui["help_text"][ui["mod_segs_funcs"][][1]]
    elseif ui["ops_tabs"][] == "Set Scale"
        help_text = ui["help_text"][ui["set_scale_funcs"][][1]]
    elseif ui["ops_tabs"][] == "Export Data"
        help_text = ui["help_text"][ui["export_data_funcs"][][1]] end
    @js_ w document.getElementById("help_text").innerHTML = $help_text; end

handle(w, "img_click") do args
    args[1] = Int64(floor(args[1] * (args[5] / args[3])))
    args[2] = Int64(floor(args[2] * (args[6] / args[4])))
    println(args)

    if haskey(s[wi], "segs")
        label = labels_map(s[wi]["segs"])[args[1], args[2]]
        area = ceil(segment_pixel_count(s[wi]["segs"])[label] / s[wi]["scale"][1])
        segs_info = """Label: $(label) @ y:$(args[1]), x:$(args[2])\n
            $(s[wi]["scale"][1] > 1 ? "Area" : "Pxl Ct"): $(area) $(s[wi]["scale"][2])²"""
    else
        segs_info = "y: $(args[1]) x: $(args[2])" end
    @js_ w document.getElementById("segs_info").innerHTML = $segs_info;

    if ui["ops_tabs"][] == "Modify Segments"
        if length(s) > 0
            label = s[wi]["segs"].image_indexmap[args[1], args[2]]
            ui["input"][] = ui["input"][] * "$label, ";
        else; label = 0 end

    elseif ui["ops_tabs"][] == "Segment Image" && ui["segs_funcs"][][1] == seeded_region_growing
        seed_num = try parse(Int64, split(split(ui["input"][], ';')[end-1], ',')[3]) catch; 1 end
        if args[7] == false
            ui["input"][] = ui["input"][] * "$(args[1]),$(args[2]),$seed_num; ";
        else; ui["input"][] = ui["input"][] * "$(args[1]),$(args[2]),$(seed_num + 1); "; end
        seeds = parse_input(ui["input"][])
        seeds_img = make_seeds_img(seeds)
        s[wi]["_seeds.png"] = seeds_img
        dummy_seeds = get_dummy("_seeds.png")
        @js_ w document.getElementById("overlay_seeds").src = $dummy_seeds;

    elseif ui["ops_tabs"][] == "Set Scale"
        ui["input"][] = ui["input"][] * "$(args[7] == true ? args[1] : args[2]),"
    end end
