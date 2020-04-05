
const ui = OrderedDict(
    "checkboxes" => OrderedDict(
        "Seeds"=>checkbox(value=false; label="Seeds"),
        "Labels"=>checkbox(value=false; label="Labels"),
        "Colorize"=>checkbox(value=false, label="Colorize"),
        "CadetPred"=>checkbox(value=false, label="CadetPred"),
    ),
    "dropdowns" => OrderedDict(
        "Set Scale"=>dropdown(
            OrderedDict(
                "feet"=>(feet, "ft"),
                "meters"=>(meters, "m")),
        ),
        "Segment Image"=>dropdown(
            OrderedDict(
                "Fast Scanning"=>(fast_scanning, Int64),
                "Felzenszwalb"=>(felzenszwalb, Int64),
                "Seeded Region Growing"=>(seeded_region_growing, Vector{Tuple{CartesianIndex,Int64}})),
        ),
        "Modify Segments"=>dropdown(
            OrderedDict(
                "Prune Segments by MGS"=>(prune_min_size, Vector{Int64}, Int64),
                "Prune Segment(s)"=>(remove_segments, Vector{Int64}),
            ),
        ),
        "Export Data"=>dropdown(
            OrderedDict(
                "Export Segment Data to CSV"=>(export_CSV, String),
                "Assign Space Types"=>(launch_space_editor, String),
        ))
    ),
    "imgs" => OrderedDict(
        "Original" => node(:img, attributes=Dict(
            "id"=>"Original", "src"=>register("assets/space_monkey.jpg"),
            "alt"=>"Error! Check original image link...", "style"=>"opacity: 0.9;", )),
        "Segmented" => node(:img, attributes=Dict(
            "id"=>"Segmented", "src"=>"",
            "alt"=>"Error! Check segs image link...", "style"=>"opacity: 0.9;", )),
        "Plots" => node(:img, attributes=Dict(
            "id"=>"Plots", "src"=>register("assets/space_monkey.jpg"),
            "alt"=>"Error! Check plots  image link...", "style"=>"opacity: 1.0;", )),
        "Overlay" => node(:img, attributes=Dict(
            "id"=>"Overlay", "src"=>register("assets/space_monkey.jpg"),
            "style"=>"position: absolute; top: 0px; left: 0px; opacity: 0.9;")),
        "Highlight" => node(:img, attributes=Dict(
            "id"=>"Highlight", "src"=>"/assets/empty.jpg",
            "alt"=>"Error! Could not display highlight image...",
            "style"=>"position: absolute; top: 50px; left: 0px; opacity: 0.4;")),
    ),
    "font" => newface("./fonts/OpenSans-Bold.ttf"),
    "font_size" => 30,
    "help_texts" => Dict(
        fast_scanning=>"Input is the threshold value, range in {5, 500}. Recursive: max_segs, mgs. e.g. '50, 2000'",
        felzenszwalb=>"Input is the k-value, typical range in {5, 500}. Recursive: max_segs, mgs. e.g. '50, 2000'",
        prune_min_size=>"Removes any segment below the input minimum group size (MGS) in whole ft², m² or pixels.",
        remove_segments=>"Remove segment(s) by label and merge with most similar neighbor, separated by commas. e.g. 1, 3, 10, ...",
        seeded_region_growing=>"Click image to create a segment seed at that location. Ctrl+click to increase, alt-click to decrease, the seed number.",
        feet=>"Click two points on floorplan and enter distance in whole feet above. Separate multiple inputs with an ';' e.g. x1, x2, l1; ...",
        meters=>"Click two points on floorplan and enter distance in whole meters above. Separate multiple inputs with an ';' e.g. x1, x2, l1; ...",
        launch_space_editor=>"Enter the number of segments you want to assign space types to. Segments are sorted largest to smallest.",
        export_CSV=>"Exports segment data to CSV.",
        export_session_data=>"Exports latest session data to file. Please send .BSON file to dustin.irwin@cadmusgroup.com. Thanks!"),
    "information" => node(:strong, "Information / instructions here..."),
)

ui["obs"] = Dict(
    "go" => button("Go!"),
    "input" => textbox("See instructions below...", attributes=Dict("size"=>"50")),
    "img_url_input" => textbox("Paste http(s) img link here..."),
    "work_index" => Observable(1),
    "confirm" => Widgets.confirm(""),
    "func_tabs" => tabs([k for k in keys(ui["dropdowns"])]),
    "func_mask" => mask(ui["dropdowns"], key="Set Scale"),
    "img_tabs" => tabs(["<<", "Original", "Segmented", "Overlay", "Plots", ">>"], value="Original"),
    "img_mask" => mask(OrderedDict(
        "Original" => ui["imgs"]["Original"],
        "Segmented" => ui["imgs"]["Segmented"],
        "Overlay" => node(:div, ui["imgs"]["Segmented"], ui["imgs"]["Overlay"]),
        "Plots" => ui["imgs"]["Plots"]), key="Original"),
    "information" => Observable(ui["information"]),
)

merge!(ui["obs"],
    Dict("$(key)_src" => Observable(value) for (key, value) in collect(ui["imgs"])))

ui["func_panel"] = vbox(
    hbox(ui["obs"]["func_tabs"], hskip(0.5em),
        ui["obs"]["img_url_input"], hskip(0.5em),
        node(:strong, "<-- Paste img link here")),
    vskip(0.5em),
    hbox(hskip(1em),
        ui["obs"]["go"], hskip(0.5em),
        ui["obs"]["func_mask"], hskip(0.5em),
        ui["obs"]["input"], hskip(0.5em),
        vbox(vskip(0.2), hbox(collect(values(ui["checkboxes"]))...))),
    hbox(hskip(1em), ui["obs"]["information"]),
    ui["obs"]["img_tabs"],
)

ui["obs"]["img_tabs"][] = "Original"
