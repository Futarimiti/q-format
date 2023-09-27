-- export q_format() setup function

local zz = function (buf)
    local cmd = function () vim.api.nvim_cmd({ cmd = 'normal', args = { 'zz' }, bang = true, mods = { silent = true } }, {}) end
    vim.api.nvim_buf_call(buf, cmd)
end

local silent_write = function (buf_id)
    local s = function ()
        vim.api.nvim_cmd({cmd='update', mods={silent=true}}, {})
    end
    local successful, errmsg = pcall(vim.api.nvim_buf_call, buf_id, s)
    if not successful then
        error('[q-format] Cannot write buffer ' .. tostring(buf_id) .. ': ' .. errmsg)
    end
end


---@param win win-id
---@param formatters table<ft, formatter>
local q = function (formatters, win)
    local prev_pos = vim.api.nvim_win_get_cursor(win)
    local buf = vim.api.nvim_win_get_buf(win)
    local ft = vim.api.nvim_buf_get_option(buf, 'filetype')
    if ft == '' then
        error '[q-format] cannot determine filetype'
   end

    -- retrive content
    local content = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), '\n')

    -- do the formatting
    -- any error araised by formatting will stop here
    local format = require 'q-format.format'
    local formatted = format(formatters, ft, content)

    -- put it back
    local L = require 'q-format.lib'
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, L.lines(formatted))

    -- restore cursor
    vim.api.nvim_win_set_cursor(win, prev_pos)

    -- zz
    zz(buf)

    -- write
    silent_write(buf)
end

local M = {}

---@param m table
M.setup_q_format = function (m, formatters, win_supplier)
    m.q_format = function ()
        q(formatters, win_supplier())
    end
end

return M
