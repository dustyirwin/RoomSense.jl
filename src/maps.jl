
maptypes = ["roadmap", "satellite", "hybrid", "terrain"]

map = (
    lat=45,
    lng=90,
    width=600,
    height=300,
    frameborder=0) -> node(:iframe,
        style=Dict("border"=>0),
        src="https://www.google.com/maps/embed/v1/view?"*
            "zoom=13&"*
            "center=$lat%2C$lng&"*
            "key=$maps_api_key"
            )

map_url_from_address(; address=home, zoom=13, width=600, height=300, api_key=maps_api_key) =
    "https://maps.googleapis.com/maps/api/staticmap?"*
    "center=$address&"*
    "zoom=$zoom&"*
    "size=$(width)x$height&"*
    "maptype=roadmap&"*
    "key=$api_key"

map_url_from_latlng(; address=home, zoom=13, width=600, height=300, api_key=maps_api_key) =
    "https://maps.googleapis.com/maps/api/staticmap?"*
    "latlng=$lat,$lng&"*
    "zoom=$zoom&"*
    "size=$(width)x$height&"*
    "maptype=roadmap&"*
    "key=$api_key"

latlng_url_from_address(; address=home, api_key=maps_api_key) =
  "https://maps.googleapis.com/maps/api/geocode/json?"*
  "address=$address&"*
  "key=$api_key"

address_from_latlng_url(; lat=45, lng=150, api_key=maps_api_key) =
    "https://maps.googleapis.com/maps/api/geocode/json?"*
    "latlng=$(lat),$(lng)&"*
    "key=$api_key"

#latlng_url = replace(latlng_url_from_address(), " "=>"+")

#download(latlng_url, "latlng.json")
