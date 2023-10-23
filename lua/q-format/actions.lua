-- buffer/window actions

local M = {}

local normal = function (keys)
  return function ()
    vim.api.nvim_cmd({ cmd = 'normal', args = { keys }, bang = true, mods = { silent = true } }, {})
  end
end

M.zz = function (buf)
  local cmd = normal 'zz'
  vim.api.nvim_buf_call(buf, cmd)
end

M.update = function (buf)
  local cmd = normal 'update'
  local successful, errmsg = pcall(vim.api.nvim_buf_call, buf, cmd)
  if not successful then
    error('[q-format] Cannot write buffer ' .. tostring(buf) .. ': ' .. errmsg)
  end
end

-- normal! gq for the whole buffer
-- NOTE: cursor position will be changed
M.gq = function (buf)
  local cmd = normal 'gggqG'
  vim.api.nvim_buf_call(buf, cmd)
end

-- normal! = for the whole buffer
M.eq = function (buf)
  local cmd = normal 'gg=G'
  vim.api.nvim_buf_call(buf, cmd)
end

-- place cursor
-- will be placed at the last row/col if out-of-bound
M.cursor = function (win, pos)
  local buf = vim.api.nvim_win_get_buf(win)
  local row, col = unpack(pos)
  local dest_row = math.min(row, vim.api.nvim_buf_line_count(buf))
  local line = vim.api.nvim_buf_get_lines(buf, dest_row - 1, dest_row, false)[1] or ''
  local dest_col = math.min(col, #line)
  vim.api.nvim_win_set_cursor(0, { dest_row, dest_col })
end

M.get_cursor = function (win)
  return vim.api.nvim_win_get_cursor(win)
end

M.with_cursor_in_place = function (win, f)
  local pos = M.get_cursor(win)
  local successful, errmsg = pcall(f)
  M.cursor(win, pos)
  if not successful then error(errmsg) end
end

-- copy contents from one buffer to another
M.bufcopy = function (from_buf, to_buf)
  local contents = vim.api.nvim_buf_get_lines(from_buf, 0, -1, false)
  vim.api.nvim_buf_set_lines(to_buf, 0, -1, false, contents)
end

-- cps
M.with_tempbuf = function (f)
  local tempbuf = vim.api.nvim_create_buf(false, true)
  local successful, errmsg = pcall(f, tempbuf)

  if vim.api.nvim_buf_is_valid(tempbuf) then
    vim.api.nvim_buf_delete(tempbuf, { force = true })
  end

  -- rethrow error
  if not successful then error(errmsg) end
end

return M
