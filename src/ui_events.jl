working_img_filename = ""

handle(w, "param_go") do args
    @js_ w document.getElementById("param_go").classList = ["button is-primary is-loading"];
    global working_img_filename
    img = try
        load(ui["img_filename"][])
    catch
        @js_ w alert("Please select a valid image file.")
        return
    end
    seg_img, segments = param_segment_image(img)
    working_img_filename = ui["img_filename"][][1:end-4] * replace("_$(now())", ":"=>".") * ui["img_filename"][][end-3:end]
    save(working_img_filename, seg_img)
    seg_info = "Segments: $(length(segments.segment_labels))"
    ui["img_tabs"][] = "Segmented Image"
    @js_ w document.getElementById("img_tabs").hidden = false;
    @js_ w document.getElementById("seg_info").innerHTML = $seg_info;
    @js_ w document.getElementById("display_img").src = $working_img_filename;
    @js_ w document.getElementById("param_go").classList = ["button is-primary"];
end

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
    end
end

handle(w, "seed_click") do args
    if args[2] > 50 && ui["img_filename"][] != ""
        @show args
        img = load(ui["img_filename"][])
        renderstring!(img, "$(ui["space_num"][])", face, (20, 20), args[1], args[2], halign=:hright)
        img_datetime_name = """$(ui["img_filename"][])_$(now()).png"""
        save(img_datetime_name, img)
        push!(seeds, (CartesianIndex(args[1], args[2]), ui["space_num"][]))
        @js_ w document.getElementById("main_img").src = $img_filename;
    end end

handle(w, "algorithm_selected") do args
    help_text = "Notes: " * ui["help_text"][ui["param_algorithm"][]]
    @js_ w document.getElementById("help_text").innerHTML = $help_text;
end

handle(w, "export_data") do args
    # save img to png, segment data to excel
end
