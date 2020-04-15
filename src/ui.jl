
variables_file = joinpath(examplefolder, "darkly", "_variables.scss") # here you would use your own style
mytheme = compile_theme(variables = variables_file)
Interact.settheme!(mytheme)

const ui = OrderedDict(
    "funcs" => OrderedDict(
        "Set Scale"=>dropdown(
            OrderedDict(k=>k for k in [
                "User Image", "Google Maps"])),
        "Segment Image"=>dropdown(
            OrderedDict(k=>k for k in [
                "Fast Scanning", "Felzenszwalb", "Seeded Region Growing"])),  #Vector{Tuple{CartesianIndex,Int64}}
        "Modify Segments"=>dropdown(
            OrderedDict(k=>k for k in [
                "Prune Segments by MGS", "Prune Segment"])),
        "Export Data"=>dropdown(
            OrderedDict(k=>k for k in [
                "Assign Space Types", "Export Data to CSV"])),
    ),
    "inputs" => OrderedDict(
        "Fast Scanning" => widget(5:250),
        "Felzenszwalb" => widget(5:250),
        "Seeded Region Growing" => widget("help text?"),
        "Prune Segments by MGS" => widget(10),
        "Prune Segment" => widget(0),
        "User Image" => textbox("See instructions below...", size=40),
        "Assign Space Types" => Observable(node(:div)),
        "Export Data to CSV" => Observable(node(:div)),
        "Google Maps" => textbox("eg Nike World Campus Beaverton, OR", size=40),
    ),
    "checkboxes" => OrderedDict(
        k => checkbox(value=false; label=k)
        for k in ["Seeds", "Labels", "Colorize", "CadetPred"]
    ),
    "imgs" => Dict(
        k => Observable(node(:img, src="", style=Dict("opacity"=>"0.9")))
        for k in ["original", "highlight", "overlay", "seeds", "segs", "map", "plot"]
    ),
    "help_texts" => Dict(
        "Fast Scanning" => "Select the threshold value above, higher values generates fewer pixel groups.",
        "Felzenszwalb" => "Select the threshold value above, higher values generatea fewer pixel groups.",
        "Seeded Region Growing" => "Click image to create a segment seed at that location. Ctrl+click to increase, alt-click to decrease, the seed number.",
        "Prune Segments by MGS" => "Removes any segment below the input minimum group size (MGS) in whole ft², m² or pixels.",
        "Prune Segment" => "Remove segment by label and merge with most similar neighbor.",
        "User Image" => "Click two points on image below and enter distance in whole feet above. Separate multiple inputs with an ';' e.g. x1, x2, l1; ...",
        "Assign Space Types" => "Enter the amount of segments you want to review space types for. Segments are sorted largest to smallest.",
        "Export Data to CSV" => "Exports segment data to CSV.",
        "Google Maps" => "Enter site address, adjust map to floorplan overlay and press Go!.",
    ),
    "font_size" => 30,
    "font" => newface("./fonts/OpenSans-Bold.ttf"),
    )

ui["obs"] = Dict(
    "img_url_input" => textbox("Paste http(s) img link here..."),
    "inputs_mask" => mask(ui["inputs"], key="User Image"),
    "imgs_mask" => mask(OrderedDict(
        "Original" => node(:div, ui["imgs"]["original"], ui["imgs"]["highlight"]),
        "Segmented" => node(:div, ui["imgs"]["segs"], ui["imgs"]["overlay"], ui["imgs"]["highlight"]),
        "Plots" => ui["imgs"]["plot"],
        "Google Maps" => vbox(
            node(:div, ui["imgs"]["overlay"], ui["imgs"]["map"]),
            hbox(values(map_controls)...)),
        ), key="Original"),
    "img_tabs" => tabs(["Original", "Google Maps"], value="Original"),
    "img_info" => Observable(node(:strong, "<-- paste image weblink here")),
    "func_tabs" => tabs([keys(ui["funcs"])...]),
    "funcs_mask" => mask(ui["funcs"]),
    "click_info" => Observable(node(:p,"")),
    "information" => Observable(node(:p, ui["help_texts"]["User Image"])),
    "checkboxes_mask" => mask(ui["checkboxes"], index=0),
    "go" => button("Go!"),
    "wi" => Observable(1),
    "<<" => button("<<", attributes=Dict("class"=>"is-small is-default")),
    ">>" => button(">>", attributes=Dict("class"=>"is-small is-default")),
    )

merge!(ui["obs"], Dict(collect(ui["imgs"])...))

merge!(ui["obs"], Dict(collect(ui["funcs"])...))

ui["func_panel"] = vbox(
    hbox(ui["obs"]["func_tabs"], hskip(1em),
        vbox(vskip(0.5em), node(:strong, "Rev: $(ui["obs"]["wi"][])")), hskip(1em),
        vbox(vskip(0.3em), ui["obs"]["img_url_input"]), hskip(1em),
        vbox(vskip(0.5em), ui["obs"]["img_info"])),
    vskip(1em),
    hbox(hskip(1em),
        ui["obs"]["go"], hskip(0.5em),
        ui["obs"]["funcs_mask"], hskip(0.5em),
        ui["obs"]["inputs_mask"], hskip(0.5em),
        vbox(vskip(0.5em), ui["obs"]["checkboxes_mask"])
    ),
    hbox(hskip(1em), ui["obs"]["information"]), vskip(0.7em),
    hbox(hskip(1em), ui["obs"]["<<"], ui["obs"]["img_tabs"], ui["obs"][">>"],
        hskip(1em), vbox(vskip(0.5em), ui["obs"]["click_info"])),
    )
