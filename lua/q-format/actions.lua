-- buffer/window actions

local M = {}

M.retaining_view = function (buf, f)
  vim.api.nvim_buf_call(buf, function ()
    local tempname = vim.fn.tempname()
    vim.cmd('silent mkview ' .. tempname)
    local successful, errmsg = pcall(f)
    vim.cmd('source ' .. tempname)
    if not successful then
      error(errmsg)
    end
  end)
end

local normal = function (keys)
  return function ()
    vim.api.nvim_cmd({ cmd = 'normal', args = { keys }, bang = true, mods = { silent = true } }, {})
  end
end

M.contents = function (buf)
  return table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), '\n')
end

M.lines = function (buf)
  return vim.api.nvim_buf_get_lines(buf, 0, -1, false)
end

M.set_lines = function (buf, lines)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
end

M.zz = function (buf)
  local cmd = normal 'zz'
  vim.api.nvim_buf_call(buf, cmd)
end

M.update = function (buf)
  local cmd = function ()
    vim.api.nvim_cmd({ cmd = 'write', mods = { silent = true } }, {})
  end
  local successful, errmsg = pcall(vim.api.nvim_buf_call, buf, cmd)
  if not successful then
    error('[q-format] Cannot write buffer ' .. tostring(buf) .. ': ' .. errmsg)
  end
end

-- normal! gq for the whole buffer
-- NOTE: cursor will be moved to top of buffer DURING formatting
-- NOTE: hence do expect transient cut screen when using external formatters
-- NOTE: use M.format_external for better experience
M.gq = function (buf)
  local cmd = normal 'gggqG'
  vim.api.nvim_buf_call(buf, cmd)
end

-- format the whole buffer using external formatter
-- formatter should be in style of formatprg
-- NOTE: cursor will be moved to top of buffer after formatting
M.format_external = function (buf, formatter)
  local cmd = function ()
    vim.cmd('%!' .. formatter)
  end
  vim.api.nvim_buf_call(buf, cmd)
end

-- normal! = for the whole buffer
-- NOTE: cursor will be moved to top of buffer after formatting
M.eq = function (buf)
  local cmd = normal 'gg=G'
  vim.api.nvim_buf_call(buf, cmd)
end

return M
