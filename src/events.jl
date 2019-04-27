handle(w, "go") do args
    global working_history
    @js_ w document.getElementById("go").classList = ["button is-primary is-loading"];

    if ui["operations_tabs"][] == "Parametric Segmentation"
        img = try load(ui["img_filename"][]) catch
            @js_ w alert("Please select a valid image file.") end
        segs, segs_img, segs_info = param_segment_img(
        img, parse(ui["param_algorithm"][][2], ui["input"][]), ui["param_algorithm"][][1])
        working_img_filename = ui["img_filename"][][1:end-4] * "_working" * ui["img_filename"][][end-3:end]

    elseif ui["operations_tabs"][] == "Modify Segments"
        try
            working_img_filename = working_history[end][3]
            segs, segs_img, segs_info = ui["mod_segs_algorithm"][][1](
                working_history[end][1], try parse(ui["mod_segs_algorithm"][][2], ui["input"][]) catch
                    ui["input"][] end)
        catch err
            println(err); @js_ w alert("No segments found to operate on.") end end
    try
        push!(working_history, (segs, segs_img, working_img_filename))
        dummy_filename = working_img_filename * "?dummy=$(now())"
        save(working_img_filename, segs_img)
        ui["img_tabs"][] = "Overlayed"; @js_ w Blink.msg("img_tab_change", "")
        @js_ w document.getElementById("segs_info").innerHTML = $segs_info;
        @js_ w document.getElementById("display_img").src = $dummy_filename;
    catch err; println(err) end
    @js_ w document.getElementById("go").classList = ["button is-primary"];
end

handle(w, "op_tab_change") do args
    selected_op = ui["operations_tabs"][]
    @js_ w document.getElementById("help_text").innerHTML = "";
    @async js(w, WebIO.JSString("""document.getElementById("$selected_op").hidden = false;"""))
    @async js(w, WebIO.JSString("""document.getElementById("$selected_op toolset").hidden = false;"""))

    for op in ui["operations"]
        if op != selected_op
            @async js(w, WebIO.JSString("""document.getElementById("$op").hidden = true;"""))
            @async js(w, WebIO.JSString("""document.getElementById("$op toolset").hidden = true;"""))
end end end

handle(w, "img_selected") do args
    img_filename = ui["img_filename"][]
    @js_ w document.getElementById("img_tabs").hidden = true;
    @js_ w document.getElementById("display_img").src = $img_filename;
end

handle(w, "img_tab_change") do args
    global working_history
    img_filename = ui["img_filename"][]
    @js_ w document.getElementById("img_tabs").hidden = false;

    if ui["img_tabs"][] == "Original"; @js_ w document.getElementById("display_img").src = $img_filename;
    else
        working_img_filename = working_history[end][3]
        dummy_filename = working_img_filename * "?dummy=$(now())"
        if ui["img_tabs"][] == "Segmented"
            @js_ w document.getElementById("display_img").src = $dummy_filename;
            @js_ w document.getElementById("overlay_img").src = "";
        else
            @js_ w document.getElementById("overlay_img").src = $img_filename;
            @js_ w document.getElementById("display_img").src = $dummy_filename;
end end end

handle(w, "dropdown_selected") do args
    if ui["operations_tabs"][] == "Parametric Segmentation"
        help_text = ui["help_text"][ui["param_algorithm"][][1]]
    elseif ui["operations_tabs"][] == "Modify Segments"
        help_text = ui["help_text"][ui["mod_segs_algorithm"][][1]]
    elseif ui["operations_tabs"][] == "Label Segments"
        help_text = "Assign a space type to a segment." end
    @js_ w document.getElementById("help_text").innerHTML = $help_text;
end
