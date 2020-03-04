using PackageCompiler


# PackageCompiler.restore_default_sysimage()

compiled_symbols = [
    :BSON, :Random, :Images, :ImageSegmentation, :Gadfly, :Interact, :Blink,
    :ImageMagick, :CuArrays, :Dates, :CSV, :FreeTypeAbstraction, :DataFrames,
    :Flux, :Zygote, :CuArrays, :Metalhead, :Pkg]

compile_list = []


@async for pkg in compile_list
    print("Compiling package: $pkg\n")
    PackageCompiler.create_sysimage(
        :BSON; precompile_statements_file="./precompiler/precompile_trace.jl",
        replace_default=true)
end


PackageCompiler.create_sysimage(
    :Pkg; precompile_statements_file="./precompiler/precompile_trace.jl",
    replace_default=true)
