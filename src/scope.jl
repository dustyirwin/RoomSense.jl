
const ObsDict = Dict{String, Tuple{Observables.AbstractObservable, Union{Nothing,Bool}}}

function _scope(session::Dict)
    ui = session[:ui]
    s = session[:s]
    i = session[:i]

    begin

    scope = session[:scope] = Scope(
        observs=ObsDict("$k"=>(v, nothing)
            for (k,v) in ui if v isa Observables.AbstractObservable)
        );

    img_click = ui[:img_click] = Observable(scope, "img_click", Union{Int,Bool}[]);
    func_keydown = ui[:func_keydown] = Observable(scope, "keydown", Union{Int,Bool}[]);

    for k in ui[:img_syms]
        ui[Symbol("$(k)_img")][] = make_clickable_img("$(k)_img", img_click, "", opacity=.9)
        end

    func_panel = vbox(
        hbox(ui[:func_tabs], hskip(.5em),
            vbox(vskip(.5em), ui[:img_info])),
        vskip(1em),
        hbox(hskip(1em),
            ui[:go], hskip(.5em),
            ui[:funcs_mask], hskip(.5em),
            ui[:inputs_mask], hskip(.5em),
            ui[:units_mask], hskip(.5em),
            vbox(vskip(.5em), hbox(values(ui[:checkbox_masks])..., hskip(.5em), ui[:click_info]))
        ),
        hbox(hskip(1em), ui[:information]),
        ui[:img_tabs],
        );

    html = vbox(
        node(:div, ui[:img_url_mask]),
        node(:div, func_panel),
        node(:div, [
            node(:div, ui[mask], style=Dict("id"=>"$mask", "z-index"=>"$i"))
                for (j, mask) in enumerate([
                    :user_mask,
                    :segs_mask,
                    :overlay_mask,
                    :highlight_mask,
                    :labels_mask,
                    :seeds_mask,
                    :plots_mask,
                    :gmap_mask,  # TODO: find magic combo that overlays user img over gmap
                ]) ]...,
            ),
        ui[:confirm],
        ui[:alert],
        )

    scope.dom = html
    return session
end end
