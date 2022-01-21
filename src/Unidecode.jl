module Unidecode

using Printf

cache = Dict()

function unidecode(str, errors="ignore", replace_str="?")
    result = []
    i = 1
    r = nothing
    while i <= lastindex(str)
        r = repl(str[i])
        if isnothing(r)
            if errors == "ignore"
                r = ""
            elseif errors == "strict"
                throw(ErrorException("no replacement found for character $(str[i]) in position $i"))
            elseif errors == "replace"
                r = replace_str
            elseif errors == "preserve"
                r = str[i]
            else
                throw(ArgumentError("invalid value for errors parameter $errors"))
            end
        end
        
        push!(result, r)
        if i == lastindex(str)
            break
        end
        i = nextind(str, i)
    end

    return join(result)
end

function make_data()
    mkpath(joinpath(@__DIR__, "../data"))
    unidecode_py = joinpath(@__DIR__, "../unidecode/unidecode")
    files = readdir(unidecode_py)
    for f in files
        if startswith(f, "x")
            contents = read(joinpath(unidecode_py, f), String)
            contents = replace(contents, "'\"'" => "\"\\\"\"")
            contents = replace(contents, "'\\''" => "\"'\"")
            contents = replace(contents, r"'(.*?)'" => s"\"\1\"")
            contents = replace(contents, "None" => "nothing")
            open("data/$f", "w") do fout
                println(fout, contents)
            end
        end
    end
end

function load_data(section)
    num = @sprintf("%03x", section)
    path = joinpath(@__DIR__, "../data/x$num.py")
    if isfile(path)
        include(path)
        return data
    else
        return nothing
    end
end

function repl(char)
    cp = codepoint(char)
    if cp < 0x80
        # already ASCII
        return char
    end

    if cp > 0xeffff
        # No data on characters in Private Use Area and above.
        return nothing
    end

    section = cp >> 8   # Chop off the last two hex digits
    position = cp % 256 # Last two hex digits

    table = nothing
    if section ∉ keys(cache)
        cache[section] = load_data(section)
    end
    table = cache[section]

    if !isnothing(table) && length(table) > position
        return table[position + 1]
    else
        return nothing
    end
end

export unidecode

end # module
