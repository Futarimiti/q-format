local M = {}

local f = require 'q-format.format'
local c = require 'q-format.check'

M.setup_format = function (user)
  M.format = function ()
    local win = vim.api.nvim_get_current_win()
    if not c.should_format(win) then return end

    f.format(user, win)
  end
end

return M
