
const ObsDict = Dict{String, Tuple{Observables.AbstractObservable, Union{Nothing,Bool}}}

ui[:scope] = Scope(
    observs=ObsDict("$k"=>(v, nothing)
        for (k,v) in ui if v isa Observables.AbstractObservable))

ui[:img_click] = Observable(ui[:scope], "img_click", Union{Int,Bool}[])

for k in [:original_img, :segs_img]
    img_name = "$k"
    ui[:imgs][k][] = make_clickable_img(img_name, ui[:img_click])
    end

ui[:func_panel] = vbox(
    hbox(ui[:func_tabs], hskip(1em),
        vbox(vskip(0.5em), node(:strong, "Rev: $i")), hskip(1em),
        vbox(vskip(0.3em), ui[:img_url_input]), hskip(1em),
        vbox(vskip(0.5em), ui[:img_info])),
    vskip(1em),
    hbox(hskip(1em),
        ui[:go_mask], hskip(0.5em),
        ui[:funcs_mask], hskip(0.5em),
        ui[:inputs_mask], hskip(0.5em),
        vbox(vskip(0.5em), hbox(values(ui[:checkbox_masks])..., hskip(0.5em), ui[:click_info]))
    ),
    hbox(hskip(1em), ui[:information]), vskip(0.7em),
    ui[:img_tabs],
    );

ui[:img_masks][:original_mask][:index][] = 1


ui[:/] = () -> node(:div,
    ui[:confirm],
    node(:div, ui[:func_panel], attributes=Dict(
        "classList"=>"navbar", "position"=>"fixed")),
    node(:div,
        ui[:original_mask],
        ui[:segs_mask],
        ui[:overlay_mask],
        ui[:labels_mask],
    ));

ui[:scope].dom = ui[:/]()
