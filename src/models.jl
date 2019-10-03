using Flux
using Zygote
using CuArrays
using JLD2: @save, @load


function make_segs_data(segs::SegmentedImage, img_fln::String, X=[], Y=[])
    img = Gray.(load(img_fln))
    bs = get_bounds(segs)
    n = length(segment_labels(segs))

    for i in 1:n
        seg_type32 = Float32.(zeros(12))
        seg_type32[rand(1:12)] = 1.  # random space_type

        img_slice = img[bs[i]["t"]:bs[i]["b"], bs[i]["l"]:bs[i]["r"]]
        img_slice = imresize(img_slice, 128, 128)
        img_slice32 = Float32.(img_slice)

        push!(X, img_slice32)
        push!(Y, seg_type32)
    end

    X = reshape(vcat(X...), (128,128,1,n)) |> gpu
    Y = reshape(vcat(Y...), (11,n)) |> gpu

    return [(X, Y)] end

function update_model(model, data, epochs::Int64)
    data |> gpu
    model |> gpu
    loss(x, y) = Flux.crossentropy(model(x), y)
    @show @time Flux.@epochs epochs Flux.train!(loss, params(model), data, ADAM(0.001))
    @save "./models/space_type_classifier.jld2" model
    return model end


"""
# 128x128x1 convolutional image classifier (10 classes)
model = Chain(
    Conv((3, 3), 1=>16, relu, pad=(1,1)), MaxPool((2,2)),
    Conv((3, 3), 16=>32, relu, pad=(1,1)), MaxPool((2,2)),
    Conv((3, 3), 32=>64, relu, pad=(1,1)), MaxPool((2,2)),
    Conv((3, 3), 64=>32, relu, pad=(1,1)), MaxPool((2,2)),
    Conv((3, 3), 32=>32, relu, pad=(1,1)), MaxPool((2,2)),
    x -> reshape(x, :, size(x, 4)),
    Dense(512, 12, swish),
    softmax)
@save "./models/space_type_classifier.jld2" model
"""

try @load "./models/space_type_classifier.jld2" model catch err; println(err) end

primary_space_types = Dict(
    1 => "Building Support",       2 => "Process",
    3 => "Public Access",          4 => "Storage",
    5 => "Refrigerated Storage",   6 => "Parking",
    7 => "Exterior",               8 => "Exterior",
    9 => "Office/Classroom",       10 => "Common Areas",
    11 => "Living Quarters",       12 => "Unknown"
    )
