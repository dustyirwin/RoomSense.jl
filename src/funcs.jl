
# terse funcs
make_segs_info(segs::SegmentedImage) = "Processed $(length(segs.segment_labels)) segments."
remove_segments(segs::SegmentedImage, args::Vector{Int64}) = prune_segments(segs, args, diff_fn_wrapper(segs))
make_transparent(img::Matrix, val=0.0, alpha=1.0) = [GrayA{Float16}(abs(val-e.val), abs(alpha-e.val)) for e in GrayA.(img)]
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

function make_labels_img(segs::SegmentedImage, draw_labels::Bool, font::Vector{Ptr{FreeType.FT_FaceRec}})
    overlay_img = Float16.(zeros(size(segs.image_indexmap)[1], size(segs.image_indexmap)[2]))
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
       #@js_ w document.getElementById("segs_info").innerHTML = $update;
   end
       return segs end

function parse_input(input::String, funcs_tab::String)
    input = replace(input, " "=>""); if input == ""; return 0 end

    if funcs_tab in ["Set Scale", "Segment Image"]
        args = Vector{Tuple{CartesianIndex{2},Int64}}()

        try for vars in split(input[end] == ';' ? input : input * ';', ';')
            var = length(vars) > 2 ? [parse(Int64, var) for var in split(vars, ',')] : continue
            push!(args, (CartesianIndex(var[1], var[2]), var[3])) end
        catch; var = [parse(Int64, var) for var in split(input, ',')]
            push!(args, (CartesianIndex(var[1], var[2]), var[3])) end

    elseif funcs_tab in ["Modify Segments"]
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

function launch_space_editor(segs::SegmentedImage, img::Matrix, img_fln::String, model::Chain)
    handle(sdw, "click_stdd") do args
        global s, w
        @show args
        img_deep = deepcopy(s[wi]["user_img"])
        hs = highlight_segs(segs, img_deep, img_fln, [args])
    end

    s[wi]["segs_types"] = ui["predict_space_type"][] ? get_segs_types(
        s[wi]["segs"], s[wi]["user_img"], model) : nothing

    if "segs_details_html" in collect(keys(s[wi])); else
    s[wi]["segs_details_html"], s[wi]["dds"], s[wi]["checks"], s[wi]["spins"] = make_segs_details(
        s[wi]["segs"], s[wi]["segs_types"], s[wi]["scale"][1], s[wi]["scale"][2],
        length(segment_labels(s[wi]["segs"]))) end end

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
        src="https://i1.sndcdn.com/avatars-000345228439-iwo1om-t500x500.jpg")

    node(:img,
        attributes=Dict(
            "id"=>img_name,
            "src"=>src,
            "style"=>"padding: 0px; border: 0px; margin: 0px;"),
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

const funcs = Dict(
    "User Image" => (w, args) -> begin
        scale = ceil(calc_scale(parse_input(args, "Set Scale")))
        s[i]["scale"][1] = scale
        ui[:img_info][] = node(:p, "width: $(s[i]["Original_width"]) height: $(s[i]["Original_height"]) scale: $scale px / ft²")
    end,
    "Google Maps" => (w, args) -> println("Pay Google da monies!"),
    "Fast Scanning" => (w, args) -> begin
        s[i]["segs"] = fast_scanning(Gray.(s[i]["Original_img"]), args)
        s[i]["segs_img"] = make_segs_img(s[i]["segs"], ui["Colorize"][])
        segs_fn = s[i]["Original_fn"][1:end-4] * "_segs.jpg"
        save(segs_fn, s[i]["segs_img"])
        ui["segs"][] = node(:img, src=register(segs_fn)) end,
    "Felzenszwalb" => (w, args) -> begin
        s[i]["segs"] = felzenszwalb(Gray.(s[i]["Original_img"]), args)
        s[i]["segs_img"] = make_segs_img(s[i]["segs"], ui["Colorize"][])
        segs_fn = s[i]["Original_fn"][1:end-4] * "_segs.jpg"
        save(segs_fn, s[i]["segs_img"])
        ui["segs"][] = node(:img, src=register(segs_fn)) end,
    "Seeded Region Growing" => (w, args) -> seeded_region_growing,
    "Prune Segments by MGS" => (w, args) -> prune_min_size,
    "Prune Segment" => (w, args) -> prune_segments,
    "Assign Space Types" => (w, args) -> launch_space_editor,
    "Export Data to CSV" => (w, args) -> export_CSV,
    )
