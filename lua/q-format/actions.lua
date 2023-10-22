-- buffer/window actions

local M = {}

M.zz = function (buf)
  local cmd = function ()
    vim.api.nvim_cmd({ cmd = 'normal', args = { 'zz' }, bang = true, mods = { silent = true } }, {})
  end
  vim.api.nvim_buf_call(buf, cmd)
end

M.update = function (buf)
  local s = function ()
      vim.api.nvim_cmd({ cmd = 'update', mods = { silent = true } }, {})
  end
  local successful, errmsg = pcall(vim.api.nvim_buf_call, buf, s)
  if not successful then
      error('[q-format] Cannot write buffer ' .. tostring(buf) .. ': ' .. errmsg)
  end
end

-- normal! gq for the whole buffer
-- NOTE: cursor position will be changed
M.gq = function (buf)
  local cmd = function ()
    vim.api.nvim_cmd({ cmd = 'normal', args = { 'zz' }, bang = true, mods = { silent = true } }, {})
  end
  vim.api.nvim_buf_call(buf, cmd)
end

-- place cursor
-- will be placed at the last row/col if out-of-bound
M.cursor = function (win, pos)
  local buf = vim.api.nvim_win_get_buf(win)
  local row, col = unpack(pos)
  local dest_row = math.min(row, vim.api.nvim_buf_line_count(win))
  local line = vim.api.nvim_buf_get_lines(buf, dest_row - 1, dest_row, false)[1] or ''
  local dest_col = math.min(col, #line)
  local cmd = function () vim.api.nvim_win_set_cursor(0, { dest_row, dest_col }) end
  vim.api.nvim_buf_call(win, cmd)
end

-- copy contents from one buffer to another
M.bufcopy = function (from_buf, to_buf)
  local contents = vim.api.nvim_buf_get_lines(from_buf, 0, -1, false)
  vim.api.nvim_buf_set_lines(to_buf, 0, -1, false, contents)
end

return M
