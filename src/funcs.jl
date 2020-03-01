
# terse funcs
make_segs_info(segs::SegmentedImage) = "Processed $(length(segs.segment_labels)) segments."
remove_segments(segs::SegmentedImage, args::Vector{Int64}) = prune_segments(segs, args, diff_fn_wrapper(segs))
make_transparent(img::Matrix, val=0.0, alpha=1.0) = [GrayA{Float64}(abs(val-e.val), abs(alpha-e.val)) for e in GrayA.(img)]
feet() = "ft"
meters() = "m"
pixels() = "pxs"


# verbose funcs
function diff_fn_wrapper(segs::SegmentedImage)
    diff_fn = (rem_label, neigh_label) -> segment_pixel_count(segs, rem_label) - segment_pixel_count(segs, neigh_label) end

function segment_img(img_fln::String, args::Union{Int64,Float64,Tuple{CartesianIndex,Int64}}, alg::Function)
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
    return prune_segments(segs, prune_list, diff_fn_wrapper(segs)) end

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
            x_centroid = ceil(Int64, oneoverpxs * sum([i[1] for i in label_pts]))
            y_centroid = ceil(Int64, oneoverpxs * sum([i[2] for i in label_pts]))
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

function make_plot_img(segs::SegmentedImage, scale::Float64)
    return plot(
        x=[i[1] for i in collect(segs.segment_pixel_count)],
        y=[i[2] for i in collect(segs.segment_pixel_count)],
        xlabel("Segment Label"),
        ylabel(scale > 1 ? "Area" : "Pixels"),
        bar,
        y_log10) end

function recursive_segmentation(img_fln::String, alg::Function, max_segs::Int64, mgs::Int64, scale::Float64, k=0.05; j=0.01)
    if alg == felzenszwalb k*=500; j*=500 end
    if alg == fast_scanning k*=1.5 end
    segs = segment_img(img_fln, k, alg)
    c = length(segs.segment_labels)
    while c > max_segs
       segs = c / max_segs > 2 ? segment_img(img_fln, k+=j*3, alg) : segment_img(img_fln, k+=j, alg)
       segs = prune_min_size(segs, [mgs], scale)
       c = length(segs.segment_labels)
       update = "alg:" * "$alg"[19:end] * "
           segs:$(length(segs.segment_labels)) k=$(round(k, digits=3)) mgs:$mgs"
       @js_ w document.getElementById("segs_info").innerHTML = $update; end
       return segs end

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
    img = register(img_fln[1:end-4] * img_type) * "?dummy=$(now())" end

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

function highlight_segs(segs::SegmentedImage, img::Matrix, img_fln::String, args::Vector)
    for j in 1:height(img)
        for k in 1:width(img)
            if segs.image_indexmap[j,k] in args
            else; img[j,k] = RGB{N0f8}(0.,0.,0.)
    end end end

    ima = make_transparent(img)
    save(img_fln[1:end-4] * "_highlight.png", ima)
    get_dummy("_highlight.png", img_fln, ima) end

function error_wrapper() end

function export_CSV(segs::SegmentedImage, dds::OrderedDict, spins::OrderedDict, checks::OrderedDict, img_fln::String, scale::Float64, scale_unit::String)
    df = DataFrame(
        segment_label=Int64[],
        segment_pixel_count=Int64[],
        area_estimate=Int64[],
        area_estimate_adjusted=Int64[],
        area_unit=String[],
        space_type=String[])
    csv_fln = "$(img_fln[1:end-4])_" * replace(replace("$(now())", "."=>"-"), ":"=>"-") * ".csv"

    for (label, px_ct) in collect(segment_pixel_count(segs))
        if label in keys(checks) && checks[label][]
            push!(df, [
                label,
                px_ct,
                ceil(px_ct/scale[1]),
                ceil((px_ct)/scale[1] + spins[label][]),
                scale_unit,
                dds[label][]]) end end

    write(csv_fln, df)
    return "Data exported to $csv_fln" end

function export_session_data(w::Window, s::Vector{Dict{Any,Any}}, xd=Dict())
    s_exp = deepcopy(s[end])
    s_exp["dds"] = Dict(k=>v[] for (k,v) in s_exp["dds"])
    s_exp["spins"] = Dict(k=>v[] for (k,v) in s_exp["spins"])
    s_exp["checks"] = Dict(k=>v[] for (k,v) in s_exp["checks"])
    img_name = split(s[end]["img_fln"][1:end-4], "\\")[end] # windows only?
    dt = string(now())[1:10]
    filename = "$(img_name)_$(dt).BSON"
    @save filename s_exp
    export_text = "Data exported to $(filename)!
Please email to dustin.irwin@cadmusgroup.com with subject: 'SpaceCadet session data'"
    @js_ w alert($export_text);
end
