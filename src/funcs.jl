# terse funcs
make_segs_info(segs::SegmentedImage, pt::Float64) = "Processed $(length(segs.segment_labels)) segments."
remove_segments(segs::SegmentedImage, args::Vector{Int64}) = prune_segments(segs, args, diff_fn_wrapper(segs))
make_transparent(img::Matrix, val=0.0, alpha=1.0) = [GrayA{Float64}(abs(val-e.val), abs(alpha-e.val)) for e in GrayA.(img)]


function diff_fn_wrapper(segs)
    diff_fn = (rem_label, neigh_label) -> segment_pixel_count(segs, rem_label) - segment_pixel_count(segs, neigh_label) end

function segment_img(img_fln::String, args::Union{Int64,Float64,Tuple{CartesianIndex,Int64}}, alg::Function)
    img = Gray.(load(img_fln))
    segs = alg(img, args) end

function get_random_color(seed::Int64)
    seed!(seed)
    rand(RGB{N0f8}) end

function prune_min_size(segs::SegmentedImage, min_size::Vector{Int64}, prune_list=Vector{Int64}())
    for (k, v) in segs.segment_pixel_count
        if s[wi]["scale"][1] != 1;
            v / s[wi]["scale"][1] < min_size[1] ? push!(prune_list, k) : continue
        elseif v < min_size[1]
            push!(prune_list, k) end end
    segs = prune_segments(segs, prune_list, diff_fn_wrapper(segs)) end

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
                overlay_img, "$label", ui["font"], (28, 28), x_centroid, y_centroid,
                halign=:hcenter, valign=:vcenter) end end
    return make_transparent(overlay_img, 1.0, 0.0) end

function make_seeds_img(seeds::Vector{Tuple{CartesianIndex{2},Int64}})
    overlay_img = zeros(height(s[wi]["user_img"]), width(s[wi]["user_img"]))
    if seeds != nothing
        for seed in seeds
            renderstring!(
                overlay_img, "$(seed[2])", ui["font"], (ui["font_size"], ui["font_size"]), seed[1][1], seed[1][2],
                halign=:hcenter, valign=:vcenter)
    end end
    return make_transparent(overlay_img, 1.0, 0.0) end

function make_plot_img(segs::SegmentedImage)
    return plot(
            x=[i[1] for i in collect(segs.segment_pixel_count)],
            y=[i[2] for i in collect(segs.segment_pixel_count)],
            xlabel("Segment Label"),
            ylabel("Pixel Group Count"),
            bar,
            y_log10) end

function recursive_segmentation(img_fln::String, alg::Function, max_segs::Int64, mgs::Int64, k=0.05; j=0.01)
    if alg == felzenszwalb k*=500; j*=500 end
    if alg == fast_scanning k*=1.5 end
    segs = segment_img(img_fln, k, alg)
    c = length(segs.segment_labels)
    while c > max_segs
        segs = c / max_segs > 2 ? segment_img(img_fln, k+=j*3, alg) : segment_img(img_fln, k+=j, alg)
        segs = prune_min_size(segs, [mgs])
        c = length(segs.segment_labels)
        update = "alg: $alg segs:$(length(segs.segment_labels)) k=$(round(k, digits=3)) mgs:$mgs"
        @js_ w document.getElementById("segs_info").innerHTML = $update; end
    return segs end

function make_segs_details(segs::SegmentedImage)
    lis = ["""<li>$label - $(haskey(s[wi], "scale") == true ? trunc(pixel_count / s[wi]["scale"][1]) : pixel_count)</li>"""
        for (label, pixel_count) in sort!(collect(segs.segment_pixel_count), by = x -> x[2], rev=true)]
    s[wi]["segs_details"] = lis
    lis = lis[1:(length(lis) > 100 ? 100 : end)]
    area_sum = sum([pixel_count / s[wi]["scale"][1] for (label, pixel_count) in segs.segment_pixel_count])
    return haskey(s[wi], "segs") ? "<p><strong>Total Area: $(trunc(area_sum)) " * "$(s[wi]["scale"][1] == 1 ? "pixels" : s[wi]["scale"][2])" * "</strong></p>" *
        "<p><strong>Segments: $(length(segment_labels(s[wi]["segs"])))</strong></p>" *
        "<p><strong>Label - $(s[wi]["scale"][1] == 1 ? "Pixel Count" : "Area")</strong></p>" *
        "<ul>$(lis...)</ul>" : "" end

function parse_input(input::String)
    input = replace(input, " "=>""); if input == ""; return 0 end
    if ui["ops_tabs"][] in ["Set Scale", "Segment Image"]
        args = Vector{Tuple{CartesianIndex{2},Int64}}()

        try for vars in split(input[end] == ';' ? input : input * ';', ';')
            var = length(vars) > 2 ? [parse(Int64, var) for var in split(vars, ',')] : continue
            push!(args, (CartesianIndex(var[1], var[2]), var[3])) end
        catch; var = [parse(Int64, var) for var in split(input, ',')]
            push!(args, (CartesianIndex(var[1], var[2]), var[3])) end
    else
        type = '.' in input ? Float64 : Int64
        args = Vector{type}()

        for i in unique!(split(input, ','))
            push!(args, parse(type, i)) end end
    return args end

function calc_scale(scales::Vector{Tuple{CartesianIndex{2},Int64}})
    pxs_per_unit_lengths = Vector{Float64}()

    for args in scales
        d = abs(args[1][2] - args[1][1]) / args[2]
        push!(pxs_per_unit_lengths, d) end

    avg_pxs_per_unit_length = sum(pxs_per_unit_lengths) / length(pxs_per_unit_lengths)
    return avg_pxs_per_unit_length^2 end

function get_img(img_type::String)
    save(s[wi]["img_fln"][1:end-4] * img_type, s[wi][img_type])
    img = s[wi]["img_fln"][1:end-4] * "$img_type?dummy=$(now())" end

function feet() return "ft" end

function meters() return "m" end

function export_CSV(input::String)
    input = parse_input(input)
    df = DataFrame(segment_labels=Int64[], segment_pixel_count=Int64[], area_estimate=Int64[])
    csv_fln = "$(s[wi]["img_fln"][1:end-4])_" * replace(replace("$(now())", "."=>"-"), ":"=>"-") * ".csv"
    println(csv_fln)
    js_str = "Data exported to $csv_fln"

    for (seg_label, px_ct) in segment_pixel_count(s[wi]["segs"])
        push!(df, [seg_label, px_ct, floor(px_ct/s[wi]["scale"][1])]) end

    write(csv_fln, df)
    return js_str end

function error_wrapper() end
