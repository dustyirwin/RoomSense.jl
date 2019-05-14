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
        user_img = load(ui["user_img_filename"][])
        img_info = "height: $(height(user_img))  width: $(width(user_img))"
        alpha_filename = ui["user_img_filename"][][1:end-4] * "_alpha.png"
        alpha_img = make_transparent(user_img);
        save(alpha_filename, alpha_img)
        ui["img_tabs"][] = "Original"
        @js_ w msg("img_tab_change", "");
        @js_ w document.getElementById("img_tabs").hidden = false;
        @js_ w document.getElementById("img_info").innerHTML = $img_info;
    catch err
        println(err); @js_ w alert("Error loading image file."); end
    @js_ w document.getElementById("go").classList = ["button is-primary"]; end

handle(w, "go") do args
    global work_history, wi
    @js_ w document.getElementById("go").classList = ["button is-danger is-loading"];

    if ui["operations_tabs"][] == "Segment Image"
        try load(ui["user_img_filename"][]) catch
            @js_ w alert("Please select a valid image file."); return end
        if ui["input"][] == ""
            @js_ w alert("Please enter an input value(s)."); return end

        pt = @elapsed begin
        if length(split(ui["input"][], ",")) > 1
            args = [parse(Int64, replace(arg," "=>"")) for arg in split(ui["input"][], ",")]
            segs = recursive_segmentation(ui["user_img_filename"][], ui["segs_funcs"][][1], args[1], args[2])
        else
            segs = segment_img(ui["user_img_filename"][], parse(
                ui["segs_funcs"][][2], ui["input"][]), ui["segs_funcs"][][1]) end
        img_filename = ui["user_img_filename"][] end

    elseif ui["operations_tabs"][] == "Modify Segments"
        try pt = @elapsed begin
            segs = ui["mod_segs_funcs"][][1](work_history[wi][2], try parse(
                ui["mod_segs_funcs"][][2], ui["input"][]) catch
                    ui["input"][] end)
            img_filename = work_history[wi][1] end
        catch err; println("ERROR: ", err)
            @js_ w alert("Could not complete request; check inputs."); end

    elseif ui["operations_tabs"][] == "Label Segments"
        try
            for label in split(replace(ui["input"][], " "=>""), ",")
                labels[parse(Int64, label)] = ui["segment_labels"][] end
            catch end end

    try
        show_segs_details(segs)
        segs_info = _segs_info(segs, pt)
        segs_img = make_segs_img(segs, ui["colorize"][])
        labels_img = make_labels_img(segs, ui["draw_labels"][])
        pxplot_img = make_plot_img(segs, ui["create_plot"][])
        save(img_filename[1:end-4] * "_working.png", segs_img)
        save(img_filename[1:end-4] * "_labels.png", labels_img)
        draw(SVG(img_filename[1:end-4] * "_pxplot.svg", 6inch, 4inch), pxplot_img)
        @js_ w document.getElementById("segs_info").innerHTML = $segs_info;
        push!(work_history, (img_filename, segs, segs_img, labels_img, pxplot_img, segs_info, OrderedDict()))
        wi=length(work_history); ui["input"][] = ""
    catch err; println(err) end

    @js_ w msg("img_tab_change", []);
    @js_ w document.getElementById("go").classList = ["button is-primary"]; end;

handle(w, "img_tab_change") do args
    global work_history, wi, prev_img_tab
    img_filename = ui["user_img_filename"][]

    if ui["img_tabs"][] == "<<"; wi<=2 ? wi=1 : wi-=1;
        ui["img_tabs"][] = prev_img_tab
    elseif ui["img_tabs"][] == ">>"; wi>=length(work_history) ? length(work_history) : wi+=1
        ui["img_tabs"][] = prev_img_tab end

    if wi > 0
        segs_info = work_history[wi][6]
        show_segs_details(work_history[wi][2])
        save(work_history[wi][1][1:end-4] * "_working.png", work_history[wi][3])
        save(work_history[wi][1][1:end-4] * "_pxplot.svg", work_history[wi][5])
        dummy_plot = work_history[wi][1][1:end-4] * "_pxplot.svg?dummy=$(now())"
        dummy_working = work_history[wi][1][1:end-4] * "_working.png?dummy=$(now())"
        @js_ w document.getElementById("segs_details").hidden = false;
        @js_ w document.getElementById("plot").src = $dummy_plot;
        @js_ w document.getElementById("segs_info").innerHTML = $segs_info; end

    if wi > 0 && ui["draw_labels"][] == true
        labels_filename = work_history[wi][1][1:end-4] * "_labels.png"
        save(labels_filename, work_history[wi][4])
        dummy_labels = labels_filename * "?dummy=$(now())"
        @js_ w document.getElementById("overlay_labels").src = $dummy_labels;
    else
        @js_ w document.getElementById("overlay_labels").src = ""; end

    if ui["img_tabs"][] == "Original"; prev_img_tab = "Original"
        @js_ w document.getElementById("overlay_alpha").src = "";
        @js_ w document.getElementById("display_img").src = $img_filename;
    elseif ui["img_tabs"][] == "Segmented"; prev_img_tab = "Segmented"
        dummy_working = wi > 0 ? dummy_working : ""
        @js_ w document.getElementById("overlay_alpha").src = "";
        @js_ w document.getElementById("display_img").src = $dummy_working;
    elseif ui["img_tabs"][] == "Overlayed"; prev_img_tab = "Overlayed"
        dummy_working = wi > 0 ? dummy_working : ""
        dummy_alpha = wi > 0 ? work_history[wi][1][1:end-4] * "_alpha.png?dummy=$(now())" : ""
        @js_ w document.getElementById("overlay_alpha").src = $dummy_alpha;
        @js_ w document.getElementById("display_img").src = $dummy_working; end end

handle(w, "dropdown_selected") do args
    if ui["operations_tabs"][] == "Segment Image"
        help_text = ui["help_text"][ui["segs_funcs"][][1]] * ui["help_text"]["recur_seg"]
    elseif ui["operations_tabs"][] == "Modify Segments"
        help_text = ui["help_text"][ui["mod_segs_funcs"][][1]]
    elseif ui["operations_tabs"][] == "Label Segments"
        help_text = "Add a tag to a segment(s) by label. To use a custom tag enter the tag name, followed by labels. eg Loft, 1, 2,..."
    elseif ui["operations_tabs"][] == "Export Data"
        help_text = "Coming soon!" end
    @js_ w document.getElementById("help_text").innerHTML = $help_text; end

handle(w, "img_click") do args
    if ui["operations_tabs"][] == "Modify Segments" || ui["operations_tabs"][] == "Label Segments"
        args[1] = Int64(floor(args[1] * (args[5] / args[3])))
        args[2] = Int64(floor(args[2] * (args[6] / args[4])))
        if length(work_history) > 0
            label = work_history[wi][2].image_indexmap[args[1], args[2]]
            ui["input"][] = ui["input"][] * "$label, "
        else label = 0 end
        println("label: $label @ $(args[1]), $(args[2])") end end
