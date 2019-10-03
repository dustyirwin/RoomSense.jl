using Flux
using Zygote
using CuArrays
using JLD2: @save, @load

function update_model(model, data, epochs::Int64)
    loss(x, y) = Flux.crossentropy(model(x), y)
    @show @time Flux.@epochs epochs Flux.train!(loss, params(model), data, ADAM(0.001))
    return model end


function classify_space_types(model, data, segs)
    return "MAGICAL AI WIZARDY HERE"
end

function make_dataset(segs::SegmentedImage, user_img:: , space_types::Dict)
    return "All the DATAZ!"
end

"""
# 128x128x1 convolutional image classifier (10 classes)
m = Chain(
    Conv((3, 3), 1=>16, relu, pad=(1,1)), MaxPool((2,2)),
    Conv((3, 3), 16=>32, relu, pad=(1,1)), MaxPool((2,2)),
    Conv((3, 3), 32=>64, relu, pad=(1,1)), MaxPool((2,2)),
    Conv((3, 3), 64=>32, relu, pad=(1,1)), MaxPool((2,2)),
    Conv((3, 3), 32=>32, relu, pad=(1,1)), MaxPool((2,2)),
    x -> reshape(x, :, size(x, 4)),
    Dense(512, 11, swish),
    softmax)
"""

#X = imgFloat32 |> gpu
#Y = OHV |> gpu

try @load "./models/space_type_classifier.jld2" model catch err; println(err) end

primary_space_types = Dict{Float32, String}(
    1. => "Building Support",       2. => "Process",
    3. => "Public Access",          4. => "Storage",
    5. => "Refrigerated Storage",   6. => "Parking",
    7. => "Exterior",               8. => "Exterior",
    9. => "Office/Classroom",       9. => "Common Areas",
    10. => "Living Quarters",       11. => "Unknown"
    )
