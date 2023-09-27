local M = {}

-- global formatters set
---@type formatters
local formatters = nil

M.setup = function (opts)
    -- init empty formatters if unset
    if formatters == nil then formatters = require('q-format.formatters').empty end

    -- setup formatters from user opts
    local user_formatters = require('q-format.opts').get_user_formatters(opts)
    local valid_formatters = require('q-format.formatters').from_users(user_formatters)
    formatters = vim.tbl_extend('keep', valid_formatters, formatters)

    -- setup q_format function
    local A = require 'q-format.actions'
    A.setup_q_format(M, formatters, vim.api.nvim_get_current_win)

    -- setup command
    vim.api.nvim_create_user_command('QFormat', M.q_format, { nargs = 0 })
end

return M
