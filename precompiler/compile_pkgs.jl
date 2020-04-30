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


@async for pkg in pkg_symbols
    print("\nCompiling package: $pkg\n\n")
    PackageCompiler.create_sysimage(
        pkg;
        precompile_statements_file="./precompiler/space_cadet_trace.jl",
        sysimage_path = "./sys/$pkg.so",
        replace_default=false,
    ) end


@async for pkg in pkg_symbols
    print("\nCompiling package: $pkg\n\n")
    PackageCompiler.create_sysimage(
        pkg;
        precompile_statements_file="./precompiler/space_cadet_trace.jl",
        #sysimage_path="/sys/$pkg.so",
        replace_default=true,
    ) end
