
img_selected_handler = on(ui["dropbox_url"]) do fn
    #global s, ui

    s[wi]["img_fln"] = dropbox_img_fn(fn)
    s[wi]["user_img"] = load(ui["img_fln"][])
    s[wi]["_alpha.png"] = make_transparent(s[wi]["user_img"])

    img_info = "height: $(height(s[wi]["user_img"]))  width: $(width(s[wi]["user_img"]))"

    if haskey(s[wi], "_pxplot.svg"); delete!(s[wi], "_pxplot.svg") end
    if haskey(s[wi], "_labels.png"); delete!(s[wi], "_labels.png") end
    if haskey(s[wi], "_seeds.png"); delete!(s[wi], "_seeds.png") end

    # load img into ui["imgs"]["original"]
end
