ui = Dict(
    "font"=>newface("./fonts/OpenSans-Bold.ttf"),
    "img_filename" => filepicker("Choose image"),
    "go" => button("Go!", attributes=Dict(
        "onclick"=>"""Blink.msg("go", null)""", "id"=>"go")),
    "segs_funcs" => dropdown(OrderedDict(
        "Seeded Region Growing"=>(seeded_region_growing, Vector{Tuple{CartesianIndex,Int64}}),
        "Fast Scanning"=>(fast_scanning, Float64),
        "Felzenszwalb"=>(felzenszwalb, Int64)), attributes=Dict(
            "onblur"=>"""Blink.msg("dropdown_selected", null)""")),
    "mod_segs_funcs" => dropdown(OrderedDict(
        "Remove Segments by MPGS"=>(prune_min_size, Int64),
        "Remove Segment(s)"=>(remove_segments, String),
        "Merge Segments"=>(merge_segments, String)), attributes=Dict(
            "onblur"=>"""Blink.msg("dropdown_selected", null)""")),
    "export_data_funcs" => dropdown(OrderedDict(
        "Calculate areas"=>(calculate_areas, Float64),
        "Export to Excel"=>(export_xlsx, String)), attributes=Dict(
            "onblur"=>"""Blink.msg("dropdown_selected", null)""")),
    "draw_labels"=>checkbox(value=true; label="Draw labels"),
    "draw_seeds"=>checkbox(value=false; label="Draw seeds"),
    "draw_plot"=>checkbox(value=false; label="Draw plots"),
    "colorize" => checkbox("Colorize result"),
    "input" => textbox("See instructions below...", attributes=Dict("size"=>"40")),
    "segment_tags" => dropdown(OrderedDict(
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
        seeded_region_growing=>"Click on the image to create a segment seed at that location. Ctrl+click to increase seed number.",
        calculate_areas=>"Click on two points within the image and enter the numerical distance between them. eg 100, 175; 350, 550; 100"),
    "operations" => ["Segment Image", "Modify Segments", "Tag Segments", "Export Data"],
    "img_tabs" => tabs(Observable(["<<", "Original", "Segmented", "Overlayed", ">>"])))

ui["operations_tabs"] = tabs(Observable(ui["operations"]));

ui["toolbox"] = hbox(
    node(:div, ui["operations_tabs"], attributes=Dict(
        "id"=>"operation_tabs",
        "onclick"=>"""Blink.msg("op_tab_change", null)""")), hskip(1em),
    node(:div, ui["img_filename"], attributes=Dict(
        "onchange"=>"""Blink.msg("img_selected", []);""")), hskip(1em),
    vbox(vskip(0.4em), node(:div, "", attributes=Dict("id"=>"img_info"))));

ui["toolset"] = vbox(
    hbox(hskip(0.7em),
        node(:div, ui["segs_funcs"], attributes=Dict("id"=>"Segment Image toolset")),
        node(:div, ui["mod_segs_funcs"], attributes=Dict("id"=>"Modify Segments toolset", "hidden"=>true)),
        node(:div, ui["export_data_funcs"], attributes=Dict("id"=>"Export Data toolset", "hidden"=>true)),
        node(:div, ui["segment_tags"], attributes=Dict("id"=>"Tag Segments toolset", "hidden"=>true)), hskip(0.6em),
        ui["input"], hskip(0.6em), ui["go"]),
    hbox(hskip(1em),
        node(:div, hbox(
            node(:p, ui["help_text"][ui["segs_funcs"][][1]], attributes=Dict("id"=>"help_text")), hskip(1em),
            node(:strong, "", attributes=Dict("id"=>"segs_info"))), attributes=Dict(
                "style"=>"buffer: 5px;"
    ))));

ui["display_options"] = node(:div,
    hbox(ui["img_tabs"], hskip(1.5em), vbox(
        vskip(0.4em), hbox(ui["draw_labels"], ui["draw_seeds"], ui["colorize"], ui["draw_plot"]))),
    attributes=Dict(
        "onclick"=>"""Blink.msg("img_tab_click", null)""",
        "id"=>"img_tabs", "hidden"=>true));

ui["display_imgs"] = vbox(
    node(:div,
        node(:img, attributes=Dict(
            "id"=>"display_img", "src"=>"", "alt"=>"", "style"=>"opacity: 0.9;")),
        node(:img, attributes=Dict(
            "id"=>"overlay_alpha", "src"=>"", "alt"=>"",
            "style"=>"position: absolute; top: 0px; left: 0px; opacity: 1.0;")),
        node(:img, attributes=Dict(
            "id"=>"overlay_labels", "src"=>"", "alt"=>"",
            "style"=>"position: absolute; top: 0px; left: 0px; opacity: 1.0;")),
        node(:img, attributes=Dict(
            "id"=>"overlay_seeds", "src"=>"", "alt"=>"",
            "style"=>"position: absolute; top: 0px; left: 0px; opacity: 1.0;")),
        attributes=Dict(
            "id"=>"img_container",
            "onclick"=>"""Blink.msg("img_click", [
                event.pageY - document.getElementById("img_container").offsetTop,
                event.pageX,
                document.getElementById("display_img").height,
                document.getElementById("display_img").width,
                document.getElementById("display_img").naturalHeight,
                document.getElementById("display_img").naturalWidth,
                event.ctrlKey]);""",
            "style"=>"position: relative; padding: 0px; border: 0px; margin: 0px;")));

ui["segs_details"] = vbox(vskip(1em),
    node(:img, attributes=Dict("id"=>"plot", "src"=>"", "alt"=>"")), vskip(1em),
    node(:ul, attributes=Dict("id"=>"segs_details")));

ui["html"] = vbox(
    ui["toolbox"],
    vskip(0.75em),
    ui["toolset"],
    ui["display_options"],
    hbox(
        ui["display_imgs"], hskip(1em), ui["segs_details"]),
    );
