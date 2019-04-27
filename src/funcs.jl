function get_random_color(seed)
    Random.seed!(seed)
    rand(RGB{N0f8})
end

function seg_info(segs, pt)
    "Processed $(length(segs.segment_labels)) segments in $(round(pt, digits=3))s."
end

function make_img_from_seg(segs)
    if ui["colorize"][] == true; map(i->get_random_color(i), labels_map(segs))
    else; map(i->segment_mean(segs, i), labels_map(segs)) end
end

function param_segment_img(img, input_1, alg)
    process_time = @elapsed begin
    segs = alg(img, input_1)
    segs_img = make_img_from_seg(segs) end
    return segs, segs_img, seg_info(segs, process_time)
end

function prune_min_size(segs, min_size, prune_list=Vector{Int64}())
    process_time = @elapsed begin
    for (k, v) in segs.segment_pixel_count
        if v < min_size; push!(prune_list, k) end end
    diff_fn = (rem_label, neigh_label) -> segment_pixel_count(segs, rem_label) - segment_pixel_count(segs, neigh_label)
    segs = prune_segments(segs, prune_list, diff_fn)
    segs_img =  make_img_from_seg(segs) end
    return segs, segs_img, seg_info(segs, process_time)
end

function merge_segments(segs, labels, arr=Vector{Int64}())
    process_time = @elapsed begin
    for i in split(labels, ",")
       push!(arr, parse(Int64, i)) end

    for i in 1:size(segs.image_indexmap)[1]
        for j in 1:size(segs.image_indexmap)[2]
            if segs.image_indexmap[i, j] == arr[1]
                segs.image_indexmap[i, j] = arr[2] end
            for k in 1:length(segs.segment_labels)
                if segs.segment_labels[k] == arr[1]
                    splice!(segs.segment_labels, k) end
    end end end
    segs = prune_segments(segs, Vector{Int64}(), diff_fn)  # forces re-evaluation of the segments object
    segs_img = make_img_from_seg(segs) end
    return segs, segs_img, seg_info(segs, process_time)
end

function remove_segments(segs, labels, arr=Vector{Int64}())
    process_time = @elapsed begin
    for i in split(labels, ",")
       push!(arr, parse(Int64, i)) end
    diff_fn = (rem_label, neigh_label) -> segment_pixel_count(segs, rem_label) - segment_pixel_count(segs, neigh_label)
    segs = prune_segments(segs, arr, diff_fn)
    segs_img = make_img_from_seg(segs) end
    return segs, segs_img, seg_info(segs, process_time)
end
