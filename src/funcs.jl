function get_random_color(seed)
    Random.seed!(seed)
    rand(RGB{N0f8})
end

function segment_img(img)
    try
        segments = ui["algorithm"][](img, ui["var1"][], ui["var2"])
    catch MethodError
        segments = ui["algorithm"][](img, ui["var1"][])
    end
    return map(i->segment_mean(segments, i), labels_map(segments)), segments
end

handle(w, "go") do args
    if ui["img_filename"][] != ""
        img = load(ui["img_filename"][])
        seg_img, segments = segment_image(img)
        save(tmp_img_filename, seg_img)
        yield()
        @async body!(w, ui["html"](tmp_img_filename, segments))
    end
end

handle(w, "file_picked") do args
    img = load(ui["img_filename"][])
    size(w, size(img, 2), size(img, 1)+50)
    yield()
    @async body!(w, ui["html"](ui["img_filename"][]))
end

handle(w, "seed_click") do args
    if args[2] > 50 && ui["img_filename"][] != ""
        @show args
        img = load(ui["img_filename"][])
        renderstring!(img, "$(ui["space_num"][])", face, (20, 20), args[1], args[2], halign=:hright)
        img_datetime_name = """$(ui["img_filename"][])_$(now()).png"""
        save(img_datetime_name, img)
        push!(seeds, (CartesianIndex(args[1], args[2]), ui["space_num"][]))
        @async body!(w, html(img_datetime_name))
    end
end

handle(w, "algorithm_selected") do args
    help_text = ui["help_text"][ui["algorithm"][]]
    @js_ w document.getElementById("help_text").innerHTML = $help_text;
end
