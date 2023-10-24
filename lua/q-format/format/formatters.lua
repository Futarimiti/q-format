-- formatters
-- some are in CPS --- what to do on success and failure
-- will move cursor

local M = {}

local a = require 'q-format.actions'
local formatters = require 'q-format.formatters'

local equalprg = function (_, buf, on_success, _, after)
  a.eq(buf)
  on_success()
  after()
end

local formatexpr = function (_, buf, on_success, _, after)
  assert(vim.api.nvim_buf_get_option(buf, 'formatexpr'), 'no formatexpr set')
  a.gq(buf)
  on_success()
  after()
end

local format_with_formatter = function (_, buf, on_success, on_failure, after, formatter)
  local backup = a.lines(buf)

  a.format(buf, formatter)
  if vim.v.shell_error ~= 0 then
    -- what's currently on the buffer will be the error msg
    -- thank you, builtin formatter
    local msg = a.contents(buf)
    a.set_lines(buf, backup)
    on_failure(msg)
  else
    on_success()
  end

  after()
end

---@param on_failure fun(msg: string)
---@param on_success fun()
---@param after fun()
local formatprg = function (user, buf, on_success, on_failure, after)
  local fp = vim.api.nvim_buf_get_option(buf, 'formatprg')
  assert(fp ~= '', 'no formatprg set')
  format_with_formatter(user, buf, on_success, on_failure, after, fp)
end

---@param on_failure fun(msg: string)
---@param on_success fun()
---@param after fun()
local custom = function (user, buf, on_success, on_failure, after)
  local ft = vim.api.nvim_buf_get_option(buf, 'filetype')
  local custom_fp = assert(user.custom[ft], 'custom formatter not found for ' .. ft)
  format_with_formatter(user, buf, on_success, on_failure, after, custom_fp)
end

-- a special formatter that does... nothing
local as_is = function (_, _, on_success, _, after)
  on_success()
  after()
end

local show = function (formatter)
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

local select_formatter = function (user, buf)
  local notify = function (...) if user.verbose then vim.notify(...) end end

  local ft = vim.api.nvim_buf_get_option(buf, 'filetype')
  local preferences = user.preferences[ft] or user.preferences['*']

  notify('[q-format] formatter preferences for ' .. ft .. ': ' .. vim.inspect(vim.tbl_map(show, preferences)))

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
    elseif formatter == formatters.FORMATPRG and vim.filetype.get_option(ft, 'formatprg') ~= '' then
      notify('[q-format] using formatprg for ' .. ft)
      return formatprg
    elseif formatter == formatters.FORMATEXPR and vim.filetype.get_option(ft, 'formatexpr') ~= '' then
      notify('[q-format] using formatexpr for ' .. ft)
      return formatexpr
    end
  end

  notify('[q-format] none of the formatters found for ' .. ft)
  return as_is
end

-- format the buffer with according to user preferences
M.format = function (user, buf, on_success, on_failure, after)
  local formatter = select_formatter(user, buf)
  formatter(user, buf, on_success, on_failure, after)
end

return M
