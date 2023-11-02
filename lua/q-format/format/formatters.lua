-- formatters
-- some are in CPS --- what to do on success and failure
-- most will move cursor

local M = {}

local formatters = require 'q-format.formatters'

local lines = function (buf)
  return vim.api.nvim_buf_get_lines(buf, 0, -1, false)
end

local contents = function (buf)
  return table.concat(lines(buf), '\n')
end

local set_lines = function (buf, lines_)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines_)
end

local show_formatter = function (formatter)
  if formatter == formatters.CUSTOM then
    return 'custom'
  elseif formatter == formatters.EQUALPRG then
    return 'equalprg'
  elseif formatter == formatters.FORMATPRG then
    return 'formatprg'
  elseif formatter == formatters.FORMATEXPR then
    return 'formatexpr'
  end
end

local normal = function (keys)
  return function ()
    vim.api.nvim_cmd(
       { cmd = 'normal'
       , args = { keys }
       , bang = true
       , mods = { silent = true }
       }, {})
  end
end

-- normal! gq for the whole buffer
-- NOTE: cursor will be moved to top of buffer DURING formatting
-- NOTE: hence do expect transient cut screen when using external formatters
-- NOTE: use M.format_external for better experience
local gq = function (buf)
  local cmd = normal 'gggqG'
  vim.api.nvim_buf_call(buf, cmd)
end

-- format the whole buffer using external formatter
-- formatter should be in style of formatprg
-- NOTE: cursor will be moved to top of buffer after formatting
local format_external = function (buf_, formatter_)
  local cmd = function ()
    vim.cmd('%!' .. formatter_)
  end
  vim.api.nvim_buf_call(buf_, cmd)
end

-- normal! = for the whole buffer
-- NOTE: cursor will be moved to top of buffer after formatting
local eq = function (buf_)
  local cmd = normal 'gg=G'
  vim.api.nvim_buf_call(buf_, cmd)
end

-------------------------------------------------------------------------------------

local equalprg = function (_, buf, on_success, _)
  eq(buf)
  on_success(buf)
end

local formatexpr = function (_, buf, on_success, _)
  assert(vim.api.nvim_buf_get_option(buf, 'formatexpr') ~= '', 'no formatexpr set')
  gq(buf)
  on_success(buf)
end

local format_with_formatter = function (_, buf, on_success, on_failure, formatter)
  local backup_lines = lines(buf)

  format_external(buf, formatter)
  if vim.v.shell_error ~= 0 then
    -- what's currently on the buffer will be the error msg
    -- thank you, builtin formatter
    local msg = contents(buf)
    set_lines(buf, backup_lines)
    on_failure(buf, msg)
  else
    on_success(buf)
  end
end

local formatprg = function (user, buf, on_success, on_failure)
  local fp = vim.api.nvim_buf_get_option(buf, 'formatprg')
  assert(fp ~= '', 'no formatprg set')
  format_with_formatter(user, buf, on_success, on_failure, fp)
end

local custom = function (user, buf, on_success, on_failure)
  local ft = vim.bo[buf].filetype
  local custom_fp = assert(user.custom[ft], 'custom formatter not found for ' .. ft)
  format_with_formatter(user, buf, on_success, on_failure, custom_fp)
end

-- a special formatter that does... nothing
local as_is = function (_, buf, on_success, _)
  on_success(buf)
end

local select_formatter = function (user, buf)
  local notify = require('q-format.logger').notify

  local ft = vim.bo[buf].filetype
  local preferences = user.preferences[ft] or user.preferences['*']

  notify('[q-format] formatter preferences for ' .. ft .. ': ' .. vim.inspect(vim.tbl_map(show_formatter, preferences)))

  if vim.tbl_isempty(preferences) then
    notify('[q-format] no formatter preference set for ' .. ft .. ', no format')
    return as_is
  end

  for _, formatter in ipairs(preferences) do
    if formatter == formatters.CUSTOM and user.custom[ft] then
      notify('[q-format] using custom formatter for ' .. ft)
      return custom
    elseif formatter == formatters.EQUALPRG then
      notify('[q-format] using equalprg for ' .. ft)
      return equalprg
    elseif formatter == formatters.FORMATPRG and vim.bo[buf].formatprg ~= '' then
      notify('[q-format] using formatprg for ' .. ft)
      return formatprg
    elseif formatter == formatters.FORMATEXPR and vim.bo[buf].formatexpr ~= '' then
      notify('[q-format] using formatexpr for ' .. ft)
      return formatexpr
    end
  end

  notify('[q-format] none of the formatters found for ' .. ft)
  return as_is
end

-- format the buffer with according to user preferences, cps
M.format = function (user, buf)
  local notify = require('q-format.logger').notify
  local formatter = select_formatter(user, buf)
  local on_success = function (buf_)
    notify '[q-format] format success'
    user.on_success(buf_)
  end
  local on_failure = function (buf_, msg)
    user.notify_failure(msg)
    user.on_failure(buf_)
  end
  formatter(user, buf, on_success, on_failure)
end

return M
