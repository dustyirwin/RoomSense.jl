"""
import googlemaps api to calibrate map scale
"""

home = "775 Cascade St Apt 801, Oregon City, OR"
map_w = 800
map_h = 600

map_url(; address=home, zoom=13, width=600, height=300, api_key=google_api_key) =
    "https://maps.googleapis.com/maps/api/staticmap?"*
    "center=$address&"*
    "zoom=$zoom&"*
    "size=$(width)x$height&"*
    "maptype=roadmap&"*
    "key=$api_key"


mul = map_url(width=map_w,height=map_h)
download(mul, "./tmp/map.jpg")


coords_url(; address=home, api_key=google_api_key) =
  "https://maps.googleapis.com/maps/api/geocode/json?"*
  "address=$address&"*
  "key=$api_key"


coords = coords_url()


node(:img, attributes=Dict("src"=>maps_url))

node(:div, attributes=Dict("id"=>"map"))


js = """<script>
// Initialize and add the map
function initMap() {
  // The location of Uluru
  var uluru = {lat: -25.344, lng: 131.036};
  // The map, centered at Uluru
  var map = new google.maps.Map(
      document.getElementById('map'), {zoom: 4, center: uluru});
  // The marker, positioned at Uluru
  var marker = new google.maps.Marker({position: uluru, map: map});
}
    </script>
    <!--Load the API from the specified URL
    * The async attribute allows the browser to render the page while the API loads
    * The key parameter will contain your own API key (which is not needed for this tutorial)
    * The callback parameter executes the initMap() function
    -->
    <script async defer
    src="https://maps.googleapis.com/maps/api/js?key=$(google_api_key)&callback=initMap">
    </script>"""

Interact.CSSUtil.alignitems( )
