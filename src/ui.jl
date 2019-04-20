ui = Dict(
    "face" => newface("./fonts/OpenSans-Bold.ttf"),
    "img_filename" => filepicker("Choose image"),
    "param_go" => button("GO", attributes=Dict(
        "onclick"=>"""Blink.msg("param_go", [])""", "id"=>"param_go")),
    "export" => button("Export", attributes=Dict(
        "onclick"=>"""Blink.msg("export_data", [])""")),
    "param_algorithm" => dropdown(OrderedDict(
        "Fast Scanning"=>fast_scanning,
        "Felzenszwalb"=>felzenszwalb,
        "Unseeded Region Growing"=>unseeded_region_growing,
        "MeanShift Segmentation"=>ImageSegmentation.meanshift,
        "Fuzzy C-means"=>fuzzy_cmeans,
        "Watershed"=>watershed,), attributes=Dict(
            "onblur"=>"""Blink.msg("algorithm_selected", [])""")),
    "colorize" => checkbox("Colorize result?"),
    "select_points" => toggle("Select point(s)"),
    "var1" => spinbox(0.0:0.1:1000.0, value=0.0),
    "var2" => spinbox(0.0:0.1:1000.0, value=0.0),
    "space_type" => dropdown(OrderedDict(
        "Building Support"=>"BS",
        "Process"=>"PR",
        "Public Access"=>"PA"), multiple=false),
    "help_text" => Dict(
        fast_scanning=>"var1 is the threshold value, typical range in {0,1}, var2 is unused.",
        felzenszwalb=>"var1 is the k-value, typical range in {5,500}, var2 is minimum pixel group size in pixels.",
        unseeded_region_growing=>"var1 is the threshold value, typical value in range {0,1}, var2 is unused.",
        meanshift=>"var1 is the spatial smoothing radii in pixels, var2 is the intensity-wise smoothing radii in pixels.",
        fuzzy_cmeans=>"var1 is the number of centers, var2 is the number of weights",
        watershed=>"Under development!"),
    "operations" => ["Parametric Segmentation", "Seeded Segmentation", "Modify Segments", "Export Data"],
    "operations_tabs" => tabs(Observable(ui["operations"])),
    "img_tabs" => tabs(Observable(["Original Image", "Segmented Image"])),
    )


ui["param_toolset"] = vbox(
    hbox(
        hskip(0.75em), ui["param_algorithm"], hskip(0.5em),
        vbox(vskip(0.4em), hbox(hskip(0.25em), "var1", hskip(0.25em))), ui["var1"],
        vbox(vskip(0.4em), hbox(hskip(0.5em), "var2", hskip(0.25em))), ui["var2"], hskip(0.5em), ui["param_go"],
        hskip(0.25em), ui["colorize"]),
    hbox(hskip(0.75em), node(:p, """Notes: $(ui["help_text"][ui["param_algorithm"][]])""", attributes=Dict(
        "id"=>"help_text")))
    );

ui["seeded_toolset"] = node(:div,
    "cool stuff here!",
    );

ui["mod_segs_toolset"] = node(:div,
    "cool stuff here!",
    );

ui["data_export_toolset"] = node(:div,
    "cool stuff here!",
    );

ui["display_img"] = vbox(
    node(:div, ui["img_tabs"], attributes=Dict(
        "onclick"=>"""Blink.msg("img_tab_change", [])""", "id"=>"img_tabs", "hidden"=>true)),
    node(:img, attributes=Dict("id"=>"display_img", "src"=>"", "alt"=>"")));

ui["html"] = node(:div,
    vbox(
        hbox(
            node(:div, ui["operations_tabs"], attributes=Dict(
                "id"=>"operation_tabs",
                "onclick"=>"""Blink.msg("operations_tab_change", [])""")),
            hskip(1em),
            node(:div, ui["img_filename"], attributes=Dict(
                "onchange"=>"""Blink.msg("img_selected", [])"""))),
        vskip(1em),
        node(:div, ui["param_toolset"], attributes=Dict("id"=>"Parametric Segmentation")),
        node(:div, ui["seeded_toolset"], attributes=Dict("id"=>"Seeded Segmentation", "hidden"=>true)),
        node(:div, ui["mod_segs_toolset"], attributes=Dict("id"=>"Modify Segments", "hidden"=>true)),
        node(:div, ui["data_export_toolset"], attributes=Dict("id"=>"Export Data", "hidden"=>true)),
        ui["display_img"]),
    );
