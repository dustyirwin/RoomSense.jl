
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

function make_labels_img(session::Dict, segs::SegmentedImage)
    s=session[:s]; i=session[:i]; ui=session[:ui];
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

function export_CSV(session::Dict)
    s=session[:s]; i=session[:i]; ui=session[:ui];
    df = DataFrame(
        segment_label=Int64[],
        segment_pixel_count=Int64[],
        area_estimate=Int64[],
        area_unit=String[],
        space_type=String[])

    csv_fn = "$(s[i][:user_fn][1:end-4])_" *
        replace(replace("$(now())", "."=>"-"), ":"=>"-") * ".csv"

    for (label, px_ct) in s[i][:segs].segment_pixel_count
        push!(df, [
            label,
            px_ct,
            ceil(px_ct / s[i][:scale][1]),
            ui["Units"][],
            try s[i][:space_types][label] catch; "Unassigned" end,
            ])
        end

    write(csv_fn, df)
    s[i][:csv_df] = df
    return csv_fn end

function export_session_data(session::Dict)
    s=session[:s];
    s_end = deepcopy(s[end])
    user_trunc = s_end[:user_fn][7:end-4]
    dt = "$(now())"[1:10]
    fn = "./exports/$(user_trunc)_$(dt).BSON"
    @save fn s_end
    return fn end

function get_img_from_url(img_url_raw::String)
    img_url_cleaned = img_url_raw[end] == "0" ? img_url_raw[1:end-1] * "1" : img_url_raw
    fn = "assets/" * split(img_url_cleaned, "/")[end][1:end-5]
    download(img_url_cleaned, fn)
    return fn end

function make_clickable_img(
    img_name::String,
    img_click::Observable{Array{Union{Int,Bool},1}},
    src=register("./assets/cadet.png");
    alt="Cadet logo image from: https://i1.sndcdn.com/avatars-000345228439-iwo1om-t500x500.jpg",
    opacity=0.9)

    node(:img,
        attributes=Dict(
            "id"=>img_name,
            "src"=>src,
            "style"=>"position:absolute; opacity:$opacity;"),
        events=Dict(
            "click" => @js () -> $img_click[] = [
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
            ),
    ) end

function update_highlight_img(session::Dict, deep_img::Matrix)
    s=session[:s]; ui=session[:ui]; i=session[:i];
    if !haskey(s[i], :highlight_fn); s[i][:highlight_fn] = s[i][:user_fn][1:end-4] * "_highlight.png" end
    selected_spaces = [k for (k,v) in s[i][:selected_spaces] if !(v isa Missing)]

    for j in 1:height(deep_img)
        for k in 1:width(deep_img)
            if s[i][:segs].image_indexmap[j,k] in selected_spaces
            else; deep_img[j,k] = RGB{N0f8}(0.,0.,0.)
            end end end

    s[i][:highlight_img] = make_transparent(deep_img)
    save(s[i][:highlight_fn], s[i][:highlight_img])
    ui[:highlight_img][] = make_clickable_img("highlight_img", ui[:img_click],
        register(s[i][:highlight_fn])*"?dummy=$(now())", opacity=0.7)
    end

function update_segs_img(session::Dict)
    s=session[:s]; i=session[:i]; ui=session[:ui];

    s[i][:segs_img] = make_segs_img(s[i][:segs], ui["Colorize"][])
    s[i][:segs_fn] = s[i][:user_fn][1:end-4] * "_segs.png"
    save(s[i][:segs_fn], s[i][:segs_img])
    ui[:segs_img][] = make_clickable_img("segs_img",
        ui[:img_click], register(s[i][:segs_fn]) * "?dummy=$(now())")
    ui[:img_tabs][] = "Segmented"
    end

function go_seg_img(session::Dict, args::Any, alg::Function)
    s=session[:s]; ui=session[:ui]; i=session[:i];
    println("creating segs img! alg: $alg args: $args")
    s[i][:segs] = alg(Gray.(s[i][:user_img]), args)
    update_segs_img(session)
    end

function go_mod_segs(session::Dict, args::Int64, alg::Function)
    ui=session[:ui]; i=session[:i]; s=session[:s]
    println("modifying segs img! alg: $alg args: $args")
    s[i][:segs] = alg(s[i][:segs], args, s[i][:scale][1])
    update_segs_img(session)
    end

function update_labels_img(session::Dict)
    s=session[:s]; ui=session[:ui]; i=session[:i];
    s[i][:labels_img] = make_labels_img(session, s[i][:segs])
    s[i][:labels_fn] = s[i][:user_fn][1:end-4] * "_labels.png"
    save(s[i][:labels_fn], s[i][:labels_img])
    ui[:labels_img][] = make_clickable_img(
        "labels_img", ui[:img_click], register(s[i][:labels_fn])*"?dummy=$(now())")
    end

function make_img_slices(segs::SegmentedImage, img::Matrix, img_slices=Dict())
    bs = get_segment_bounds(segs)

    for i in segment_labels(segs)
        img_slice = try img[bs[i]["t"]:bs[i]["b"], bs[i]["l"]:bs[i]["r"]]
                    catch; missing end
        if length(img_slice[1,:]) > 1 && length(img_slice[:,1]) > 1
            img_slice32 = Float32.(imresize(img_slice, (128,128)))
            img_slices[i] = img_slice32
        end end
    return img_slices
    end

function get_space_type(session::Dict, label::Int64, model)
    s=session[:s]; i=session[:i]; ui=session[:ui]
    model |> gpu
    bs = get_segment_bounds(s[i][:segs])
    img_slice = s[i][:img_slices][label]

    img_slice |> gpu
    w = width(img_slice)
    h = height(img_slice)
    pred_vec = model(reshape(img_slice, (w,h,1,1)))
    max_pred = findmax(pred_vec)

    # confidence level of prediction
    s[i][:preds][label] = [pred_vec, img_slice]
    s[i][:space_types][label] = ui[:space_types][max_pred[2]]
    end

function write_zip(session::Dict)
    s=session[:s]; ui=session[:ui]; i=session[:i]
    zip_fn = "./exports/" * s[i][:user_fn][7:end-4] * "_space_cadet_data.zip"
    s[i][:csv_fn] = export_CSV(session)

    create_zip(zip_fn, Dict(
        s[i][:csv_fn][7:end] => read(s[i][:csv_fn]),
        s[i][:segs_fn][7:end] => read(s[i][:segs_fn]),
        s[i][:labels_fn][7:end] => read(s[i][:labels_fn]),
        s[i][:overlay_fn][7:end] => read(s[i][:overlay_fn]),
        # s[i][:seeds_fn]=> load(s[i][:seeds_fn]),
        ))
    return zip_fn end

const go_funcs = Dict(
    "User Image" => (session::Dict, args::Float64) -> begin
        s=session[:s]; i=session[:i]; ui=session[:ui]
        s[i][:scale][2] = push!(ceil(calc_scale(args)))
        ui[:img_info][] = node(:p,
            "width: $(s[i][:user_width]) height: $(
                s[i][:user_height]) scale: $(s[i][:scale][1]) pxs / $(ui["Units"][])²")
        end,
    "Google Maps" => (session::Dict, args::Any) -> session[:ui][:gmap][] = gmap(args),
    "Fast Scanning" => (session::Dict, args::Float64) -> go_seg_img(
        session, args, fast_scanning),
    "Felzenszwalb" => (session::Dict, args::Int64) -> go_seg_img(
        session, args, felzenszwalb),
    "Seeded Region Growing" => (session::Dict, args::String) -> go_seg_img(
        session, parse_input_str(args), seeded_region_growing),
    "Prune Segments by MGS" => (session::Dict, args::Int64) -> go_mod_segs(
        session, args, prune_min_size),
    "Prune Segment(s)" => (session::Dict, args::String) -> go_seg_img(
        session, args, prune_segments),
    "Assign Space Types" => (session::Dict, args::Int64) -> begin
        s=session[:s]; ui=session[:ui]; i=session[:i]

        if ui["CadetPred"][]
            txt = "SpaceCadet will now ignore user inputs and attempt to detect space types automatically. This feature is highly experimental and under construction. Continue?"
            ui[:confirm](txt) do resp
                if !resp; return end
                if !haskey(s[i], :img_slices)
                    s[i][:img_slices] = make_img_slices(s[i][:segs], s[i][:user_img]) end
            end end

            for (label, size) in s[i][:selected_spaces]
                s[i][:space_types][label] = ui["CadetPred"][] ? try
                    get_space_type(session, label, sn_g50) catch
                    "CadetPredError1" end : ui[:space_types][args]
                end
        update_highlight_img(session, deepcopy(s[i][:user_img]))
        ui[:alert]("Assigned space types:\n$(join([ "$k: $v\n" for (k,v) in
            s[i][:space_types] if k in keys(s[i][:selected_spaces]) ]))"
            ) end,
    "Download Data as ZIP" => (session::Dict, args::Any) -> begin
        ui=session[:ui]; s=session[:s]; i=session[:i];

        ui["Labels"][] = true
        ui["Overlay"][] = true
        @async export_session_data(session)

        zip_fn = write_zip(session)
        link = register(zip_fn)
        txt = "Thank you for using Space Cadet! Please email questions and comments to dustin.irwin@cadmusgroup.com"
        ui["Labels"][] = false
        ui["Overlay"][] = false
        ui[:alert](txt)
        ui[:information][] = node(:a, "CLICK HERE TO DOWNLOAD ZIP", href=link);
        end,
    )
