seg_info = (segs::SegmentedImage, pt::Float64) -> "Processed $(length(segs.segment_labels)) segments in $(round(pt, digits=4))s."

function param_segment_img(img_filename::String, input::Union{Int64,Float64}, alg::Function)
    img = load(img_filename)
    segs = alg(img, input) end

function get_random_color(seed::Int64)
    Random.seed!(seed)
    rand(RGB{N0f8}) end

function make_img_from_segs(segs::SegmentedImage, colorize::Bool)
    if colorize == true; map(i->get_random_color(i), labels_map(segs))
    else; map(i->segment_mean(segs, i), labels_map(segs)) end end

function prune_min_size(segs::SegmentedImage, min_size::Int64, prune_list=Vector{Int64}())
    for (k, v) in segs.segment_pixel_count
        if v < min_size; push!(prune_list, k) end end
    diff_fn = (rem_label, neigh_label) -> segment_pixel_count(segs, rem_label) - segment_pixel_count(segs, neigh_label)
    segs = prune_segments(segs, prune_list, diff_fn) end

function remove_segments(segs::SegmentedImage, labels::String, arr=Vector{Int64}())
    for i in split(labels, ",")
       push!(arr, parse(Int64, i)) end
    diff_fn = (rem_label, neigh_label) -> segment_pixel_count(segs, rem_label) - segment_pixel_count(segs, neigh_label)
    segs = prune_segments(segs, arr, diff_fn) end

function merge_segments(segs::SegmentedImage, labels::String, arr=Vector{Int64}())
    for i in split(labels, ",")
       push!(arr, parse(Int64, i)) end
    for i in 1:size(segs.image_indexmap)[1]
        for j in 1:size(segs.image_indexmap)[2]
            if segs.image_indexmap[i, j] == arr[1]
                segs.image_indexmap[i, j] = arr[2] end
            for k in 1:length(segs.segment_labels)
                if segs.segment_labels[k] == arr[1]
                    splice!(segs.segment_labels, k) end end end end
    return prune_min_size(segs, 1, diff_fn) end

function make_labels_from_segs(segs::SegmentedImage, draw_labels::Bool)
    labels_img = GrayA.(ones(size(segs.image_indexmap)[1], size(segs.image_indexmap)[2]))
    if draw_labels == true
        for label in segs.segment_labels
            oneoverpxs = 1/segs.segment_pixel_count[label]
            label_pts = []
            for i in 1:size(segs.image_indexmap)[1]
                for j in 1:size(segs.image_indexmap)[2]
                    if segs.image_indexmap[i, j] == label
                        push!(label_pts, (i, j))
            end end end
            x_centroid = trunc(Int64, oneoverpxs * sum([i[1] for i in label_pts]))
            y_centroid = trunc(Int64, oneoverpxs * sum([i[2] for i in label_pts]))
            labels_img = renderstring!(
                labels_img, "$label", ui["font"], (30, 30), x_centroid, y_centroid, halign=:hleft) end end
    return labels_img end

function recur_segs(img_filename::String, alg::Function, max_segs::Int64, mpgs::Int64, k=0.1; j=0.01)
    if alg == felzenszwalb k*=500; j*=500 end
    img = load(img_filename)
    segs = alg(img, k)
    c = length(segs.segment_labels)

    while c > max_segs
        segs = c / max_segs > 2 ? alg(img, k+=j*2) : alg(img, k+=j)
        segs = prune_min_size(segs, mpgs)
        c = length(segs.segment_labels)
        println("segs:$(length(segs.segment_labels)) k=$k mpgs:$mpgs")
    end
    return segs
end
