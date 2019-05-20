make_segs_info = (segs::SegmentedImage, pt::Float64) -> "Processed $(length(segs.segment_labels)) segments in $(round(pt, digits=2))s."

make_transparent(img::Matrix, val=0.0, alpha=1.0) = [GrayA{Float64}(abs(val-e.val), abs(alpha-e.val)) for e in GrayA.(img)]

function diff_fn_wrapper(segs)
    diff_fn = (rem_label, neigh_label) -> segment_pixel_count(segs, rem_label) - segment_pixel_count(segs, neigh_label) end

function segment_img(img_filename::String, input::Union{Int64,Float64,Tuple{CartesianIndex,Int64}}, alg::Function)
    img = Gray.(load(img_filename))
    segs = alg(img, input)
    return prune_segments(segs, [0], diff_fn_wrapper(segs)) end

function get_random_color(seed::Int64)
    seed!(seed)
    rand(RGB{N0f8}) end

function prune_min_size(segs::SegmentedImage, min_size::Int64, prune_list=Vector{Int64}())
    for (k, v) in segs.segment_pixel_count
        if v < min_size; push!(prune_list, k) end end
    segs = prune_segments(segs, prune_list, diff_fn_wrapper(segs))
    return prune_segments(segs, [0], diff_fn_wrapper(segs)) end

function make_segs_img(segs::SegmentedImage, colorize::Bool)
    if colorize == true; map(i->get_random_color(i), labels_map(segs))
    else; map(i->segment_mean(segs, i), labels_map(segs)) end end

function make_labels_img(segs::SegmentedImage, draw_labels::Bool)
    overlay_img = zeros(size(segs.image_indexmap)[1], size(segs.image_indexmap)[2])
    if draw_labels == true
        for (label, count) in collect(segs.segment_pixel_count)
            oneoverpxs = 1 / count
            label_pts = []
            for x in 1:size(segs.image_indexmap)[1]
                for y in 1:size(segs.image_indexmap)[2]
                    if segs.image_indexmap[x, y] == label
                        push!(label_pts, (x, y))
            end end end
            x_centroid = trunc(Int64, oneoverpxs * sum([i[1] for i in label_pts]))
            y_centroid = trunc(Int64, oneoverpxs * sum([i[2] for i in label_pts]))
            try label = label * labels[label] catch end
            renderstring!(
                overlay_img, "$label", ui["font"], (30, 30), x_centroid, y_centroid,
                halign=:hcenter, valign=:vcenter) end end
    return make_transparent(overlay_img, 1.0, 0.0) end

function make_seeds_img(seeds::Vector{Tuple{CartesianIndex{2},Int64}})
    overlay_img = zeros(height(s[wi]["user_img"]), width(s[wi]["user_img"]))
    if seeds != nothing
        for seed in seeds
            renderstring!(
                overlay_img, "$(seed[2])", ui["font"], (30, 30), seed[1][1], seed[1][2],
                halign=:hcenter, valign=:vcenter)
    end end
    return make_transparent(overlay_img, 1.0, 0.0) end

function make_plot_img(segs::SegmentedImage, create_plot::Bool)
    if create_plot == true
        return plot(
            x=[i[1] for i in collect(segs.segment_pixel_count)],
            y=[i[2] for i in collect(segs.segment_pixel_count)],
            xlabel("Segment Label"),
            ylabel("Pixel Group Count"),
            bar,
            y_log10)
    else; return plot(x=[], y=[], xlabel("Segment Label"), ylabel("Pixel Group Count"), bar, y_log10) end end

function recursive_segmentation(img_filename::String, alg::Function, max_segs::Int64, mpgs::Int64, k=0.05; j=0.01)
    if alg == felzenszwalb k*=500; j*=500 end
    if alg == fast_scanning k*=1.5 end
    segs = segment_img(img_filename, k, alg)
    c = length(segs.segment_labels)
    while c > max_segs
        segs = c / max_segs > 2 ? segment_img(img_filename, k+=j*3, alg) : segment_img(img_filename, k+=j, alg)
        segs = prune_min_size(segs, mpgs)
        c = length(segs.segment_labels)
        update = "alg:" * "$alg"[19:end] * "
            segs:$(length(segs.segment_labels)) k=$(round(k, digits=3)) mpgs:$mpgs"
        @js_ w document.getElementById("segs_info").innerHTML = $update; end
    return segs end

function make_segs_details(segs::SegmentedImage)
    lis = [haskey(s[wi]["tags"], label) ?
            "<li>$(s[wi]["tags"][label])$label - $pixel_count</li>" :
            "<li>$label - $pixel_count</li>" for (label, pixel_count) in sort!(
                collect(segs.segment_pixel_count), by = x -> x[2], rev=true)]
    s[wi]["segs_details"] = lis
    lis = lis[1:(length(lis) > 100 ? 100 : end)]
    return "<strong>Label - Pixel Count</strong>" * "<ul>$(lis...)</ul>" end

function merge_segments(segs::SegmentedImage, input::String)
    args = parse_input(input)
    for i in 1:height(segs.image_indexmap)
        for j in 1:width(segs.image_indexmap)
            if segs.image_indexmap[i, j] in args
                segs.image_indexmap[i, j] = args[end]
    end end end
    return prune_segments(segs, [0], diff_fn_wrapper(segs)) end

function remove_segments(segs::SegmentedImage, input::String)
    args = parse_input(input)
    segs = prune_segments(segs, args, diff_fn_wrapper(segs))
    return prune_segments(segs, [0], diff_fn_wrapper(segs)) end

function parse_input(input::String)
    if ';' in input
        args = Vector{Tuple{CartesianIndex{2},Int64}}()
        input = replace(input, " "=>""); input = input[end] == ';' ? input[1:end-1] : input
        if length(split(input, ';')) > 1
            for (i, seed) in enumerate(split(input, ';'))
                seed = [parse(Int64, seed) for seed in split(seed, ',')]
                push!(args, (CartesianIndex(seed[1], seed[2]), seed[3])) end
        else
            seed = [parse(Int64, seed) for seed in split(input, ',')]
            push!(args, (CartesianIndex(seed[1], seed[2]), seed[3])) end
    else
        args = Vector{Int64}()
        input = replace(input, " "=>""); input = input[end] == ',' ? input[1:end-1] : input
        for i in unique!(split(input, ','))
            push!(args, parse(Int64, i))
    end end
    return args end

function tag_segments(input::String)
    global s; args = parse_input(input)
    for label in args
        s[wi]["tags"][label] = ui["segment_tags"][]
end end

function get_dummy(img_type::String)
    save(s[wi]["img_filename"][1:end-4] * img_type, s[wi][img_type])
    dummy_name = s[wi]["img_filename"][1:end-4] * "$img_type?dummy=$(now())" end

function calculate_areas(segs::SegmentedImage, input::String)
    global s; args = parse_input(input)
    px_dist = ((args[2][1]-args[1][1])^2 + (args[2][2]-args[1][2])^2)^(1/2)
    scaling_factor = (length / px_dist)^2
    areas = OrderedDict(
        label=>pixel_count * scaling_factor for (label, pixel_count) in collect(segs.segment_pixel_count)) end

function export_xlsx()
    return "" end
