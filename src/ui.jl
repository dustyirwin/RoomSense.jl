
variables_file = joinpath(examplefolder, "darkly", "_variables.scss")
mytheme = compile_theme(variables = variables_file)
settheme!(mytheme)

const ui = Dict{Union{Symbol,String},Any}(
    :img_syms => [:original, :overlay, :segs, :highlight, :seeds, :labels, :plots, :gmap],
    :funcs => OrderedDict(
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
    :inputs => OrderedDict(
        "Fast Scanning" => widget(0.05:0.01:0.25),
        "Felzenszwalb" => widget(25:5:125),
        "Seeded Region Growing" => widget("help text?"),
        "Prune Segments by MGS" => widget(0),
        "Prune Segment" => widget(0),
        "User Image" => textbox("See instructions below...", size=40),
        "Assign Space Types" => Observable(node(:div)),
        "Export Data to CSV" => Observable(node(:div)),
        "Google Maps" => textbox("eg Nike World Campus Beaverton, OR", size=40),
    ),
    :checkboxes => OrderedDict(
        k => checkbox(value=false; label=k) for k in
            ["Overlay", "Labels", "Seeds", "Colorize", "CadetPred"]),
    :help_texts => Dict(
        "Fast Scanning" => "Select the threshold value above, higher values generates fewer pixel groups.",
        "Felzenszwalb" => "Select the threshold value above, higher values generatea fewer pixel groups.",
        "Seeded Region Growing" => "Click image to create a segment seed at that location. Ctrl+click to increase, alt-click to decrease, the seed number.",
        "Prune Segments by MGS" => "Removes any segment below the input minimum group size (MGS) in whole ft², m² or pixels (if you haven't set the scale).",
        "Prune Segment" => "Remove segment by label and merge with most similar neighbor.",
        "User Image" => "Click two points on image below and enter distance in whole feet above. Separate multiple inputs with an ';' e.g. x1, x2, l1; ...",
        "Assign Space Types" => "Enter the amount of segments you want to review space types for. Segments are sorted largest to smallest.",
        "Export Data to CSV" => "Exports segment data to CSV.",
        "Google Maps" => "Enter site address, adjust map to floorplan overlay and press Go!.",
    ),
    :font_size => 27,
    :font => FTFont("./fonts/OpenSans-Bold.ttf"),
    :img_url_input => textbox("Paste http(s) img link here..."),
    :img_tabs => tabs([], value="Original"),
    :img_info => Observable(node(:strong, "<-- paste image weblink here")),
    :click_info => Observable(node(:p,"")),
    :information => Observable(node(:p, "")),
    :alert => alert(""),
    :go => button("Go!"),
    )


ui[:imgs] = OrderedDict(
    Symbol("$(k)_img") => Observable(node(:img, style=Dict("position"=>"absolute")))
        for k in ui[:img_syms])
ui[:imgs][:gmap_img] = Observable(gmap());
ui[:func_tabs] = tabs([keys(ui[:funcs])...]);
ui[:funcs_mask] = mask(ui[:funcs]);
ui[:inputs_mask] = mask(ui[:inputs], key="User Image");
ui[:checkbox_masks] = Dict("$(k)_mask"=>mask(Observable([v]),index=0) for (k,v) in ui[:checkboxes])
ui[:img_masks] = Dict(Symbol("$(k)_mask")=>mask(Observable(
    [ ui[:imgs][Symbol("$(k)_img")] ]), index=0) for k in ui[:img_syms])


for collection in [:imgs, :img_masks, :funcs, :checkboxes, :inputs, :checkbox_masks]
    merge!(ui, Dict(ui[collection]...))
end
