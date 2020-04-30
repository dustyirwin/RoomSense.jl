using PackageCompiler

# julia --trace-compile=space_cadet_trace.jl
# PackageCompiler.restore_default_sysimage()

pkg_symbols = unique!([
    :BSON, :Random, :Images, :ImageSegmentation, :Dates, :Metalhead,
    :FreeTypeAbstraction, :DataFrames, :Pkg, :AssetRegistry, :Interact,
    :ImageTransformations, :Logging, :WebIO, :JSExpr, :InteractBulma,
    :Plots, :PlotlyJS, :ImageIO, :Flux, :InfoZIP, :ZipFile, :CSV, :Mux,
    :JSON,
    ])

compile_pkgs = []  # added pkgs / funcs


@async for pkg in compile_pkgs
    print("\nCompiling package: $pkg\n\n")
    PackageCompiler.create_sysimage(
        pkg;
        precompile_statements_file="./precompiler/space_cadet_trace.jl",
        sysimage_path = "./pkg_bins",
        replace_default=false,
    ) end
