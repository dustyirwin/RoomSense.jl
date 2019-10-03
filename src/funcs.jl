using ImageSegmentation: fast_scanning, felzenszwalb, seeded_region_growing, prune_segments,
    segment_pixel_count, labels_map, segment_mean, segment_labels, SegmentedImage
using FreeTypeAbstraction: renderstring!, newface, FreeType
using ImageTransformations: imresize
using Images: save, load, height, width, Gray, GrayA, RGB, N0f8, FixedPointNumbers
using Gadfly: plot, inch, draw, SVG, Guide.xlabel, Guide.ylabel, Geom.bar, Scale.y_log10
using Blink: @js_ js, tools
using DataFrames: DataFrame
using Random: seed!
using CSV: write
using Dates: now

# terse funcs
make_segs_info(segs::SegmentedImage) = "Processed $(length(segs.segment_labels)) segments."
remove_segments(segs::SegmentedImage, args::Vector{Int64}) = prune_segments(segs, args, diff_fn_wrapper(segs))
make_transparent(img::Matrix, val=0.0, alpha=1.0) = [GrayA{Float64}(abs(val-e.val), abs(alpha-e.val)) for e in GrayA.(img)]
pred_space_type(m,) = Int64(m(img_slices[label]))

# verbose funcs
function diff_fn_wrapper(segs::SegmentedImage)
    diff_fn = (rem_label, neigh_label) -> segment_pixel_count(segs, rem_label) - segment_pixel_count(segs, neigh_label) end

function segment_img(img_fln::String, args::Union{Int64,Float64,Tuple{CartesianIndex,Int64}}, alg::Function, m, SP::Bool)
    img = Gray.(load(img_fln))
    segs = alg(img, args) end

function get_random_color(seed::Int64)
    seed!(seed)
    rand(RGB{N0f8}) end

function prune_min_size(segs::SegmentedImage, min_size::Vector{Int64}, scale::Float64, prune_list=Vector{Int64}())
    for (k, v) in segs.segment_pixel_count
        if scale != 1;
            v / scale < min_size[1] ? push!(prune_list, k) : continue
        elseif v < min_size[1]
            push!(prune_list, k) end end
    segs = prune_segments(segs, prune_list, diff_fn_wrapper(segs))
    return prune_segments(segs, [0], diff_fn_wrapper(segs)) end

function make_segs_img(segs::SegmentedImage, colorize::Bool)
    if colorize == true; map(i->get_random_color(i), labels_map(segs))
    else; map(i->segment_mean(segs, i), labels_map(segs)) end end

function make_labels_img(segs::SegmentedImage, draw_labels::Bool, font::Vector{Ptr{FreeType.FT_FaceRec}})
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
                overlay_img, "$label", font, (28, 28), x_centroid, y_centroid,
                halign=:hcenter, valign=:vcenter) end end
    return make_transparent(overlay_img, 1.0, 0.0) end

function make_seeds_img(seeds::Vector{Tuple{CartesianIndex{2},Int64}}, height::Int64, width::Int64,
        font::Vector{Ptr{FreeType.FT_FaceRec}}, font_size::Int64)
    overlay_img = zeros(height, width)
    for seed in seeds
        renderstring!(
            overlay_img, "$(seed[2])", font, (font_size, font_size),
            seed[1][1], seed[1][2], halign=:hcenter, valign=:vcenter) end
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
    segs, segs_types = segment_img(img_fln, k, alg)

    while c > length(segs.segment_labels)
        segs, segs_types = c / max_segs > 2 ? segment_img(img_fln, k+=j*3, alg) : segment_img(img_fln, k+=j, alg)
        segs = prune_min_size(segs, [mgs], s[wi]["scale"][1])
        c = length(segs.segment_labels)
        update = "alg: $alg segs:$(length(segs.segment_labels)) k=$(round(k, digits=3)) mgs:$mgs"
        @js_ w document.getElementById("segs_info").innerHTML = $update; end
    return (segs, segs_types) end

function make_segs_details(segs::SegmentedImage, segs_types::Dict, scale::Float64, scale_units::String)
    lis = ["""<li>$label - $(scale > 1 ? trunc(pixel_count / scale) : pixel_count) - $(segs_types[label])</li>"""
        for (label, pixel_count) in sort!(collect(segs.segment_pixel_count), by = x -> x[2], rev=true)]
    lis = lis[1:(length(lis) > 100 ? 100 : end)]
    area_sum = sum([pixel_count / scale for (label, pixel_count) in segs.segment_pixel_count])
    return scale > 1 ? "<p><strong>Total Area: $(trunc(area_sum)) " * "$(scale == 1 ? "pixels" : scale_units)" * "</strong></p>" *
        "<p><strong>Total Segments: $(length(segment_labels(segs)))</strong></p>" *
        "<p><strong>Label - $(scale == 1 ? "Pixel Count" : "Area") - Type (Top 100)</strong></p>" *
        "<ul>$(lis...)</ul>" : "" end

function parse_input(input::String, ops_tabs::String)
    input = replace(input, " "=>""); if input == ""; return 0 end
    if ops_tabs in ["Set Scale", "Segment Image"]
        args = Vector{Tuple{CartesianIndex{2},Int64}}()

        try for vars in split(input[end] == ';' ? input : input * ';', ';')
            var = length(vars) > 2 ? [parse(Int64, var) for var in split(vars, ',')] : continue
            push!(args, (CartesianIndex(var[1], var[2]), var[3])) end
        catch; var = [parse(Int64, var) for var in split(input, ',')]
            push!(args, (CartesianIndex(var[1], var[2]), var[3])) end
    elseif ops_tabs in ["Modify Segments"]
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

function get_dummy(img_type::String, img_fln::String, img::Any)
    save(img_fln[1:end-4] * img_type, img)
    img = img_fln[1:end-4] * "$img_type?dummy=$(now())" end

function feet() return "ft" end

function meters() return "m" end

function export_CSV(segs::SegmentedImage, segs_types::Dict, img_fln::String, scale::Float64, scale_unit::String)
    area_estimate = Symbol("area_estimate_$scale_unit")
    df = DataFrame(segment_labels=Int64[], segment_pixel_count=Int64[], area_estimate=Int64[], space_type_pred=String[])
    csv_fln = "$(img_fln[1:end-4])_" * replace(replace("$(now())", "."=>"-"), ":"=>"-") * ".csv"
    js_str = "Data exported to $csv_fln"

    for (label, px_ct) in segment_pixel_count(segs)
        push!(df, [label, px_ct, floor(px_ct/scale[1]), segs_types[label]]) end

    write(csv_fln, df)
    return js_str end

function get_segment_bounds(segs::SegmentedImage, bounds=Dict())

    for label in segment_labels(segs)
        x_range = []
        y_range = []

        for i in 1:width(labels_map(segs))
            if label in labels_map(segs)[:,i]
                push!(x_range, i) end end

        for i in 1:height(labels_map(segs))
            if label in labels_map(segs)[i,:]
                push!(y_range, i) end end

        left = min(x_range...)
        right = max(x_range...)
        top = min(y_range...)
        bottom = max(y_range...)

        bounds[label] = Dict(
            "l"=>left,
            "r"=>right,
            "t"=>top,
            "b"=>bottom) end

    return bounds end

function get_segs_types(segs::SegmentedImage, img_fln::String, m, SP::Bool)
    if SP
        segs_types=Dict()
        img_slices = make_segs_data(segs, img_fln)[2]
        for (label, img_slice) in img_slices
            pred_vec = m(img_slice)
            segs_types[label] = primary_space_types[Int64(findall(pred_vec .== maximum(pred_vec))[1])] end
    else
        segs_types = Dict(label=>primary_space_types[12] for label in segment_labels(segs)) end end

function error_wrapper() end
