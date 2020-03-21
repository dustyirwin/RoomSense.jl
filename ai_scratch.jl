@load "/home/dusty/Documents/tmp/chelan hospital/1st Flr/1st_Flr_cleaned_2020-03-02.BSON" s_exp
using BSON: @load
using Flux
@load "./models/SqueezeNet_50g.bson" m


using Flux
using Metalhead

vgg19 = Metalhead.VGG19()
s[wi]["segs"]
s[wi]


pic = load("/home/dusty/Pictures/Boston-Terrier-jpg.jpg")
Metalhead.classify(vgg19, pic)

s[4]["dds"][75][]
sn = SqueezeNet()
SN_50g = Chain(Conv((3,3), 1=>64), sn.layers[2:end-5]..., Conv((1, 1), 512=>50), sn.layers[end-3:end]...)

@save "./models/SN_50g.bson" SN_50g





X, y = Float32.(vcat(rand(128,128,3,10))), Float32.(vcat(rand(50,1,10)))
yhat = predict(mach, rows = train)

segs = s_exp["segs"]
img = s_exp["user_img"];
segs_types = s_exp["dds"]

length(segment_labels(segs))
segs.segment_labels

bs = get_segment_bounds(segs)

length(segs_types)

k = collect(keys(segs_types))[1]
segs_types[k]

for i in 1:height(img)
    for j in 1:width(img)
        if segs.image_indexmap[i,j] !== k
            img[i,j] = 0
        end end end

img_slice = img[bs[k]["t"]:bs[k]["b"], bs[k]["l"]:bs[k]["r"]]
delta = abs(width(img_slice) - height(img_slice))
img_slice = if width(img_slice) > height(img_slice)
                vcat(img_slice, zeros(delta, width(img_slice)))
            elseif width(img_slice) < height(img_slice)
                hcat(img_slice, zeros(height(img_slice), delta)) end

w = width(img_slice)
h = height(img_slice)

img_slice = Float32.(imresize(img_slice, (128,128)))

img_slice = reshape(img_slice, (128,128,1,1))


pred_vec = sn_50g(img_slice)
pred = findmax(pred_vec)
pred_space_type = detailed_space_types[pred[2]]

inds = Int64.(collect(keys(segs_types)))

X = reshape(vcat(dataz[1][1][:,:,:,1:5]...), (128,128,1,5))
Y = reshape(vcat(dataz[1][2][:,:,1:5]...), (50,1,5))
X
Y = Float32.(Y)
X=Float32[]

X |> cpu
Y |> cpu
sn_50g |> cpu
epochs = 1
k

@time sn_50g = update_model(sn_50g, X, Y, [1], epochs)

@save "./models/SqueezeNet_50g_3-1-20.bson" sn_50g

dataz

m = update_model(sn_50g, dataz, 1)
se = export_session_data(w, s)


@save "./models/space_type_classifier_1080.BSON" m

export_session_data(w, s)

n_labels = length(s[wi]["segs"].segment_labels)


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
