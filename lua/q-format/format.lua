local M = {}

local a = require('q-format.actions')

local shell_error = function ()
  return vim.v.shell_error ~= 0
end

-- vim's builtin gq has some drawbacks:
-- - upon reformatting errors, the error message will be regarded as the result
-- - cursor position will be changed and you will immediately lose the focus
-- - buffer is modified
--
-- here's an improved version that handle things more properly:
-- the buffer content will be first backup to a temporary buffer
-- reformatting will be done on the original buffer
-- if there's any error, the temporary buffer contents will be restored
-- and the error will be notified to the user
--
-- through the format, cursor position will be not changed
-- buffer will be :update'd if there's no error
-- the screen will also be zz'd to make sure you don't lose the focus
M.format = function (_user, win)
  local buf = vim.api.nvim_win_get_buf(win)

  a.with_cursor_in_place(win, function ()
    a.with_tempbuf(function (tempbuf)
      a.bufcopy(buf, tempbuf)
      a.gq(buf)
      if shell_error() then
        local errmsg = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), '\n')
        a.bufcopy(tempbuf, buf)
        vim.notify('[q-format] format error:\n' .. errmsg, vim.log.levels.ERROR)
      else
        a.update(buf)
      end
    end)
  end)

  a.zz(buf)
end

return M
