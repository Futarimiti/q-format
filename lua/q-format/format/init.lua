local M = {}

local a = require 'q-format.actions'
local f = require 'q-format.format.formatters'

-- view will not be updated throughout formatting, successful or not
-- buffer will be :update'd only if without error
M.format = function (user, win)
  local notify = require('q-format.logger').notify
  local buf = vim.api.nvim_win_get_buf(win)
  local on_success = function (buf_)
    notify '[q-format] format success'
    a.update(buf_)
    notify '[q-format] wrote buffer'
  end
  local on_failure = function (_, msg)
    vim.notify('[q-format] format error:\n' .. msg, vim.log.levels.ERROR)
  end
  local after = function (_) end

  a.retaining_view(buf, function ()
    f.format(user, buf, on_success, on_failure)
  end)

  if user.centre then a.zz(buf) end

  after(buf)
end

return M
