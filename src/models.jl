"""
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


#X = imgFloat32 |> gpu
#Y = OHV |> gpu

data = [(X,Y)]

m = update_model(model, data, 10)
vec = @time m(X)
vec

model = model |> cpu
@save "./models/space_type_classifier.jld2" model

try @load "./models/space_type_classifier.jld2" model catch err; println(err) end
"""
