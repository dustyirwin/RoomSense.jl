using PackageCompiler


# julia --trace-compile=space_cadet_trace.jl
# PackageCompiler.restore_default_sysimage()

compiled_symbols = [
    :BSON, :Random, :Images, :ImageSegmentation, :Gadfly, :ImageMagick,
    :CuArrays, :Dates, :CSV, :FreeTypeAbstraction, :DataFrames, :Flux,
    :Metalhead, :Pkg, :AssetRegistry, :Interact, :Mux, :ColorTypes,
    :ImageTransformations, :Logging, :WebIO, :JSExpr, :Distances,
    :InteractBulma, :JSON,
]

compile_list = []


for pkg in compiled_symbols
    print("\nCompiling package: $pkg\n")
    PackageCompiler.create_sysimage(
        pkg; precompile_statements_file="./precompiler/space_cadet_trace.jl",
        replace_default=true)
end


PackageCompiler.create_sysimage(
    :Metalhead; precompile_statements_file="./precompiler/space_cadet_trace.jl",
    replace_default=true)
