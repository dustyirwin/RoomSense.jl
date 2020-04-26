
const ObsDict = Dict{String, Tuple{Observables.AbstractObservable, Union{Nothing,Bool}}}

ui[:scope] = Scope(
    observs=ObsDict("$k"=>(v, nothing)
        for (k,v) in ui if v isa Observables.AbstractObservable)
    );

ui[:img_click] = Observable(ui[:scope], "img_click", Union{Int,Bool}[]);
ui[:img_keydown] = Observable(ui[:scope], "keystroke", Union{Int,Bool}[]);


for k in [:user_img, :segs_img]
    img_name = "$k"
    ui[:imgs][k][] = make_clickable_img(img_name, ui[:img_click], ui[:img_keydown], opacity=1.)
    end

ui[:func_panel] = vbox(
    hbox(ui[:func_tabs], hskip(0.5em),
        vbox(vskip(0.5em), ui[:step]), hskip(0.5em),
        vbox(vskip(0.5em), ui[:img_info])),
    vskip(1em),
    hbox(hskip(1em),
        ui[:go], hskip(0.5em),
        ui[:funcs_mask], hskip(0.5em),
        ui[:inputs_mask], hskip(0.5em),
        ui[:units_mask], hskip(0.5em),
        vbox(vskip(0.5em), hbox(values(ui[:checkbox_masks])..., hskip(0.5em), ui[:click_info]))
    ),
    hbox(hskip(1em), ui[:information]),
    ui[:img_tabs],
    );

ui[:img_masks][:user_mask][:index][] = 1


ui[:/] = () -> node(:div,
    ui[:confirm],
    ui[:alert],
    node(:div,
        ui[:func_panel],
        attributes=Dict("classList"=>"navbar", "position"=>"fixed")),
    ui[:img_url_mask],
    node(:div,
        ui[:user_mask],
        ui[:segs_mask],
        ui[:overlay_mask],
        ui[:labels_mask],
        # ui[:seeds_mask],
        ui[:highlight_mask],
        ui[:gmap_mask],
        ui[:plots_mask],
        ),
    )

ui[:scope].dom = ui[:/]()
