#!/usr/bin/env lua

-- JSON key extractor CLI tool.
-- Usage: lua json_key.lua <file.json> [key]
--        lua json_key.lua -  (read from stdin)

local function parse_simple_json(str)
    local result = {}
    str = str:match("^%s*{(.*)}%s*$")
    if not str then return nil, "not a JSON object" end

    for pair in str:gmatch("([^,]+)") do
        local key, val = pair:match('^%s*"([^"]+)"%s*:%s*(.+)%s*$')
        if key and val then
            val = val:match('^"(.*)"$') or tonumber(val) or val
            result[key] = val
        end
    end
    return result
end

local function main()
    if #arg < 1 or arg[1] == "-h" or arg[1] == "--help" then
        print("Usage: lua json_key.lua <file.json|-> [key]")
        print("  If key is given, prints its value.")
        print("  Otherwise prints all keys, one per line.")
        return
    end

    local source = arg[1]
    local lookup = arg[2]
    local input

    if source == "-" then
        input = io.read("*a")
    else
        local f = io.open(source, "r")
        if not f then
            io.stderr:write("Error: cannot open '" .. source .. "'\n")
            os.exit(1)
        end
        input = f:read("*a")
        f:close()
    end

    local data, err = parse_simple_json(input)
    if not data then
        io.stderr:write("Error: " .. (err or "parse failed") .. "\n")
        os.exit(1)
    end

    if lookup then
        if data[lookup] == nil then
            io.stderr:write("Key not found: " .. lookup .. "\n")
            os.exit(1)
        end
        print(data[lookup])
    else
        local keys = {}
        for k in pairs(data) do keys[#keys + 1] = k end
        table.sort(keys)
        for _, k in ipairs(keys) do print(k) end
    end
end

main()
