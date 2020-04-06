
const ui = OrderedDict(
    "funcs" => OrderedDict(
        "Set Scale"=>dropdown(OrderedDict(
            "feet"=>feet,
            "meters"=>meters,
        )),
        "Segment Image"=>dropdown(OrderedDict(
            "Fast Scanning"=>fast_scanning,
            "Felzenszwalb"=>felzenszwalb,
            "Seeded Region Growing"=>seeded_region_growing, #Vector{Tuple{CartesianIndex,Int64}}
        )),
        "Modify Segments"=>dropdown(OrderedDict(
            "Prune Segments by MGS"=>prune_min_size,
            "Prune Segment"=>prune_segments,
        )),
        "Export Data"=>dropdown(OrderedDict(
            "Assign Space Types"=>launch_space_editor,
            "Export Data to CSV"=>export_CSV,
        )),
    ),
    "inputs" => Dict(
        "Fast Scanning"=>widget(5:250),
        "Felzenszwalb"=>widget(5:250),
        "Seeded Region Growing"=>widget("help text?"),
        "Prune Segments by MGS"=>widget(10),
        "Prune Segment"=>widget(0),
        "feet"=>widget("help text?"),
        "meters"=>widget("help text?"),
        "Assign Space Types"=>Observable(node(:div)),
        "Export Data to CSV"=>Observable(node(:div)),
    ),
    "checkboxes" => OrderedDict(
        "Seeds"=>checkbox(value=false; label="Seeds"),
        "Labels"=>checkbox(value=false; label="Labels"),
        "Colorize"=>checkbox(value=false, label="Colorize"),
        "CadetPred"=>checkbox(value=false, label="CadetPred"),
    ),
    "imgs" => Dict(
        "display" => Observable(node(:img,attributes=Dict("src"=>"", "style"=>"opacity: 1.0;", ))),
        "overlay" => Observable(node(:img,attributes=Dict("src"=>"", "style"=> "opacity: 0.9;"))),
        "seeds" => Observable(node(:img, attributes=Dict("src"=>"", "style"=>"opacity: 0.9;"))),
        "highlight" => Observable(node(:img, attributes=Dict("src"=>"", "style"=>"opacity: 0.4;"))),
    ),
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
    ),
    "font" => newface("./fonts/OpenSans-Bold.ttf"),
    "font_size" => 30,
)

ui["obs"] = Dict(
    "func_tabs" => tabs([keys(ui["funcs"])...]),
    "funcs_mask" => mask(ui["funcs"]),
    "img_url_input" => textbox("Paste http(s) img link here..."),
    "img_info" => Observable(node(:strong, "<-- paste image weblink here")),
    "inputs_mask" => mask(ui["inputs"]),
    "go" => button("Go!"),
    "wi" => Observable(1),
    "information" => Observable(node(:strong, "Information / instructions here...")),
    "imgs_mask" => mask(OrderedDict(
        "Original" => node(:div, ui["imgs"]["display"], ui["imgs"]["highlight"]),
        "Segmented" => node(:div, ui["imgs"]["display"], ui["imgs"]["highlight"]),
        "Overlay" => node(:div, ui["imgs"]["display"], ui["imgs"]["overlay"], ui["imgs"]["highlight"]),
        "Plots" => ui["imgs"]["display"],
        ), key="Original"),
    "img_tabs" => tabs(["<<", "Original", "Segmented", "Overlay", "Plots", ">>"], value="Original"),
    "confirm" => Widgets.confirm(""),
)

merge!(ui["obs"], Dict(collect(ui["imgs"])...))

merge!(ui["obs"], Dict(collect(ui["inputs"])...))

ui["func_panel"] = vbox(
    hbox(ui["obs"]["func_tabs"], hskip(1em),
        ui["obs"]["img_url_input"], hskip(0.5em),
        vbox(vskip(0.3em), ui["obs"]["img_info"]),
        ),
    vskip(0.3em),
    hbox(hskip(1em),
        ui["obs"]["go"], hskip(0.5em),
        ui["obs"]["funcs_mask"], hskip(0.5em),
        ui["obs"]["inputs_mask"], hskip(0.5em),
        vbox(vskip(0.2), hbox(collect(values(ui["checkboxes"]))...))),
    hbox(hskip(1em), ui["obs"]["information"]),
    ui["obs"]["img_tabs"],
)
