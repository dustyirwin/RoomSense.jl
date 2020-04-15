
map_controls = OrderedDict(k=>button(k) for k in ["↑", "↓", "←", "→", "↷","↶","+","-"])

map_url_from_latlng(lat, lng, zoom, w, h) =
    "https://maps.googleapis.com/maps/api/staticmap?"*
    "latlng=$lat,$lng&"*
    "zoom=$zoom&"*
    "size=$(w)x$h&"*
    "maptype=satellite&"*
    "key=$maps_api_key"

function update_map(; scope=scope, lat=45.5051, lng=-122.6750, zoom=5, w=600, h=400, rotation=0.)
    buffer = 20
    try w = width(s[ wi[] ]["Original_img"]) catch end
    try h = height(s[ wi[] ]["Original_img"]) catch end
    dirty_url = map_url_from_latlng(lat, lng, zoom, w, h)
    clean_url = replace(dirty_url, [" "=>"+",]...)
    download(clean_url, "./tmp/gmap.jpg")
    # apply rotation to gmpa.jpg or rotate img_container?
    scope.observs["map"][1][] = node(:img, src=register("./tmp/gmap.jpg"))
end


map_url_from_address(; address=home, zoom=17, width=500, height=300) =
    "https://maps.googleapis.com/maps/api/staticmap?"*
    "center=$address&"*
    "zoom=$zoom&"*
    "size=$(width)x$height&"*
    "maptype=satellite&"*
    "key=$maps_api_key"

latlng_url_from_address(; address=home) =
    "https://maps.googleapis.com/maps/api/geocode/json?"*
    "address=$address&"*
    "key=$maps_api_key"

address_from_latlng_url(; lat=45, lng=150) =
    "https://maps.googleapis.com/maps/api/geocode/json?"*
    "latlng=$(lat),$(lng)&"*
    "key=$map_api_key"

map(w=600, h=450, zoom=17, lat=45.3463, lng=-122.5931) = node(:iframe,
    width="$w",
    height="$h",
    frameborder="0",
    style=Dict("border"=>"0"),
    src="https://www.google.com/maps/embed/v1/view?"*
        "zoom=$zoom&"*
        "center=$lat,$lng&"*
        "key=$maps_api_key&"
    )
