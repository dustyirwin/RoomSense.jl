working_history = []

handle(w, "param_go") do args
    @js_ w document.getElementById("param_go").classList = ["button is-primary is-loading"];
    img = try
        load(ui["img_filename"][])
    catch
        @js_ w alert("Please select a valid image file.")
        @js_ w document.getElementById("param_go").classList = ["button is-primary"];
        return
    end
    seg_img, segments, seg_info = param_segment_image(img)
    working_img_filename = ui["img_filename"][][1:end-4] * "_working" * ui["img_filename"][][end-3:end]
    push!(working_history, (segments, seg_img, working_img_filename, now()))
    save(working_img_filename, seg_img)
    dummy_filename = working_img_filename * "?dummy=" * replace("$(now())", ":"=>".")
    ui["img_tabs"][] = "Segmented Image"
    @js_ w document.getElementById("img_tabs").hidden = false;
    @js_ w document.getElementById("seg_info").innerHTML = $seg_info;
    @js_ w document.getElementById("display_img").src = $dummy_filename;
    @js_ w document.getElementById("param_go").classList = ["button is-primary"];
end

handle(w, "prune_go") do args
    working_seg = working_history[end][1]
    seg_img, new_seg = min_pixel_group_size(working_seg, ui["min_segment_size"][])
    working_img_filename = working_history[end][3]
    push!(working_history, (segments, seg_img, working_img_filename, now()))
    save(working_img_filename, seg_img)
    dummy_filename = working_img_filename * "?dummy=" * replace("$(now())", ":"=>".")
    @js_ w document.getElementById("display_img").src = $dummy_filename;
end

handle(w, "operations_tab_change") do args
    selected_op = ui["operations_tabs"][]
    @async js(w, WebIO.JSString("""document.getElementById("$selected_op").hidden = false;"""))

    for op in ui["operations"]
        if op != selected_op
            @async js(w, WebIO.JSString("""document.getElementById("$op").hidden = true;"""))
        end end end

handle(w, "img_selected") do args
    img_filename = ui["img_filename"][]
    @js_ w document.getElementById("img_tabs").hidden = true;
    @js_ w document.getElementById("display_img").src = $img_filename;
end

handle(w, "img_tab_change") do args
    if ui["img_tabs"][] == "Original Image"
        img_filename = ui["img_filename"][]
        @js_ w document.getElementById("display_img").src = $img_filename;
    else
        @js_ w document.getElementById("display_img").src = $working_img_filename;
    end end

handle(w, "algorithm_selected") do args
    help_text = "Notes: " * ui["help_text"][ui["param_algorithm"][]]
    @js_ w document.getElementById("help_text").innerHTML = $help_text;
end

handle(w, "img_click") do args
    @show args
end

handle(w, "export_data") do args
    # save img to png, segment data to excel
end
