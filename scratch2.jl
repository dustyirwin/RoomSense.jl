
using WebIO


fieldnames(typeof(ui["dropbox_url"]))

ui["dropbox_url"].components[:value].val = "hello user!"

segs_img = node(:img, attributes=Dict("alt"=>"segment image here", "src"=>""))

tpage = node(:div,
    node(:a, segs_img, attributes=Dict("href"=>"/")))

segs_img.props[:attributes]["src"]
tpage.children.tail[1].props[:attributes]["src"] = rfn1
tpage
fn1 = "/home/dusty/OneDrive/Documents/Personal_Projects/RoomSense.jl/tmp/1_test.png"
fn2 = "/home/dusty/OneDrive/Documents/Personal_Projects/RoomSense.jl/tmp/fp1.jpg"

img = load(fn)

rfn1 = Observable("")
rfn2 = Observable("")

rfn1[] = register(fn1)
rfn2[] = register(fn2)

webio_serve(page("/",req->tpage), 8001)

fieldnames(typeof(tpage.children.tail[1]))

but = button();

but = dom"button"(
    "Greet",
     events=Dict(
        "click" => js"function() { alert('Hello, World!'); }",
        ),
)

function myapp(req)
    global but
    segs_img.props[:attributes]["src"] = rand(Bool) ? rfn1 : rfn2
    return but
end

using WebIO


server = webio_serve(page("/", req -> stacked), 8003)

stacked = Mux.stack(page("/", button("But 1")), page("/", button("But 2"))
)
``
app = @app button("hallo")
serve(button())


Observables.@on println(&rfn1, &rfn2)

butt = dom"button"(
    "Greet",
     events=Dict(
        "click" => js"function() { alert('Hello, World!'); }",
        ))

using Mux

im load()

@app test = (
  Mux.defaults,
  page(respond("<h1>Hello World!</h1>")),
  page("/about",
       probabilty(0.1, respond("<h1>Boo!</h1>")),
       respond("<h1>About Me</h1>")),
  page("/user/:user", req -> "<h1>Hello, $(req[:params][:user])!</h1>"),
  page("/butts", respond(butt)),
  Mux.notfound())

serve(test, 8050)
