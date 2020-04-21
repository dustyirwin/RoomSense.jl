using PackageCompiler


# julia --trace-compile=space_cadet_trace.jl
# PackageCompiler.restore_default_sysimage()

compiled_symbols = [
    :BSON, :Random, :Images, :ImageSegmentation, :PlotlyJS, :ImageMagick,
    :CuArrays, :Dates, :CSV, :FreeTypeAbstraction, :DataFrames, :Flux,
    :Metalhead, :Pkg, :AssetRegistry, :Interact, :ColorTypes, :Mux,
    :ImageTransformations, :Logging, :WebIO, :JSExpr, :Distances,
    :InteractBulma,
    ]

compile_list = [:ImageSegmentation]


@async for pkg in compile_list
    print("\nCompiling package: $pkg\n\n")
    PackageCompiler.create_sysimage(
        pkg; precompile_statements_file="./precompiler/space_cadet_trace.jl",
        replace_default=true)
end


PackageCompiler.create_sysimage(
    :Metalhead; precompile_statements_file="./precompiler/space_cadet_trace.jl",
    replace_default=true)
