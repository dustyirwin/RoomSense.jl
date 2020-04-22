
# terse funcs
make_segs_info(segs::SegmentedImage) = "Processed $(length(segs.segment_labels)) segments."

remove_segments(segs::SegmentedImage, args::Vector{Int64}) = prune_segments(segs, args, diff_fn_wrapper(segs))

make_transparent(img::Matrix, val=0.0, alpha=1.0) = [GrayA{Float16}(abs(val-e.val), abs(alpha-e.val)) for e in GrayA.(img)]


# verbose funcs
function diff_fn_wrapper(segs::SegmentedImage)
    diff_fn = (rem_label, neigh_label) -> segment_pixel_count(segs, rem_label) - segment_pixel_count(segs, neigh_label) end

function get_random_color(seed::Int64)
    seed!(seed)
    rand(RGB{N0f8}) end

function prune_min_size(segs::SegmentedImage, min_size::Int64, scale::Float64, prune_list=Vector{Int64}())
    for (k, v) in segs.segment_pixel_count
        if scale != 1;
            v / scale < min_size ? push!(prune_list, k) : continue
        elseif v < min_size
            push!(prune_list, k) end end
    return prune_segments(segs, prune_list, diff_fn_wrapper(segs)) end

function make_segs_img(segs::SegmentedImage, colorize::Bool)
    if colorize == true; map(i->get_random_color(i), labels_map(segs))
    else; map(i->segment_mean(segs, i), labels_map(segs)) end end

function make_labels_img(segs::SegmentedImage)
    labels_img = Float16.(zeros(size(segs.image_indexmap)[1], size(segs.image_indexmap)[2]))

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
            labels_img, "$label", ui[:font], ui[:font_size], x_centroid, y_centroid,
            halign=:hcenter, valign=:vcenter) end

    return make_transparent(labels_img, 1.0, 0.0) end

function make_seeds_img(seeds::Vector{Tuple{CartesianIndex{2},Int64}}, height::Int64, width::Int64)
    seeds_img = zeros(height, width)
    for seed in seeds
        renderstring!(
            seeds_img, "$(seed[2])", ui[:font], ui[:font_size],
            seed[1][1], seed[1][2], halign=:hcenter, valign=:vcenter) end
    return make_transparent(seeds_img, 1.0, 0.0) end

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
   end
       return segs end

function parse_input_str(input::String)
    input = replace(input, " "=>""); if input == ""; return 0 end
    args = Vector{Tuple{CartesianIndex{2},Int64}}()

    try for vars in split(input[end] == ';' ? input : input * ';', ';')
        var = length(vars) > 2 ? [parse(Int64, var) for var in split(vars, ',')] : continue
        push!(args, (CartesianIndex(var[1], var[2]), var[3])) end
    catch; var = [parse(Int64, var) for var in split(input, ',')]
        push!(args, (CartesianIndex(var[1], var[2]), var[3]))
    end

    return args end

function calc_scale(scales::Vector{Tuple{CartesianIndex{2},Int64}})
    pxs_per_unit_lengths = Vector{Float64}()

    for args in scales
        d = abs(args[1][2] - args[1][1]) / args[2]
        push!(pxs_per_unit_lengths, d) end

    avg_pxs_per_unit_length = sum(pxs_per_unit_lengths) / length(pxs_per_unit_lengths)
    return avg_pxs_per_unit_length^2 end

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

function make_highlight_img(segs::SegmentedImage, img::Matrix, seg_labels::Vector)
    for j in 1:height(img)
        for k in 1:width(img)
            if segs.image_indexmap[j,k] in seg_labels
            else; img[j,k] = RGB{N0f8}(0.,0.,0.)
    end end end

    save(s[i][:original_fn][1:end-4] * "_highlight.png", make_transparent(img))
    return register(img_fln[1:end-4] * "_highlight.png") * "?dummy=$(now())" end

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

function export_session_data(s::Vector{Dict{Any,Any}}, xd=Dict())
    s_exp = deepcopy(s[end])
    s_exp["dds"] = Dict(k=>v[] for (k,v) in s_exp["dds"])
    s_exp["spins"] = Dict(k=>v[] for (k,v) in s_exp["spins"])
    s_exp["checks"] = Dict(k=>v[] for (k,v) in s_exp["checks"])
    img_name = split(s[end]["img_fln"][1:end-4], "\\")[end]
    dt = string(now())[1:10]
    filename = "$(img_name)_$(dt).BSON"
    @save filename s_exp
    export_text = "Data exported to $(filename).
 Please email BSON file to dustin.irwin@cadmusgroup.com with subject: 'SpaceCadet session data'. Thanks!" end

function launch_space_editor(segs::SegmentedImage, img::Matrix, img_fln::String, model)
    on(sdw, "click_stdd") do args
        global s
        @show args
        img_deep = deepcopy(s[i][:user_img])
        hs = highlight_segs(segs, img_deep, img_fln, [args])
    end

    ui["Cadet Pred"][] ? get_segs_types(s[i][:segs], s[i][:user_img], model) : nothing

    if :segs_details_html in keys(s[i]); else
    s[i][:segs_details_html], s[i][:dds], s[i][:checks], s[i][:spins] = make_segs_details(
        s[i][:segs], s[i][:segs_types], s[i][:scale][1], s[i][:scale][2],
        length(s[i][:segs].segment_labels)) end end

function make_segs_details(segs::SegmentedImage, segs_types::Union{Dict, Nothing}, scale::Float64, scale_units::String, segs_limit::Int64)
    segs_details = sort!(collect(segs.segment_pixel_count), by=x -> x[2], rev=true)
    segs_details = length(segs_details) > segs_limit ? segs_details[1:segs_limit] : segs_details  # restricted to the Top 100 elements by size

    area_sum = sum([pixel_count / scale for (label, pixel_count) in segs.segment_pixel_count])
    summary_text = hbox(
        "Total Area: $(ceil(area_sum)) $(scale == 1 ? "pxs" : scale_units) Total Segs: $(length(segment_labels(segs))) (Top $segs_limit)")

    dds = OrderedDict(lbl => dropdown(dd_opts, value=try segs_types[lbl] catch; "" end, label="""
        $lbl - $(scale > 1 ? ceil(px_ct / scale) : px_ct) $scale_units""", attributes=Dict(
            "onclick"=>"""Blink.msg("click_stdd", $lbl)"""))
        for (lbl, px_ct) in segs_details)
    checks = OrderedDict(lbl => checkbox(label="Export?", value=true) for (lbl, px_ct) in segs_details)
    spins = OrderedDict(lbl => spinbox(-100:100, value=0, label="Area +/-") for (lbl, px_ct) in segs_details)

    details = [node(:div, hbox(dds[lbl], vbox(vskip(1.5em), spins[lbl]), vbox(vskip(2em), checks[lbl])))
        for (lbl, px_ct) in segs_details]

    html = hbox(hskip(0.75em), vbox(node(:p, summary_text) , vbox(details)))
    return html, dds, checks, spins end

function get_img_from_url(img_url_raw::String)
    img_url_cleaned = img_url_raw[end] == "0" ? img_url_raw[1:end-1] * "1" : img_url_raw
    fn = "assets/" * split(img_url_cleaned, "/")[end][1:end-5]
    download(img_url_cleaned, fn)
    return fn end

function make_clickable_img(
        img_name::String,
        img_click::Observable{Array{Union{Int,Bool},1}},
        src="https://i1.sndcdn.com/avatars-000345228439-iwo1om-t500x500.jpg",
        opacity=0.9)

    node(:img,
        attributes=Dict(
            "id"=>img_name,
            "src"=>src,
            "style"=>"position:absolute; opacity:$opacity;"),
        events=Dict("click" => @js () -> $img_click[] = [
            event.pageY - document.getElementById($img_name).offsetTop,
            event.pageX,
            document.getElementById($img_name).height,
            document.getElementById($img_name).width,
            document.getElementById($img_name).naturalHeight,
            document.getElementById($img_name).naturalWidth,
            event.ctrlKey,
            event.shiftKey,
            event.altKey,
            ];
    )) end

function gmap(w=640, h=640, zoom=17, lat=45.3463, lng=-122.5931)
    node(:iframe,
        width="$w",
        height="$h",
        frameborder="0",
        style=Dict("border"=>"0"),
        src="https://www.google.com/maps/embed/v1/view?"*
            "zoom=$zoom&"*
            "center=$lat,$lng&"*
            "key=$maps_api_key&"
    ) end

function update_segs_img(ui::Dict)
    s[i][:segs_img] = make_segs_img(s[i][:segs], ui["Colorize"][])
    s[i][:segs_fn] = s[i][:original_fn][1:end-4] * "_segs.png"
    save(s[i][:segs_fn], s[i][:segs_img])
    ui[:segs_img][] = make_clickable_img(
        "segs_img", ui[:img_click], register(s[i][:segs_fn])*"?dummy=$(now())")
    ui[:img_tabs][] = "Segmented"; ui["Labels"][] = false
    end

function go_seg_img(ui::Dict, args::Any, alg::Function)
    println("creating segs img! alg: $alg args: $args")
    s[i][:segs] = alg(Gray.(s[i][:original_img]), args)
    update_segs_img(ui)
    end

function go_mod_segs(ui::Dict, args::Int64, alg::Function)
    println("modifying segs img! alg: $alg args: $args")
    s[i][:segs] = alg(s[i][:segs], args, s[i][:scale][1])
    update_segs_img(ui)
    end

function go_make_labels(ui::Dict)
    s[i][:labels_img] = make_labels_img(s[i][:segs])
    s[i][:labels_fn] = s[i][:original_fn][1:end-4] * "_labels.png"
    save(s[i][:labels_fn], s[i][:labels_img])
    ui[:labels_img][] = make_clickable_img(
        "labels_img", ui[:img_click], register(s[i][:labels_fn])*"?dummy=$(now())")
    end

const f = Dict()

const go_funcs = Dict(
    "User Image" => (ui::Dict, args::String) -> begin
        s[i][:scale][1] = ceil(calc_scale(parse_input_str(args)))
        ui[:img_info][] = node(:p,
            "width: $(s[i][:original_width]) height: $(s[i][:original_height]) scale: $(s[i][:scale][1]) pxs / unit area")
        end,
    "Google Maps" => (ui::Dict, args::Any) -> println("Pay Google da monies!"),
    "Fast Scanning" => (ui::Dict, args::Float64) -> go_seg_img(
        ui, args, fast_scanning),
    "Felzenszwalb" => (ui::Dict, args::Int64) -> go_seg_img(
        ui, args, felzenszwalb),
    "Seeded Region Growing" => (ui::Dict, args::String) -> go_seg_img(
        ui, parse_input_str(args), seeded_region_growing),
    "Prune Segments by MGS" => (ui::Dict, args::Int64) -> go_mod_segs(
        ui, args, prune_min_size),
    "Prune Segment" => (ui::Dict, args::Any) -> go_seg_img(
        ui, args, prune_segments),
    "Assign Space Types" => (ui::Dict, args::Any) -> begin
        launch_space_editor()
        end,
    "Export Data to CSV" => (ui::Dict, args::Any) -> begin
        export_CSV()
        end,
)
