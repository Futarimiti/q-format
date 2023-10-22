-- buffers actions

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

return M
