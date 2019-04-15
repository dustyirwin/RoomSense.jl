ui = Dict(
    "face" => newface("./fonts/OpenSans-Bold.ttf"),
    "img_filename" => filepicker("Choose image"),
    "go" => button("Go"),
    "algorithm" => dropdown(OrderedDict(
        "Fast Scanning"=>fast_scanning,
        "Felzenszwalb"=>felzenszwalb,
        "MeanShift Segmentation"=>meanshift,
        "Fuzzy C-means"=>fuzzy_cmeans,
        "Watershed"=>watershed,
        "Unseeded Region Growing"=>unseeded_region_growing,
        "*Seeded Region Growing"=>seeded_region_growing,
        )),
    "var1" => spinbox(0:1000, value=1),
    "var2" => spinbox(0:1000, value=1),
    "space_type" => dropdown(OrderedDict(
        "Building Support"=>"BS",
        "Process"=>"PR",
        "Public Access"=>"PA"), multiple=false),
    "html" => (img_filename) -> node(:div,
        vbox(
            hbox(
                hskip(0.5em), ui["algorithm"], ui["var1"], ui["var2"], ui["go"], hskip(0.5em), ui["img_filename"]),
            hbox(hskip(0.5), ". Help text goes here."),
            vskip(0.5em),
                node(:img, attributes=Dict("src"=>"$img_filename",
                    "alt"=>"^^^ LOAD AN IMAGE ABOVE ^^^"))))
    )
