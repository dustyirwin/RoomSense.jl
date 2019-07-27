"""
X = rand(128,128,1,25) |> gpu
Y = zeros(Float32,10,25) |> gpu
data = [(X,Y)]

# 128x128x1 convolutional image classifier (10 classes)
model = Chain(
    Conv((3, 3), 1=>16, relu, pad=(1,1)), MaxPool((2,2)),
    Conv((3, 3), 16=>32, relu, pad=(1,1)), MaxPool((2,2)),
    Conv((3, 3), 32=>64, relu, pad=(1,1)), MaxPool((2,2)),
    Conv((3, 3), 64=>32, relu, pad=(1,1)), MaxPool((2,2)),
    Conv((3, 3), 32=>32, relu, pad=(1,1)), MaxPool((2,2)),
    x -> reshape(x, :, size(x, 4)),
    Dense(512, 10, swish),
    softmax) |> gpu

@time model(rand(128,128,1,1)|>gpu)

#try using CuArrays catch err; println(err) end

function update_model(model, data, epochs::Int64)
    model = model|>gpu
    loss(x, y) = Flux.crossentropy(model(x), y)
    @time Flux.@epochs epochs Flux.train!(loss, params(model), data, ADAM(0.001))
    model = model|>cpu
    @save "./models/space_type_classifier.jld2" model
end

#try @load "./models/space_type_classifier.jld2" model catch err; println(err) end
"""
