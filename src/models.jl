"""
model = GoogleNet()

dims = size(m.layers[end-1].W)[2]
new_layer = Dense(dims, 20)
model = Chain(m.layers[1:end-1], new_layer, m.layers[end])


Flux.testmode!(model.layers, false)
opt = ADAM(params(model.layers[end-1]), 0.0001)
loss(x, y) = Flux.crossentropy(model(x), y)
one_hot = zeros(20); one_hot[1] = 1
data = [img, one_hot]

Flux.@epochs 5 Flux.train!(loss, data, opt)
"""
