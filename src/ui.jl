
ui = OrderedDict(
    "checkboxes" => OrderedDict(
        "draw_seeds"=>checkbox(value=false; label="Seeds"),
        "draw_labels"=>checkbox(value=false; label="Labels"),
        "colorize"=>checkbox(value=false, label="Colorize"),
        "predict_space_type"=>checkbox(value=false, label="PredType"),
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
        "display" => node(:img, attributes=Dict("id"=>"display", "src"=>"",
            "alt"=>"Error! Check image link...", "style"=>"opacity: 0.9;", )),
        "overlay" => node(:img, attributes=Dict("id"=>"overlay", "src"=>"/assets/empty.jpg",
            "alt"=>"Error! Could not display overlay image...",
            "style"=>"position: absolute; top: 50px; left: 0px; opacity: 0.9;")),
        "highlight" => node(:img, attributes=Dict("id"=>"highlight", "src"=>"/assets/empty.jpg",
            "alt"=>"Error! Could not display highlight image...",
            "style"=>"position: absolute; top: 50px; left: 0px; opacity: 0.4;")),
    ),
    "font" => newface("./fonts/OpenSans-Bold.ttf"),
    "font_size" => 30,
    "input" => textbox("See instructions below...", attributes=Dict("size"=>"65")),
    "help_texts" => Dict(
        fast_scanning=>"Input is the threshold value, range in {5, 500}. Recursive: max_segs, mgs. e.g. '50, 2000'",
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
    "information" => node(:strong, "", attributes=Dict("id"=>"console")),
    "obs" => Dict(
        "go" => button("Go!", attributes=Dict("id"=>"go", "classList"=>["button is-loading"])),
        "img_url_input" => textbox("Paste http(s) img link here..."),
        "img_click" => Observable([]),
        "work_index" => Observable(1),
    )
);


ui["funcs"] = tabulator(
    Observable(
        OrderedDict(
            dropdown => node(:div,
                hbox(hskip(1em),
                    ui["dropdowns"][dropdown], hskip(0.5em),
                    ui["input"], hskip(1em)),
            ) for dropdown in collect(keys(ui["dropdowns"]))))
);

ui["func_panel"] = vbox(
    ui["funcs"],
    hbox(hskip(1em),
        ui["obs"]["go"], hskip(0.5em),
        vbox(vskip(0.5em), hbox(collect(values(ui["checkboxes"]))...)),
        ui["obs"]["img_url_input"], hskip(0.5em),
        ui["information"])
);

ui["img_tabs"] = tabulator(
    Observable(
        OrderedDict(
            "Original" => node(:div, ui["imgs"]["display"]),
            "Segmented" => node(:div, ui["imgs"]["display"]),
            "Overlay" => node(:div, ui["imgs"]["display"], ui["imgs"]["overlay"]),
            "Plots" => node(:div, ui["imgs"]["display"]),))
);

ui["home_img"] = AssetRegistry.register("./assets/welcome.jpg")

ui["imgs"]["display"].props[:attributes]["src"] = ui["home_img"]
