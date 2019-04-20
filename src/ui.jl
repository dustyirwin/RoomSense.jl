ui = Dict(
    "face" => newface("./fonts/OpenSans-Bold.ttf"),
    "img_filename" => filepicker("Choose image"),
    "param_go" => button("GO", attributes=Dict(
        "onclick"=>"""Blink.msg("param_go", [])""")),
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
    "operation_tabs" => tabs(Observable([
        "Parametized Segmentation", "Seeded Segmentation", "Modify Segments", "Export Data"]), attributes=Dict(
        "onclick"=>"""Blink.msg("operation_tab_change", [])""")),
    "img_tabs" => tabs(Observable(["Original Image", "Segmented Image"])),
    )

ui["param_seg_html"] = node(:div,
    vbox(
        hbox(
            node(:div, ui["operation_tabs"]), hskip(1em),
            node(:div, ui["img_filename"], attributes=Dict(
                "onchange"=>"""Blink.msg("img_selected", [])"""))),
        vskip(1em),
        hbox(
            hskip(0.75em), ui["param_algorithm"], hskip(0.5em),
            vbox(vskip(0.4em), hbox(hskip(0.25em), "var1", hskip(0.25em))), ui["var1"],
            vbox(vskip(0.4em), hbox(hskip(0.5em), "var2", hskip(0.25em))), ui["var2"], hskip(0.5em), ui["param_go"],
            hskip(1em), vbox(vskip(0.4em), node(:p, "", attributes=Dict("id"=>"seg_info")))),
        hbox(
            hskip(0.25em), ui["colorize"],
            hskip(0.4em), node(:p, """Notes: $(ui["help_text"][ui["param_algorithm"][]])""", attributes=Dict("id"=>"help_text"))),
        node(:div, ui["img_tabs"], attributes=Dict(
            "onclick"=>"""Blink.msg("img_tab_change", [])""", "id"=>"img_tabs", "hidden"=>true)),
        node(:img, attributes=Dict("id"=>"display_img", "src"=>"", "alt"=>"")))
    );

ui["seeded_seg_html"] = node(:div,
    "cool stuff here!",
    );

ui["mod_segs_html"] = node(:div,
    "cool stuff here!",
    );

ui["export_data_html"] = node(:div,
    "cool stuff here!",
    );
