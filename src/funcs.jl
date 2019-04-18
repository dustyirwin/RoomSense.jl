function get_random_color(seed)
    Random.seed!(seed)
    rand(RGB{N0f8})
end

function segment_image(img)
    try
        segments = ui["algorithm"][](img, ui["var1"][], ui["var2"])
    catch MethodError
        segments = ui["algorithm"][](img, ui["var1"][])
    end
    return map(i->segment_mean(segments, i), labels_map(segments)), segments
end

handle(w, "go") do args
    try
        img = load(ui["img_filename"][])
    catch
        @js w alert("Please select a valid image file.")
    end
    seg_img, segments = segment_image(img)
    tmp_img_filename = ui["img_filename"][] * "_$(now())"
    save(tmp_img_filename, seg_img)
    @js_ w document.getElementById("main_img").src = $tmp_img_filename;
end

handle(w, "file_picked") do args
    img_filename = ui["img_filename"][]
    @js_ w document.getElementById("main_img").src = $img_filename;
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
    help_text = ui["help_text"][ui["algorithm"][]]
    @js_ w document.getElementById("help_text").innerHTML = $help_text;
end

handle(w, "export_data") do args
    # save img to png, segment data to excel
end
