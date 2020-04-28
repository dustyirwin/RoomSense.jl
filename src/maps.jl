
latlng_url_from_address(address="775+Cascade+St+Oregon+City+OR+USA") =
    "https://maps.googleapis.com/maps/api/geocode/json?"*
    "address=$address&"*
    "key=$maps_api_key"


latlng_url = latlng_url_from_address()
download(latlng_url, "./tmp/latlng.json")


function update_gmap(address="Cadmus Office, Portland, OR")
    latlng_url = latlng_url_from_address(address)
    latlng_url = replace(latlng_url, " "=>"+")
    json_fn = "./tmp/latlong_$(now())_.json"

    download(latlng_url, json_fn)
    latlng_json = JSON.Parser.parse(open(json_fn))
    s[i][:lat] = latlng_json["results"]["geometry"]["location"]["lat"]
    s[i][:lng] = latlng_json["results"]["geometry"]["location"]["lng"]

    ui[:gmap][] = gmap(
        h=s[i][:user_height],
        w=s[i][:user_height],
        lat=s[i][:lat],
        lng=s[i][:lng],
    ) end

gmap(
    h=600,
    w=800,
    lat=45.3463,
    lng=-122.593;
    zoom=17,
    ) = node(:div,
        node(:iframe,
            id="gmap",
            height="$h",
            width="$w",
            frameborder="0",
            allowfullscreen=true,
            style=Dict(
                "border" => "0",
                "left" => "0",
                "top" => "0",
                "height" => "75%",
                "width" => "100%",
                "position" => "absolute"),
            src="https://www.google.com/maps/embed/v1/view?"*
                "zoom=$zoom&" *
                "center=$lat,$lng&" *
                "key=$maps_api_key&"
            ),
        style=Dict(
            "opacity" => "0.8",
            "overflow" => "hidden",
            "padding-bottom" => "56.25%",
            "position" => "relative",
            "height" => "0",
            )
    )




###


map_url_from_latlng(lat, lng, zoom, w, h) =
    "https://maps.googleapis.com/maps/api/staticmap?"*
    "latlng=$lat,$lng&"*
    "zoom=$zoom&"*
    "size=$(w)x$h&"*
    "maptype=satellite&"*
    "key=$maps_api_key"

map_url_from_address(; address=home, zoom=17, width=500, height=300) =
    "https://maps.googleapis.com/maps/api/staticmap?"*
    "center=$address&"*
    "zoom=$zoom&"*
    "size=$(width)x$height&"*
    "maptype=satellite&"*
    "key=$maps_api_key"


address_from_latlng_url(; lat=45, lng=150) =
    "https://maps.googleapis.com/maps/api/geocode/json?"*
    "latlng=$(lat),$(lng)&"*
    "key=$map_api_key"

###
