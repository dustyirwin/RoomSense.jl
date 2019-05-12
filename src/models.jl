@load "./models/GoogleNet20.jld2" m; m;

# Construct model from GoogleNet
function make_model(classes::Int64)
    m = GoogleNet()
    tail = Chain(Dense(1024, classes), m.layers[end])
    head = m.layers[1:end-2]
    return Chain(head, tail) end
