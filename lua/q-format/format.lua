-- formatting a file given formatters and filetype.
-- will throw an error if no corresponding formatter found,
-- or the formatter process throws an error.
-- return the formatted result.
---@param formatters formatters
---@param buf buf-id
---@return string
return function (formatters, buf, opts)
    local content = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), '\n')
    local ft = vim.api.nvim_buf_get_option(buf, 'filetype')
    if ft == '' then
        if opts.silent then
            -- do nothing
            return content
        else
            error '[q-format] cannot determine filetype'
        end
    end

    ---@type formatter
    local formatter = (function ()
        local designated = formatters[ft]
        if designated ~= nil then
            return designated
        end

        local fp = vim.bo[buf].formatprg
        if opts.use_fp and fp ~= '' then
            return require('q-format.formatters').from_user(fp)
        elseif opts.silent then
            -- do nothing
            local as_is = function (cont) return cont end
            return as_is
        else
            error('[q-format] no formatter found for filetype: ' .. ft)
        end
    end)()

    local ok, result = pcall(formatter, content)

    if not ok then
        error('[q-format] formatter error, no format: ' .. result)
    end

    return result
end
