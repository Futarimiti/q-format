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

---@param on_failure fun(msg: string)
---@param on_success fun()
---@param after fun()
local formatprg = function (_, buf, on_success, on_failure, after)
  assert(vim.api.nvim_buf_get_option(buf, 'formatprg') ~= '', 'no formatprg set')

  local fex = vim.api.nvim_buf_get_option(buf, 'formatexpr')
  vim.api.nvim_buf_set_option(buf, 'formatexpr', '')

  local backup = a.lines(buf)

  a.gq(buf)
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

  vim.api.nvim_buf_set_option(buf, 'formatexpr', fex)
end

---@param on_failure fun(msg: string)
---@param on_success fun()
---@param after fun()
local custom = function (user, buf, on_success, on_failure, after)
  local ft = vim.api.nvim_buf_get_option(buf, 'filetype')
  local custom_fp = assert(user.custom[ft], 'custom formatter not found for ' .. ft)
  local fp = vim.api.nvim_buf_get_option(buf, 'formatprg')
  vim.api.nvim_buf_set_option(buf, 'formatprg', custom_fp)
  formatprg(user, buf, on_success, on_failure, after)
  vim.api.nvim_buf_set_option(buf, 'formatprg', fp)
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

    -- ({ [formatters.CUSTOM] = function () custom(user, buf, on_success, on_failure, after) end
    --  , [formatters.EQUALPRG] = function () equalprg(user, buf) end
    --  , [formatters.FORMATPRG] = function () formatprg(user, buf, on_success, on_failure, after) end
    --  , [formatters.FORMATEXPR] = function () formatexpr(user, buf) end
    --  })[f]()
-- read user config for formatter preference
-- then use the appropriate formatter
M.corres_format = function (user, buf, on_success, on_failure, after)
  local notify = function (...)
    if user.verbose then vim.notify(...) end
  end

  local ft = vim.api.nvim_buf_get_option(buf, 'filetype')
  local preferences = user.preferences[ft] or user.preferences['*']

  notify('[q-format] formatter preferences for ' .. ft .. ': ' .. vim.inspect(vim.tbl_map(show, preferences)))

  if vim.tbl_isempty(preferences) then
    notify('[q-format] no formatter preference set for ' .. ft .. ', using as-is')
    as_is(user)
  end

  for _, formatter in ipairs(preferences) do
    if formatter == formatters.CUSTOM and user.custom[ft] then
      notify('[q-format] using custom formatter for ' .. ft)
      custom(user, buf, on_success, on_failure, after)
      return
    elseif formatter == formatters.EQUALPRG then
      notify('[q-format] using equalprg for ' .. ft)
      equalprg(user, buf, on_success, on_failure, after)
      return
    elseif formatter == formatters.FORMATPRG and vim.filetype.get_option(ft, 'formatprg') ~= '' then
      notify('[q-format] using formatprg for ' .. ft)
      formatprg(user, buf, on_success, on_failure, after)
      return
    elseif formatter == formatters.FORMATEXPR and vim.filetype.get_option(ft, 'formatexpr') ~= '' then
      notify('[q-format] using formatexpr for ' .. ft)
      formatexpr(user, buf, on_success, on_failure, after)
      return
    end
  end

  notify('[q-format] none of the formatters found for ' .. ft)
  as_is(user, buf, on_success, on_failure, after)
end

return M
