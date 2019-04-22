function get_random_color(seed)
    Random.seed!(seed)
    rand(RGB{N0f8})
end

function param_segment_image(img)
    process_time = @elapsed begin
        segments = try ui["param_algorithm"][](img, ui["var1"][], ui["var2"]) catch
            try ui["param_algorithm"][](img, ui["var1"][]) catch err
                println(err); return
            end end
        if ui["colorize"][] == true
            seg_img = map(i->get_random_color(i), labels_map(segments))
        else
            seg_img =  map(i->segment_mean(segments, i), labels_map(segments))
    end end
    renderstring!(seg_img, """algorithm=$(ui["param_algorithm"][]) segments=$(length(segments.segment_labels))""",
        ui["face"], (20,20), 25, 10, halign=:hleft)
    renderstring!(seg_img, """var1=$(ui["var1"][]) var2=$(ui["var2"][]) process_time=$(round(process_time, digits=3))s""",
        ui["face"], (20,20), 55, 10, halign=:hleft)
    return seg_img, segments
end

function seeded_segment_image(img, seeds)
    return "work work work"
end

function remove_segments(w, segs, rm_segs)
    # @js w alert("Remove segments?")
    rm_segs = typeof(rm_segs) == Int ? [rm_segs] : rm_segs
    diff_fn(rem_label, neigh_label) = segment_pixel_count(segs, rem_label) - segment_pixel_count(segs, neigh_label)
    prune_segments(segs, rm_segs, diff_fn)
end

function split_segment()
    return
end

function merge_segment()
    return
end
