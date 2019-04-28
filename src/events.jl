handle(w, "go") do args
    global working_history
    @js_ w document.getElementById("go").classList = ["button is-primary is-loading"];

    if ui["operations_tabs"][] == "Image Segmentation"
        img = try Gray.(load(ui["img_filename"][])) catch end
        if typeof(img) != Nothing
            pt = @elapsed begin
            working_img_filename = ui["img_filename"][][1:end-4] * "_working" * ui["img_filename"][][end-3:end]
            working_labels_filename = ui["img_filename"][][1:end-4] * "_labels" * ui["img_filename"][][end-3:end]
            segs = param_segment_img(img, parse(ui["segs_funcs"][][2], ui["input"][]), ui["segs_funcs"][][1])
            segs_img = make_img_from_segs(segs, ui["colorize"][])
            labels_img = make_labels_from_segs(segs, ui["draw_labels"][]) end
            segs_info = seg_info(segs, pt)
        else @js_ w alert("Please select a valid image file."); end

    elseif ui["operations_tabs"][] == "Modify Segments"
        working_img_filename = try working_history[end][4] catch end
        working_labels_filename = working_history[end][5]
        if typeof(working_img_filename) == String
            pt = @elapsed begin
            segs = ui["mod_segs_funcs"][][1](working_history[end][1], try parse(
                ui["mod_segs_funcs"][][2], ui["input"][]) catch
                    ui["input"][] end)
            segs_img = make_img_from_segs(segs, ui["colorize"][])
            labels_img = make_labels_from_segs(segs, ui["draw_labels"][]) end
            segs_info = seg_info(segs, pt)
        else @js_ w alert("No segments found to operate on."); end

    elseif ui["operations_tabs"][] == "Label Segments"
        labels = try label_seg() catch end end

    try
        push!(working_history, (segs, segs_img, labels_img, working_img_filename, working_labels_filename))
        save(working_img_filename, segs_img)
        save(working_labels_filename, labels_img)
        ui["img_tabs"][] = "Overlayed"; @js_ w Blink.msg("img_tab_change", "")
        dummy_img_filename = working_img_filename * "?dummy=$(now())"
        dummy_labels_filename = working_img_filename * "?dummy=$(now())"
        @js_ w document.getElementById("segs_info").innerHTML = $segs_info;
        @js_ w document.getElementById("display_img").src = $dummy_img_filename;
        @js_ w document.getElementById("overlay_labels").src = $dummy_labels_filename;
    catch err; println(err) end
    @js_ w document.getElementById("go").classList = ["button is-primary"]; end

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
    img_filename = ui["img_filename"][]
    @js_ w document.getElementById("img_tabs").hidden = true;
    @js_ w document.getElementById("display_img").src = $img_filename; end

handle(w, "img_tab_change") do args
    global working_history
    img_filename = ui["img_filename"][]
    working_img_filename = working_history[end][4]
    working_labels_filename = working_history[end][5]
    dummy_img_filename = working_img_filename * "?dummy=$(now())"
    dummy_labels_filename = working_labels_filename * "?dummy=$(now())"
    @js_ w document.getElementById("img_tabs").hidden = false;

    if ui["img_tabs"][] == "Original"
        @js_ w document.getElementById("display_img").src = $img_filename;
        @js_ w document.getElementById("overlay_labels").src = "";
        @js_ w document.getElementById("overlay_img").src = "";
    elseif ui["img_tabs"][] == "Segmented"
        @js_ w document.getElementById("display_img").src = $dummy_img_filename;
        @js_ w document.getElementById("overlay_img").src = "";
        @js_ w document.getElementById("overlay_labels").src = "";
    elseif ui["img_tabs"][] == "Overlayed"
        @js_ w document.getElementById("display_img").src = $dummy_img_filename;
        @js_ w document.getElementById("overlay_img").src = $img_filename;
        @js_ w document.getElementById("overlay_labels").src = $dummy_labels_filename; end end

handle(w, "dropdown_selected") do args
    if ui["operations_tabs"][] == "Image Segmentation"
        help_text = ui["help_text"][ui["segs_funcs"][][1]]
    elseif ui["operations_tabs"][] == "Modify Segments"
        help_text = ui["help_text"][ui["mod_segs_funcs"][][1]]
    elseif ui["operations_tabs"][] == "Label Segments"
        help_text = "Assign a space type to a segment(s) by number, separated by a comma. eg 1, 3, ..."
    elseif ui["operations_tabs"][] == "Export Data"
        help_text = "Coming soon!" end
    @js_ w document.getElementById("help_text").innerHTML = $help_text; end

handle(w, "labels") do args
    global working_history
    if ui["labels"][] == true
        segs = working_history[end][1]
        dummy_filename = make_labels_img(segs)
        @js_ w document.getElementById("labels_img").src = $dummy_filename;
    else
        @js_ w document.getElementById("labels_img").src = ""; end end
