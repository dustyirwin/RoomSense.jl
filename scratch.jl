@time include("SpaceCadet.jl")


@js_ w document.getElementById("go").classList = ["button is-loading"];
if n_labels > 300

warning_text = "                          WARNING!
You are attempting to draw $n_labels labels.
This could take a very long time to complete.
                        Are you sure?"

@js_ w proceed=confirm($warning_text)
if @js w proceed
    return
else @js_ w document.getElementById("go").classList = ["button is-primary"];
end

@js w proceed
@js_ w document.getElementById("go").classList = ["button is-primary"];



# Diag tools
# tools(w)
# using Debugger


rgb = @manipulate for r = 0:.05:1, g = 0:.05:1, b = 0:.05:1
    HTML(string("<div style='color:#", hex(RGB(r,g,b)), "'>Color me</div>"))
end

@js_ w document.getElementById("segs_details").innerHTML = $segs_details

dom"div"(dropdown_obs[1])

close(w)
for i in 1:100 @time (1 in (1, 2, 3)) end
rbs = radiobuttons(OrderedDict(1=>1,2=>2,3=>3))

nots = notifications([]; layout = node(:div))
nots[] = ["2"]

using Interact
observe(nots)


@async try
    somefunc()
  catch exc
    @error(
      "An error occurred while trying to do a thing!",
      exception=exc,
      )
end

@js_str

using Images

img_url = ui["dropbox_img_link"][]

function dropbox_img_fn(img_url::String)
    fn = mktemp() do fn, f
        global img_url
        img_url = replace(img_url, "0"=>"1")
        fn = "." * fn
        download(img_url, fn)
        return fn
end end

img = load(fn)

load(dropbox_img_fn(img_url))
dblink = "https://www.dropbox.com/s/tbyrfc68iwenq5w/1st_Flr_cleaned.JPG?dl=0"
dbimg = download(dblink)
fn = "https://1drv.ms/u/s!AqpjBcixuEpcwkwGGrHWHsaFXjkd"



img = try load(fn) catch ui[""]
latex("\\sum_{i=1}^{\\infty} e^i")

wdg = alert("Error!")
wdg()

using WebIO
ui["dropbox_url"][]
typeof(ui["go"])
ui["go"].components[Symbol("is-loading")].val = true
ui["dropbox_url"].components[:value].val = "Hello dolly!"
ui["html"]

ui["dropbox_url"][]

ui["image_display"]
fieldnames(typeof(ui["imgs"]["original"]))

img_fn = dropbox_img_fn(ui["dropbox_url"][])

ui["imgs"]["original"].props[:attributes]["src"] = img_fn






fieldnames(typeof(user_img.children.tail[1]))

user_img.children.tail[1].props[:attributes]["src"] = "/home/dusty/OneDrive/Documents/Personal_Projects/RoomSense.jl/tmp/1_test.png"


img = load("/home/dusty/OneDrive/Documents/Personal_Projects/RoomSense.jl/tmp/1_test.png")

im_reg = register("/home/dusty/OneDrive/Documents/Personal_Projects/RoomSense.jl/tmp/1_test.png")

segs_img = Observable(node(:img, attributes=Dict("href"=>"$im_reg")))





fieldnames(typeof(ui["display_options"]))

ui["display_options"].props[:attributes]["hidden"] = false
ui["html"]


ui["dropdown"]["segs_funcs"]



fn = ui["dropbox_url"][]


tmp_files = readdir("./tmp/")



using Gadfly
using Interact

plot(y=rand(10))


ui["dropdown"][] = ui["dropdown"]
fieldnames(typeof(ui["dropdown"]))

wdg = mask(OrderedDict("plot" => plot(y=rand(10)), "scatter" => plot(y=rand(50))), key = "plot")

wdg

wdg.components[:key][] = "plot"
wdg[:options] = ["this is great"
tabulator(OrderedDict("plot" => plot(rand(10)), "scatter" => scatter(rand(10))), key = "plot")


h_img_click = on(ui["dropbox_url"]) do val
    println("Got an update: ", val)
end


maskt = mask(Observable(["a","b","c"]))
maskt[] = [2, 3]

const Struct Pane
    img::Matrix

end

fieldnames(typeof(ui["imgs"]["original"]))

using Mux

@app serve_imgs = (
  Mux.defaults,
  page(respond("<h1>Hello World!</h1>")),
  page("/imgs/:img", req -> node(:img,src="/tmp/$(req[:params][:img]).jpg")),
  Mux.notfound())

serve(serve_imgs, 8001)


node(:img,alt="", href="$ri")

load("./tmp/jl_6jfjWv.jpg")

r_img = ImgURL(ri)

org = fieldnames(typeof(ui["imgs"]["original"]))
fieldnames(typeof(ui["imgs"]["display"](0.9)))



ri = ngrok * AssetRegistry.register("assets/astronaut.jpg")
ui["imgs"]["original"].props[:src] = ri

ui["img_display"]
riurl = ImgURL(ri)


ui["notifications"][] = []

ui["imgs"]


using WebIO

route("/img", page(render(r_img)), 8001)

const BASE_DIR = "/home/dusty/OneDrive/Documents/Personal_Projects/RoomSense.jl/"

route("/", page(ui["html"]))

fieldnames(typeof(ui["go"]))


fieldnames(typeof(ui["imgs"]["original"]))

ui["imgs"]["original"].props[:src] = ri

ui["imgs"]["original"]



ui["go"].components[Symbol("is-loading")].val = false
ui["go"].components[Symbol("is-warning")].val = true


route("/img/:fn::String") do
    serve_static_file("/tmp/$(@params(:fn))")
end




s[wi]["img_fln"] = dropbox_img_fn(fn)
s[wi]["user_img"] = load(s[wi]["img_fln"])
s[wi]["_alpha.png"] = make_transparent(s[wi]["user_img"])

tfn = s[wi]["img_fln"]
load(s[wi]["img_fln"])

node(:img, attributes=Dict("src"=>"$tfn", "alt"=>"error!"))
ui["imgs"]["original"]

fieldnames(typeof(ui["imgs"]["original"]))
