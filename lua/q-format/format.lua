-- formatting a file given formatters and filetype.
-- will throw an error if no corresponding formatter found,
-- or the formatter process throws an error.
-- return the formatted result.
---@param formatters formatters
---@param ft any
---@param content any
---@return string
return function (formatters, ft, content)
    local formatter = formatters[ft]
    if formatter == nil then
        error('[q-format] no formatter found for filetype: ' .. ft)
    end

    local ok, result = pcall(formatter, content)

    if not ok then
        error('[q-format] formatter error, no format: ' .. result)
    end

    return result
end
