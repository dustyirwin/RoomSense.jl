using PackageCompiler

# julia --trace-compile=space_cadet_trace.jl
# PackageCompiler.restore_default_sysimage()

compiled_symbols = [
    :BSON, :Random, :Images, :ImageSegmentation, :PlotlyJS, :Dates, :CSV,
    :FreeTypeAbstraction, :DataFrames, :Metalhead, :Pkg, :AssetRegistry,
    :Interact, :Mux, :ImageTransformations, :Logging, :WebIO, :JSExpr,
    :InteractBulma,
    ]

compile_list = [:Mux]  # Mux loading in 0.231s


@async for pkg in compile_list
    print("\nCompiling package: $pkg\n\n")
    PackageCompiler.create_sysimage(
        pkg; precompile_statements_file="./precompiler/space_cadet_trace.jl",
        replace_default=true)
end


PackageCompiler.create_sysimage(
    :Metalhead; precompile_statements_file="./precompiler/space_cadet_trace.jl",
    replace_default=true)
