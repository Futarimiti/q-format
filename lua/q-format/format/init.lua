local M = {}

local a = require 'q-format.actions'
local f = require 'q-format.format.formatters'

-- through the format, cursor position will not be changed
-- buffer will be :update'd if there's no error
-- the screen will also be zz'd to make sure you don't lose the focus
M.format = function (user, win)
  local buf = vim.api.nvim_win_get_buf(win)
  local notify = function (...) if user.verbose then vim.notify(...) end end
  local on_success = function ()
    notify('[q-format] format success')
    a.update(buf)
    notify('[q-format] wrote buffer')
  end
  local on_failure = function (msg)
    vim.notify('[q-format] format error:\n' .. msg, vim.log.levels.ERROR)
  end
  local after = function () end

  a.with_cursor_in_place(win, function ()
    f.corres_format(user, buf, on_success, on_failure, after)
  end)

  a.zz(buf)
  notify '[q-format] zz'
end

return M
