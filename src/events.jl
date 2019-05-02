handle(w, "op_tab_change") do args
    selected_op = ui["operations_tabs"][]
    @js_ w Blink.msg("dropdown_selected", []);
    @js_ w document.getElementById("help_text").innerHTML = "";
    @async js(w, WebIO.JSString("""document.getElementById("$selected_op").hidden = false;"""))
    @async js(w, WebIO.JSString("""document.getElementById("$selected_op toolset").hidden = false;"""))
    for op in ui["operations"]
        if op != selected_op
            @async js(w, WebIO.JSString("""document.getElementById("$op").hidden = true;"""))
            @async js(w, WebIO.JSString("""document.getElementById("$op toolset").hidden = true;""")) end end end

handle(w, "img_selected") do args
    global work_history, wi
    img_filename = ui["user_img_filename"][]
    push!(work_history, (nothing, nothing, nothing, img_filename, nothing, nothing)); wi+=1
    ui["img_tabs"][] = "Original"
    @js_ w Blink.msg("img_tab_change", "")
    @js_ w document.getElementById("img_tabs").hidden = false;
    end

handle(w, "go") do args
    global work_history, wi
    if length(work_history) > 0; work_history = work_history[1:wi] end
    @js_ w document.getElementById("go").classList = ["button is-danger is-loading"];

    if ui["operations_tabs"][] == "Image Segmentation"
        try load(ui["user_img_filename"][]) catch
            @js_ w alert("Please select a valid image file."); return end
        if ui["input"][] == ""
            @js_ w alert("Please enter an input value(s)."); return end

        pt = @elapsed begin
        args = [parse(Int64, replace(arg," "=>"")) for arg in split(ui["input"][], ",")]
        if length(args) > 1
            segs = recur_segs(ui["user_img_filename"][], ui["segs_funcs"][][1], args[1], args[2])
        else
            segs = param_segment_img(ui["user_img_filename"][], parse(
                ui["segs_funcs"][][2], ui["input"][]), ui["segs_funcs"][][1]) end
        segs_img_filename = ui["user_img_filename"][][1:end-4] * "_working.png"
        labels_filename = ui["user_img_filename"][][1:end-4] * "_labels.png"
        segs_img = make_img_from_segs(segs, ui["colorize"][])
        labels_img = make_labels_from_segs(segs, ui["draw_labels"][]) end
        segs_info = seg_info(segs, pt)

    elseif ui["operations_tabs"][] == "Modify Segments"
        try pt = @elapsed begin
            segs = ui["mod_segs_funcs"][][1](work_history[wi][1], try parse(
                ui["mod_segs_funcs"][][2], ui["input"][]) catch
                    ui["input"][] end)
            img_filename = work_history[wi][4]
            labels_filename = work_history[wi][5]
            segs_img = make_img_from_segs(segs, ui["colorize"][])
            labels_img = make_labels_from_segs(segs, ui["draw_labels"][]) end
            segs_info = seg_info(segs, pt)
        catch err; println("ERROR: ", err)
            @js_ w alert("No segments found to operate on."); end

    elseif ui["operations_tabs"][] == "Label Segments"
        labels = try label_seg() catch end end

    try push!(work_history, (segs, segs_img, labels_img, segs_img_filename, labels_filename, segs_info)); wi+=1
        segs_details = sort!(["$label - $pixel_count pxs" for (label, pixel_count) in collect(segs.segment_pixel_count)])
        save(segs_img_filename, segs_img)
        save(labels_filename, labels_img)
        @js_ w document.getElementById("segs_info").innerHTML = $segs_info;
    catch err; println(err) end
    @js_ w Blink.msg("img_tab_change", []);
    @js_ w document.getElementById("go").classList = ["button is-primary"]; end;

handle(w, "img_tab_change") do args
    global work_history, wi, prev_img_tab
    if ui["img_tabs"][] == "<<"; wi<=2 ? wi=1 : wi-=1; ui["img_tabs"][] = prev_img_tab
    elseif ui["img_tabs"][] == ">>"; wi>=length(work_history) ? length(work_history) : wi+=1
        ui["img_tabs"][] = prev_img_tab end

    img_filename = ui["user_img_filename"][]; dummy_img = ""
    if wi > 1
        save(work_history[wi][4], work_history[wi][2])
        dummy_img = work_history[wi][4] * "?dummy=$(now())"
        segs_info = work_history[wi][6]
        @js_ w document.getElementById("segs_info").innerHTML = $segs_info;
    end

    if ui["draw_labels"][] == true && typeof(work_history[wi][5]) == String
        labels_filename = work_history[wi][5]
        save(labels_filename, work_history[wi][3])
        dummy_labels = labels_filename * "?dummy=$(now())"
        @js_ w document.getElementById("overlay_labels").src = $dummy_labels;
    else
        @js_ w document.getElementById("overlay_labels").src = ""; end

    if ui["img_tabs"][] == "Original"; prev_img_tab = "Original"
        @js_ w document.getElementById("display_img").src = $img_filename;
        @js_ w document.getElementById("overlay_original").src = "";
    elseif ui["img_tabs"][] == "Segmented"; prev_img_tab = "Segmented"
        @js_ w document.getElementById("display_img").src = $dummy_img;
        @js_ w document.getElementById("overlay_original").src = "";
    elseif ui["img_tabs"][] == "Overlayed"; prev_img_tab = "Overlayed"
        @js_ w document.getElementById("display_img").src = $dummy_img;
        @js_ w document.getElementById("overlay_original").src = $img_filename; end end

handle(w, "dropdown_selected") do args
    if ui["operations_tabs"][] == "Image Segmentation"
        help_text = ui["help_text"][ui["segs_funcs"][][1]] * ui["help_text"]["recur_seg"]
    elseif ui["operations_tabs"][] == "Modify Segments"
        help_text = ui["help_text"][ui["mod_segs_funcs"][][1]]
    elseif ui["operations_tabs"][] == "Label Segments"
        help_text = "Assign a space type to a segment(s) by number, separated by a comma. eg 1, 3, ..."
    elseif ui["operations_tabs"][] == "Export Data"
        help_text = "Coming soon!" end
    @js_ w document.getElementById("help_text").innerHTML = $help_text; end

handle(w, "labels") do args
    global s; work_history = s["work_history"]; wi = s["wi"]
    if ui["labels"][] == true
        segs = work_history[end][1]
        dummy_filename = make_labels_img(segs)
        @js_ w document.getElementById("labels_img").src = $dummy_filename;
    else
        @js_ w document.getElementById("labels_img").src = ""; end end
