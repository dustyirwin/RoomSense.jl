wi = 1  # work index

s = [Dict{Any,Any}(
    "current_img_tab"=>"Original",
    "prev_op_tab"=>"Set Scale",
    "scale"=>(1.,"ft",""),
    "segs_types"=>nothing,
    "selected_areas"=>Vector{Int64}())];


function launch_space_editor(w::Window, segs::SegmentedImage, img::Matrix, img_fln::String, model)
    sdw = Window()
    size(sdw, 750, 850); title(sdw, "Space Type Editor")

    handle(sdw, "click_stdd") do args
        global s, w
        @show args
        img_deep = deepcopy(s[wi]["user_img"])
        hs = highlight_segs(segs, img_deep, img_fln, [args])
        @js_ w document.getElementById("highlight_segment").hidden = false;
        @js_ w document.getElementById("highlight_segment").src = $hs; end

    s[wi]["segs_types"] = ui["predict_space_type"][] ? get_segs_types(s[wi]["segs"], s[wi]["img_fln"], model) : nothing
    s[wi]["segs_details_html"], s[wi]["dds"], s[wi]["checks"], s[wi]["spins"] = make_segs_details(
        s[wi]["segs"], s[wi]["segs_types"], s[wi]["scale"][1], s[wi]["scale"][2],
        parse_input(ui["input"][], "Modify Segments")[1])

    body!(sdw, s[wi]["segs_details_html"]) end

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

    html = hbox(hskip(0.75em), vbox(node(:strong, summary_text) , vbox(details)))
    return html, dds, checks, spins end

detailed_space_types = OrderedDict{Int64,String}(
    1=>"Building Support - Other",                  2=>"Building Support - Mechanical Room",
    3=>"Building Support - Garbage",                4=>"Building Support - Electrical",
    5=>"Building Support - Mechnical Mezzanine",    6=>"Process - Other",
    7=>"Process - Stage/Backstage",                 8=>"Process - Kitchen",
    9=>"Process - Food Prep (Deli/Bakery/Meat)",    10=>"Process - Repair/Service Area",
    11=>"Process - Medical Exam",                   12=>"Process - Medical Procedure",
    13=>"Process - Data Center",                    14=>"Process - Laboratory",
    15=>"Process - Laundry/Housekeeping",           16=>"Public Access - Other",
    17=>"Public Access - Auditorium",               18=>"Public Access - Seating Area",
    19=>"Public Access - Dining",                   20=>"Public Access - Playing/Court Area",
    21=>"Public Access - Gym",                      22=>"Public Access - Locker Room",
    23=>"Public Access - Stacks",                   24=>"Public Access - Reading/Computer Room",
    25=>"Public Access - Multipurpose Room",        26=>"Public Access - Sales",
    27=>"Public Access - Gallery",                  28=>"Storage - All",
    29=>"Refrigerated Storage - All",               30=>"Parking - All",
    31=>"Exterior - Other",                         32=>"Exterior - Building Façade",
    33=>"Exterior - Walkways",                      34=>"Exterior - Open Air Parking",
    35=>"Office/Classroom - Other",                 36=>"Office/Classroom - Open Office",
    37=>"Office/Classroom - Enclosed Office",       38=>"Office/Classroom - Meeting/Conference Room",
    39=>"Office/Classroom - Classroom",             40=>"Common Areas - Other",
    41=>"Common Areas - Lobby",                     42=>"Common Areas - Corridor",
    43=>"Common Areas - Restroom",                  44=>"Common Areas - Stairwell",
    45=>"Living Quarters - Other",                  46=>"Living Quarters - Dwelling Unit",
    47=>"Living Quarters - Guest Room",             48=>"Living Quarters - Patient Room",
    49=>"Unknown - All",                            50=>"_Walls/Windows/Doors/Etc")

dd_opts = Observable(collect(values(detailed_space_types)))


ui = Dict(
    "font"=>newface("./fonts/OpenSans-Bold.ttf"),
    "font_size"=>30,
    "img_fln" => filepicker("Load Image"),
    "go" => button("Go!", attributes=Dict(
        "onclick"=>"""Blink.msg("go", null)""", "id"=>"go")),
    "set_scale_funcs" => dropdown(OrderedDict(
        "pixels"=>(pixels, "pxs"),
        "feet"=>(feet, "ft"),
        "meters"=>(meters, "m")), attributes=Dict(
            "onblur"=>"""Blink.msg("dropdown_selected", null)""")),
    "segs_funcs"=>dropdown(OrderedDict(
        "Fast Scanning"=>(fast_scanning, Float64),
        "Felzenszwalb"=>(felzenszwalb, Int64),
        "Seeded Region Growing"=>(seeded_region_growing, Vector{Tuple{CartesianIndex,Int64}})),
            attributes=Dict("onblur"=>"""Blink.msg("dropdown_selected", null)""")),
    "mod_segs_funcs"=>dropdown(OrderedDict(
        "Prune Segments by MGS"=>(prune_min_size, Vector{Int64}, Float64),
        "Prune Segment(s)"=>(remove_segments, String),
        "Assign Space Types"=>(launch_space_editor, String)), attributes=Dict(
            "onblur"=>"""Blink.msg("dropdown_selected", null)""")),
    "export_data_funcs"=>dropdown(OrderedDict(
        "Export Segment Data to CSV"=>(export_CSV, String),
        "Export Session Data"=>(export_session_data, String)), attributes=Dict(
            "onblur"=>"""Blink.msg("dropdown_selected", null)""")),
    "draw_seeds"=>checkbox(value=false; label="Seeds"),
    "draw_labels"=>checkbox(value=false; label="Labels"),
    "colorize"=>checkbox(value=false, label="Colorize"),
    "predict_space_type"=>checkbox(value=false, label="SpacePred"),
    "input"=>textbox("See instructions below...", attributes=Dict("size"=>"60")),
    "help_text"=>Dict(
        fast_scanning=>"Input is the threshold value, range in {0, 1}. Recursive: max_segs, mgs. e.g. '50, 2000'",
        felzenszwalb=>"Input is the k-value, typical range in {5, 500}. Recursive: max_segs, mgs. e.g. '50, 2000'",
        prune_min_size=>"Removes any segment below the input minimum group size (MGS) in whole ft², m² or pixels.",
        remove_segments=>"Remove segment(s) by label and merge with most similar neighbor, separated by commas. e.g. 1, 3, 10, ...",
        seeded_region_growing=>"Click image to create a segment seed at that location. Ctrl+click to increase, alt-click to decrease, the seed number.",
        feet=>"Click two points on floorplan and enter distance in whole feet above. Separate multiple inputs with an ';' e.g. x1, x2, l1; ...",
        meters=>"Click two points on floorplan and enter distance in whole meters above. Separate multiple inputs with an ';' e.g. x1, x2, l1; ...",
        pixels=>"Click two points on floorplan and enter distance in pixels above. Separate multiple inputs with an ';' e.g. x1, x2, l1; ...",
        launch_space_editor=>"Enter the number of segments you want to export.",
        export_CSV=>"Exports segment data to CSV.",
        export_session_data=>"Exports latest session data to file. Please send .BSON file to dustin.irwin@cadmusgroup.com. Thanks!"),
    "ops_tabs" => tabs(Observable(["Set Scale", "Segment Image", "Modify Segments", "Export Data"])),
    "img_tabs" => tabs(Observable(["<<", "Original", "Segmented", "Overlayed", "Plots", ">>"])))


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
    hbox(ui["img_tabs"], hskip(0.5em), vbox(vskip(0.5em),
        node(:strong, "1", attributes=Dict("id"=>"wi", "style"=>"buffer: 5px;"))), hskip(0.5em), vbox(vskip(0.5em),
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
            "style"=>"position: absolute; top: 0px; left: 0px; opacity: 0.9;")),
        node(:img, attributes=Dict(
            "id"=>"overlay_labels", "src"=>"", "alt"=>"",
            "style"=>"position: absolute; top: 0px; left: 0px; opacity: 0.9;")),
        node(:img, attributes=Dict(
            "id"=>"overlay_seeds", "src"=>"", "alt"=>"",
            "style"=>"position: absolute; top: 0px; left: 0px; opacity: 0.9;")),
        node(:img, attributes=Dict(
            "id"=>"highlight_segment", "src"=>"", "alt"=>"",
            "style"=>"position: absolute; top: 0px; left: 0px; opacity: 0.75;")),
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

ui["tools"] = vbox(
    ui["toolbox"],
    vskip(0.5em),
    ui["toolset"],
    ui["display_options"]);

ui["html"] = node(:div,
    node(:div, ui["tools"], attributes=Dict("classList"=>"navbar", "position"=>"fixed")),
    node(:div, ui["display_imgs"], attributes=Dict("position"=>"relative")));

ui["img_tabs"][] = "Original"
