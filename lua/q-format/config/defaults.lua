local typecheck = function (config)
  vim.validate
  { config = { config, 'table' }
  , custom = { config.custom, 'table' }
  , preferences = { config.preferences, 'table' }
  , ['preferences.*'] = { config.preferences['*'], 'table' }
  , verbose = { config.verbose, 'boolean' }
  , on_success = { config.on_success, 'function' }  -- accepts: buffer handle
  , on_failure = { config.on_failure, 'function' }  -- accepts: buffer handle
  , after = { config.after, 'function' }  -- accepts: buffer handle
  , notify_failure = { config.notify_failure, 'function' }  -- accepts: error message string
  , when_no_format = { config.when_no_format, 'function' }  -- accepts: window handle
  }
end

local e = require 'q-format.formatters'

local defaults =
{ custom = {}  -- custom formatters as filetype-formatter pairs, in the format that you would pass to formatprg
, preferences = { ['*'] = { e.CUSTOM, e.FORMATEXPR, e.FORMATPRG } }  -- preferences of formatters for each filetype
, verbose = false
, on_success = function (_) end  -- additional actions to take after a successful format, e.g. write buffer
, on_failure = function (_) end  -- additional actions to take after a failed format
, after = function (_) end  -- additional actions to take after a format, regardless of success or failure
, notify_failure = function (msg) vim.notify('[q-format] format error:\n' .. msg, vim.log.levels.ERROR) end  -- how to announce a format failure; to suppress, set to a function that does nothing
, when_no_format = function (win) vim.api.nvim_win_call(win, function () vim.cmd 'write' end) end  -- what to do when the window is determined to not need formatting?
}

assert(pcall(typecheck, defaults))

return { defaults = defaults, typecheck = typecheck }
