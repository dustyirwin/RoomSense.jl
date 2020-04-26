using PackageCompiler

# julia --trace-compile=space_cadet_trace.jl
# PackageCompiler.restore_default_sysimage()

pkg_symbols = [
    :BSON, :Random, :Images, :ImageSegmentation, :Dates, :Metalhead,
    :FreeTypeAbstraction, :DataFrames, :Pkg, :AssetRegistry, :Interact, :Mux,
    :ImageTransformations, :Logging, :WebIO, :JSExpr, :InteractBulma,
    :Plots, :PlotlyJS, :ImageIO
    ]

compile_pkgs = [:Flux, :InfoZIP, :ZipFile, :CSV, :Interact]  # added pkgs / funcs

for pkg in pkg_symbols
    print("\nCompiling package: $pkg\n\n")
    PackageCompiler.create_sysimage(
        pkg; precompile_statements_file="./precompiler/space_cadet_trace.jl",
        replace_default=true)
end


PackageCompiler.create_sysimage(
    :Metalhead; precompile_statements_file="./precompiler/space_cadet_trace.jl",
    replace_default=true)
