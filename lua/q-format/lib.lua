local M = {}

M.lines = function (str)
    local result = {}
    for line in string.gmatch(str .. "\n", "(.-)\n") do
        table.insert(result, line)
    end
    return result
end

return M
