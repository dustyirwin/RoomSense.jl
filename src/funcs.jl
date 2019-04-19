function get_random_color(seed)
    Random.seed!(seed)
    rand(RGB{N0f8})
end

function param_segment_image(img)
    segments = try ui["param_algorithm"][](img, ui["var1"][], ui["var2"]) catch
        try ui["param_algorithm"][](img, ui["var1"][]) catch err
            println(err); return end end
    if ui["colorize"][] == true
        return map(i->get_random_color(i), labels_map(segments)), segments
    else
        return map(i->segment_mean(segments, i), labels_map(segments)), segments
    end
end

function seeded_segment_image(img, seeds)
    return "work work work"
end

function cleanup_tmp_files(dir_name)
    return "clean up temp files"
end
