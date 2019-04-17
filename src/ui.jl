ui = Dict(
    "face" => newface("./fonts/OpenSans-Bold.ttf"),
    "img_filename" => filepicker("Choose image", attributes=Dict(
        "onchange"=>"""Blink.msg("file_picked", [])""")),
    "go" => button("Go", attributes=Dict(
        "onclick"=>"""Blink.msg("go", [])""")),
    "export" => button("Export"),
    "algorithm" => dropdown(OrderedDict(
        "Fast Scanning"=>fast_scanning,
        "Felzenszwalb"=>felzenszwalb,
        "Unseeded Region Growing"=>unseeded_region_growing,
        "MeanShift Segmentation"=>meanshift,
        "Fuzzy C-means"=>fuzzy_cmeans,
        "Watershed"=>watershed,
        "Prune Segments"=>prune_segments,), attributes=Dict(
            "onchange"=>"""Blink.msg("algorithm_selected", [])""")),
    "var1" => spinbox(0.0:0.1:1000.0, value=1.0),
    "var2" => spinbox(0.0:0.1:1000.0, value=1.0),
    "space_type" => dropdown(OrderedDict(
        "Building Support"=>"BS",
        "Process"=>"PR",
        "Public Access"=>"PA"), multiple=false),
    "help_text" => Dict(
        fast_scanning=>"var1 is the threshold value, typical range in {0,1}. var2 is unused.",
        felzenszwalb=>"var1 is the k-value, typical range in {5,500}. var2 is minimum pixel group size in pixels.",
        unseeded_region_growing=>"var1 is the threshold value, typical value in range {0,1}. var2 is unused.",
        meanshift=>"var1 is the spatial smoothing radii in pixels. var2 is the intensity-wise smoothing radii in pixels.",
        fuzzy_cmeans=>"var1 is the number of centers, var2 is the number of weights",
        watershed=>"var1 is ",
        prune_segments=>"",
    ),
    "html" => (img_filename="", segments="") -> node(:div,
        vbox(
            hbox(hskip(0.5em),
                ui["algorithm"], ui["var1"], ui["var2"], ui["go"], hskip(0.5em),
                ui["img_filename"], hskip(0.5em)),
            hbox(hskip(0.75em),
                node(:p, """$(ui["help_text"][ui["algorithm"][]])""", attributes=Dict("id"=>"help_text"))),
            vskip(0.5em),
            hbox(hskip(0.5em),
                ui["img_filename"][] == "" && img_filename == "" ? node(
                    :h1, "Welcome to RoomSense.jl", attributes=Dict()) : node(
                    :img, attributes=Dict(
                        "src"=>"$img_filename", "alt"=>"^^^ LOAD AN IMAGE ABOVE ^^^")))
                ))
    )
