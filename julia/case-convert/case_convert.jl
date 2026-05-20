#!/usr/bin/env julia

if isempty(ARGS) || ARGS[1] == "-h" || ARGS[1] == "--help"
    println("Usage: case_convert [--upper|--lower|--title|--swap] <string>")
    println("  --upper  UPPERCASE")
    println("  --lower  lowercase")
    println("  --title  Title Case")
    println("  --swap   sWAP cASE (default)")
    exit(isempty(ARGS) ? 1 : 0)
end

mode = "--swap"
text_args = String[]

for arg in ARGS
    if startswith(arg, "--")
        mode = arg
    else
        push!(text_args, arg)
    end
end

text = join(text_args, " ")
if isempty(text)
    text = read(stdin, String) |> strip |> String
end

result = if mode == "--upper"
    uppercase(text)
elseif mode == "--lower"
    lowercase(text)
elseif mode == "--title"
    titlecase(text)
else
    map(c -> isuppercase(c) ? lowercase(c) : islowercase(c) ? uppercase(c) : c, text) |> String
end

println(result)
