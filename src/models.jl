using CuArrays
using Flux
using Flux: crossentropy, train!, @epochs
using Metalhead

@load "./models/SqueezeNet_50g.bson" sn_50g

function make_segs_data(segs::SegmentedImage, segs_types::Dict, img::Matrix, X=[], Y=[], img_slices=Dict())
    bs = get_segment_bounds(segs)
    n = length(segs_types)
    DSTs = collect(values(detailed_space_types))

    for i in collect(keys(segs_types))
        onehot = Flux.onehot(segs_types[i], DSTs)
        img_slice = try img[bs[i]["t"]:bs[i]["b"], bs[i]["l"]:bs[i]["r"]] catch; n-= 1; continue end
        img_slices[i] = img_slice
        diff = abs(width(img_slice) - height(img_slice))

        img_slice = if width(img_slice) > height(img_slice)
            vcat(img_slice, zeros(diff, width(img_slice)))
        elseif width(img_slice) < height(img_slice)
            hcat(img_slice, zeros(height(img_slice), diff)) end

        try img_slice = imresize(img_slice, (128,128)) catch; n-=1; continue end

        push!(X, img_slice)
        push!(Y, onehot)
    end

    X = reshape(vcat(X...), (128,128,1,n))
    Y = reshape(vcat(Y...), (50,1,n))

    return ([(X, Y)], img_slices) end

function update_model(model::Chain, X::Array{Float32,4}, Y::Array{Float32,3}, inds::Array{Int64}, epochs::Int64)
    for i in inds
    try
        x = reshape(X[:,:,:,i], (128,128,1,1))
        y = reshape(Y[:,:,i], (50,1,1))

        loss(x, y) = Flux.mse(model(x), y)
        @epochs epochs train!(loss, params(model), [(x, y)], ADAM(0.001))
        print("Completed $epochs epochs of training on segment $i data.\n")
    catch err
        print("An error occured processing segment $(i)!\n")
    end end

    return model end

function get_segs_types(segs::SegmentedImage, img_fln::String, model::Chain, segs_types=Dict(), img_slices=Dict())
    bs = get_segment_bounds(segs)

    for i in segment_labels(segs)
        img_slice = try img[bs[i]["t"]:bs[i]["b"], bs[i]["l"]:bs[i]["r"]] catch; continue end
        img_slice32 = Float32.(imresize(img_slice, (128,128)))
        img_slices[i] = img_slice32 end

    for (label, img_slice) in img_slices
        img_slice = img_slice |> gpu
        pred_vec = model(img_slice)
        segs_types[label] = detailed_space_types[findfirst(pred_vec .== maximum(pred_vec))[1][1]] end

    return segs_types end
