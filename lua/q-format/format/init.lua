local M = {}

local f = require 'q-format.format.formatters'

local retaining_view = function (buf, f_)
  vim.api.nvim_buf_call(buf, function ()
    local tempname = vim.fn.tempname()
    vim.cmd('silent mkview! ' .. tempname)
    local successful, errmsg = pcall(f_)
    vim.cmd('source ' .. tempname)
    if not successful then
      error(errmsg)
    end
  end)
end

-- view will not be updated throughout formatting, successful or not
-- buffer will be :update'd only if without error
M.format = function (user, win)
  local buf = vim.api.nvim_win_get_buf(win)

  retaining_view(buf, function ()
    f.format(user, buf)
  end)

  user.after(buf)
end

return M
