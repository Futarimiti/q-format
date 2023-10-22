local M = {}

local f = require('q-format.format')

M.setup_format = function (user)
  M.format = function ()
    local win = vim.api.nvim_get_current_win()
    f.format(user, win)
  end
end

return M
