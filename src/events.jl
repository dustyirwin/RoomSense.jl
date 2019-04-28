handle(w, "go") do args
    global work_history, custom_labels, wi
    @js_ w document.getElementById("go").classList = ["button is-primary is-loading"];

    if ui["operations_tabs"][] == "Image Segmentation"
        img = try Gray.(load(ui["img_filename"][])) catch end
        if typeof(img) != Nothing
            pt = @elapsed begin
            wi = 1; work_history = []
            img_filename = ui["img_filename"][][1:end-4] * "_working.png"
            labels_filename = ui["img_filename"][][1:end-4] * "_labels.png"
            segs = param_segment_img(img, parse(ui["segs_funcs"][][2], ui["input"][]), ui["segs_funcs"][][1])
            display_img = make_img_from_segs(segs, ui["colorize"][])
            labels_img = make_labels_from_segs(segs, ui["draw_labels"][]) end
            segs_info = seg_info(segs, pt)
            ui["img_tabs"][] = "Segmented"
        else @js_ w alert("Please select a valid image file."); end

    elseif ui["operations_tabs"][] == "Modify Segments"
        work_history = work_history[1:wi]
        img_filename = try work_history[wi][4] catch end
        labels_filename = work_history[wi][5]
        if typeof(img_filename) == String
            pt = @elapsed begin
            segs = ui["mod_segs_funcs"][][1](work_history[end][1], try parse(
                ui["mod_segs_funcs"][][2], ui["input"][]) catch
                    ui["input"][] end)
            display_img = make_img_from_segs(segs, ui["colorize"][])
            labels_img = make_labels_from_segs(segs, ui["draw_labels"][]) end
            segs_info = seg_info(segs, pt)
            wi += 1
        else @js_ w alert("No segments found to operate on."); end

    elseif ui["operations_tabs"][] == "Label Segments"
        labels = try label_seg() catch end end

    try
        save(img_filename, display_img)
        save(labels_filename, labels_img)
        @js_ w Blink.msg("img_tab_change", null)
        dummy_img = img_filename * "?dummy=$(now())"
        dummy_labels = img_filename * "?dummy=$(now())"
        push!(work_history, (
            segs, display_img, labels_img, img_filename, labels_filename, segs_info));
        @js_ w document.getElementById("segs_info").innerHTML = $segs_info;
        @js_ w document.getElementById("display_img").src = $dummy_img;
        @js_ w document.getElementById("overlay_labels").src = $dummy_labels;
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
    @js_ w document.getElementById("display_img").src = $img_filename;
    @js_ w document.getElementById("overlay_labels").src = ""; end

handle(w, "img_tab_change") do args
    global work_history, wi
    if ui["img_tabs"][] == "<<"; wi==1 ? wi=1 : wi-=1 end
    if ui["img_tabs"][] == ">>"; wi==length(work_history) ? wi : wi+=1 end

    img_filename = work_history[wi][4]
    labels_filename = work_history[wi][5]
    segs_info = work_history[wi][6]
    save(img_filename, work_history[wi][2])
    save(labels_filename, work_history[wi][3])
    dummy_img = img_filename * "?dummy=$(now())"
    dummy_labels = labels_filename * "?dummy=$(now())"

    @js_ w document.getElementById("segs_info").innerHTML = $segs_info;
    @js_ w document.getElementById("img_tabs").hidden = false;

    if ui["draw_labels"][] == true && (@isdefined dummy_labels) == true
        @js_ w document.getElementById("overlay_labels").src = $dummy_labels;
    else
        @js_ w document.getElementById("overlay_labels").src = ""; end

    if ui["img_tabs"][] == "Original"
        img_filename = ui["img_filename"][]
        @js_ w document.getElementById("display_img").src = $img_filename;
        @js_ w document.getElementById("overlay_original").src = "";
    elseif ui["img_tabs"][] == "Segmented"
        @js_ w document.getElementById("display_img").src = $dummy_img;
        @js_ w document.getElementById("overlay_original").src = "";
    elseif ui["img_tabs"][] == "Overlayed"
        img_filename = ui["img_filename"][]
        @js_ w document.getElementById("display_img").src = $dummy_img;
        @js_ w document.getElementById("overlay_original").src = $img_filename; end end

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
    global work_history
    if ui["labels"][] == true
        segs = work_history[end][1]
        dummy_filename = make_labels_img(segs)
        @js_ w document.getElementById("labels_img").src = $dummy_filename;
    else
        @js_ w document.getElementById("labels_img").src = ""; end end
