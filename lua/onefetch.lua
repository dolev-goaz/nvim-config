local M = {}

local function capture(cmd, raw)
    local f = assert(io.popen(cmd, "r"))
    local s = assert(f:read("*a"))
    f:close()
    if raw then
        return s
    end
    s = string.gsub(s, "^%s+", "")
    s = string.gsub(s, "%s+$", "")
    s = string.gsub(s, "[\n\r]+", " ")
    return s
end

local function split(source, sep)
    local result, i = {}, 1
    while true do
        local a, b = source:find(sep)
        if not a then
            break
        end
        local candidat = source:sub(1, a - 1)
        if candidat ~= "" then
            result[i] = candidat
        end
        i = i + 1
        source = source:sub(b + 1)
    end
    if source ~= "" then
        result[i] = source
    end
    return result
end

function M.is_available()
    return vim.fn.executable("onefetch") == 1
end

function M.get()
    if not M.is_available() then
        return nil
    end

    local header = split(
        capture(
            [[onefetch 2>/dev/null | sed 's/\x1B[@A-Z\\\]^_]\|\x1B\[[0-9:;<=>?]*[-!"#$%&'"'"'()*+,.\/]*[][\\@A-Z^_`a-z{|}~]//g']],
            true
        ),
        "\n"
    )

    return header
end

return M
