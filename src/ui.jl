const wi = 1  # work index

const s = [Dict{Any,Any}(
    "current_img_tab"=>"Original",
    "prev_op_tab"=>"Set Scale",
    "scale"=>(1.,"ft",""),
    "segs_types"=>nothing,
    "selected_areas"=>Vector{Int64}())];

const detailed_space_types = OrderedDict{Int64,String}(
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
    49=>"Unknown - All",                            50=>"_Walls/Windows/Doors/Etc"
)

const dd_opts = collect(values(detailed_space_types))

const ui = OrderedDict(
    "go" => button("Go!"),
    "checkboxes" => checkboxes(OrderedDict(
        "overlay_alpha"=>checkbox(value=true; label="Overlay"),
        "draw_seeds"=>checkbox(value=false; label="Seeds"),
        "draw_labels"=>checkbox(value=false; label="Labels"),
        "colorize"=>checkbox(value=false, label="Colorize"),
        "predict_space_type"=>checkbox(value=false, label="SpacePred"),
        )
    ),
    "dropdowns" => OrderedDict(
        "Set Scale"=>dropdown(
            OrderedDict(
                "pixels"=>(pixels, "pxs"),
                "feet"=>(feet, "ft"),
                "meters"=>(meters, "m")),
        ),
        "Segment Image"=>dropdown(
            OrderedDict(
                "Fast Scanning"=>(fast_scanning, Float64),
                "Felzenszwalb"=>(felzenszwalb, Int64),
                "Seeded Region Growing"=>(seeded_region_growing, Vector{Tuple{CartesianIndex,Int64}})),
        ),
        "Modify Segments"=>dropdown(
            OrderedDict(
                "Prune Segments by MGS"=>(prune_min_size, Vector{Int64}, Float64),
                "Prune Segment(s)"=>(remove_segments, String),
                "Assign Space Types"=>(launch_space_editor, String)),
        ),
        "Export Data"=>dropdown(
            OrderedDict(
                "Export Segment Data to CSV"=>(export_CSV, String),
                "Export Session Data"=>(export_session_data, String)),
        ),
    ),
    "imgs" => OrderedDict(
        "original" => node(:img, attributes=Dict("src"=>"", "alt"=>"ERROR!",
            "style"=>"opacity: 0.9;")),
        "segs" => node(:img, attributes=Dict("src"=>"", "alt"=>"ERROR!",
            "style"=>"opacity: 0.9;")),
        "plot" => node(:img, attributes=Dict("src"=>"", "alt"=>"ERROR!",
            "style"=>"opacity: 1.0;")),
        "overlay" => node(:img, attributes=Dict("src"=>"", "alt"=>"ERROR!",
            "style"=>"position: absolute; top: 0px; left: 0px; opacity: 0.9;"))
    ),
    "font" => newface("./fonts/OpenSans-Bold.ttf"),
    "font_size" => 30,
    "img_fn" => filepicker("Load Image"),
    "dropbox_url" => textbox("Paste DropBox img link here"),
    "input" => textbox("See instructions below...", attributes=Dict("size"=>"60")),
    "help_texts" => Dict(
        fast_scanning=>"Input is the threshold value, range in {0, 1}. Recursive: max_segs, mgs. e.g. '50, 2000'",
        felzenszwalb=>"Input is the k-value, typical range in {5, 500}. Recursive: max_segs, mgs. e.g. '50, 2000'",
        prune_min_size=>"Removes any segment below the input minimum group size (MGS) in whole ft², m² or pixels.",
        remove_segments=>"Remove segment(s) by label and merge with most similar neighbor, separated by commas. e.g. 1, 3, 10, ...",
        seeded_region_growing=>"Click image to create a segment seed at that location. Ctrl+click to increase, alt-click to decrease, the seed number.",
        feet=>"Click two points on floorplan and enter distance in whole feet above. Separate multiple inputs with an ';' e.g. x1, x2, l1; ...",
        meters=>"Click two points on floorplan and enter distance in whole meters above. Separate multiple inputs with an ';' e.g. x1, x2, l1; ...",
        pixels=>"Click two points on floorplan and enter distance in pixels above. Separate multiple inputs with an ';' e.g. x1, x2, l1; ...",
        launch_space_editor=>"Enter the number of segments you want to assign space types to. Segments are sorted largest to smallest.",
        export_CSV=>"Exports segment data to CSV.",
        export_session_data=>"Exports latest session data to file. Please send .BSON file to dustin.irwin@cadmusgroup.com. Thanks!"),
    "img_info" => node(:p, ""),
    "scale_info" => node(:p, ""),
    "segs_info" => node(:strong, ""),
    "work_index" => node(:strong, "1", attributes=Dict("style"=>"buffer: 5px;")),
);



ui["img_tabs"] = tabulator(
    Observable(
        OrderedDict(
            "Original" => node(:div, ui["imgs"]["original"]),
            "Segmented" => node(:div, ui["imgs"]["segs"]),
            "Segs Plot" => node(:div, ui["imgs"]["plot"]),))
)

ui["funcs"] = tabulator(
    Observable(
        OrderedDict(
            dropdown => node(:div,
                vbox(
                    hbox(hskip(0.6em),
                        ui["go"], hskip(0.6em),
                        ui["dropdowns"][dropdown], hskip(0.6em),
                        ui["input"], hskip(0.6em),
                        vbox(
                            vskip(0.2em),
                            ui["segs_info"],
            )))) for dropdown in collect(keys(ui["dropdowns"]))))
);

ui["toolbox"] = vbox(
    hbox(
        ui["funcs"], hskip(1em),
        ui["dropbox_url"], hskip(1em),
        ui["img_info"], hskip(0.25em),
        ui["scale_info"],)
);

ui["image_display"] = node(:div,
    hbox(ui["img_tabs"], hskip(1em),
    vbox(vskip(0.5em), ui["work_index"]), hskip(1em),
    checkboxes(ui["checkboxes"])),
    attributes=Dict(
        "id"=>"image_display",
        "style"=>"position: relative; padding: 0px; border: 0px; margin: 0px;",
        "onclick"=>"""click = [
            event.pageY - document.getElementById("img_container").offsetTop,
            event.pageX,
            document.getElementById("display_img").height,
            document.getElementById("display_img").width,
            document.getElementById("display_img").naturalHeight,
            document.getElementById("display_img").naturalWidth,
            event.ctrlKey,
            event.shiftKey,
            event.altKey];""")
);

ui["html"] = node(:div,
    node(:div, ui["toolbox"], attributes=Dict("classList"=>"navbar", "position"=>"fixed")),
    node(:div, ui["image_display"], attributes=Dict("position"=>"relative"))
)



hbox(cb for cb in collect(values(ui["checkboxes"])))
ui["checkboxes"]


checkboxes()
