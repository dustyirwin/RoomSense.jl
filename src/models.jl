using CuArrays
using Flux
using Flux: crossentropy, train!, @epochs
using Metalhead

@load "./models/SqueezeNet_50g.bson" sn_50g

function make_segs_data(segs::SegmentedImage, segs_types::Dict, img::Matrix, X=[], Y=[], img_slices=Dict())
    bs = get_segment_bounds(segs)
    n = length(segs_types)

    for i in keys(segs_types)
        onehot = Flux.onehot(segs_types[i], collect(values(detailed_space_types)))

        img_slice = try img[bs[i]["t"]:bs[i]["b"], bs[i]["l"]:bs[i]["r"]] catch; continue end
        img_slice32 = Float32.(imresize(img_slice, (128,128)))
        img_slices[i] = img_slice32

        push!(X, img_slice32)
        push!(Y, onehot) end

    X = reshape(vcat(X...), (128,128,1,n)) |> gpu
    Y = reshape(vcat(Y...), (50,1,n)) |> gpu

    return ([(X, Y)], img_slices) end

function update_model(model, data::Tuple{Array{Float32,4},Array{Float32,2}}, epochs::Int64)
    data |> gpu
    model |> gpu
    loss(x, y) = crossentropy(model(x), y)
    @show @time @epochs epochs train!(loss, params(model), data, ADAM(0.001))

    return model end

function get_segs_types(segs::SegmentedImage, img_fln::String, model::Chain, segs_types=Dict(), img_slices=Dict())
    bs = get_segment_bounds(segs)

    for i in segment_labels(segs)
        img_slice = try img[bs[i]["t"]:bs[i]["b"], bs[i]["l"]:bs[i]["r"]] catch; continue end
        img_slice32 = Float32.(imresize(img_slice, (128,128)))
        img_slices[i] = img_slice32 end

    model = model |> gpu

    for (label, img_slice) in img_slices
        img_slice = img_slice |> gpu
        pred_vec = model(img_slice)
        segs_types[label] = detailed_space_types[findfirst(pred_vec .== maximum(pred_vec))[1][1]] end

    return segs_types end


"""
# 128x128x1 convolutional image classifier (12 classes)
m = Chain(
    Conv((3, 3), 1=>16, relu, pad=(1,1)), MaxPool((2,2)),
    Conv((3, 3), 16=>32, relu, pad=(1,1)), MaxPool((2,2)),
    Conv((3, 3), 32=>64, relu, pad=(1,1)), MaxPool((2,2)),
    Conv((3, 3), 64=>32, relu, pad=(1,1)), MaxPool((2,2)),
    Conv((3, 3), 32=>32, relu, pad=(1,1)), MaxPool((2,2)),
    x -> reshape(x, :, size(x, 4)),
    Dense(512, 256, swish),
    Dense(256, 50, swish),
    softmax)

@save "./models/space_type_classifier.BSON" m
"""
