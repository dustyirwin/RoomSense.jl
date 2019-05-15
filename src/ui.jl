ui = Dict(
    "font"=>newface("./fonts/OpenSans-Bold.ttf"),
    "user_img_filename" => filepicker("Choose image"),
    "go" => button("Go!", attributes=Dict(
        "onclick"=>"""Blink.msg("go", null)""", "id"=>"go")),
    "segs_funcs" => dropdown(OrderedDict(
        "Fast Scanning"=>(fast_scanning, Float64),
        "Felzenszwalb"=>(felzenszwalb, Int64),
        "Seeded Region Growing"=>(seeded_region_growing, Vector{Tuple{CartesianIndex,Int64}})), attributes=Dict(
            "onblur"=>"""Blink.msg("dropdown_selected", null)""")),
    "mod_segs_funcs" => dropdown(OrderedDict(
        "Remove Segments by MPGS"=>(prune_min_size, Int64),
        "Remove Segment(s)"=>(remove_segments, String),
        "Merge Segments"=>(merge_segments, String)), attributes=Dict(
            "onblur"=>"""Blink.msg("dropdown_selected", null)""")),
    "draw_labels"=>checkbox(value=false; label="Draw labels?"),
    "create_plot"=>checkbox(value=false; label="Draw plot?"),
    "colorize" => checkbox("Colorize result?"),
    "input" => textbox("See instructions below...", attributes=Dict("size"=>"30")),
    "segment_labels" => dropdown(OrderedDict(
        "Office"=>"OF",
        "Common Areas"=>"CA",
        "Building Support"=>"BS",
        "Process"=>"PR",
        "Public Access"=>"PA",
        "Storage"=>"ST",
        "Exterior"=>"XT",
        "Living Quarters"=>"LQ",
        "Unknown"=>"??",
        "Custom"=>""), multiple=false, attributes=Dict(
            "onblur"=>"""Blink.msg("dropdown_selected", null)""")),
    "help_text" => Dict(
        fast_scanning=>"Input is the threshold value, range in {0, 1}. Recursive: max_segs, mpgs. e.g. '50, 2000'",
        felzenszwalb=>"Input is the k-value, typical range in {5, 500}. Recursive: max_segs, mpgs. e.g. '50, 2000'",
        prune_min_size=>"Removes any segment below the input minimum pixel group size (MPGS) in pixels.",
        remove_segments=>"Remove any segment(s) by label and merge with the least difference neighbor, separated by commas. e.g. 1, 3, 10, ...",
        merge_segments=>"Merge segments by label, separated by commas. e.g. 1, 3, 4",
        seeded_region_growing=>"Click on the image to create a segment seed at that location."),
    "operations" => ["Segment Image", "Modify Segments", "Label Segments", "Export Data"],
    "img_tabs" => tabs(Observable(["<<", "Original", "Segmented", "Overlayed", ">>"])))

ui["operations_tabs"] = tabs(Observable(ui["operations"]));

ui["options"] = hbox(ui["colorize"], ui["draw_labels"], ui["create_plot"]);

ui["toolset"] = vbox(
    hbox(hskip(0.7em),
        node(:div, ui["segs_funcs"], attributes=Dict("id"=>"Segment Image toolset")),
        node(:div, ui["mod_segs_funcs"], attributes=Dict("id"=>"Modify Segments toolset", "hidden"=>true)),
        node(:div, ui["segment_labels"], attributes=Dict("id"=>"Label Segments toolset", "hidden"=>true)), hskip(0.6em),
        node(:div, hbox(), attributes=Dict("id"=>"Export Data toolset", "hidden"=>true)),
        ui["input"], ui["go"], ui["options"]),
    hbox(hskip(1em),
        node(:div, hbox(
            node(:p, ui["help_text"][ui["segs_funcs"][][1]], attributes=Dict("id"=>"help_text")), hskip(1em),
            node(:strong, "", attributes=Dict("id"=>"segs_info"))), attributes=Dict(
                "style"=>"buffer: 5px;"
            ))));

ui["display_imgs"] = vbox(
    node(:div, ui["img_tabs"], attributes=Dict(
        "onclick"=>"""Blink.msg("img_tab_change", null)""",
        "id"=>"img_tabs", "hidden"=>true)),
    node(:div,
        node(:img, attributes=Dict(
            "id"=>"display_img", "src"=>"", "alt"=>"", "style"=>"opacity:0.9;")),
        node(:img, attributes=Dict(
            "id"=>"overlay_alpha", "src"=>"", "alt"=>"",
            "style"=>"position: absolute; top: 0px; left: 0px; opacity: 1.0;")),
        node(:img, attributes=Dict(
            "id"=>"overlay_labels", "src"=>"", "alt"=>"",
            "style"=>"position: absolute; top: 0px; left: 0px; opacity: 1.0;")),
        attributes=Dict(
            "id"=>"img_container",
            "onclick"=>"""Blink.msg("img_click", [
                event.pageY - document.getElementById("img_container").offsetTop,
                event.pageX,
                document.getElementById("display_img").height,
                document.getElementById("display_img").width,
                document.getElementById("display_img").naturalHeight,
                document.getElementById("display_img").naturalWidth]);""",
            "style"=>"position: relative; padding:0px; border:0px; margin:0px;")));

ui["segs_details"] = hbox(hskip(1em),
    node(:img, attributes=Dict("id"=>"plot", "src"=>"", "alt"=>"")), hskip(1em),
    node(:ul, attributes=Dict("id"=>"segs_details")));

ui["html"] = node(:div,
    vbox(
        hbox(
            node(:div, ui["operations_tabs"], attributes=Dict(
                "id"=>"operation_tabs",
                "onclick"=>"""Blink.msg("op_tab_change", null)""")), hskip(1em),
            node(:div, ui["user_img_filename"], attributes=Dict(
                "onchange"=>"""Blink.msg("img_selected", []);""")), hskip(1em),
            node(:div, "", attributes=Dict("id"=>"img_info"))),
        vskip(0.75em),
        ui["toolset"],
        ui["display_imgs"],
        ui["segs_details"])
    );
