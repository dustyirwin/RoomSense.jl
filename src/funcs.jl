function diff_fn(rem_label, neigh_label)
    segment_pixel_count(segments, rem_label) - segment_pixel_count(segments, neigh_label)
end

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
    seg_info = "$(length(segments.segment_labels)) segments found in $(round(process_time, digits=3))s."
    return seg_img, segments, seg_info
end

function seeded_segment_image(img, seeds)
    return "work work work"
end

function min_pixel_group_size(segments, min_size)
    prune_list = Vector{Int64}()
    for (k, v) in seg.segment_pixel_count
        if v < min_size
            push!(prune_list, k)
        end end
    seg_count = length(prune_list)
    if @js w alert("This will remove $seg_count segments. Continue?") == true
        seg = prune_segments(segments, prune_list, diff_fn)
        seg_img = map(i->get_random_color(i), labels_map(segments))
        return seg_img, seg
    end
end

function split_segment()
    return
end

function merge_segment()
    return
end
