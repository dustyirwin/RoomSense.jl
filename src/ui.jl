ui = Dict(
    "font"=>newface("./fonts/OpenSans-Bold.ttf"),
    "font_size"=>30,
    "img_fln" => filepicker("Load Image"),
    "go" => button("Go!", attributes=Dict(
        "onclick"=>"""Blink.msg("go", null)""", "id"=>"go")),
    "set_scale_funcs" => dropdown(OrderedDict(
        "feet"=>(feet, "ft"),
        "meters"=>(meters, "m")), attributes=Dict(
            "onblur"=>"""Blink.msg("dropdown_selected", null)""")),
    "segs_funcs"=>dropdown(OrderedDict(
        "Felzenszwalb"=>(felzenszwalb, Int64),
        "Fast Scanning"=>(fast_scanning, Float64),
        "Seeded Region Growing"=>(seeded_region_growing, Vector{Tuple{CartesianIndex,Int64}})),
            attributes=Dict("onblur"=>"""Blink.msg("dropdown_selected", null)""")),
    "mod_segs_funcs"=>dropdown(OrderedDict(
        "Prune Segments by MGS"=>(prune_min_size, Vector{Int64}),
        "Prune Segment(s)"=>(remove_segments, String)), attributes=Dict(
            "onblur"=>"""Blink.msg("dropdown_selected", null)""")),
    "export_data_funcs"=>dropdown(OrderedDict(
        "Export to CSV"=>(export_CSV, String)), attributes=Dict(
            "onblur"=>"""Blink.msg("dropdown_selected", null)""")),
    "draw_labels"=>checkbox(value=false; label="Labels"),
    "draw_seeds"=>checkbox(value=true; label="Seeds"),
    "colorize"=>checkbox(value=false, label="Colorize"),
    "input"=>textbox("See instructions below...", attributes=Dict("size"=>"60")),
    "help_text"=>Dict(
        fast_scanning=>"Input is the threshold value, range in {0, 1}. Recursive: max_segs, mgs. e.g. '50, 2000'",
        felzenszwalb=>"Input is the k-value, typical range in {5, 500}. Recursive: max_segs, mgs. e.g. '50, 2000'",
        prune_min_size=>"Removes any segment below the input minimum group size (MGS) in ft or pixels. Enter 0 to re-label segment data.",
        remove_segments=>"Remove segment(s) by label and merge with most similar neighbor, separated by commas. e.g. 1, 3, 10, ... Leave blank reorder segments.",
        seeded_region_growing=>"Click on the image to create a segment seed at that location. Ctrl+click to increase seed number.",
        feet=>"Click on two points on the floorplan and enter the length in whole feet above. Separate multiple inputs with an ';' e.g. x1, x2, l1; ...",
        meters=>"Click on two points on the floorplan and enter the length in whole meters above. Separate multiple inputs with an ';' e.g. x1, x2, l1; ...",
        export_CSV=>"Exports segment data to CSV. To export specific segments, enter their labels, separated by commas."),
    "ops_tabs" => tabs(Observable(["Set Scale", "Segment Image", "Modify Segments", "Export Data"])),
    "img_tabs" => tabs(Observable(["<<", "Original", "Segmented", "Overlayed", "Info", ">>"])),
    "notifications" => notifications([], layout = node(:div)))

ui["toolbox"] = hbox(
    node(:div, ui["ops_tabs"], attributes=Dict(
        "id"=>"operation_tabs", "onclick"=>"""Blink.msg("op_tab_change", null)""")), hskip(1em),
    node(:div, ui["img_fln"], attributes=Dict(
        "onchange"=>"""Blink.msg("img_selected", []);""")), hskip(1em),
        node(:div, "", attributes=Dict("id"=>"img_info")), hskip(0.25em),
        node(:div, "", attributes=Dict("id"=>"scale_info")));

ui["toolset"] = node(:div,
    vbox(
        hbox(hskip(0.7em),
            node(:div, ui["set_scale_funcs"], attributes=Dict("id"=>"Set Scale toolset")),
            node(:div, ui["segs_funcs"], attributes=Dict("id"=>"Segment Image toolset", "hidden"=>true)),
            node(:div, ui["mod_segs_funcs"], attributes=Dict("id"=>"Modify Segments toolset", "hidden"=>true)),
            node(:div, ui["export_data_funcs"], attributes=Dict("id"=>"Export Data toolset", "hidden"=>true)), hskip(0.6em),
            ui["input"], hskip(0.6em), ui["go"], hskip(0.6em), vbox(
                vskip(0.3em),
                node(:strong, "", attributes=Dict("id"=>"segs_info")))),
        hbox(hskip(1em),
            node(:p, ui["help_text"][ui["segs_funcs"][][1]], attributes=Dict("id"=>"help_text", "style"=>"buffer: 5px;")))),
    attributes=Dict("id"=>"toolset", "hidden"=>true));

ui["display_options"] = node(:div,
    hbox(ui["img_tabs"], hskip(1.5em), vbox(
        vskip(0.4em), hbox(ui["draw_seeds"], ui["draw_labels"], ui["colorize"]))),
    attributes=Dict(
        "onclick"=>"""Blink.msg("img_tab_click", [])""",
        "id"=>"img_tabs", "hidden"=>true));

ui["display_imgs"] = vbox(
    node(:div,
        node(:img, attributes=Dict(
            "id"=>"display_img", "src"=>"", "alt"=>"", "style"=>"opacity: 0.9;")),
        node(:img, attributes=Dict(
            "id"=>"plot", "src"=>"", "alt"=>"", "style"=>"opacity: 1.0;")),
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
                event.ctrlKey,
                event.shiftKey,
                event.altKey]);""",
            "style"=>"position: relative; padding: 0px; border: 0px; margin: 0px;")));

ui["segs_details"] = node(:ul, attributes=Dict("id"=>"segs_details", "hidden"=>true));

ui["tools"] = vbox(
    ui["toolbox"],
    vskip(0.5em),
    ui["toolset"],
    ui["display_options"]);

ui["html"] = node(:div,
    node(:div, ui["tools"], attributes=Dict("position"=>"fixed")),
    ui["notifications"],
    node(:div, hbox(ui["display_imgs"], hskip(1em), ui["segs_details"]), attributes=Dict("position"=>"relative")),
    ui["notifications"])

ui["img_tabs"][] = "Original"
