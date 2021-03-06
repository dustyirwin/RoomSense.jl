
model = load("./models/squeeze_net_gray_50.bson")[:sn_g50]

function make_training_data(segs::SegmentedImage, segs_types::Dict, img::Matrix, X=[], Y=[])
    bs = get_segment_bounds(segs)
    n = length(segs_types)
    DSTs = collect(values(detailed_space_types))
    img = img

    for i in collect(keys(segs_types))
        onehot = Flux.onehot(segs_types[i], DSTs)

        for k in 1:height(img)
            for j in 1:width(img)
                if segs.image_indexmap[k,j] !== i
                    img[k,j] = 0
                end end end

        img_slice = img[bs[i]["t"]:bs[i]["b"], bs[i]["l"]:bs[i]["r"]]

        diff = abs(width(img_slice) - height(img_slice))

        img_slice = if width(img_slice) > height(img_slice)
                        vcat(img_slice, zeros(diff, width(img_slice)))
                    elseif width(img_slice) < height(img_slice)
                        hcat(img_slice, zeros(height(img_slice), diff)) end

        img_slice = imresize(img_slice, (128,128))

        push!(X, Float32.(img_slice))
        push!(Y, Float32.(onehot))
    end

    X = reshape(vcat(X...), (128,128,1,n))
    Y = reshape(vcat(Y...), (50,1,n))

    return (X, Y) end

function update_model(model::Chain, X::Array{Float32,4}, Y::Array{Float32,3}, inds::Array{Int64}, epochs::Int64)
    for i in inds
        x = X[:,:,:,i:i]
        y = Y[:,:,i:i]

        loss(x, y) = Flux.mse(model(x), y)
        @epochs epochs train!(loss, params(model), [(x, y)], ADAM(0.001))
        print("Completed $epochs epochs of training on segment $i data.\n")
    end

    return model end

function get_segs_types(segs::SegmentedImage, img::Matrix, model, segs_types=Dict(), img_slices=Dict())
    bs = get_segment_bounds(segs)
    model |> gpu

    for i in segment_labels(segs)
        img_slice = try img[bs[i]["t"]:bs[i]["b"], bs[i]["l"]:bs[i]["r"]] catch; continue end
        img_slice32 = Float32.(imresize(img_slice, (128,128)))
        img_slices[i] = img_slice32 end

    for (label, img_slice) in img_slices
        img_slice |> gpu
        w = width(img_slice)
        h = height(img_slice)
        pred = findmax(model(reshape(img_slice, (w,h,1,1))))
        segs_types[label] = detailed_space_types[pred[2]] end

    return segs_types end
