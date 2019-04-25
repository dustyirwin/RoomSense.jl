function diff_fn(rem_label, neigh_label)
    segment_pixel_count(segments, rem_label) - segment_pixel_count(segments, neigh_label)
end

function get_random_color(seed)
    Random.seed!(seed)
    rand(RGB{N0f8})
end

function make_img_from_seg(segments)
    if ui["colorize"][] == true
        map(i->get_random_color(i), labels_map(segments))
    else
        map(i->segment_mean(segments, i), labels_map(segments))
end end

function param_segment_img(img)
    process_time = @elapsed begin
        segments = ui["param_algorithm"][](img, ui["input_1"][])
        seg_img = make_img_from_seg(segments)
    end
    seg_info = "Processed $(length(segments.segment_labels)) segments in $(round(process_time, digits=3))s."
    return segments, seg_img, seg_info
end

function prune_min_size(segments, min_size)
    process_time = @elapsed begin
        prune_list = Vector{Int64}()
        for (k, v) in segments.segment_pixel_count
            if v < min_size
                push!(prune_list, k)
            end end
        diff_fn(rem_label, neigh_label) = segment_pixel_count(segments, rem_label) - segment_pixel_count(segments, neigh_label)
        new_seg = prune_segments(segments, prune_list, diff_fn)
        seg_img = make_img_from_seg(new_seg)
    end
    seg_info = "Processed $(length(new_seg.segment_labels)) segments in $(round(process_time, digits=3))s."
    return new_seg, seg_img, seg_info
end

function remove_segments()
    return ""
end

function merge_segments()
    return ""
end
