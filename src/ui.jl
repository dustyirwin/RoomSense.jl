
variables_file = joinpath(examplefolder, "darkly", "_variables.scss")
mytheme = compile_theme(variables = variables_file)
settheme!(mytheme)
# settheme!(:nativehtml)

const ui = Dict{Union{Symbol,String},Any}(
    :img_syms => [:user, :segs, :overlay, :labels, :highlight, :seeds],
    :available_space_types => OrderedDict{Int64,String}(
        1=>"Building Support - Other",                   2=>"Building Support - Mechanical Room",
        3=>"Building Support - Garbage",                 4=>"Building Support - Electrical",
        5=>"Building Support - Mechnical Mezzanine",     6=>"Process - Other",
        7=>"Process - Stage/Backstage",                  8=>"Process - Kitchen",
        9=>"Process - Food Prep (Deli/Bakery/Meat)",     10=>"Process - Repair/Service Area",
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
        49=>"Unknown - All",                            50=>"_Walls/Windows/Doors/Etc",
        ),
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
                "Assign Space Types", "Export Data to ZIP"])),
    ),
    :checkboxes => OrderedDict(
        k => checkbox(value=false; label=k) for k in
            ["Overlay", "Colorize", "Labels", "Seeds", "CadetPred"]),
    :help_texts => Dict(
        "Fast Scanning" => "Select the threshold value above, higher values generates fewer pixel groups.",
        "Felzenszwalb" => "Select the threshold value above, higher values generates fewer pixel groups.",
        "Seeded Region Growing" => "Click image to create a segment seed at that location. Ctrl+click to increase, alt-click to decrease, the seed number.",
        "Prune Segments by MGS" => "Removes any segment below the input minimum group size (MGS) in whole area units or pixels (if you haven't set the scale).",
        "Prune Segment" => "Remove segment by label and merge with most similar neighbor.",
        "User Image" => "Click two points on image below and enter distance in whole units above. Separate multiple inputs with an ';' e.g. x1, x2, l1; ...",
        "Assign Space Types" => "Enter the amount of segments you want to review space types for. Segments are sorted largest to smallest.",
        "Export Data to CSV" => "Exports segment data to CSV.",
        "Google Maps" => "Enter site address, adjust map to floorplan overlay and press Go!.",
    ),
    :font_size => 24,
    :font => FTFont("./fonts/OpenSans-Bold.ttf"),
    :img_url_input => textbox("PASTE (CTRL+V) the http web-link to your image ( .jpg .png .bmp ) here..."),
    :img_tabs => tabs(["Original"]),
    :img_info => Observable(node(:p)),
    :click_info => Observable(node(:p)),
    :information => Observable(node(:p)),
    :step => Observable(node(:strong, "step: $i")),
    :confirm => confirm(""),
    :alert => alert("Images larger than FHD are not supported. Reduce the image size below 2.036e6 pixels (1920 x 1080)"),
    :go => button("Go!"),
    );

ui[:inputs] = OrderedDict(
    "Fast Scanning" => widget(0.05:0.01:0.25),
    "Felzenszwalb" => widget(25:5:125),
    "Seeded Region Growing" => widget("*func under construction"),
    "Prune Segments by MGS" => widget(100),
    "Prune Segment" => node(:p, "shift+click to select a space, shift+alt+click to unselect a space, ctrl+click to highlight a space. You may combine these commands. "),
    "User Image" => textbox("See instructions below...", size=40),
    "Assign Space Types" => dropdown(
        OrderedDict(v=>k for (k,v) in ui[:available_space_types]), multiple=false),
    "Export Data to ZIP" => Observable(node(:div)),
    "Google Maps" => textbox("*func under construction"),
    "Units" => radiobuttons(["ft", "m"], stack=false),
    )
ui[:imgs] = OrderedDict(
    Symbol("$(k)_img") => Observable(node(:img)) for k in ui[:img_syms])
ui[:imgs][:gmap_img] = Observable(node(:div, gmap()));
ui[:func_tabs] = tabs([ keys(ui[:funcs])... ], key="Set Scale");
ui[:funcs_mask] = mask(ui[:funcs], index=1);
ui[:inputs_mask] = mask(ui[:inputs], index=6);
ui[:checkbox_masks] = Dict("$(k)_mask"=>mask([v],index=0)
    for (k,v) in ui[:checkboxes])
ui[:img_masks] = Dict(
    Symbol("$(k)_mask")=>mask(Observable([ ui[:imgs][Symbol("$(k)_img")] ]), index=0)
        for k in ui[:img_syms])
ui[:gmap_mask] = mask(Observable([ gmap() ]), index=0);
ui[:img_url_mask] = mask(Observable([ ui[:img_url_input] ]), index=1);
ui[:plots] = Observable(node(:div));
ui[:plots_mask] = mask(Observable([ ui[:plots] ]), index=0);

for collection in [
    :imgs, :img_masks, :funcs, :checkboxes, :inputs, :checkbox_masks]

    merge!(ui, Dict(ui[collection]...)
    ) end

ui[:units] = radiobuttons(["ft", "m"], stack=false)
ui[:units_mask] = mask([ ui[:units] ], index=0)
