ui = Dict(
    "img_filename" => filepicker("Choose image"),
    "go" => button("GO", attributes=Dict(
        "onclick"=>"""Blink.msg("go", [])""", "id"=>"go")),
    "param_algorithm" => dropdown(OrderedDict(
        "Felzenszwalb"=>felzenszwalb,
        "Fast Scanning"=>fast_scanning,
        "Unseeded Region Growing"=>unseeded_region_growing), attributes=Dict(
            "onblur"=>"""Blink.msg("dropdown_selected", [])""")),
    "mod_segs_algorithm" => dropdown(OrderedDict(
        "Prune Segments (MPGS)"=>prune_min_size,
        "Remove Segment(s)"=>remove_segments,
        "Merge Segments"=>merge_segments,), attributes=Dict(
            "onblur"=>"""Blink.msg("dropdown_selected", [])""")),
    "colorize" => checkbox("Colorize result?"),
    "input_1" => spinbox(0.0:0.1:9999, value=0.0),
    "segment_type" => dropdown(OrderedDict(
        "Building Support"=>"BS",
        "Process"=>"PR",
        "Public Access"=>"PA"), multiple=false, attributes=Dict(
            "onblur"=>"""Blink.msg("dropdown_selected", [])""")),
    "help_text" => Dict(
        fast_scanning=>"Input is the threshold value, range in {0, 1}.",
        felzenszwalb=>"Input is the k-value, typical range in {5, 500}.",
        unseeded_region_growing=>"Input is the threshold value, range {0, 1}.",
        prune_min_size=>"Removes any segment below the input minimum segment size in pixels.",
        remove_segments=>"Remove segments by label, separated by commas. eg 1, 3, 10, ...",
        merge_segments=>"Merge segments by label, separated by commas. eg 1, 3, 10, ..."
        ),
    "operations" => ["Parametric Segmentation", "Modify Segments", "Label Segments", "Export Data"],
    "img_tabs" => tabs(Observable(["Original Image", "Segmented Image", "Overlayed Image"]))
    )

ui["operations_tabs"] = tabs(Observable(ui["operations"]));
ui["toolset"] = vbox(
    hbox(hskip(0.75em),
        node(:div, ui["param_algorithm"], attributes=Dict(
            "id"=>"Parametric Segmentation toolset")),
        node(:div, ui["mod_segs_algorithm"], attributes=Dict(
            "id"=>"Modify Segments toolset", "hidden"=>true)),
        node(:div, ui["segment_type"], attributes=Dict(
            "id"=>"Label Segments toolset", "hidden"=>true)), hskip(0.75em),
        ui["input_1"], hskip(0.75em), ui["go"], hskip(0.5em), ui["colorize"], hskip(1em),
            node(:strong, node(:p, "", attributes=Dict("id"=>"segs_info")))),
    hbox(hskip(1em),
        node(:p, """$(ui["help_text"][ui["param_algorithm"][]])""", attributes=Dict(
            "id"=>"help_text", "style"=>"padding: 5px")), hskip(1em))
    );
ui["display_img"] = vbox(
    node(:div, ui["img_tabs"], attributes=Dict(
        "onclick"=>"""Blink.msg("img_tab_change", [])""", "id"=>"img_tabs", "hidden"=>true)),
    node(:div,
        node(:img, attributes=Dict(
            "id"=>"display_img", "src"=>"", "alt"=>"",
            "onclick"=>"""Blink.msg("img_click", [event.clientX, event.clientY]);""")),
        node(:img, attributes=Dict(
            "id"=>"overlay_img", "src"=>"", "alt"=>"",
            "style"=>"position: absolute; top: 0px; left: 0px; opacity: 0.5;")), attributes=Dict(
        "style"=>"position: relative;")),
    );
ui["html"] = node(:div,
    vbox(
        hbox(
            node(:div, ui["operations_tabs"], attributes=Dict(
                "id"=>"operation_tabs",
                "onclick"=>"""Blink.msg("op_tab_change", [])""")),
            hskip(1em),
            node(:div, ui["img_filename"], attributes=Dict(
                "onchange"=>"""Blink.msg("img_selected", [])"""))),
        vskip(1em),
        ui["toolset"],
        ui["display_img"],
    ));
