local M = {}

local a = require 'q-format.actions'
local f = require 'q-format.format.formatters'

-- view will not be updated throughout formatting, successful or not
-- buffer will be :update'd only if without error
M.format = function (user, win)
  local buf = vim.api.nvim_win_get_buf(win)

  a.retaining_view(buf, function ()
    f.format(user, buf, user.on_success, user.on_failure)
  end)

  user.after(buf)
end

return M
