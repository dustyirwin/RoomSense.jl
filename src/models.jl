
function make_segs_data(segs::SegmentedImage, img_fln::String, X=[], Y=[], img_slices=Dict())
    img = Gray.(load(img_fln))
    bs = get_segment_bounds(segs)
    n = length(segment_labels(segs))

    for i in keys(segment_labels(segs))
        seg_type32 = Float32.(zeros(12))  # TODO: write func for csv space_type ground-truth data as a OHVF32

        img_slice = try img[bs[i]["t"]:bs[i]["b"], bs[i]["l"]:bs[i]["r"]] catch; rand(128,128,1,1) end
        img_slice = height(img_slice) > 1 && width(img_slice) > 1 ? imresize(img_slice, 128, 128) : rand(128,128,1)
        img_slice32 = Float32.(img_slice)
        img_slices[i] = reshape(img_slice32, 128,128,1,1)

        push!(X, img_slice32)
        push!(Y, seg_type32)
    end

    X = reshape(vcat(X...), (128,128,1,n)) |> gpu
    Y = reshape(vcat(Y...), (12,n)) |> gpu

    return ([(X, Y)], img_slices) end

function update_model(model, data::Tuple{Array{Float32,4},Array{Float32,2}}, epochs::Int64)
    data |> gpu
    model |> gpu
    loss(x, y) = Flux.crossentropy(model(x), y)
    @show @time Flux.@epochs epochs Flux.train!(loss, params(model), data, ADAM(0.001))
    return model end

function get_segs_types(segs::SegmentedImage, img_fln::String, model::Chain, segs_types=Dict())
    img_slices = make_segs_data(segs, img_fln)[2]
    model = model |> gpu

    for (label, img_slice) in img_slices
        img_slice = img_slice |> gpu
        pred_vec = model(img_slice)
        segs_types[label] = primary_space_types[findall(pred_vec .== maximum(pred_vec))[1][1]] end
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
    Dense(512, 12, swish),
    softmax)

@save "./models/space_type_classifier.BSON" m
"""

@load "./models/space_type_classifier.BSON" m

primary_space_types = Dict(
    1 => "Building Support",       2 => "Process",
    3 => "Public Access",          4 => "Storage",
    5 => "Refrigerated Storage",   6 => "Parking",
    7 => "Exterior",               8 => "Exterior",
    9 => "Office/Classroom",       10 => "Common Areas",
    11 => "Living Quarters",       12 => "Unknown"
    )
