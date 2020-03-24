
function go_pressed(ui)
    println("go pressed!")

    fn = get_img_from_url(ui["img_url"][])
    rfn = register(fn)
    ui["imgs"]["original"].props[:attributes]["src"] = rfn
end


fn = get_img_from_url(ui["img_url"][])
rfn = register(fn)
