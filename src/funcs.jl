function get_random_color(seed)
    Random.seed!(seed)
    rand(RGB{N0f8})
end

function seg_img(img_filename)
    img = load(img_filename);
    segments = felzenszwalb(img, 500);
    img = map(i->get_random_color(i), labels_map(segments))
end

function go_event(w)
    @async while true
        if ui["go"][] > 0
            ui["go"][] = 0; println("Go click detected!")
            if ui["img_filename"][] != ""
                img = load(ui["img_filename"][])
                size(w, size(img, 2), size(img, 1))
                tmp_img_filename = ui["img_filename"][][1:end-4]*"$(now())"
                save(tmp_img_filename, seg_img(img))
                @async body!(w, ui["html"](tmp_img_filename))
            end end
        sleep(0.1)
    end end



handle(w, "load_img") do args
    mkdir("""$(ui["img_filename"])""")
    @async body!(w, html(ui["img_filename"][]))
end

handle(w, "click") do args
    if args[2] > 50 && ui["img_filename"][] != ""
        @show args
        img = load(ui["img_filename"][])
        renderstring!(img, "$(ui["space_num"][])", face, (20, 20), args[1], args[2], halign=:hright)
        img_datetime_name = "$(ui["img_filename"][][])_$(now()).png"
        save(img_datetime_name, img)
        push!(seeds, (CartesianIndex(args[1], args[2]), ui["space_num"][]))
        @async body!(w, html(img_datetime_name))
    end
end

handle(w, "alg_select") do args
    @show args
    @async body!(w, html(ui["img_filename"][]))
end
