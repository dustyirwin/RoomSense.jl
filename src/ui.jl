
wi = 1  # work index
s = [Dict{Any,Any}(
    "current_img_tab"=>"Original",
    "prev_op_tab"=>"Set Scale",
    "scale"=>(1.,"ft",""),
    "selected_areas"=>Vector{Int64}())];

# WEB SECURTY SET TO OFF, DO NOT DEPLOY APP TO ANY WEBSERVER !!!
try close(w) catch end
w = Window(async=false, Dict("webPreferences"=>Dict("webSecurity"=>false)));
title(w, "SpaceCadet.jl v0.1"); size(w, 1100, 700);


ui = Dict(
    "font"=>newface("./fonts/OpenSans-Bold.ttf"),
    "font_size"=>30,
    "img_fln" => filepicker("Load Image"),
    "go" => button("GO!", attributes=Dict(
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
        "Prune Segments by MGS"=>(prune_min_size, Vector{Int64}, Float64),
        "Prune Segment(s)"=>(remove_segments, String)), attributes=Dict(
            "onblur"=>"""Blink.msg("dropdown_selected", null)""")),
    "export_data_funcs"=>dropdown(OrderedDict(
        "Export to CSV"=>(export_CSV, String)), attributes=Dict(
            "onblur"=>"""Blink.msg("dropdown_selected", null)""")),
    "draw_seeds"=>checkbox(value=true; label="Seeds"),
    "draw_labels"=>checkbox(value=false; label="Labels"),
    "colorize"=>checkbox(value=false, label="Colorize"),
    "predict_space_type"=>checkbox(value=false, label="SpacePred"),
    "input"=>textbox("See instructions below...", attributes=Dict("size"=>"60")),
    "help_text"=>Dict(
        fast_scanning=>"Input is the threshold value, range in {0, 1}. Recursive: max_segs, mgs. e.g. '50, 2000'",
        felzenszwalb=>"Input is the k-value, typical range in {5, 500}. Recursive: max_segs, mgs. e.g. '50, 2000'",
        prune_min_size=>"Removes any segment below the input minimum group size (MGS) in whole ft², m² or pixels.",
        remove_segments=>"Remove segment(s) by label and merge with most similar neighbor, separated by commas. e.g. 1, 3, 10, ... Leave blank reorder segments.",
        seeded_region_growing=>"Click image to create a segment seed at that location. Ctrl+click to increase, alt-click to decrease, the seed number.",
        feet=>"Click two points on floorplan and enter distance in whole feet above. Separate multiple inputs with an ';' e.g. x1, x2, l1; ...",
        meters=>"Click two points on floorplan and enter distance in whole meters above. Separate multiple inputs with an ';' e.g. x1, x2, l1; ...",
        export_CSV=>"Exports segment data to CSV."),
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
        hbox(hskip(0.6em),
            ui["go"], hskip(0.6em),
            node(:div, ui["set_scale_funcs"], attributes=Dict("id"=>"Set Scale toolset")),
            node(:div, ui["segs_funcs"], attributes=Dict("id"=>"Segment Image toolset", "hidden"=>true)),
            node(:div, ui["mod_segs_funcs"], attributes=Dict("id"=>"Modify Segments toolset", "hidden"=>true)),
            node(:div, ui["export_data_funcs"], attributes=Dict("id"=>"Export Data toolset", "hidden"=>true)), hskip(0.6em),
            node(:div, ui["input"], attributes=Dict("id"=>"input")), hskip(0.6em), vbox(vskip(0.2em),
            node(:strong, "", attributes=Dict("id"=>"segs_info")))),
        hbox(hskip(1em),
            node(:p, ui["help_text"][ui["segs_funcs"][][1]], attributes=Dict("id"=>"help_text", "style"=>"buffer: 5px;")))),
    attributes=Dict("id"=>"toolset", "hidden"=>false));

ui["display_options"] = node(:div,
    hbox(ui["img_tabs"],
        node(:p, "1", attributes=Dict("id"=>"wi", "style"=>"buffer: 5px;")), vbox(vskip(0.5em), 
        hbox(ui["draw_seeds"], ui["draw_labels"], ui["colorize"], ui["predict_space_type"]))),
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
    ui["notifications"],
    ui["toolset"],
    ui["display_options"],
    ui["notifications"]);

ui["html"] = node(:div,
    node(:div, ui["tools"], attributes=Dict(
        "classList"=>"navbar", "position"=>"fixed")),
    node(:div, hbox(ui["display_imgs"], hskip(1em), ui["segs_details"]), attributes=Dict(
        "class"=>"main", "position"=>"relative")));

ui["img_tabs"][] = "Original";


body!(w, ui["html"])
