local M = {}

-- determine if a window is supposed to be formatted
M.should_format = function (win)
  local buf = vim.api.nvim_win_get_buf(win)
  local buftype = vim.bo[buf].buftype
  return buftype == ''
end

return M
