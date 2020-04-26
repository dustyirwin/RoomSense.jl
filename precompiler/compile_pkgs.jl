using PackageCompiler

# julia --trace-compile=space_cadet_trace.jl
# PackageCompiler.restore_default_sysimage()

pkg_symbols = [
    :BSON, :Random, :Images, :ImageSegmentation, :Dates, :CSV, :Metalhead,
    :FreeTypeAbstraction, :DataFrames, :Pkg, :AssetRegistry, :Interact, :Mux,
    :ImageTransformations, :Logging, :WebIO, :JSExpr, :InteractBulma,
    :Plots, :PlotlyJS, :ImageIO
    ]

compile_pkgs = [:Flux]  # added Flux for gpu, NNlib

for pkg in pkg_symbols
    print("\nCompiling package: $pkg\n\n")
    PackageCompiler.create_sysimage(
        pkg; precompile_statements_file="./precompiler/space_cadet_trace.jl",
        replace_default=true)
end


PackageCompiler.create_sysimage(
    :Metalhead; precompile_statements_file="./precompiler/space_cadet_trace.jl",
    replace_default=true)
