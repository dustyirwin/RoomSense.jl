
build_ui = (req=Dict()) -> begin
    ui = OrderedDict(
        "go" => button("Go!", href="/results"),
        "checkboxes" => OrderedDict(
            "overlay_alpha"=>checkbox(value=true; label="Overlay"),
            "draw_seeds"=>checkbox(value=false; label="Seeds"),
            "draw_labels"=>checkbox(value=false; label="Labels"),
            "colorize"=>checkbox(value=false, label="Colorize"),
            "predict_space_type"=>checkbox(value=false, label="SpacePred"),
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
                    "Fast Scanning"=>(fast_scanning, Float64),
                    "Felzenszwalb"=>(felzenszwalb, Int64),
                    "Seeded Region Growing"=>(seeded_region_growing, Vector{Tuple{CartesianIndex,Int64}})),
            ),
            "Modify Segments"=>dropdown(
                OrderedDict(
                    "Prune Segments by MGS"=>(prune_min_size, Vector{Int64}, Float64),
                    "Prune Segment(s)"=>(remove_segments, String),
                    "Assign Space Types"=>(launch_space_editor, String)),
            ),
            "Export Data"=>dropdown(
                OrderedDict(
                    "Export Segment Data to CSV"=>(export_CSV, String),
                    "Export Session Data"=>(export_session_data, String)),
            ),
        ),
        "imgs" => OrderedDict(
            "original" => node(:img, attributes=Dict("id"=>"original",
                "src"=>"", "alt"=>"Check ngrok?", "style"=>"opacity: 0.9;", )),
            "segs" => node(:img, attributes=Dict("src"=>"", "alt"=>"Error!",
                "style"=>"opacity: 0.9;")),
            "plot" => node(:img, attributes=Dict("src"=>"", "alt"=>"Error!",
                "style"=>"opacity: 1.0;")),
            "overlay" => node(:img, attributes=Dict("src"=>"", "alt"=>"Error!",
                "style"=>"position: absolute; top: 0px; left: 0px; opacity: 0.9;"))
        ),
        "font" => newface("./fonts/OpenSans-Bold.ttf"),
        "font_size" => 30,
        "img_fn" => filepicker("Load Image"),
        "dropbox_url" => textbox("Paste DropBox img link here"),
        "input" => textbox("See instructions below...", attributes=Dict("size"=>"60")),
        "help_texts" => Dict(
            fast_scanning=>"Input is the threshold value, range in {0, 1}. Recursive: max_segs, mgs. e.g. '50, 2000'",
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
        "img_info" => node(:p, ""),
        "scale_info" => node(:p, ""),
        "segs_info" => node(:strong, ""),
        "work_index" => node(:strong, "1",
         attributes=Dict("style"=>"buffer: 5px;")),
        );

    ui["img_tabs"] = tabulator(
        Observable(
            OrderedDict(
                "Original" => node(:div, ui["imgs"]["original"]),
                "Segmented" => node(:div, ui["imgs"]["segs"]),
                "Segs Plot" => node(:div, ui["imgs"]["plot"]),))
    );
    ui["funcs"] = tabulator(
        Observable(
            OrderedDict(
                dropdown => node(:div,
                    vbox(
                        hbox(hskip(0.6em),
                            ui["go"], hskip(0.6em),
                            ui["dropdowns"][dropdown], hskip(0.6em),
                            ui["input"], hskip(0.6em),
                            vbox(
                                vskip(0.2em),
                                ui["segs_info"],
                )))) for dropdown in collect(keys(ui["dropdowns"]))))
    );
    ui["toolbox"] = vbox(
        hbox(
            ui["funcs"], hskip(1em),
            ui["dropbox_url"], hskip(1em),
            ui["img_info"], hskip(0.25em),
            ui["scale_info"],)
    );
    ui["image_display"] = node(:div,
        hbox(ui["img_tabs"], hskip(1em),
        vbox(vskip(0.5em), ui["work_index"]), hskip(1em),
        collect(values(ui["checkboxes"]))...),
        attributes=Dict(
            "id"=>"image_display",
            "style"=>"position: relative; padding: 0px; border: 0px; margin: 0px;",
            "onclick"=>"""click = [
                event.pageY - document.getElementById("img_container").offsetTop,
                event.pageX,
                document.getElementById("display_img").height,
                document.getElementById("display_img").width,
                document.getElementById("display_img").naturalHeight,
                document.getElementById("display_img").naturalWidth,
                event.ctrlKey,
                event.shiftKey,
                event.altKey];""")
    );
    ui["html"] = node(:div,
        node(:div, ui["toolbox"], attributes=Dict("classList"=>"navbar", "position"=>"fixed")),
        node(:div, ui["image_display"], attributes=Dict("position"=>"relative"))
    );

    return ui
end
