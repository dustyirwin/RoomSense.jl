ui = Dict(
    "font"=>newface("./fonts/OpenSans-Regular.ttf"),
    "user_img_filename" => filepicker("Choose image"),
    "go" => button("Go!", attributes=Dict(
        "onclick"=>"""Blink.msg("go", null)""", "id"=>"go")),
    "segs_funcs" => dropdown(OrderedDict(
        "Fast Scanning"=>(fast_scanning, Float64),
        "Felzenszwalb"=>(felzenszwalb, Int64),
        "Unseeded Region Growing"=>(unseeded_region_growing, Float64)), attributes=Dict(
            "onblur"=>"""Blink.msg("dropdown_selected", null)""")),
    "mod_segs_funcs" => dropdown(OrderedDict(
        "Merge Segments"=>(merge_segments, String),
        "Remove Segment(s)"=>(remove_segments, String),
        "Remove Segments by MPGS"=>(prune_min_size, Int64),), attributes=Dict(
            "onblur"=>"""Blink.msg("dropdown_selected", null)""")),
    "draw_labels"=>checkbox(value=false; label="Draw labels?"),
    "colorize" => checkbox("Colorize result?"),
    "input" => textbox("See notes below..."),
    "segment_labels" => dropdown(OrderedDict(
        "Office"=>"OF",
        "Common Areas"=>"CA",
        "Building Support"=>"BS",
        "Process"=>"PR",
        "Public Access"=>"PA",
        "Storage"=>"ST",
        "Exterior"=>"XT",
        "Living Quarters"=>"LQ",
        "Unknown"=>"??"), multiple=false, attributes=Dict(
            "onblur"=>"""Blink.msg("dropdown_selected", null)""")),
    "help_text" => Dict(
        fast_scanning=>"Input is the threshold value, range in {0, 1}.",
        felzenszwalb=>"Input is the k-value, typical range in {5, 500}.",
        unseeded_region_growing=>"Input is the threshold value, range {0, 1}.",
        prune_min_size=>"Removes any segment below the input minimum pixel segment size (MPGS) in pixels.",
        remove_segments=>"Remove any segment(s) by label and merge with the least difference neighbor, separated by commas. e.g. 1, 3, 10, ...",
        merge_segments=>"Merge two segments by label, separated by commas. e.g. 1, 3",
        "recur_seg"=>" Recursive input: max_segs, mpgs. e.g. '50, 2000'"
        ),
    "operations" => ["Image Segmentation", "Modify Segments", "Label Segments", "Export Data"],
    "img_tabs" => tabs(Observable(["<<", "Original", "Segmented", "Overlayed", ">>"])))

ui["operations_tabs"] = tabs(Observable(ui["operations"]));

ui["options"] = hbox(ui["colorize"], ui["draw_labels"]);

ui["toolset"] = vbox(
    hbox(hskip(0.7em),
        node(:div, hbox(ui["segs_funcs"], hskip(0.6em), ui["input"], ui["options"]),
            attributes=Dict("id"=>"Image Segmentation toolset")),
    node(:div, hbox(ui["mod_segs_funcs"], hskip(0.6em), Widgets.tooltip!(ui["input"], "tooltip!"), ui["options"]),
            attributes=Dict("id"=>"Modify Segments toolset", "hidden"=>true)),
        node(:div, hbox(ui["segment_labels"], hskip(0.6em), ui["input"]),
            attributes=Dict("id"=>"Label Segments toolset", "hidden"=>true)), hskip(0.6em),
        node(:div, hbox(),
            attributes=Dict("id"=>"Export Data toolset", "hidden"=>true)),
        ui["go"]),
    hbox(hskip(1em),
        node(:div, hbox(
            node(:p, ui["help_text"][ui["segs_funcs"][][1]] * ui["help_text"]["recur_seg"], attributes=Dict("id"=>"help_text")), hskip(1em),
            node(:strong, node(:p, "", attributes=Dict("id"=>"segs_info")))), attributes=Dict(
                "style"=>"buffer: 5px;"
            ))));

ui["display_imgs"] = vbox(
    node(:div, ui["img_tabs"], attributes=Dict(
        "onclick"=>"""Blink.msg("img_tab_change", null)""",
        "id"=>"img_tabs", "hidden"=>true)),
    node(:div,
        node(:img, attributes=Dict(
            "id"=>"segs_img", "src"=>"", "alt"=>"", "style"=>"opacity: 0.9;",
            "onclick"=>"""Blink.msg("img_click", [event.clientX, event.clientY]);""")),
        node(:img, attributes=Dict(
            "id"=>"overlay_alpha", "src"=>"", "alt"=>"",
            "style"=>"position: absolute; top: 0px; left: 0px; opacity: 0.9;")),
        node(:img, attributes=Dict(
            "id"=>"overlay_labels", "src"=>"", "alt"=>"",
            "style"=>"position: absolute; top: 0px; left: 0px; opacity: 0.9;")), attributes=Dict(
        "style"=>"position: relative;")));

ui["html"] = node(:div,
    vbox(
        hbox(
            node(:div, ui["operations_tabs"], attributes=Dict(
                "id"=>"operation_tabs",
                "onclick"=>"""Blink.msg("op_tab_change", null)""")), hskip(1em),
            node(:div, ui["user_img_filename"], attributes=Dict(
                "onchange"=>"""Blink.msg("img_selected", null)"""))),
        vskip(1em),
        ui["toolset"],
        hbox(ui["display_imgs"]), hskip(0.75em), node(:p, "", attributes=Dict("id"=>"segs_details"))));
