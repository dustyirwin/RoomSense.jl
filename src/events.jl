handle(w, "op_tab_change") do args
    selected_op = ui["operations_tabs"][]
    @js_ w msg("dropdown_selected", []);
    @js_ w document.getElementById("help_text").innerHTML = "";
    @async js(w, WebIO.JSString("""document.getElementById("$selected_op").hidden = false;"""))
    @async js(w, WebIO.JSString("""document.getElementById("$selected_op toolset").hidden = false;"""))
    for op in ui["operations"]
        if op != selected_op
            @async js(w, WebIO.JSString("""document.getElementById("$op").hidden = true;"""))
            @async js(w, WebIO.JSString("""document.getElementById("$op toolset").hidden = true;""")) end end end

handle(w, "img_selected") do args
    @js_ w document.getElementById("go").classList = ["button is-danger is-loading"];
    try
        s[wi]["img_filename"] = ui["img_filename"][]
        s[wi]["user_img"] = load(ui["img_filename"][])
        s[wi]["alpha_img"] = make_transparent(s[wi]["user_img"]);
        save(s[wi]["img_filename"][1:end-4] * "_alpha.png", s[wi]["alpha_img"])
        img_info = "height: $(height(s[wi]["user_img"]))  width: $(width(s[wi]["user_img"]))"
        ui["img_tabs"][] = "Original"
        @js_ w msg("img_tab_change", "");
        @js_ w document.getElementById("img_tabs").hidden = false;
        @js_ w document.getElementById("img_info").innerHTML = $img_info;
    catch err
        println(err); @js_ w alert("Error loading image file."); end
    @js_ w document.getElementById("go").classList = ["button is-primary"]; end

handle(w, "go") do args
    global s, wi
    img_filename=ui["img_filename"][]
    @js_ w document.getElementById("go").classList = ["button is-danger is-loading"];

    if ui["operations_tabs"][] == "Segment Image"
        try load(ui["img_filename"][]) catch
            @js_ w alert("Please select a valid image file."); return end
        if ui["input"][] == ""
            @js_ w alert("Please enter an input value(s)."); return end

        pt = @elapsed begin
        if length(split(ui["input"][], ";")) > 1
            seeds = parse_input(ui["input"][])
            segs = seeded_region_growing(Gray.(load(ui["img_filename"][])), seeds)
        elseif length(split(ui["input"][], ",")) > 1
            segs = recursive_segmentation(ui["img_filename"][], ui["segs_funcs"][][1], args[1], args[2])
        else
            segs = segment_img(ui["img_filename"][], parse(
                ui["segs_funcs"][][2], ui["input"][]), ui["segs_funcs"][][1]) end end

    elseif ui["operations_tabs"][] == "Modify Segments"
        try pt = @elapsed begin
            segs = ui["mod_segs_funcs"][][1](s[wi]["segs"], try parse(
                ui["mod_segs_funcs"][][2], ui["input"][]) catch
                    ui["input"][] end)
            img_filename = s[wi]["img_filename"] end
        catch err; println("ERROR: ", err)
            @js_ w alert("Could not complete request; check inputs."); end

    elseif ui["operations_tabs"][] == "Tag Segments"
        try
            for label in split(replace(ui["input"][], " "=>""), ",")
                labels[parse(Int64, label)] = ui["segment_labels"][] end
            catch end end

    try
        segs_info = make_segs_info(segs, pt)
        segs_details = make_segs_details(segs)
        segs_img = make_segs_img(segs, ui["colorize"][])
        labels_img = make_labels_img(segs, ui["draw_labels"][])
        pxplot_img = make_plot_img(segs, ui["draw_plot"][])
        save(img_filename[1:end-4] * "_segs.png", segs_img)
        save(img_filename[1:end-4] * "_labels.png", labels_img)
        draw(SVG(img_filename[1:end-4] * "_pxplot.svg", 6inch, 4inch), pxplot_img)
        @js_ w document.getElementById("segs_info").innerHTML = $segs_info;
        @js_ w document.getElementById("segs_details").innerHTML = $segs_details;
        push!(s, Dict(
            "img_filename"=>img_filename,
            "input"=>ui["input"][],
            "segs"=>segs,
            "user_img"=>load(ui["img_filename"][]),
            "segs_img"=>segs_img,
            "labels_img"=>labels_img,
            "pxplot_img"=>pxplot_img,
            "segs_info"=>segs_info,
            "tags"=>OrderedDict()))
        wi=length(collect(s)); ui["input"][] = ""
    catch err; println(err) end

    @js_ w msg("img_tab_change", []);
    @js_ w document.getElementById("go").classList = ["button is-primary"]; end;

handle(w, "img_tab_change") do args
    global s, wi
    img_filename = ui["img_filename"][]

    if ui["img_tabs"][] == "<<"; wi<=2 ? wi=1 : wi-=1;
        ui["img_tabs"][] = s[wi]["prev_img_tab"]; ui["input"][] = s[wi]["input"]
    elseif ui["img_tabs"][] == ">>"; wi>=length(s) ? length(s) : wi+=1
        ui["img_tabs"][] = s[wi]["prev_img_tab"]; ; ui["input"][] = s[wi]["input"] end

    if wi > 1
        ui["img_filename"][] = s[wi]["img_filename"]
        segs_info = s[wi]["segs_info"]
        segs_details = make_segs_details(s[wi]["segs"])
        save(s[wi]["img_filename"][1:end-4] * "_segs.png", s[wi]["segs_img"])
        save(s[wi]["img_filename"][1:end-4] * "_pxplot.svg", s[wi]["pxplot_img"])
        dummy_plot = s[wi]["img_filename"][1:end-4] * "_pxplot.svg?dummy=$(now())"
        dummy_segs = s[wi]["img_filename"][1:end-4] * "_segs.png?dummy=$(now())"
        @js_ w document.getElementById("plot").src = $dummy_plot;
        @js_ w document.getElementById("segs_details").hidden = false;
        @js_ w document.getElementById("segs_details").innerHTML = $segs_details;
        @js_ w document.getElementById("segs_info").innerHTML = $segs_info; end

    if wi > 1 && ui["draw_labels"][] == true
        labels_filename = s[wi]["img_filename"][1:end-4] * "_labels.png"
        save(labels_filename, s[wi]["labels_img"])
        dummy_labels = labels_filename * "?dummy=$(now())"
        @js_ w document.getElementById("overlay_labels").src = $dummy_labels;
    else
        @js_ w document.getElementById("overlay_labels").src = ""; end

    if wi > 1 && ui["draw_seeds"][] == true
        seeds_filename = s[wi]["img_filename"][1:end-4] * "_seeds.png"
        dummy_seeds = seeds_filename * "?dummy=$(now())"
        @js_ w document.getElementById("overlay_seeds").src = $dummy_seeds;
    else
        @js_ w document.getElementById("overlay_seeds").src = ""; end

    if ui["img_tabs"][] == "Original"; s[wi]["prev_img_tab"] = "Original"
        @js_ w document.getElementById("overlay_alpha").src = "";
        @js_ w document.getElementById("display_img").src = $img_filename;
    elseif ui["img_tabs"][] == "Segmented"; s[wi]["prev_img_tab"] = "Segmented"
        dummy_segs = wi > 1 ? dummy_segs : ""
        @js_ w document.getElementById("overlay_alpha").src = "";
        @js_ w document.getElementById("display_img").src = $dummy_segs;
    elseif ui["img_tabs"][] == "Overlayed"; s[wi]["prev_img_tab"] = "Overlayed"
        dummy_segs = wi > 1 ? dummy_segs : ""
        dummy_alpha = wi > 1 ? s[wi]["img_filename"][1:end-4] * "_alpha.png?dummy=$(now())" : ""
        @js_ w document.getElementById("overlay_alpha").src = $dummy_alpha;
        @js_ w document.getElementById("display_img").src = $dummy_segs; end end

handle(w, "dropdown_selected") do args
    if ui["operations_tabs"][] == "Segment Image"
        help_text = ui["help_text"][ui["segs_funcs"][][1]]
    elseif ui["operations_tabs"][] == "Modify Segments"
        help_text = ui["help_text"][ui["mod_segs_funcs"][][1]]
    elseif ui["operations_tabs"][] == "Tag Segments"
        help_text = "Add a tag to a segment(s) by label. To use a custom tag enter the tag name, followed by labels. eg Loft, 1, 2,..."
    elseif ui["operations_tabs"][] == "Export Data"
        help_text = "Coming soon!" end
    @js_ w document.getElementById("help_text").innerHTML = $help_text; end

handle(w, "img_click") do args
    @show args
    args[1] = Int64(floor(args[1] * (args[5] / args[3])))
    args[2] = Int64(floor(args[2] * (args[6] / args[4])))
    if ui["operations_tabs"][] == "Modify Segments" || ui["operations_tabs"][] == "Tag Segments"
        if length(s) > 0
            label = s[wi]["segs"].image_indexmap[args[1], args[2]]
            ui["input"][] = ui["input"][] * "$label, "
        else
            label = 0 end
        println("label: $label @ y:$(args[1]), x:$(args[2])")
    elseif ui["operations_tabs"][] == "Segment Image" && ui["segs_funcs"][][1] == seeded_region_growing
        seed_num = parse(Int64, split(ui["input"][], ';')[end-1][end])
        if args[7] == true
            ui["input"][] = ui["input"][] * "$(args[1]),$(args[2]),$seed_num; "
        else
            ui["input"][] = ui["input"][] * "$(args[1]),$(args[2]),$(seed_num + 1); " end
        seeds = parse_input(ui["input"][])
        seeds_img = make_seeds_img(seeds)
        s[wi]["seeds_img"] = seeds_img
        save(s[wi]["img_filename"][1:end-4] * "_seeds.png", seeds_img)
        dummy_seeds = s[wi]["img_filename"][1:end-4] * "_seeds.png?dummy=$(now())"
        @js_ w document.getElementById("overlay_seeds").src = $dummy_seeds;
    end end
